pulseaudio -D --exit-idle-time=-1
pactl load-module module-null-sink sink_name=MicOutput sink_properties=device.description="Virtual_Microphone_Output"
pacmd set-default-source MicOutput.monitor
pacmd load-module module-virtual-source source_name=VirtualMic

cd /opt/bin/
node /opt/bin/main.js /opt/media/audio.wav