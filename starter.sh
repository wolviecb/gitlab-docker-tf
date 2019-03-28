#!/usr/bin/env bash
#shellcheck disable=SC2154

set -euo pipefail

BASE_PATH="${base_path}"
TLS_CERT="${cert_path}"
TLS_KEY="${key_path}"

info() {
  echo "$(date) [ $(basename "$0")] $*"
}

sys_setup () {
  # Mounting attached disks
  info "Mounting "
  mount /dev/disk/by-id/google-"${disk_name}" $BASE_PATH

  # Redirect stdout and stderr to file.
  LOGFILE="$BASE_PATH/bootstrap.log"
  exec 1>$LOGFILE 2>&1

# Set SSH Host Keys
  info "Setting SSH Host Keys"
  cp -v $BASE_PATH/ssh/* /etc/ssh/ && info "OK"

  # Changing SSH port
  info "Changing SSH Port: "
  if sed -e '/^Protocol.*/a Port 2222' -i /etc/ssh/sshd_config; then
    systemctl restart sshd
    iptables -A INPUT -p tcp --dport 2222 -j ACCEPT
    info "OK"
  else
    info "FAILED"
  fi

  # Creating docker network
  info "Creating docker network: "
  if docker network create "${docker_network}" >/dev/null 2>&1; then
    info "OK"
  else
    info "FAILED"
  fi
}

# Running NGX docker container
ngx() {
  case $1 in
  start)
    if docker inspect -f "{{.State.Running}}" "${nginx_container}" >/dev/null 2>&1; then
      return 0
    else
      info "Starting NGINX container: "
      if docker run -d \
        -p 80:80 \
        -p 443:443 \
        --name "${nginx_container}" \
        --restart always \
        --network "${docker_network}" \
        -v $BASE_PATH/ngx/nginx.conf:/etc/nginx/nginx.conf:ro \
        -v $BASE_PATH/ngx/tunes.conf:/etc/nginx/tunes.conf:ro \
        -v $BASE_PATH/ngx/conf.d:/etc/nginx/conf.d:ro \
        -v $BASE_PATH/letsencrypt:/etc/letsencrypt:ro \
        -v $BASE_PATH/www:/var/www/certbot:ro \
      tandrade/ngx:latest; then
      info "OK"
      else
        info "FAILED"
      fi
    fi
    ;;
  stop)
    if docker inspect -f "{{.State.Running}}" "${nginx_container}" >/dev/null 2>&1; then
      docker rm -f "${nginx_container}"
    else
      return 0
    fi
    ;;
  esac
}

certbot() {
  info "Starting certbot container:"
  docker run -d \
    --rm \
    --name certbot \
    -v $BASE_PATH/letsencrypt:/etc/letsencrypt:rw \
    -v $BASE_PATH/www:/var/www/certbot:rw \
    --entrypoint /bin/sh \
    certbot/certbot -c 'trap exit TERM; while :; do certbot renew; sleep 12h & wait $${!}; done;'
}

short() {
  docker run -d \
  --name short \
  --network "${docker_network}" \
  --restart always \
  tandrade/short:latest \
  -addr 0.0.0.0:443 \
  -redis redis:6379 \
  -domain thebarrens.nu \
  -path short
}

redis(){
  docker run -d \
  --name redis \
  --network "${docker_network}" \
  -v $BASE_PATH/short/redis.conf:/etc/redis/redis.conf \
  redis redis-server /etc/redis/redis.conf
}

