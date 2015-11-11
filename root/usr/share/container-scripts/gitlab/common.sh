#!/bin/bash

export GITLAB_CONFIG_FILE=/etc/gitlab/gitlab.rb

function generate_gitlab_config() {

# configure supervisord to start gitlab-git-http-server
cat > /etc/supervisor/conf.d/gitlab-git-http-server.conf <<EOF
[program:gitlab-git-http-server]
priority=20
directory=${GITLAB_INSTALL_DIR}
environment=HOME=${GITLAB_HOME}
command=/opt/gitlab/embedded/bin/gitlab-git-http-server
  -listenUmask 0
  -listenNetwork unix
  -listenAddr ${GITLAB_INSTALL_DIR}/tmp/sockets/gitlab-git-http-server.socket
  -authBackend http://127.0.0.1:8080
  {{GITLAB_REPOS_DIR}}
user=git
autostart=true
autorestart=true
stdout_logfile=/data/log/gitlab/gitlab-git-http-server/%(program_name)s.log
stderr_logfile=/data/log/gitlab/gitlab-git-http-server%(program_name)s.log
EOF

# configure supervisord to start nginx
cat > /etc/supervisor/conf.d/nginx.conf <<EOF
[program:nginx]
priority=20
directory=/tmp
command=/usr/sbin/nginx -g "daemon off;"
user=root
autostart=true
autorestart=true
stdout_logfile=/data/log/nginx/%(program_name)s.log
stderr_logfile=/data/log/nginx/%(program_name)s.log
EOF


envsubst \
     < "${CONTAINER_SCRIPTS_PATH}/gitlab.rb.template" \
     > "${GITLAB_CONFIG_FILE}"

/usr/bin/gitlab-ctl reconfigure
}
