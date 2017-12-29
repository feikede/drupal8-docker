# drupal8-docker
A Dockerfile for Drupal based on drupal:8-apache with additional ssmtp and special php configuration.

The official Dupal Dockerfile can not send mail because there's no smtp in the image. This 
Dockerfile uses ssmtp to forward the mail to a host outside of the docker container (or where ever).

## Build image
Build the image like:
```
sudo docker build -t proxiss/drupal8:latest -t proxiss/drupal8:4.2.0 .
```

## Run the container
Run the container like
```
sudo docker run --name myContainer --link myDbServer:mysql -v ./modules:/var/www/html/modules -v ./themes:/var/www/html/themes -v ./files:/var/www/html/sites/default/files  --network myNetwork -p 8080:80  -d proxiss/drupal8:4.2.0
```
If you don't want to install additional modules or themes, you don't need to "bind-mount" the modules and themes. At the first start you should ```chmod 777 ./files```.

