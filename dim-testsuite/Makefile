PYTHON          ?= python3
VDIR            ?= virtual_env
ODIR            ?= out
VPIP            ?= ${VDIR}/bin/pip3
VPYTHON         ?= ${VDIR}/bin/python3
VPYTEST         ?= ${VDIR}/bin/pytest
PYTESTS         ?= .
LDIR            ?= log
SRVLOG          ?= ${LDIR}/server.log
NDCLI_USERNAME  ?= admin
NDCLI_SERVER    ?= http://localhost:5000
NDCLI_CONFIG    ?= /dev/null
VFLASK          ?= ${VDIR}/bin/flask
FLASK_APP       ?= 'dim:create_app(db_mode="TEST")'
PDNS1_DB_SERVER ?= 127.0.0.1
PDNS1_DB_PORT   ?= 3307
PDNS1_DB_NAME   ?= pdns1
PDNS1_DB_USER   ?= pdns1
PDNS1_DB_PW     ?= pdns
PDNS2_DB_SERVER ?= 127.0.0.1
PDNS2_DB_PORT   ?= 3307
PDNS2_DB_NAME   ?= pdns2
PDNS2_DB_USER   ?= pdns2
PDNS2_DB_PW     ?= pdns

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
	FLASK_APP=${FLASK_APP} ${VDIR}/bin/flask db clear

db: db-clear
	mysql -h${PDNS1_SERVER} -P${PDNS1_PORT} -u${PDNS1_USER} -p${PDNS1_PW} ${PDNS1_DB} < ./testenv/pdns.sql
	mysql -h${PDNS2_SERVER} -P${PDNS2_PORT} -u${PDNS2_USER} -p${PDNS2_PW} ${PDNS2_DB} < ./testenv/pdns.sql

test:
	-mkdir ${ODIR}
	-mkdir ${LDIR}

	PATH="${VDIR}/bin:${PATH}" \
		TEST_OUTPUT_DIR="${ODIR}" \
		SRVLOG="${SRVLOG}" \
		NDCLI_USERNAME="${NDCLI_USERNAME}" \
		NDCLI_CONFIG="${NDCLI_CONFIG}" \
		NDCLI_SERVER="${NDCLI_SERVER}" \
		VFLASK="${VFLASK}" \
		FLASK_APP=${FLASK_APP} \
		${VPYTHON} runtest.py -d ${TESTS}

pytest:
	${VPYTEST} -k ${PYTESTS}

.PHONY: db test install clean
