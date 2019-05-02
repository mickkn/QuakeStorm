cd..
ezquake.exe -windows -mem 128 -zone 512 -dinput -m_smooth -bpp 32 +set cl_confirmquit 0 -noforceparms -cheats +cfg_load storm +cheats -dev -particles 80000 -condebug +sv_cheats 1 +crosshair 1 +gamedir storm +sv_gamedir storm +map storm_test +exec server.cfg +exec binds.cfg

cd.. 
fteqw64.exe -windows +set cl_confirmquit 0 +gamedir storm +exec binds.cfg +connect localhost