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

ARG JAVA_HOME
ENV JAVA_HOME ${JAVA_HOME:-"/opt/jdk"}

ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

#####################

WORKDIR /opt/

RUN yum -y update && yum install -y python-setuptools curl tzdata sudo tar wget \
  && easy_install supervisor && echo ${timezone} > /etc/timezone \
  && printf "${admin_password}\n${admin_password}" | adduser ${admin_username} \
  && echo "${admin_username} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
  && echo -e "[supervisord]\nnodaemon=true\n\n[include]\nfiles = /etc/supervisor.d/*.ini" > /etc/supervisord.conf \
  && wget --no-cookies --quiet --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "${jdk_url}" \
  && tar -xzf $(basename $jdk_url) && mv $(tar tfz $(basename $jdk_url) --exclude '*/*') jdk \
  && alternatives --install /usr/bin/java java "/opt/jdk/bin/java" 20000 \
  && alternatives --install /usr/bin/keytool keytool "/opt/jdk/bin/keytool" 20000 \
  && rm $(basename $jdk_url) && rm -rf /tmp/* && yum clean all \
  && rm -rf $JAVA_HOME/lib/missioncontrol $JAVA_HOME/lib/visualvm $JAVA_HOME/lib/*javafx* \
    $JAVA_HOME/jre/lib/plugin.jar $JAVA_HOME/jre/lib/ext/jfxrt.jar $JAVA_HOME/jre/bin/javaws \
    $JAVA_HOME/jre/lib/javaws.jar $JAVA_HOME/jre/lib/desktop $JAVA_HOME/jre/plugin \    $JAVA_HOME/jre/lib/deploy* $JAVA_HOME/jre/lib/*javafx* $JAVA_HOME/jre/lib/*jfx* \
    $JAVA_HOME/jre/lib/amd64/libdecora_sse.so $JAVA_HOME/jre/lib/amd64/libprism_*.so \
    $JAVA_HOME/jre/lib/amd64/libfxplugins.so $JAVA_HOME/jre/lib/amd64/libglass.so \
    $JAVA_HOME/jre/lib/amd64/libgstreamer-lite.so $JAVA_HOME/jre/lib/amd64/libjavafx*.so

ENTRYPOINT ["supervisord", "--nodaemon", "-c", "/etc/supervisord.conf", "-j", "/tmp/supervisord.pid", "-l", "/var/log/supervisord.log"]
