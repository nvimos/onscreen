# MAKE = /a/cygwin64/bin/make.exe -- off: included from Makefile, it would set MAKE for all of it

DATA_DIR ?= C:/gitea
SERVICE_NAME ?= gitea
GITEA_EXE = $(DATA_DIR)/gitea.exe
CONFIG_FILE = $(DATA_DIR)/custom/conf/app.ini
DOWNLOAD_URL = https://dl.gitea.com/gitea/

.PHONY: download-browser download-cli install run start stop enable disable status uninstall

info:
	ls /c/
	ls /p/

# Opens default web browser to the download directory
download-browser:
	cmd.exe /c start "" "$(DOWNLOAD_URL)"

# Silently scrapes and downloads the latest windows-amd64 binary via PowerShell
download-cli:
	mkdir -p "$(DATA_DIR)"
	powershell.exe -Command "\
		$$link = (Invoke-WebRequest -Uri '$(DOWNLOAD_URL)' -UseBasicParsing).Links | Where-Href -like '*windows-amd64.exe' | Select-Object -First 1 -ExpandProperty href; \
		Invoke-WebRequest -Uri ('$(DOWNLOAD_URL)' + $$link) -OutFile '$(GITEA_EXE)'"

# Registers Gitea as a Windows service
install:
	mkdir -p "$(DATA_DIR)"
	sc.exe create $(SERVICE_NAME) start= auto binPath= "\"$(GITEA_EXE)\" web --config \"$(CONFIG_FILE)\""

# Runs Gitea in foreground (useful for initial wizard setup)
run:
	cd "$(DATA_DIR)" && ./gitea.exe web

# Service control targets
start:
	net.exe start $(SERVICE_NAME)

stop:
	net.exe stop $(SERVICE_NAME)

enable:
	sc.exe config $(SERVICE_NAME) start= auto

disable:
	sc.exe config $(SERVICE_NAME) start= disabled

status:
	sc.exe query $(SERVICE_NAME)

uninstall:
	net.exe stop $(SERVICE_NAME)
	sc.exe delete $(SERVICE_NAME)
