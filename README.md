1. Build image:

    sudo docker build -t andyceo/phpdevenv:1.0 .

2. Push image:



3. Start container:

    sudo docker run -d --name phpdevenv -p 2580:80 -p 2522:22 --restart always andyceo/phpdevenv:1.0

