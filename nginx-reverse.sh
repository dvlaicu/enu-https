#!/usr/bin/env bash
# This is a small script that installs and configures NGINX as a reverse proxy
# using letsencrypt free certificate autority.
# Prerequisites:
# - OS: Ubuntu based (tested on ubuntu 16.04/18.04 docker containers)
# - domain: you will need a valid domain name handled by a public DNS nameserver
# IF you don't have one you can simply use a free subdomain
# - access: The certbot will deploy a dummy file and it will test http access to
# that file. You need to temporary allow access to 80 port until the deployment
# is finished.
# Dragos Vlaicu - 07/08/2018 - ENU BP - dragosvlaicu
# Version: 1.0

# web url for your http ENU server.
url='http://localhost:8000'
# Your domain name
domain='domainname.hopto.org'
# a valid email address that can be used to recover the certificate if needed
email='validemailforrecovery@mail.com'

sudo apt-get update
sudo apt-get install sudo software-properties-common -y
# Add certbot repository to automate let's encrypt certification configuration
sudo add-apt-repository ppa:certbot/certbot -y
# Install nginx, python-certbot-nginx and dependencies
sudo apt-get install nginx python-certbot-nginx -y

# we need to create some dummy selfsigned certs in order to allow nginx to start using a valid SSL configuration
mkdir /tmp/dummycerts
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /tmp/dummycerts/privkey.pem \
-out /tmp/dummycerts/certificate.pem -subj "/C=RO/ST=Bucharest/L=Bucharest/O=dummy/OU=dummy/CN=dummy/emailAddress=dummy@mail.com"

# deploy ssl configuration
echo 'server {
    listen 443;
    server_name '${domain}';

    ssl on;
    ssl_certificate /tmp/dummycerts/certificate.pem;
    ssl_certificate_key /tmp/dummycerts/privkey.pem;
    ssl_session_cache shared:SSL:10m;

    location / {

        proxy_pass '${url}';
        proxy_set_header Host $host;

        # re-write redirects to http as to https
        proxy_redirect http:// https://;
    }

}' > /etc/nginx/sites-available/${domain}_SSL.conf

# enable ssl configuration in NGINX
ln -s /etc/nginx/sites-available/${domain}_SSL.conf /etc/nginx/sites-enabled/

# confgure certbot
sudo certbot --nginx -d ${domain} -m ${email} -n --agree-tos
# remove dummy certs
rm -fr /tmp/dummycerts
# enable NGINX to start at boot
sudo systemctl enable nginx
