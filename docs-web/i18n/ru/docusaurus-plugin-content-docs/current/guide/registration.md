---
sidebar_position: 2
---

# Регистрация
Для успешной на платформе выполните следующие шаги:

1. Генерирование SSH-ключей 

```
ssh-keygen
```

2. Открытый ключ копируется в специальное поле при регистрации на сайте 

3. После прохождения регистрации необходимо скачать OpenVPN config

4. Запуск OpenVPN, используя скаченный config

#### для Linux:
```
sudo openvpn <path_to_filename>.ovpn 
```
#### Для Windows:

поместив скаченный файл в папку `C:\Program Files\OpenVPN\config`

6. Подключение по SSH

Mission complete!

7. Развертывание инфраструктуры Docker


