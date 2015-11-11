FROM openshift/base-centos7

MAINTAINER Michael Morello <michael.morello@gmail.com>

ENV GITLAB_VERSION=8.1.4 \
    GITLAB_SHELL_VERSION=2.6.5 \
    GITLAB_GIT_HTTP_SERVER_VERSION=0.3.0 \
    GITLAB_USER="git" \
    GITLAB_HOME="/home/git" \
    GITLAB_LOG_DIR="/data/log" \
    SETUP_DIR="/var/cache/gitlab" \
    RAILS_ENV=production

ADD root /
RUN rpm --import /etc/gitlab.gpg

EXPOSE 80 443

LABEL io.k8s.description="Gitlab" \
      io.k8s.display-name="Gitlab 8" \
      io.openshift.expose-services="80:http 443:https" \
      io.openshift.tags="gitlab" \
      io.openshift.s2i.destination="/opt/s2i/destination"


# Install Gitlab CE
RUN \
  yum -y install gitlab-ce supervisor  git-core  postgresql-client redis-tools

RUN mkdir -p /data/git-data/repositories \
 && mkdir -p /data/backups/gitlab \
 && mkdir -p /data/nginx \
 && mkdir -p /data/log/gitlab-git-http-server \
 && mkdir -p /data/log/gitlab-rails \
 && mkdir -p /data/log/gitlab-shell \
 && mkdir -p /data/log/nginx \
 && mkdir -p /data/gitlab-rails/uploads \
 && chmod -R a+rwx /data

# Define mountable directories.
VOLUME ["/data"]

# Get prefix path and path to scripts rather than hard-code them in scripts
ENV CONTAINER_SCRIPTS_PATH=/usr/share/container-scripts/gitlab


#USER 26

ENTRYPOINT ["container-entrypoint"]
CMD ["run-gitlab"]
