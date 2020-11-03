#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y asterisk=1:1.8.13.1~dfsg1-3+deb7u8
