#!/bin/bash

FILE="/etc/pulse/default.pa"
if ! grep -q "Enable Echo/Noise-Cancellation" "$FILE"; then
    sudo cat << EOT >> "$FILE"
### Enable Echo/Noise-Cancellation
load-module module-echo-cancel use_master_format=1 aec_method=webrtc aec_args="analog_gain_control=0\ digital_gain_control=1 extended_filter=1 beamforming=1 mic_geometry=-0.0257,0,0,0.0257,0,0" source_name=echoCancel_source sink_name=echoCancel_sink
set-default-source echoCancel_source
set-default-sink echoCancel_sink
EOT
fi
