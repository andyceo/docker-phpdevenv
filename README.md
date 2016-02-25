1. Build image:

        sudo docker build -t andyceo/phpdevenv:1.0 .

2. Push image:

        sudo docker push andyceo/phpdevenv:1.0

3. Start container:

        sudo docker run -d --name phpdevenv -p 2580:80 -p 2522:22 --restart always andyceo/phpdevenv:1.0
