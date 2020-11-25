@echo off
set /P AUDIO_FILE="Movie or Audio File Path: "
set /P DOCKER_NAME="DockerName(Default: audio-transcriber): "
set /P DISPLAY="DISPLAY(Default: localhost:0): "
IF "%DOCKER_NAME%"=="" set DOCKER_NAME=audio-transcriber

echo.
echo AUDIO_FILE: %AUDIO_FILE%
echo DOCKER_NAME: %DOCKER_NAME%
echo DISPLAY: %DISPLAY%
echo.

pause
ffmpeg -y -i %AUDIO_FILE% audio.wav

docker build -t audio-transcriber .
docker stop %DOCKER_NAME%
docker rm %DOCKER_NAME%
mkdir %~dp0output
docker run -v "%~dp0output\:/opt/output/" -e DISPLAY="%DISPLAY%" --name %DOCKER_NAME% -it audio-transcriber
docker rm %DOCKER_NAME%
pause