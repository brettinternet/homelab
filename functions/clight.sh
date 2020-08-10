#!/bin/bash


function toggle_calibrate {
    OFF=${1:=false}
    # Source: https://github.com/FedeDP/Clight/issues/50#issuecomment-491818912
    busctl --user set-property org.clight.clight /org/clight/clight/Conf org.clight.clight.Conf NoAutoCalib "b" $OFF
}

function clight_auto {
    toggle_calibrate false
}

function clight_off {
    toggle_calibrate true
}
