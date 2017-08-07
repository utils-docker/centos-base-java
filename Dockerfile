FROM centos
MAINTAINER Fábio Luciano <fabio@naoimporta.com>
LABEL Description="CentOS Base for Java Environment"

ARG timezone
ENV timezone ${timezone:-"America/Sao_Paulo"}

ARG admin_username
ENV admin_username ${admin_username:-"admin"}

ARG admin_password
ENV admin_password ${admin_password:-"password"}

#####################

RUN yum -y update && yum install -y python-setuptools curl tzdata sudo tar \
  && easy_install supervisor \
  && echo ${timezone} > /etc/timezone \
  && printf "${admin_password}\n${admin_password}" | adduser ${admin_username} \
  && echo "${admin_username} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
  && echo -e "[supervisord]\nnodaemon=true\n\n[include]\nfiles = /etc/supervisor.d/*.ini" > /etc/supervisord.conf \
  && yum clean all

WORKDIR /opt/

ENTRYPOINT ["supervisord", "--nodaemon", "-c", "/etc/supervisord.conf", "-j", "/tmp/supervisord.pid", "-l", "/var/log/supervisord.log"]
