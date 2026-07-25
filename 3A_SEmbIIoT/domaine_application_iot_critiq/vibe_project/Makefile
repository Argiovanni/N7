# Makefile pour le projet Android Find My Friend

# Variables
GRADLEW = ./gradlew
DEBUG_APK_PATH = app/build/outputs/apk/debug/app-debug.apk
ADB = adb
PACKAGE_NAME = com.findmyfriend.project
MAIN_ACTIVITY = .MainActivity

.PHONY: all build clean install uninstall help install-all

all: build

build:
	@echo "▶️  Compilation de l'APK de débogage..."
	@$(GRADLEW) assembleDebug
	@echo "✅ APK compilé : $(DEBUG_APK_PATH)"

clean:
	@echo "🧹 Nettoyage du projet..."
	@$(GRADLEW) clean
	@echo "✅ Projet nettoyé."

# Installe ET lance sur TOUS les appareils connectés
install: build
	@echo "📲 Installation et Lancement sur TOUS les appareils..."
	@$(ADB) devices | grep -v List | grep device | cut -f 1 | xargs -I {} -P 4 sh -c '$(ADB) -s {} install -r $(DEBUG_APK_PATH) && echo "🚀 Lancement sur {}..." && $(ADB) -s {} shell am start -n $(PACKAGE_NAME)/$(MAIN_ACTIVITY)'
	@echo "✅ Déploiement terminé."

uninstall:
	@echo "🗑️  Désinstallation de l'application sur TOUS les appareils..."
	@$(ADB) devices | grep -v List | grep device | cut -f 1 | xargs -I {} -P 4 $(ADB) -s {} uninstall $(PACKAGE_NAME)
	@echo "✅ Désinstallation terminée."

help:
	@echo "Commandes disponibles pour le projet Find My Friend :"
	@echo "  make build       : Compile l'APK de débogage."
	@echo "  make install     : Installe et LANCE l'application sur tous les appareils."
	@echo "  make uninstall   : Désinstalle de tous les appareils."
	@echo "  make clean       : Supprime les fichiers de build."
