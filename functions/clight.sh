#!/bin/bash


function toggle_calibrate {
    OFF=${1:false}
    busctl --user set-property org.clight.clight /org/clight/clight/Conf org.clight.clight.Conf NoAutoCalib "b" "$OFF"
}

function clight_auto {
    toggle_calibrate false
}

function clight_off {
    toggle_calibrate true
}
