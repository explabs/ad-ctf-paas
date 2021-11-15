---
sidebar_position: 5
---
# Docker

> Docker — это проект с открытым исходным кодом для автоматизации развертывания приложений в виде переносимых автономных контейнеров, выполняемых в облаке или локальной среде.

## Установка для Linux
Чтобы установить Docker на Linux сначала нужно подготовить систему:
1. Удалить старую версии
```
sudo apt-get remove docker docker-engine docker.io containerd runc
```
2. Настроить репозиторий Docker перед первой установкой Docker Engine на новый хост-компьютер. После этого вы можете установить и обновить Docker из репозитория.
```
sudo apt-get update
```
 
```
sudo apt-get install \
   ca-certificates \
   curl \
   gnupg \
   lsb-release
```
3. Добавить официальный ключ GPG Docker
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

4. Настройте стабильный репозиторий
``` 
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```
5. Обновите пакет apt и установите последнюю версию Docker Engine и containerd
```
sudo apt-get update &&  sudo apt-get install docker-ce docker-ce-cli containerd.io
```
:::info
По умолчанию демон Docker можно использовать только root, другие пользователи могут получить к нему доступ только с помощью sudo. Если вы не хотите, чтобы команда docker начиналась с sudo, нужно создать группу с именем docker и добавь в нее пользователей. 
:::
* Чтобы взаимодействовать Docker, не используя sudo, выполните следующие шаги:
1. Создайте группу docker
```
sudo groupadd docker
```
2. Добавьте в нее пользователя
```
sudo usermod -aG docker $USER
```
4. Выйдите из системы и войдите снова. Так вы сможете проверить состоите ли вы в группе.
```
newgrp docker 
```
### Убедитесь, что Docker Engine установлен правильно
```
docker run hello-world
```


## Docker-compose
> Docker Compose — инструмент, позволяющий запускать среды приложений с несколькими контейнерами

1. sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
2. sudo chmod +x /usr/local/bin/docker-compose
3. docker-compose --version
4. Если вылает ошибка -> so ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

## Установка для Windows
Подсистема и клиент Docker не входят в состав Windows, потому их нужно устанавливать и настраивать отдельно. В ОС Windows эти конфигурации можно указать в файле конфигурации или с помощью диспетчера служб Windows.