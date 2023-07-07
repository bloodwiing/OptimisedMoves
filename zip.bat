@ECHO OFF


:: You can set these variables up to your own flavour, they're for basically folder/file names
SET OUTPUT=D:\SteamGames\steamapps\common\YourOnlyMoveIsHUSTLE\mods
SET OUTPUT_PREFIX=.1.1.0
SET ZIPTEMP=%TEMP%\.modziptemp


ECHO Preparing to create a mod ZIP file


:: The Mod name itself is based off of the folder name where the BAT file is
:: You may replace this with a "SET" statement, do whatever, but I have it automatic for ease
FOR %%A IN ("%CD%\.") DO @SET MODNAME=%%~nxA
ECHO Mod Name: %MODNAME%


:: Creates a temporary folder
MKDIR %ZIPTEMP%

:: Copies all files to the temporary folder
:: Supports also copying the .import folder separately for assets
ROBOCOPY "%CD%" "%ZIPTEMP%\%MODNAME%" /MIR /XD .import /XF *.bat
ROBOCOPY "%CD%\.import" "%ZIPTEMP%\.import" /MIR 2> NUL

:: Compresses using 7-Zip (Make sure that 7z.exe is available from your PATH)
7z a -tZip "%OUTPUT%\%MODNAME%%OUTPUT_PREFIX%.zip" "%ZIPTEMP%\*"

:: Deletes that temporary folder
RMDIR /S /Q %ZIPTEMP%


ECHO Finished!
PAUSE > NUL
