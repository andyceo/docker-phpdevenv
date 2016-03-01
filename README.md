1. Build image:

        sudo docker build -t andyceo/phpdevenv:1.2 .

2. Push image:

        sudo docker push andyceo/phpdevenv:1.2

3. Start container with port prefix 2500:

        PORT_PREFIX=2500 && sudo docker run \
            --detach \
            --name phpdevenv \
            --restart always \
            --hostname phpdevenv \
            -p `echo $PORT_PREFIX+80|bc`:80 \
            -p `echo $PORT_PREFIX+22|bc`:22 \
            andyceo/phpdevenv:1.2
