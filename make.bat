rem DEPLOY deploys over serial port to Mega6y5 or Nexys boards
set DEPLOY="C:\C64\Tools\m65_connect\M65Connect Resources\m65.exe" -l COM6 -F -r 

rem C1541.exe from vice - used to create a D81 and add files
set WRITE="C:\C64\Tools\vice\bin\c1541.exe" -attach "./bin/DISK.D81" 8 -write
set FORMAT="C:\C64\Tools\vice\bin\c1541.exe" -format "turricandemo,0" d81 "./bin/DISK.D81"

set KICKASM=java -cp Z:\Projects\Mega65\_build_utils\kickass519.jar kickass.KickAssembler65CE02  -vicesymbols -showmem 
%KICKASM%  main.s -odir ./bin 

rem create and write disk
rem %FORMAT%
rem %WRITE% "./bin/main.prg" main
rem %WRITE% "./chars.bin" chars
rem %WRITE% "./pal.bin" pal
rem launch XEMU with disk image
rem "C:\Program Files\xemu\xmega65.exe" -besure -autoload -8 "./bin/DISK.D81"

rem launch XEMU with prg
"C:\Program Files\xemu\xmega65.exe" -besure -prg "./bin/main.prg"

%DEPLOY% "./bin/main.prg"