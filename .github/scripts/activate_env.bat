REM Configure environment variables
@call "C:\Program Files (x86)\Intel\oneAPI\setvars-vcvarsall.bat" %VS_VER%

for /f "tokens=* usebackq" %%f in (`dir /b "C:\Program Files (x86)\Intel\oneAPI\compiler\" ^| findstr /V latest ^| sort`) do @set "LATEST_VERSION=%%f"
@call "C:\Program Files (x86)\Intel\oneAPI\compiler\%LATEST_VERSION%\env\vars.bat"

REM Copy libiomp5md.dll to working directory
copy /Y "C:\Program Files (x86)\Intel\oneAPI\compiler\%LATEST_VERSION%\bin\libiomp5md.dll" .

@call "C:\Program Files (x86)\Intel\oneAPI\setvars.bat" intel64 vs2022

ifort.exe

ifort.exe -version

