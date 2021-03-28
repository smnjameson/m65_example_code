set DEPLOY="C:\C64\Tools\m65_connect\M65Connect Resources\m65.exe" -l COM6 -F -r 
set KICKASM=java -cp Z:\Projects\Mega65\_build_utils\kickass.jar kickass.KickAssembler65CE02  -vicesymbols -showmem 
%KICKASM%  main.s -odir ./bin 

"C:\Program Files\xemu\xmega65.exe" -besure -prg "./bin/main.prg"

rem %DEPLOY% "./bin/main.prg"