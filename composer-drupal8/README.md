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

