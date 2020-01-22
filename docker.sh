#!/bin/bash

rsyslogd

/dim/manage_db init
/dim/manage_dim runserver --host 0.0.0.0
