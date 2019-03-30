Gitlab on Docker
================

[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://git.thebarrens.nu/wolvie/gitlab-docker-tf/blob/master/LICENSE)

This is a simple TF module for deploying gitlab-ce in docker containers on an GCE instance. This module will start these containers:

* nginx forwarder (tandrade/ngx custom nginx image)
  * Documentation on this container can be found at [tandrade/ngx](https://hub.docker.com/r/tandrade/ngx)
* gitlab-ce (gitlab/gitlab-ce official image)
  * Documentation on gitlab on docker can be found [here](https://docs.gitlab.com/omnibus/docker/)
* 3 gitlab runners (2 gitlab-runner:latest, 1 gitlab-runner:alpine)
  * Documentation on gitlab-runners on docker can be found [here](https://docs.gitlab.com/runner/install/docker.html)
* certbot (certbot/cerbot official image)
  * Documentation on certbot image can be found [here](https://hub.docker.com/r/certbot/certbot/)
* redis and short (small project of a url shortener in GO)
  * Documentation on short can be found [here](https://github.com/wolviecb/short)

It asumes you have a bunch of stuff under ${base_path}:

* nginx configuration file on ${base_path}/ngx/nginx.conf
* letsencrypt configuration or certificates under ${base_path}/letsencrypt
* gitlab ominibus docker configuration files under ${base_path}/srv/{gitlab,gitlab-runner/config[0-2]}

If you are going to use this I recommend forking and cleaning up to your personal needs