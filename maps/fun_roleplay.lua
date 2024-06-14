RP_LUA = true
UTSFX_SILENCED = true
NPC_PROTECTION = false

parse("sv_gamemode 1")
parse("mp_buytime 0")
parse("mp_randomspawn 0")
parse("mp_radar 0")
parse("mp_hud 27")
parse("bot_add_t")
parse("bot_add_ct")
parse("bot_freeze 0")
--parse("sv_forcelight 1")
parse("mp_luamap 1")
parse("mp_deathdrop 0")
parse("mp_supply_items 51,21,39,1,10,34,67,30,32")
parse("mp_weaponfadeout 60")
timer(1000,"parse","mp_randomspawn 0")
--parse("trigger light")