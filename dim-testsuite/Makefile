PYTHON        ?= python3
VDIR          ?= virtual_env
ODIR          ?= out
VPIP          ?= ${VDIR}/bin/pip3
VPYTHON       ?= ${VDIR}/bin/python3
NDCLI_USERNAME ?= admin
NDCLI_SERVER   ?= http://localhost:5000

all: install db test
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

test:
	-mkdir ${ODIR}
	${VDIR}/bin/manage_db clear
	PATH="${VDIR}/bin:${PATH}" \
			 TEST_OUTPUT_DIR="${ODIR}" \
			 NDCLI_USERNAME="${NDCLI_USERNAME}" \
			 NDCLI_SERVER="${NDCLI_SERVER}" ${VPYTHON} runtest.py -d

.PHONY: db test install clean
