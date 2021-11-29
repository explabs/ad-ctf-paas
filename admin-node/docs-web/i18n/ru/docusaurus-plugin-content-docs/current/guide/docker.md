---
sidebar_position: 6
---
# Docker и Docker Compose 

> Docker — это проект с открытым исходным кодом для автоматизации развертывания приложений в виде переносимых автономных контейнеров, выполняемых в облаке или локальной среде.

:::info
Полная информация о приложении Docker можно посмотреть [здесь](http://xgu.ru/wiki/Docker)
:::
## Установка для Linux
Чтобы установить Docker на Linux сначала нужно подготовить систему:
1. Удалить старую версии
```
sudo apt-get remove docker docker-engine docker.io containerd runc
```
2. Настроить репозиторий Docker перед первой установкой Docker Engine на новый хост-компьютер. 
```
sudo apt-get update
```
После этого вы можете установить и обновить Docker из репозитория.
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
### Чтобы взаимодействовать Docker, не используя sudo, выполните следующие шаги:

1. Добавьте в нее пользователя
```
sudo usermod -aG docker $USER
```

2. Выйдите из системы и войдите снова. Так вы сможете проверить состоите ли вы в группе.
```
newgrp docker 
```
### Убедитесь, что Docker Engine установлен правильно
```
docker run hello-world
```


## Docker Compose

> Docker Compose — инструмент, позволяющий запускать среды приложений с несколькими контейнерами

:::info
Полная информация о приложении Docker Compose можно посмотреть [здесь](https://dker.ru/docs/docker-compose/overview-of-docker-compose/)
:::

Чтобы установить Docker Compose необходимо выполнить следующие шаги:
1. Скачать текущуюю стабильную версию
```
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```
2. Сделать файл исполняемым 
```
sudo chmod +x /usr/local/bin/docker-compose
```
3. Проверить выполнение установки
```
docker-compose --version
```
###  В случае **ошибки** используйте строку  

```
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
```
