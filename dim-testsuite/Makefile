PYTHON         ?= python3
VDIR           ?= virtual_env
ODIR           ?= out
VPIP           ?= ${VDIR}/bin/pip3
VPYTHON        ?= ${VDIR}/bin/python3
VPYTEST        ?= ${VDIR}/bin/pytest
PYTESTS        ?= .
LDIR           ?= log
SRVLOG         ?= ${LDIR}/server.log
NDCLI_USERNAME ?= admin
NDCLI_SERVER   ?= http://localhost:5000
NDCLI_CONFIG   ?= /dev/null

all: install db test
	mkdir ${VDIR}
	mkdir ${OUTDIR}
	mkdir ${LDIR}

install-deps:
	${PYTHON} -m venv ${VDIR}
	${VPIP} install -r ../dim/requirements.txt
	${VPIP} install -r ../ndcli/requirements.txt

install-deps-local: install-deps
	${VPIP} install ../dim
	${VPIP} install ../dimclient
	${VPIP} install ../ndcli

install-deps-local-editable: install-deps
	${VPIP} install -e ../dim
	${VPIP} install -e ../dimclient
	${VPIP} install -e ../ndcli

install: install-deps-local

install-dev: install-deps-local-editable
	${VPIP} install -r ../dim/requirements-dev.txt
	${VPIP} install -r ../ndcli/requirements-dev.txt

db-clear:
	${VDIR}/bin/manage_db clear

db: db-clear
	mysql -h127.0.0.1 -P3307 -updns -ppdns pdns1 < ./testenv/pdns.sql
	mysql -h127.0.0.1 -P3307 -updns -ppdns pdns2 < ./testenv/pdns.sql

test:
	-mkdir ${ODIR}
	-mkdir ${LDIR}

	PATH="${VDIR}/bin:${PATH}" \
		TEST_OUTPUT_DIR="${ODIR}" \
		SRVLOG="${SRVLOG}" \
		NDCLI_USERNAME="${NDCLI_USERNAME}" \
		NDCLI_CONFIG="${NDCLI_CONFIG}" \
		NDCLI_SERVER="${NDCLI_SERVER}" \
		${VPYTHON} runtest.py -d ${TESTS}

pytest:
	${VPYTEST} -k ${PYTESTS}

.PHONY: db test install clean
