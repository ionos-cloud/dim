FROM python:2-buster

RUN apt-get update && apt-get install -y default-libmysqlclient-dev python-dev libsasl2-dev libldap2-dev gcc rsyslog python-pip
# fix for MySQL-python
# https://github.com/DefectDojo/django-DefectDojo/issues/407#issuecomment-415862064
RUN sed '/st_mysql_options options;/a unsigned int reconnect;' /usr/include/mysql/mysql.h -i.bkp
RUN sed -i 's/^[^#]*imk/#&/' /etc/rsyslog.conf
RUN echo 'input(type="imuxsock" HostName="localhost" Socket="/dev/log")' >> /etc/rsyslog.d/devlog.conf

# ndcli
COPY dimclient /dimclient/
COPY ndcli /ndcli/
RUN cd /dimclient && pip install .
RUN cd /ndcli && pip install -r requirements.txt && pip install .

COPY dim /dim/
RUN cd dim && pip install -r requirements.txt
RUN touch /etc/rsyslog.d/listen.conf

COPY .ndclirc .bashrc /root/
COPY docker.sh /

ENTRYPOINT ["/docker.sh"]
