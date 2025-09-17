# Makefile pour fitness-programs-api

# Variables
DOCKER_COMPOSE = docker compose
EXEC_APP = $(DOCKER_COMPOSE) exec app
COMPOSER = $(EXEC_APP) composer
CONSOLE = $(EXEC_APP) php bin/console

# Couleurs pour l'affichage
GREEN = \033[0;32m
YELLOW = \033[1;33m
RED = \033[0;31m
NC = \033[0m # No Color

.PHONY: help install start stop restart build logs bash test test-unit test-integration test-functional test-coverage clean db-create db-migrate db-fixtures db-reset jwt-keys

## Affiche l'aide
help:
	@echo "$(GREEN)🚀 Fitness Programs API - Commandes disponibles$(NC)"
	@echo "======================================================"
	@echo ""
	@echo "$(YELLOW)🐳 Docker:$(NC)"
	@echo "  make install        - Installation complète du projet"
	@echo "  make start          - Démarrer les conteneurs"
	@echo "  make stop           - Arrêter les conteneurs"
	@echo "  make restart        - Redémarrer les conteneurs"
	@echo "  make build          - Construire les images Docker"
	@echo "  make logs           - Afficher les logs"
	@echo "  make bash           - Accéder au conteneur PHP"
	@echo ""
	@echo "$(YELLOW)🧪 Tests TDD:$(NC)"
	@echo "  make test           - Lancer tous les tests"
	@echo "  make test-unit      - Tests unitaires uniquement"
	@echo "  make test-integration - Tests d'intégration"
	@echo "  make test-functional  - Tests fonctionnels"
	@echo "  make test-coverage  - Tests avec couverture de code"
	@echo ""
	@echo "$(YELLOW)🗄️ Base de données:$(NC)"
	@echo "  make db-create      - Créer la base de données"
	@echo "  make db-migrate     - Appliquer les migrations"
	@echo "  make db-fixtures    - Charger les fixtures"
	@echo "  make db-reset       - Reset complet de la DB"
	@echo ""
	@echo "$(YELLOW)🔐 Sécurité:$(NC)"
	@echo "  make jwt-keys       - Générer les clés JWT"
	@echo ""
	@echo "$(YELLOW)🧹 Utilitaires:$(NC)"
	@echo "  make clean          - Nettoyer le projet"

## Installation complète
install:
	@echo "$(GREEN)🚀 Installation de fitness-programs-api$(NC)"
	@echo "============================================="
	$(DOCKER_COMPOSE) build --no-cache
	$(DOCKER_COMPOSE) up -d
	@echo "$(YELLOW)⏳ Attente que les conteneurs soient prêts...$(NC)"
	@sleep 10
	@echo "$(YELLOW)🧩 Vérification du conteneur PHP...$(NC)"
	@until [ "`docker inspect -f '{{.State.Running}}' fitness_api_app 2>/dev/null`" = "true" ]; do \
		echo "   ⏳ En attente du conteneur PHP..."; \
		sleep 2; \
	done
	@echo "✅ Le conteneur PHP est prêt !"
	$(DOCKER_COMPOSE) exec -u www-data app sh -c "mkdir -p var vendor && chown -R www-data:www-data var vendor"
	$(DOCKER_COMPOSE) exec -u www-data app sh -c "composer install --optimize-autoloader --no-interaction"
	@make jwt-keys
	@make db-create
	@echo "$(GREEN)✅ Installation terminée !$(NC)"
	@echo ""
	@echo "🌐 URLs disponibles :"
	@echo "  - API: http://localhost:8080"
	@echo "  - API Doc: http://localhost:8080/api"
	@echo "  - PHPMyAdmin: http://localhost:8081"

## Démarrer les conteneurs
start:
	@echo "$(GREEN)🚀 Démarrage des conteneurs...$(NC)"
	$(DOCKER_COMPOSE) up -d

## Arrêter les conteneurs
stop:
	@echo "$(RED)🛑 Arrêt des conteneurs...$(NC)"
	$(DOCKER_COMPOSE) down

## Redémarrer les conteneurs
restart: stop start

## Construire les images
build:
	@echo "$(YELLOW)🔨 Construction des images Docker...$(NC)"
	$(DOCKER_COMPOSE) build --no-cache

## Afficher les logs
logs:
	$(DOCKER_COMPOSE) logs -f

## Accéder au conteneur PHP
bash:
	$(EXEC_APP) bash

## Lancer tous les tests TDD
test:
	@echo "$(GREEN)🧪 Lancement de tous les tests TDD...$(NC)"
	$(EXEC_APP) php bin/phpunit

## Tests unitaires
test-unit:
	@echo "$(GREEN)🧪 Tests unitaires...$(NC)"
	$(EXEC_APP) php bin/phpunit tests/Unit

## Tests d'intégration
test-integration:
	@echo "$(GREEN)🧪 Tests d'intégration...$(NC)"
	$(EXEC_APP) php bin/phpunit tests/Integration

## Tests fonctionnels
test-functional:
	@echo "$(GREEN)🧪 Tests fonctionnels...$(NC)"
	$(EXEC_APP) php bin/phpunit tests/Functional

## Tests avec couverture
test-coverage:
	@echo "$(GREEN)🧪 Tests avec couverture de code...$(NC)"
	$(EXEC_APP) php bin/phpunit --coverage-html coverage

## Créer la base de données
db-create:
	@echo "$(GREEN)🗄️ Création de la base de données...$(NC)"
	@$(CONSOLE) about | grep "Environment"
	$(DOCKER_COMPOSE) exec app php bin/console doctrine:database:create --if-not-exists || true
	$(DOCKER_COMPOSE) exec app php bin/console doctrine:database:create --env=test --if-not-exists || true

## Appliquer les migrations
db-migrate:
	@echo "$(GREEN)🗄️ Application des migrations...$(NC)"
	$(CONSOLE) doctrine:migrations:migrate --no-interaction
	$(CONSOLE) doctrine:migrations:migrate --env=test --no-interaction

## Charger les fixtures
db-fixtures:
	@echo "$(GREEN)🗄️ Chargement des fixtures...$(NC)"
	$(CONSOLE) doctrine:fixtures:load --no-interaction

## Reset complet de la base
db-reset:
	@echo "$(RED)🗄️ Reset complet de la base de données...$(NC)"
	-$(CONSOLE) doctrine:database:drop --force
	-$(CONSOLE) doctrine:database:drop --env=test --force
	@make db-create
	@make db-migrate
	@make db-fixtures

## Générer les clés JWT
jwt-keys:
	@echo "$(GREEN)🔐 Génération des clés JWT...$(NC)"
	$(EXEC_APP) mkdir -p config/jwt
	$(EXEC_APP) openssl genpkey -out config/jwt/private.pem -aes256 -algorithm rsa -pkeyopt rsa_keygen_bits:4096 -pass pass:fitness_jwt_secret
	$(EXEC_APP) openssl pkey -in config/jwt/private.pem -out config/jwt/public.pem -pubout -passin pass:fitness_jwt_secret

## Nettoyer le projet
clean:
	@echo "$(RED)🧹 Nettoyage du projet...$(NC)"
	$(DOCKER_COMPOSE) down -v
	docker system prune -f
	sudo rm -rf var/cache/* var/log/* coverage/
