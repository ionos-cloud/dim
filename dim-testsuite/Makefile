PYTHON        ?= python3
VDIR          ?= virtual_env
ODIR          ?= out
VPIP          ?= ${VDIR}/bin/pip3
VPYTHON       ?= ${VDIR}/bin/python3

all: install db run
	mkdir ${VDIR}
	mkdir ${OUTDIR}

install:
	${PYTHON} -m venv ${VDIR}
	${VPIP} install -r ../dim/requirements.txt
	${VPIP} install ../dim
	${VPIP} install ../dimclient
	${VPIP} install -r ../ndcli/requirements.txt
	${VPIP} install ../ndcli

db:
	mysql pdns1 < ./testenv/pdns.sql
	mysql pdns2 < ./testenv/pdns.sql
	${VDIR}/bin/manage_db clear

run:
	-mkdir ${ODIR}
	${VDIR}/bin/manage_db clear
	PATH="${VDIR}/bin:${PATH}" TEST_OUTPUT_DIR="${ODIR}" ${VPYTHON} runtest.py -d

.PHONY: db run install clean
