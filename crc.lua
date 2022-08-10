local rom = gru.n64rom_load('rom/mp1RZ.z64')
rom:crc_update()
rom:save_file('rom/mp1RZ.z64')