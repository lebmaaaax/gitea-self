#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Установка Docker на vm's (Debian)..."

# Обновление системы
sudo apt update && sudo apt -y upgrade
sudo apt -y install ca-certificates curl gnupg git

# Добавление репозитория Docker
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Установка Docker
sudo apt update
sudo apt -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Проверка
sudo docker run --rm hello-world

echo " Docker is up"
echo "📝 Следующий шаг: cd vm1-gitea && cp .env.example .env && nano .env"
