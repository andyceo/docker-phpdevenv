1. Build image:

        sudo docker build --rm -t andyceo/phpdevenv:1.3 .

2. Push image:

        sudo docker push andyceo/phpdevenv:1.3

3. Start container with port prefix 2500:

        PORT_PREFIX=2500 && sudo docker run \
            --detach \
            --name phpdevenv \
            --restart always \
            --hostname phpdevenv \
            --net docknet
            -p `echo $PORT_PREFIX+80|bc`:80 \
            -p `echo $PORT_PREFIX+22|bc`:22 \
            andyceo/phpdevenv:1.3

4. If you want to run mysql in container and link your phpdevenv with it:

        sudo docker run -d --restart always --name mysql -v /data/mysql:/var/lib/mysql -e MYSQL_ROOT_PASSWORD="123qwe" mysql:5.5.48

    And add link to mysql container to command from 3: `--link mysql`.
