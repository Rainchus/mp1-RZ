require("lua/rom_info")

local arg = { ... }

local rom = gru.n64rom_load(arg[1])
local rom_info = roms[rom:crc32()]

-- We don't have an identiable rom here, stop patching
print(rom_info)
if rom_info == nil then
    error("invalid rom", 0)
    return 1
end

print("Building rz-" .. rom_info.rom_id)
local makeopts = os.getenv("MAKEOPTS") or ""
local configopts = os.getenv("CONFIGOPTS") or ""

local make_rz = "python3 configure.py " .. configopts ..  " && ninja " .. makeopts .. " " .. rom_info.rom_id
print(make_rz)
local _,_,res = os.execute(make_rz)
if res ~= 0 then
    error("could not build rz", 0)
end

local hooks = gru.gsc_load("build/patch/" .. rom_info.rom_id .. "/hooks.gsc")

print("Applying hooks")
hooks:shift(-rom_info.rom_to_ram)
hooks:apply_be(rom)

local old_ldr = rom:copy(rom_info.ldr_rom, 0x54)
local rz = gru.blob_load("build/bin/" .. rom_info.rom_id .. "/mp1-rz.bin")
local payload_rom = rom_info.payload_addr
local rz_rom = payload_rom + 0x60

print("Building Loader")

local make_ldr = string.format("ninja -t clean " .. rom_info.rom_id .. "_ldr && python3 configure.py " .. configopts .. " --cppflags='-DPAYLOAD=0x%06x -DDMA_COPY=0x%08x -DEND=0x%08x' --ldflags='-Wl,--defsym,start=0x%08x' && ninja " ..
                                makeopts .. " " .. rom_info.rom_id .. "_ldr", rom_info.payload_addr, rom_info.dma_func, rz:size() + rz_rom, rom_info.ldr_addr)

print(make_ldr)
local _,_,res = os.execute(make_ldr)
if(res ~= 0) then
    error("Could not build loader", 0)
end

local ldr = gru.blob_load("build/bin/" .. rom_info.rom_id .. "/ldr.bin")

print("Inserting payload")
rom:write(rom_info.ldr_rom, ldr)
rom:write(payload_rom, old_ldr)
local payload = gru.blob_load("build/bin/" .. rom_info.rom_id .. "/mp1-rz.bin")
rom:write(rz_rom, rz)
rom:crc_update()

return rom, rom_info.rom_id
