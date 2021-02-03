PYTHON        ?= python3
DIR           ?= virtual_env
VPIP          ?= ${DIR}/bin/pip3
VPYTHON       ?= ${DIR}/bin/python3

all: install run cleanup
	mkdir ${DIR}
	mkdir ${OUTDIR}

install:
	${PYTHON} -m venv ${DIR}
	${VPIP} install -r ../dim/requirements.txt
	${VPIP} install ../dim
	${VPIP} install ../dimclient
	${VPIP} install -r ../ndcli/requirements.txt
	${VPIP} install ../ndcli

run:
	${VPYTHON} runtest.py

.PHONY: install
