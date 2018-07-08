# ENU NGINX HTTPS reverse proxy
NGINX HTTPS configured as a reverse proxy using letsencrypt certificate. Tested
on Ubuntu 16.04 LTS.
## Prerequisites
* You'll need to have a valid domain for your host otherwise you won't be able to create a certificate. You can simply use a free subdomain from any dyndns services.
* Your nginx http service should be temporarily accessible otherwise certbot will fail it's configuration. There is an offline version available but it's not covered here.
## What it does
The script will install nginx, certbot and dependencies on Ubuntu OS. Tested on both Ubuntu 16.04 and 18.04 docker images.
