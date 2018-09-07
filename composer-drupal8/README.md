# Drupal 8 build with composer and drush

Use docker build to build it. Runs out of the box with apache and php7.

## Quickstart with docker run
First start a db:
```bash
docker run --name db -e MYSQL_ROOT_PASSWORD=mypassword  -d mariadb
```

Then start Drupal 8 container with db link
```bash
docker run --link db:mysql --name drupal8 -p 8084:80 -d feikede/drupal8-docker
```

Enter "http://localhost:8084" in your browser and install drupal with database name = whatever, database host = mysql, password = mypassword, user = root.

Drupal gets installed with the contributed modules 

* Chaos Tools (ctools)
* Field Group (field_group)
* Entity Reference Revisions (entity_reference_revisions)
* Flag (flag)
* Pathauto (pathauto)
* Token (token)
* Paragraphs (paragraphs)
* Metatag (metatag)
* Webform (webform)

and the contributed theme

* Bootstrap

## Persistent Volumes
Usually you want to keep some of the installation's files beyond container removal. I propose to use three volumes:

* /var/www/html/web/themes/custom - custom themes you want to install
* /var/www/html/web/modules/custom - for custom modules you want to install (sure, you can install contributed modules here, too)
* /var/www/html/web/publicfs - Drupal puts the "public files" here, like uploaded images etc. (by drupal - default this is /sites/default/files)

Now, if you want to start the container with the publicfs directory mounted to your ./files path, use

```bash
docker run --link db:mysql --name drupal8 -p 8084:80 -v $PWD/files:/var/www/html/web/publicfs -d feikede/drupal8-docker
chmod 777 ./files
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

