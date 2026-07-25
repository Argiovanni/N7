# Makefile pour compiler et exécuter le serveur RMI, l'annuaire, et les clients
USER = pbn1882
PROJECT = ~/Documents/ENSEEIHT/2A/hagimule/
DWNLD_FOLDER = downloaded
# Variables
JAVA = javac
RUN = java
SOURCES = src/**/*.java
# Répertoires des binaires
BIN = bin

CLIENTS = bobafett chewie dagobah ewok lando kenobi palpatine luke tao snorki scoubidou ladyoscar maya goldorak 
SERVER = ackbar
PORTS = 8081:8082:8083:8084
CURRENT ?= ackbar
STORAGE_DL ?= ../downloaded/
LATENCY ?= 10
PACKET_SIZE ?= 1024
# Cibles
.PHONY: all clean server client close deploy downloader

all:
	$(JAVA) -d $(BIN) $(SOURCES)  -sourcepath src $(SOURCES)

# Nettoyage
clean:
	rm -rf $(BIN)/Client/*
	rm -rf $(BIN)/Server/*
	rm -rf $(DWNLD_FOLDER)/*

close:
	pkill xterm

deploy:
	xterm -hold -T "Diary" -e 'ssh $(USER)@$(SERVER).enseeiht.fr -t "cd $(PROJECT); make; make server"' &
	sleep 3
	@for CLIENT in $(CLIENTS); \
	do \
		xterm -hold -T "$$CLIENT" -e "ssh $(USER)@$$CLIENT.enseeiht.fr -t 'cd $(PROJECT); make; make client CURRENT=$$CLIENT'" & \
		sleep 1; \
	done
client: 
	cd $(BIN) && $(RUN) Client.DaemonImpl $(CURRENT).enseeiht.fr $(PORTS) ../Storage/ $(SERVER).enseeiht.fr $(PACKET_SIZE) $(LATENCY)

server: 
	cd $(BIN) && $(RUN) Server.DiaryImpl

downloader:
	cd $(BIN) && $(RUN) Client.DownloaderImpl $(SERVER) $(STORAGE_DL)
