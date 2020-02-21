FROM python:2-buster

RUN apt-get update && apt-get install -y default-libmysqlclient-dev python-dev libsasl2-dev libldap2-dev gcc rsyslog python-pip

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
