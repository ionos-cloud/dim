FROM centos:centos7
RUN rm /etc/yum.repos.d/*
# need solution to not have to use internal repos
COPY etc/yum.repos.d/* /etc/yum.repos.d/
RUN sed -e s/enabled=1/enabled=0/g -i /etc/yum/pluginconf.d/fastestmirror.conf
RUN yum update -y ; yum clean all

COPY etc/ /etc/
RUN yum install -y \
    pdns \
    pdns-backend-mysql \
    pdns-tools \
    ldns \
    rsyslog \
    git \
    sudo \
    man \
    bash-completion \
    tmux \
    vim \
    tcpdump \
    jdk \
    MariaDB-client \
    MariaDB-server \
    MariaDB-compat \
    ; yum clean all

COPY .ndclirc /root/.ndclirc
COPY *.sh pdns.sql /var/local/dim/
COPY runtest unittests /opt/dim/bin/
ENV PATH $PATH:/opt/dim/bin

COPY redhat/*\.el7\.*.rpm /root/
RUN yum localinstall -y /root/*.rpm ; rm /root/*.rpm ; yum clean all

ENTRYPOINT ["/var/local/dim/docker.sh"]
