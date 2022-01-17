PYTHON        ?= python3
VDIR          ?= virtual_env
ODIR          ?= out
VPIP          ?= ${VDIR}/bin/pip3
VPYTHON       ?= ${VDIR}/bin/python3
LDIR          ?= log
SRVLOG        ?= ${LDIR}/server.log

all: install db test
	mkdir ${VDIR}
	mkdir ${OUTDIR}
	mkdir ${LDIR}

install:
	${PYTHON} -m venv ${VDIR}
	${VPIP} install -r ../dim/requirements.txt
	${VPIP} install ../dim
	${VPIP} install ../dimclient
	${VPIP} install -r ../ndcli/requirements.txt
	${VPIP} install ../ndcli

db:
	mysql -h127.0.0.1 -P3307 -uroot pdns1 < ./testenv/pdns.sql
	mysql -h127.0.0.1 -P3307 -uroot pdns2 < ./testenv/pdns.sql
	${VDIR}/bin/manage_db clear

test:
	-mkdir ${ODIR}
	${VDIR}/bin/manage_db clear
	PATH="${VDIR}/bin:${PATH}" SRVLOG="${SRVLOG}" TEST_OUTPUT_DIR="${ODIR}" ${VPYTHON} runtest.py -d

.PHONY: db test install clean
