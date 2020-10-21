# Drupal 8 CI Runner
I am using this image for automated tests of my drupal 8 installs. It's used in gitlab's gitlab-ci.yml files as image for docker runners.

## Here's what I do for the phpunit test in my .gitlab-ci.yml

```yml
test_job:
  only:
    - dev
  stage: test
  script:
    - pwd
    - echo $CI_JOB_ID
    - echo $CI_PROJECT_NAME
    # setup testrun
    - cd /builds/mysecret
    - ls -al
    - export COMPOSER_ALLOW_SUPERUSER=1
    # tweak apache for drupal must-haves
    - sed -i 's:DocumentRoot /var/www/html:DocumentRoot /builds/mysecret/web:g' /etc/apache2/sites-enabled/000-default.conf
    - sed -i 's:/var/www/:/builds/mysecret/:g' /etc/apache2/apache2.conf
    - sed -i 's:AllowOverride None:AllowOverride All:g' /etc/apache2/apache2.conf
    # create drupal scaffoldings and lib stuff
    - composer install
    # cp phpunit test-setup to core
    - cp phpunit.citest.xml web/core/phpunit.xml
    - ps -eaf
    # add mod_rewrite for path_aliases
    - a2enmod rewrite
    # install test module and run it
    - /etc/init.d/apache2 start
    - ps -eaf
    - mkdir -p /builds/mysecret/web/sites/simpletest/browser_output
    - chown -R www-data /builds/mysecret/web/sites
    - sudo -u www-data -E vendor/bin/phpunit --configuration web/core web/modules/custom/testautomat/tests/src/Functional/FullTest.php
    - php -r 'echo "\nFantastico\n";'
    - ls -altr /builds/mysecret/web/sites/simpletest/browser_output
    # echo last test-output
    - cat `ls -1tr /builds/mysecret/web/sites/simpletest/browser_output/*html | tail -1`

```


Have fun.
