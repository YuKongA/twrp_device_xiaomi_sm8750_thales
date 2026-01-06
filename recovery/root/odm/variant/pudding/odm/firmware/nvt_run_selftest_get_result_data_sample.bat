@echo off

REM To run this batch file, please rename this filename extension from ".txt" to ".bat"

FOR /F "tokens=1-3 delims=/ " %%a IN ("%date%") DO (SET _MyDate=%%a%%b%%c)
FOR /F "tokens=1-4 delims=:." %%a IN ("%time%") DO (SET _MyTime=%%a%%b%%c)
SET _MyTime=%_MyTime: =0%
SET myDIR=Samples
IF not exist %myDIR% (mkdir %myDIR%)

echo ====== Run Selftesting ... ======
REM adb shell cat /proc/nvt_selftest > .\%myDIR%\Selftest_Result_Data_"%_MyDate%%_MyTime%".txt
adb shell "cat /proc/nvt_selftest > /data/local/tmp/Selftest_Result_Data.txt"
adb pull /data/local/tmp/Selftest_Result_Data.txt .\%myDIR%\Selftest_Result_Data_"%_MyDate%%_MyTime%".txt
echo ====== Run Selftest Done. ======
adb shell dmesg > .\%myDIR%\dmesg_"%_MyDate%%_MyTime%".txt

echo ====== Get selftest result data file in %myDIR% folder finished. ======
echo Press any key to exit...
pause