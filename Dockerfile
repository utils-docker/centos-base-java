FROM centos
MAINTAINER Fábio Luciano <fabio@naoimporta.com>
LABEL Description="CentOS Base for Java Environment"

ARG timezone
ENV timezone ${timezone:-"America/Sao_Paulo"}

ARG admin_username
ENV admin_username ${admin_username:-"admin"}

ARG admin_password
ENV admin_password ${admin_password:-"password"}

ARG jdk_url
ENV jdk_url ${jdk_url:-"http://download.oracle.com/otn-pub/java/jdk/8u144-b01/090f390dda5b47b9b721c7dfaa008135/jdk-8u144-linux-x64.tar.gz"}

ENV JAVA_HOME '/opt/jdk/'

#####################

WORKDIR /opt/

RUN yum -y update && yum install -y python-setuptools curl tzdata sudo tar wget \
  && easy_install supervisor \
  && echo ${timezone} > /etc/timezone \
  && printf "${admin_password}\n${admin_password}" | adduser ${admin_username} \
  && echo "${admin_username} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
  && echo -e "[supervisord]\nnodaemon=true\n\n[include]\nfiles = /etc/supervisor.d/*.ini" > /etc/supervisord.conf \
  && wget --no-cookies --quiet --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "${jdk_url}" \
  && tar -xzf $(basename $jdk_url) && mv $(tar tfz $(basename $jdk_url) --exclude '*/*') jdk \
  && alternatives --install /usr/bin/java java "/opt/jdk/bin/java" 20000 \
  && alternatives --install /usr/bin/keytool keytool "/opt/jdk/bin/keytool" 20000 \
  && rm $(basename $jdk_url) && yum clean all

ENTRYPOINT ["supervisord", "--nodaemon", "-c", "/etc/supervisord.conf", "-j", "/tmp/supervisord.pid", "-l", "/var/log/supervisord.log"]
