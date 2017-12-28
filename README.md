# drupal8-docker
A Dockerfile for Drupal based on drupal:8-apache with additional ssmtp and special php configuration.

The official Dupal Dockerfile can not send mail because there's no smtp in the image. This 
Dockerfile uses ssmtp to forward the mail to a host outside of the docker container (or where ever).

TODO: Write usage instructions

