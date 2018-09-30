# Run Drupal 8 in Docker in development mode without caching and xdebug enabled

Use my docker image from docker hub at https://hub.docker.com/r/feikede/drupal-dev/ - it should run out of the box.

Settings.local.php is installed and activated with cache-backend /dev/null. CSS and JS aggregation is disabled. XDebug port is 9000 (default).
Check this page for using xdebug with PHPStorm and docker: https://serversforhackers.com/c/getting-xdebug-working

## Quickstart Drupal 8, composer, drush with docker run
First start a db:
```bash
docker run --name db -e MYSQL_ROOT_PASSWORD=mypassword  -d mariadb
```

Then start Drupal 8 container with db link
```bash
docker run --link db:mysql --name drupal8 -p 8084:80 -d feikede/drupal-dev
```

Enter "http://localhost:8084" in your browser and install drupal with database name = whatever, database host = mysql, password = mypassword, user = root.

Drupal gets installed with the contributed modules

* Chaos Tools (ctools)
* Devel (devel)
* Field Group (field_group)
* Entity Reference Revisions (entity_reference_revisions)
* Flag (flag)
* Pathauto (pathauto)
* Token (token)
* Paragraphs (paragraphs)
* Metatag (metatag)
* Webform (webform)

and the contributed theme

* Bootstrap (bootstrap)

## Persistent Volumes
Usually you want to keep some of the installation's files beyond container removal. I propose to use three volumes:

* /var/www/html/web/themes/custom - custom themes you want to install
* /var/www/html/web/modules/custom - for custom modules you want to install (sure, you can install contributed modules here, too)
* /var/www/html/web/publicfs - Drupal puts the "public files" here, like uploaded images etc. (by drupal - default this is /sites/default/files)

Now, if you want to start the container with the publicfs directory mounted to your ./files path, use

```bash
docker run --link db:mysql --name drupal8 -p 8084:80 -v $PWD/files:/var/www/html/web/publicfs -d feikede/drupal-dev
chmod 777 ./files
```

## docker-compose
You docker-compose like so to get up drupal, mariad and phpmyadmin:

```yaml
version: '3'
services:
  db:
    image: "mariadb"
    restart: unless-stopped
    volumes:
      - ./db:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: mariadb
  app:
    image: "feikede/drupal-dev"
    restart: unless-stopped
    depends_on:
      - db
    links:
      - db
    volumes:
      - ./publicfs:/var/www/html/web/publicfs
      - ./custom_modules:/var/www/html/web/modules/custom
      - ./custom_themes:/var/www/html/web/themes/custom
    ports:
      - 8080:80    
    environment:
      DOCUMENT_ROOT: /var/www/html
      ENVIRONMENT: dev
  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    depends_on:
      - db
    environment:
      PMA_USER: root
      PMA_PASSWORD: mariadb
      PMA_HOST: db
    restart: unless-stopped
    links:
      - db
    ports:
      - 8082:80
```


## Run drush commands
You can use drush inside of the container, keep in mind that your changes to non-volume filesystems will be lost after removing the container.

```bash
rainer@tuxtop ~/src/asde8modules $ docker exec -it drupal8 bash
root@8b4cad8b87eb:/var/www/html# cd web
root@8b4cad8b87eb:/var/www/html/web# ../vendor/drush/drush/drush cr
 [success] Cache rebuild complete.
root@8b4cad8b87eb:/var/www/html/web#
```

## Run drupal console commands
You can use drupal console commands inside of the container. Keep in mind that your changes to non-volume filesystems will be lost after removing the container.

```bash
rainer@tuxtop ~/src/asde8modules $ docker exec -it drupal8 bash
root@8b4cad8b87eb:/var/www/html# cd web
root@8b4cad8b87eb:/var/www/html/web# ../vendor/drupal/console/bin/drupal cache:rebuild

 Rebuilding cache(s), wait a moment please.

 [OK] Done clearing cache(s).                                                                                           

root@8b4cad8b87eb:/var/www/html/web#
```

## Run composer commands in container
Also, you can run composer commands in the container, like so:

```bash
rainer@tuxtop ~/src/asde8modules $ docker exec -it drupal8 bash
root@8b4cad8b87eb:/var/www/html# composer require drupal/devel
Using version ^1.2 for drupal/devel
./composer.json has been updated
> DrupalProject\composer\ScriptHandler::checkComposerVersion
Loading composer repositories with package information
Updating dependencies (including require-dev)
Package operations: 1 install, 0 updates, 0 removals
  - Installing drupal/devel (1.2.0): Downloading (100%)         
Writing lock file
Generating autoload files
> DrupalProject\composer\ScriptHandler::createRequiredFiles
root@8b4cad8b87eb:/var/www/html#
```

Keep in mind, that these contributed modules will be installed at the non-mounted path at /modules/contributed. But that's fantastic for testing purposes and upgrade szenarios.
