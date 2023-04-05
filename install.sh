#!/bin/bash
wget https://raw.githubusercontent.com/NodeRunTeam/NodeGuide/main/logo.sh
chmod +x logo.sh && ./logo.sh
sudo apt-get update && sudo apt-get upgrade -y
sleep 3
sudo apt install nano
sleep 3
sudo apt install cmake
sleep 3
sudo apt install -y git clang curl libssl-dev llvm libudev-dev
sleep 3
curl https://sh.rustup.rs -sSf | sh
sleep 3
source ~/.cargo/env
sleep 3
rustup default stable
rustup update
rustup update nightly
rustup target add wasm32-unknown-unknown --toolchain nightly
sleep 3
wget https://builds.gear.rs/gear-nightly-linux-x86_64.tar.xz && \
tar xvf gear-nightly-linux-x86_64.tar.xz && \
rm gear-nightly-linux-x86_64.tar.xz && \
sleep 3
chmod +x gear-node
cd /etc/systemd/system
touch gear-node.service
sudo nano gear-node.service
sleep 3
