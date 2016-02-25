1. Build image:

        sudo docker build -t andyceo/phpdevenv:1.2 .

2. Push image:

        sudo docker push andyceo/phpdevenv:1.2

3. Start container:

        sudo docker run -d --name phpdevenv \
            --restart always \
            -p 2580:80 -p 2522:22 \
            --hostname phpdevenv
            andyceo/phpdevenv:1.2
