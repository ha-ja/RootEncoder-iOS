#!/usr/bin/env bash

/Applications/VLC.app/Contents/MacOS/VLC --network-caching=0 --clock-jitter=0 --clock-synchro=0 --no-audio --codec=h264 stream.sdp
