#!/bin/bash

pacman -Syu --noconfirm
pacman -S --noconfirm man texinfo bash-completion iproute2 nmap tcpdump vim tree base-devel git net-tools dnsutils
