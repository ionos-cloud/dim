PYTHON         ?= python3
VDIR           ?= virtual_env
ODIR           ?= out
VPIP           ?= ${VDIR}/bin/pip3
VPYTHON        ?= ${VDIR}/bin/python3
LDIR           ?= log
SRVLOG         ?= ${LDIR}/server.log
NDCLI_USERNAME ?= admin
NDCLI_SERVER   ?= http://localhost:5000
NDCLI_CONFIG   ?= /dev/null

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
	mysql -h127.0.0.1 -P3307 -updns -ppdns pdns1 < ./testenv/pdns.sql
	mysql -h127.0.0.1 -P3307 -updns -ppdns pdns2 < ./testenv/pdns.sql
	${VDIR}/bin/manage_db clear

test:
	-mkdir ${ODIR}
	-mkdir ${LDIR}
	${VDIR}/bin/manage_db clear

	PATH="${VDIR}/bin:${PATH}" \
	TEST_OUTPUT_DIR="${ODIR}" \
	SRVLOG="${SRVLOG}" \
	NDCLI_USERNAME="${NDCLI_USERNAME}" \
	NDCLI_CONFIG="${NDCLI_CONFIG}" \
	NDCLI_SERVER="${NDCLI_SERVER}" \
	${VPYTHON} runtest.py -d

.PHONY: db test install clean
