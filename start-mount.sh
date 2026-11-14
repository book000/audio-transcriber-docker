#!/bin/bash
echo -n "Movie or Audio File Path: "
read AUDIO_FILE
echo -n "DockerName(Default: audio-transcriber): "
read DOCKER_NAME
echo -n "DISPLAY: "
read _DISPLAY
[ -z "$DOCKER_NAME" ] && DOCKER_NAME=audio-transcriber
[ -z "$_DISPLAY" ] && _DISPLAY=$DISPLAY

echo
echo AUDIO_FILE: $AUDIO_FILE
echo DOCKER_NAME: $DOCKER_NAME
echo DISPLAY: $_DISPLAY
echo

echo "Press Any Key to continue."
read
ffmpeg -y -i $AUDIO_FILE audio.wav

SCRIPT_DIR=$(cd "$(dirname "$0")" || exit; pwd)
mkdir -p $SCRIPT_DIR/user-dir
docker build -t audio-transcriber .
docker stop $DOCKER_NAME
docker rm $DOCKER_NAME
mkdir -p $SCRIPT_DIR/output
docker run -v "$SCRIPT_DIR/user-dir/:/opt/user-dir/" -v "$SCRIPT_DIR/output:/opt/output/" -e DISPLAY="$_DISPLAY" --name $DOCKER_NAME -it audio-transcriber
docker rm $DOCKER_NAME
echo "Press Any Key to continue."
read