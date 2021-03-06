#!/bin/bash
echo -n "Movie or Audio File Path: "
read AUDIO_FILE
echo -n "DockerName(Default: audio-transcriber): "
read AUDIO_FILE
echo -n "DISPLAY: "
read _DISPLAY
IF "%DOCKER_NAME%"=="" DOCKER_NAME=audio-transcriber
IF "%_DISPLAY%"=="" _DISPLAY=$DISPLAY

echo
echo AUDIO_FILE: $AUDIO_FILE
echo DOCKER_NAME: $DOCKER_NAME
echo DISPLAY: $DISPLAY
echo

echo "Press Any Key to continue."
read
ffmpeg -y -i $AUDIO_FILE audio.wav

docker build -t audio-transcriber .
docker stop $DOCKER_NAME
docker rm $DOCKER_NAME
SCRIPT_DIR=$(cd $(dirname $0); pwd)
mkdir -p $SCRIPT_DIR/user-dir
mkdir -p $SCRIPT_DIR/output
docker run -v "$SCRIPT_DIR/output/:/opt/output/" -e DISPLAY="$DISPLAY" --name $DOCKER_NAME -it audio-transcriber
docker rm $DOCKER_NAME
echo "Press Any Key to continue."
read