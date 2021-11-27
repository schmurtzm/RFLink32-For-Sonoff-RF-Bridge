:: RFLink32 FLashing script by Schmurtz

@echo off
cls

echo. & echo Please enter the number of the COM port (only the number, without "COM")
echo if you don't know just press enter
set /p com=

cls
if "%com%"=="" (
echo. & echo This will let ESPtool flash an ESP connected to your computer.
echo Do not use this if you have another ESP device connected (it could flash the wrong one !^) 
pause > NUL
)

if not "%com%"=="" set ComCmd=--port COM%com%


cls
echo. & echo Step 1/3 : Backuping Sonoff firmware on port COM%COM%
echo ==========================================
echo Please put your Sonoff RF Bridge in flash mode and then press a key to start the backup
pause > NUL
echo esptool.exe %ComCmd% --baud 460800 read_flash 0x00000 0x100000 Backup_SonoffRFBridge.bin
esptool.exe %ComCmd% --baud 460800 read_flash 0x00000 0x100000 Backup_SonoffRFBridge.bin


echo. & echo Step 2/3 :Erasing Sonoff firmware on port COM%COM%
echo ========================================
echo Please put your Sonoff RF Bridge in flash mode again and then press a key to start full erase 
pause > NUL
esptool.exe %ComCmd% --baud 460800 erase_flash


echo. & echo Step 3/3 :Flashing Sonoff firmware on port COM%COM%
echo =========================================
echo Please put your Sonoff RF Bridge in flash mode again and then press a key to start flashing
pause > NUL
esptool.exe %ComCmd% --baud 460800 write_flash -fs 1MB -fm dout 0x0 ..\firmwares\RFLink32-v5.1_Sonoff-RF-Bridge-Direct.bin

echo. & echo Please reboot your Sonoff RF Bridge and look for "RFLink-AP" wifi access point.
echo.
pause