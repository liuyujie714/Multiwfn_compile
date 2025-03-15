REM Install Fortran compiler with Visual Studio 2022

set URL=%1
set COMPONENTS=%2

curl.exe --output %TEMP%\webimage.exe --url %URL% --retry 5 --retry-delay 5
%TEMP%\webimage.exe --list-components
%TEMP%\webimage.exe -s -a --silent --eula accept --action install --components=%COMPONENTS% -p=NEED_VS2017_INTEGRATION=0 -p=NEED_VS2019_INTEGRATION=0 -p=NEED_VS2022_INTEGRATION=1 --log-dir=.

del %TEMP%\webimage.exe

set installer_exit_code=%ERRORLEVEL%
exit /b %installer_exit_code%
