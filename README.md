Gitlab on Docker
================

This is a simple TF module for deploying a gitlab-ce in one GCE instance on docker containers. This module will start this containers:

* nginx forwarder (tandrade/ngx custom nginx image)
* gitlab-ce (gitlab/gitlab-ce official image)
* 3 gitlab runners (2 gitlab-runner:latest, 1 gitlab-runner:alpine)
* certbot (certbot/cerbot official image)
* redis and short (small project of a url shortener in GO)

It asumes you have a bunch of stuff under ${base_path}:

* nginx configuration file on ${base_path}/ngx/nginx.conf
* letsencrypt configuration or certificates under ${base_path}/letsencrypt
* gitlab ominibus docker configuration files under ${base_path}/srv/{gitlab,gitlab-runner/config[0-2]}

If you are going to use this I recommend forking and cleaning up to your personal needs