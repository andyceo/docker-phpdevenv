## Image Badges

[![](https://images.microbadger.com/badges/image/andyceo/phpdevenv.svg)](http://microbadger.com/images/andyceo/phpdevenv "Get your own image badge on microbadger.com") [![](https://images.microbadger.com/badges/version/andyceo/phpdevenv.svg)](http://microbadger.com/images/andyceo/phpdevenv "Get your own version badge on microbadger.com")

## Usage

1. Build image:

        sudo docker build --rm -t andyceo/phpdevenv:latest .

2. Push image:

        sudo docker push andyceo/phpdevenv:latest

3. Start container with port prefix 2500:

        PORT_PREFIX=2500 && sudo docker run \
            --detach \
            --name phpdevenv \
            --restart always \
            --hostname phpdevenv \
            --net docknet
            -p `echo $PORT_PREFIX+80|bc`:80 \
            -p `echo $PORT_PREFIX+22|bc`:22 \
            andyceo/phpdevenv:latest

4. If you want to run mysql in container and link your phpdevenv with it:

        sudo docker run -d --restart always --name mysql -v /data/mysql:/var/lib/mysql -e MYSQL_ROOT_PASSWORD="123qwe" mysql:5.5.48

    And add link to mysql container to command from 3: `--link mysql`.

## About (in russian) | Об образе

- Вы можете поднимать новые сервисы в вашей подсетке `docknet` и они автоматически будут вам видимы по адресу вроде redis-master (благодаря встроеному в докер dns)
- Ваши данные в папках `/root` (хомяк рута) и `/var/www` могут быть смонтированы на хост-систему, а это значит, что если ваш контейнер внезапно погибнет, ваши данные в этих папках сохранятся и перекочуют в новый контейнер. Это позволит с меньшей болью обновлять разработческие контейнеры на новые версии
- У всех разработческих контейнеров папка /tmp может быть общей. Вы можете обмениваться с ее помощью файлами, пользуйтесь с умом, чтобы не навредить другим людям
- Также `/tmp` может быть смонтирован во временную файловую систему `tmpfs` на хосте, а это значит, что теперь она имеет быстродействие памяти и при перезагрузке хоста ее содержимое будет потеряно (раньше так не было)
- вы можете сами рестартовать контейнеры: `kill 1`
