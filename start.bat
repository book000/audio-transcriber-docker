@echo off
set /P AUDIO_FILE="Movie or Audio File Path: "
set "AUDIO_FILE=%AUDIO_FILE:"=%"
set /P DOCKER_NAME="DockerName(Default: audio-transcriber): "
set /P DISPLAY="DISPLAY(Default: localhost:0): "
IF "%DOCKER_NAME%"=="" set DOCKER_NAME=audio-transcriber
IF "%DISPLAY%"=="" set DISPLAY=localhost:0

echo.
echo AUDIO_FILE: %AUDIO_FILE%
echo DOCKER_NAME: %DOCKER_NAME%
echo DISPLAY: %DISPLAY%
echo.

pause
ffmpeg -y -i "%AUDIO_FILE%" -f wav "%~dp0audio.wav.tmp"
if errorlevel 1 (
    echo ERROR: ffmpeg failed to convert the input file. 1>&2
    if exist "%~dp0audio.wav.tmp" del "%~dp0audio.wav.tmp"
    pause
    exit /b 1
)
move /Y "%~dp0audio.wav.tmp" "%~dp0audio.wav"
if errorlevel 1 (
    echo ERROR: failed to replace audio.wav. 1>&2
    pause
    exit /b 1
)

if not exist "%~dp0user-dir" mkdir "%~dp0user-dir"
if not exist "%~dp0output" mkdir "%~dp0output"
docker build -t audio-transcriber "%~dp0."
if errorlevel 1 (
    echo ERROR: docker build failed. 1>&2
    pause
    exit /b 1
)
docker stop "%DOCKER_NAME%"
docker rm "%DOCKER_NAME%"
docker run -v "%~dp0output\:/opt/output/" -e DISPLAY="%DISPLAY%" --name "%DOCKER_NAME%" -it audio-transcriber
docker rm "%DOCKER_NAME%"
pause