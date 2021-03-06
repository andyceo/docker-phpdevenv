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
            --net docknet \
            -p `echo $PORT_PREFIX+80|bc`:80 \
            -p `echo $PORT_PREFIX+22|bc`:22 \
            andyceo/phpdevenv:latest

4. If you want to run mysql in container and link your phpdevenv with it:

        sudo docker run -d --restart always --name mysql -v /data/mysql:/var/lib/mysql -e MYSQL_ROOT_PASSWORD="123qwe" mysql:5.5.48

    And add link to mysql container to command from 3: `--link mysql`.

## About (in russian) | Об образе

Если вы хотите смонтировать свою папку `/root`, то вам надо либо использовать именованные тома Docker (чтобы именованный том при первом запуске получил то содержимое, которое заложено в образе), либо вначале инициализировать контейнер без инициализации тома (будет создан неименованный том `/root`). Для этого сначала просто запустите контейнер:

    PORT_PREFIX=2500 && sudo docker run \
            --detach \
            --name developer-01 \
            --hostname developer-01 \
            --restart always \
            --net docknet \
            -p `echo $PORT_PREFIX+80|bc`:80 \
            -p `echo $PORT_PREFIX+22|bc`:22 \
            andyceo/phpdevenv:latest
            
Затем, скопируйте содержимое `/root` в папку на хост-машине:

    sudo docker cp developer-01:/root /data/developers/developer-01
    
Внимание! папка `/data/developers/developer-01` уже должна существовать, тогда `docker` скопирует папку `root` из контейнера в папку `/data/developers/developer-01/root`, как и должно быть.

Затем уничтожте существующий контейнер

    sudo docker rm -f developer-01

И создайте новый, с примонтированными с хост-системы папками:
 
    PORT_PREFIX=2500 && sudo docker run \
            --detach \
            --name developer-01 \
            --hostname developer-01 \
            --restart always \
            --net docknet \
            -p `echo $PORT_PREFIX+80|bc`:80 \
            -p `echo $PORT_PREFIX+22|bc`:22 \
            -v /data/developers/developer-01/root:/root:rw \
            andyceo/phpdevenv:latest

- Вы можете поднимать новые сервисы в вашей подсетке `docknet` и они автоматически будут вам видимы по адресу вроде `redis-master` (благодаря встроеному в докер внутреннему service discovery)
- Ваши данные в папке `/root` (домашняя директория пользователя `root`) может быть смонтирована на хост-систему, а это значит, что если ваш контейнер внезапно погибнет, ваши данные в этой папке сохранятся и перекочуют в новый контейнер. Это позволит обновлять разработческие контейнеры на новые версии
- У всех разработческих контейнеров папка /tmp может быть общей. Вы можете обмениваться с ее помощью файлами, пользуйтесь с умом, чтобы не навредить другим людям
- Также `/tmp` может быть смонтирован во временную файловую систему `tmpfs` на хосте, а это значит, что теперь она имеет быстродействие памяти и при перезагрузке хоста ее содержимое будет потеряно (раньше так не было)
- Вы можете сами рестартовать контейнеры: `kill 1` (если докер настроен перезапускать данный контейнер если он упадет)
- Чтобы воспользоваться своей конфигурацией нужных сервисов, используйте папку `/root/rootdirectories` для хранения папок с конфигами сервисов, например, папка `/etc/nginx` будет при запуске контейнера перемещена в `/etc/nginx-old`, а `/etc/nginx` будет символьной ссылкой на `/root/rootdirectories/etc-nginx`. Это произойдет при условии, что последняя папка существует и `/etc/nginx` еще не символьная ссылка
- Чтобы сохранять данные какой-либо базы данных в папке `/root/databases/some-database`, создайте соответствующий папку с конфигурацией для этой базы данных в `/root/rootdirectories`, саму папку `/root/databases/some-database` и перезапустите контейнер
- Про tor внутри контейнера: https://github.com/arulrajnet/torprivoxy
- sudo docker cp mongo:/data/configdb .
- @todo: настроить denyhosts: http://linuxru.org/tips/146
