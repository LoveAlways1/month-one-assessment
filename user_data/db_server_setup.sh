#!/bin/bash
yum update -y
yum install -y postgresql-server

postgresql-setup initdb
systemctl start postgresql
systemctl enable postgresql