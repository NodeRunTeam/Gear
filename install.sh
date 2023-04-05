#!/bin/bash
exists()
{
  command -v "$1" >/dev/null 2>&1
}

echo "---------------------------------------------------"
echo -e "\e[32mШаг 1: Инициализация скрипта \e[0m" && sleep 2

sudo apt install curl -y
curl -s https://raw.githubusercontent.com/NodeRunTeam/NodeGuide/main/logo.sh | bash


echo "---------------------------------------------------"
echo -e "\e[32mВыберите действие. Введите на нужную цифру и подтвердите действие клавишей Enter\e[0m" && sleep 3
echo -e ""
echo "1 Установить ноду с нуля (gear_stable_testnet_v7) - встроен снапшот"
echo "2 Обновиться на уже работающей ноде на gear_stable_testnet_v7"
echo "3 Выполнить перенос ключа c gear_stable_testnet_v6 на gear_staging_testnet_v7"
echo "4 Удалить ноду (ключ будет сохранен в корень $HOME)"

read doing

case $doing in 
  1) 
  echo "---------------------------------------------------"
  echo -e "\e[32mШаг 2: скачивание и установка ноды: \e[0m" && sleep 2

  sudo apt update && sudo apt upgrade -y
  sudo apt-get install htop nano net-tools git clang libssl-dev llvm libudev-dev make build-essential cmake curl -y
  sudo curl https://sh.rustup.rs -sSf | sh -s -- -y
  source $HOME/.cargo/env
  rustup default stable
  rustup update --force
  rustup update nightly --force
  rustup target add wasm32-unknown-unknown --toolchain nightly
  wget https://get.gear.rs/gear-nightly-linux-x86_64.tar.xz
  sudo tar -xvf gear-nightly-linux-x86_64.tar.xz -C /usr/bin
  rm gear-nightly-linux-x86_64.tar.xz
  # sudo chmod +x gear
  # git clone https://github.com/gear-tech/gear.git
  # cd gear

  # echo "---------------------------------------------------"
  # echo -e "\e[32mШаг 3: сборка ноды: \e[0m" && sleep 2

  # cargo build -p gear-cli --release
  # sleep 2
  read -p "Введите имя для своей ноды: " node
  sleep 2

  echo "---------------------------------------------------"
  echo -e "\e[32mШаг 3: создание сервисных файлов: \e[0m" && sleep 2

  echo "[Service]
  Type=simple
  User=root
  WorkingDirectory=/root/
  ExecStart=/usr/bin/gear \
  --name $node \
  --execution wasm \
  --log runtime \
  --telemetry-url 'ws://telemetry-backend-shard.gear-tech.io:32001/submit 0'
  Restart=on-failure
  RestartSec=3
  LimitNOFILE=10000
  [Install]
  WantedBy=multi-user.target" > $HOME/gear-node.service
  mv $HOME/gear-node.service /etc/systemd/system/


  echo "---------------------------------------------------"
  echo -e "\e[32mШаг 4: запуск ноды\e[0m" && sleep 3
  systemctl daemon-reload
  systemctl start gear-node && sleep 10

  # echo "---------------------------------------------------"
  # echo -e "\e[32mШаг 4.1: установка снапшота \e[0m" && sleep 2

  # systemctl stop gear-node

  #   function createdirectory () {
  #     mkdir $HOME/.local/share/gear/chains/gear_staging_testnet_v7/db/full/
  #   }

  #   if ! [ -d $HOME/.local/share/gear/chains/gear_staging_testnet_v7/db/full/ ]; then
  #     createdirectory
  #   fi

  # rm -rf .local/share/gear/chains/gear_staging_testnet_v7/db/full/*
  # wget -P $HOME/.local/share/gear/chains/gear_staging_testnet_v7/db/full/ https://nodes.wenmoney.io/snapshots/gear.tgz
  # cd $HOME/.local/share/gear/chains/gear_staging_testnet_v7/db/full/ && tar -xvzf gear.tgz && rm gear.tgz

  # systemctl restart gear-node && sleep 5

  echo "---------------------------------------------------"
  echo -e '\e[32mШаг 5: проверка статуса ноды\e[0m\n' && sleep 3

  if [[ `service gear-node status | grep active` =~ "running" ]]; then
    echo -e "Нода \e[32mустановлена корректно\e[39m!"
    echo -e "Проверить статус ноды можно командой: \e[32mservice gear-node status\e[0m"
    echo -e "Проверить логи ноды можно командой: \e[32mjournalctl -n 100 -f -u gear-node -o cat\e[0m"
    echo -e ""
  else
    echo -e "Ваша Gear нода \e[31mустановлена некорректно\e[39m, переустановите ее"
  fi

  rm $HOME/gear.sh

  echo "---------------------------------------------------"
  echo -e "Проверьте свою ноду в телеметрии: \e[32mhttps://telemetry.gear-tech.io/\e[39m"
  echo "---------------------------------------------------"
  ;;
  
  2)
  echo "---------------------------------------------------"
  echo -e "\e[32mШаг 2: остановка ноды \e[0m" && sleep 2
  sudo systemctl stop gear-node
  sudo cp .local/share/gear/chains/gear_staging_testnet_v6/network/secret_ed25519 $HOME/
  # сброс сети
  # ./gear-node purge-chain -y
  gear purge-chain -y
  # ./gear purge-chain -y
  # sudo cp .local/share/gear/chains/gear_stable_testnet/network/secret_ed25519 $HOME/
  # rm -rf .local/share/gear-node/chains/gear_staging_testnet_v4/db/full/



  echo "---------------------------------------------------"
  echo -e "\e[32mШаг 3: скачивание и установка новой версии \e[0m" && sleep 2

  wget https://get.gear.rs/gear-nightly-linux-x86_64.tar.xz
  sudo tar -xvf gear-nightly-linux-x86_64.tar.xz -C /usr/bin
  rm gear-nightly-linux-x86_64.tar.xz

  echo "---------------------------------------------------"
  echo -e "\e[32mШаг 4: запуск ноды \e[0m" && sleep 2

  sudo systemctl start gear-node

  echo "---------------------------------------------------"
  echo -e '\e[32mШаг 5: проверка статуса ноды\e[0m\n' && sleep 3

  if [[ `service gear-node status | grep active` =~ "running" ]]; then
    echo -e "Нода \e[32mустановлена корректно\e[39m!"
    echo -e "Проверить статус ноды можно командой: \e[32mservice gear-node status\e[0m"
    echo -e "Проверить логи ноды можно командой: \e[32mjournalctl -n 10 -f -u gear-node -o cat\e[0m"
    echo -e ""
  else
    echo -e "Ваша Gear нода \e[31mустановлена некорректно\e[39m, переустановите ее"
  fi
  sleep 3

  echo "---------------------------------------------------"
  echo -e "Что делаем дальше - чекните логи и посмотрите чтобы нода начала набирать высоту, после чего запустите скрипт и выберите пункт по переносу ключа"
  echo "---------------------------------------------------"
  echo -e ""

  ;;
  3)
    echo "---------------------------------------------------"
    echo -e "\e[32mОстановка ноды \e[0m" && sleep 2
    sudo systemctl stop gear-node

    echo "---------------------------------------------------"
    echo -e "\e[32mПеренос ключа \e[0m" && sleep 2
    # cp .local/share/gear/chains/gear_stable_testnet/network/secret_ed25519 $HOME
    mv $HOME/secret_ed25519 .local/share/gear/chains/gear_staging_testnet_v7/network/

    echo "---------------------------------------------------"
    echo -e "\e[32mЗапуск ноды \e[0m" && sleep 2

    sudo systemctl restart gear-node

    echo "---------------------------------------------------"
    echo -e '\e[32mПроверка статуса ноды\e[0m\n' && sleep 3

    if [[ `service gear-node status | grep active` =~ "running" ]]; then
      echo -e "Нода \e[32mустановлена корректно\e[39m!"
      echo -e "Проверить статус ноды можно командой: \e[32mservice gear-node status\e[0m"
      echo -e "Проверить логи ноды можно командой: \e[32mjournalctl -n 10 -f -u gear-node -o cat\e[0m"
      echo -e ""
    else
      echo -e "Ваша Gear нода \e[31mустановлена некорректно\e[39m, переустановите ее"
    fi

  ;;
  4)
    echo "---------------------------------------------------"
    echo -e "\e[32mОстановка ноды \e[0m" && sleep 2
    
    sudo systemctl stop gear-node
    sudo systemctl disable gear-node

    mv .local/share/gear/chains/gear_staging_testnet_v7/network/secret_ed25519 $HOME/

    echo "---------------------------------------------------"
    echo -e "\e[32mУдаление ноды \e[0m" && sleep 2

    sudo rm -rf /root/.local/share/gear-node
    sudo rm /etc/systemd/system/gear-node.service
    sudo rm /root/gear
    sudo rm /usr/bin/gear

  ;;
*)
echo "Введено неправильное действие. Скрипт завершен. Запустите скрипт по-новой и выберите корректное действие!"
esac
