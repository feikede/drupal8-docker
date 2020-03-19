# Drupal 8 Runtime Container
I am using this image to setup new Drupal sites very quick.
It contains an apache2 server at port 80 and a running mariadb 10.3 instance.

Check up your Drupal 8 installation with composer and mount that basedir at /webserver/webroot in the container, like so:

```bash
composer create-project drupal/recommended-project my_site_name_dir --no-interaction
docker run --name d8rtest1 -p 17564:80 -v $PWD/my_site_name_dir:/webserver/webroot -d feikede/d8r:latest
```

Connect to localhost:17564, use database=drupal, database-user=drupal, database-pwd=drupal for your fresh drupal installation. 

apache in the container runs as user drupal. There's also a sshd running and user drupal is allowd to connect. You map that out like -p 17563:22 or whatever port you like.

Also, theres a ssh keypair for drupal (need that for gitlab CI). Cat it out like 

```bash
docker exec -it d8rtest1 cat /home/drupal/.ssh/id_rsa.pub
```

Have fun.