# Running gitlab docker container
gitlab() {
  case $1 in
  start)
    info "Starting gitlab container:"
    if docker inspect -f "{{.State.Running}}" "${gitlab_container}" >/dev/null 2>&1; then
      return 0
    else
      if docker run -d \
        --hostname git.thebarrens.nu \
        -e GITLAB_OMNIBUS_CONFIG="external_url 'https://git.thebarrens.nu/'; gitlab_rails['lfs_enabled'] = true;" \
        -p 22:22 \
        --name "${gitlab_container}" \
        --network "${docker_network}" \
        --restart always \
        -v $TLS_CERT:/etc/gitlab/ssl/git.thebarrens.nu.crt:ro \
        -v $TLS_KEY:/etc/gitlab/ssl/git.thebarrens.nu.key:ro \
        -v $BASE_PATH/srv/gitlab/config:/etc/gitlab \
        -v $BASE_PATH/srv/gitlab/logs:/var/log/gitlab \
        -v $BASE_PATH/srv/gitlab/data:/var/opt/gitlab \
        gitlab/gitlab-ce:latest; then
  #  --add-host="git.thebarrens.nu:172.17.0.1" \
  #  -p 127.0.0.1:10443:443 \
        info "OK"
      else
        info "FAILED"
      fi
    fi
    ;;
  stop)
    docker rm -f "${gitlab_container}"
    ;;
  esac
}

# Running gitlab-runners docker container
runners() {
  case $1 in
  start)
    info "Starting runner0:"
    if docker inspect -f "{{.State.Running}}" "${runner0_container}" >/dev/null 2>&1; then
      return 0
    else
      if docker run -d \
        --name "${runner0_container}" \
        --restart always \
        --network "${docker_network}" \
        -v $BASE_PATH/srv/gitlab-runner/config0:/etc/gitlab-runner \
        -v /var/run/docker.sock:/var/run/docker.sock \
        gitlab/gitlab-runner:latest; then
        info "OK"
      else
        info"FAILED"
      fi
    fi

    info "Starting runner1:"
    if docker inspect -f "{{.State.Running}}" "${runner1_container}" >/dev/null 2>&1; then
      return 0
    else
      if docker run -d \
        --name "${runner1_container}" \
        --restart always \
        --network "${docker_network}" \
        -v $BASE_PATH/srv/gitlab-runner/config1:/etc/gitlab-runner \
        -v /var/run/docker.sock:/var/run/docker.sock \
        gitlab/gitlab-runner:latest; then
        info "OK"
      else
        info"FAILED"
      fi
    fi

    info "Starting runner2:"
    if docker inspect -f "{{.State.Running}}" "${runner2_container}" >/dev/null 2>&1; then
      return 0
    else
      if docker run -d \
        --name "${runner2_container}" \
        --restart always \
        --network "${docker_network}" \
        -v $BASE_PATH/srv/gitlab-runner/config2:/etc/gitlab-runner \
        -v /var/run/docker.sock:/var/run/docker.sock \
        gitlab/gitlab-runner:alpine; then
        info "OK"
      else
        info"FAILED"
      fi
    fi
    ;;
  stop)
    docker rm -f "${runner0_container}" "${runner1_container}" "${runner2_container}"
    ;;
  esac
}

self_certs() {
  local config
  local csr
  config=$(mktemp)
  csr=$(mktemp)
  cat <<EOM >"$config"
[ req ]
distinguished_name="req_distinguished_name"
prompt="no"
[ req_distinguished_name ]
C="SE"
ST="Stockholm"
L="Stockholm"
O="GTH"
CN="${tls_name}"
EOM

  mkdir -p "$(dirname $TLS_KEY)"
  mkdir -p "$(dirname $TLS_CERT)"

  info "Creating Key and CSR:"
  openssl req -config "$config" -new -newkey rsa:2048 -nodes -keyout $TLS_KEY -out "$csr" && info "OK"

  info "Self signing CSR:"
  openssl x509 -req -days 365 -in "$csr" -signkey $TLS_KEY -out $TLS_CERT && info "OK"
}

sys_setup

if [[ -e $TLS_CERT ]] && [[ -e $TLS_KEY ]]; then
  ngx start
else
  self_certs
  ngx start
fi

gitlab start

runners start

certbot

redis

short

info "Done"