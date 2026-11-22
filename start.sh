#!/bin/bash
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd) || exit 1

echo -n "Movie or Audio File Path: "
IFS= read -r AUDIO_FILE
echo -n "DockerName(Default: audio-transcriber): "
IFS= read -r DOCKER_NAME
echo -n "DISPLAY: "
IFS= read -r _DISPLAY
[ -z "$DOCKER_NAME" ] && DOCKER_NAME=audio-transcriber
[ -z "$_DISPLAY" ] && _DISPLAY=$DISPLAY

echo
echo "AUDIO_FILE: $AUDIO_FILE"
echo "DOCKER_NAME: $DOCKER_NAME"
echo "DISPLAY: $_DISPLAY"
echo

echo "Press Any Key to continue."
read -r

# Replace audio.wav only on success so a failed conversion never leaves a partial or stale file.
if ! ffmpeg -y -i "$AUDIO_FILE" -f wav "$SCRIPT_DIR/audio.wav.tmp"; then
    echo "ERROR: ffmpeg failed to convert: $AUDIO_FILE" >&2
    rm -f "$SCRIPT_DIR/audio.wav.tmp"
    exit 1
fi
mv -f "$SCRIPT_DIR/audio.wav.tmp" "$SCRIPT_DIR/audio.wav" || exit 1

mkdir -p "$SCRIPT_DIR/user-dir" "$SCRIPT_DIR/output" || exit 1
docker build -t audio-transcriber "$SCRIPT_DIR" || exit 1
docker stop "$DOCKER_NAME" || true
docker rm "$DOCKER_NAME" || true
docker run --user "$(id -u):$(id -g)" -v "$SCRIPT_DIR/output/:/opt/output/" -e DISPLAY="$_DISPLAY" --name "$DOCKER_NAME" -it audio-transcriber
STATUS=$?
docker rm "$DOCKER_NAME" || true
echo "Press Any Key to continue."
read -r
exit "$STATUS"
