#!/usr/bin/env bash

ffplay -protocol_whitelist file,rtp,udp stream.sdp
