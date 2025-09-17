#!/bin/bash

echo "🚀 Installation de fitness-programs-api avec TDD"
echo "================================================"

# Vérifications préalables
if ! command -v docker &> /dev/null; then
    echo "❌ Docker n'est pas installé. Installez Docker Desktop d'abord."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose n'est pas installé."
    exit 1
fi

echo "✅ Docker et Docker Compose sont installés"

# Création de la structure de dossiers
echo "📁 Création de la structure de dossiers..."

mkdir -p docker/php/conf.d
mkdir -p docker/nginx/sites
mkdir -p docker/nginx/conf.d
mkdir -p docker/mysql
mkdir -p src/Entity
mkdir -p src/Repository
mkdir -p src/Controller
mkdir -p tests/Unit/Entity
mkdir -p tests/Integration/Repository
mkdir -p tests/Functional/Controller
mkdir -p config/jwt
mkdir -p public
mkdir -p var/log
mkdir -p var/cache

# Création des fichiers de configuration PHP
echo "⚙️ Création des fichiers de configuration..."

# opcache.ini
cat > docker/php/conf.d/opcache.ini << 'EOF'
[opcache]
opcache.enable=1
opcache.enable_cli=1
opcache.memory_consumption=256
opcache.interned_strings_buffer=16
opcache.max_accelerated_files=20000
opcache.validate_timestamps=1
opcache.revalidate_freq=2
opcache.fast_shutdown=1
EOF

# xdebug.ini
cat > docker/php/conf.d/xdebug.ini << 'EOF'
[xdebug]
xdebug.mode=debug,coverage
xdebug.start_with_request=yes
xdebug.client_host=host.docker.internal
xdebug.client_port=9003
xdebug.log=/var/log/xdebug.log
EOF

# error_reporting.ini
cat > docker/php/conf.d/error_reporting.ini << 'EOF'
log_errors=On
display_errors=On
display_startup_errors=On
error_reporting=E_ALL
error_log=/var/log/php_errors.log
EOF

# Configuration MySQL
cat > docker/mysql/my.cnf << 'EOF'
[mysqld]
general_log = 1
general_log_file = /var/lib/mysql/general.log
slow_query_log = 1
slow_query_log_file = /var/lib/mysql/slow.log
long_query_time = 2

# Optimisations pour le développement
innodb_buffer_pool_size = 256M
innodb_log_file_size = 64M
max_connections = 200
EOF

# Création du .env.local
cat > .env.local << 'EOF'
APP_ENV=dev
APP_DEBUG=1
DATABASE_URL="mysql://fitness_user:fitness_password@127.0.0.1:3306/fitness_programs_db"
EOF

# Création du .env.test
cat > .env.test << 'EOF'
APP_ENV=test
DATABASE_URL="mysql://fitness_user:fitness_password@database:3306/fitness_programs_test_db"
MAILER_DSN=null://null
EOF

# Création de tests/bootstrap.php
cat > tests/bootstrap.php << 'EOF'
<?php

use Symfony\Component\Dotenv\Dotenv;

require dirname(__DIR__).'/vendor/autoload.php';

if (file_exists(dirname(__DIR__).'/config/bootstrap.php')) {
    require dirname(__DIR__).'/config/bootstrap.php';
} elseif (method_exists(Dotenv::class, 'bootEnv')) {
    (new Dotenv())->bootEnv(dirname(__DIR__).'/.env');
}
EOF

# Création d'un .gitignore basique
cat > .gitignore << 'EOF'
###> symfony/framework-bundle ###
/.env.local
/.env.local.php
/.env.*.local
/config/secrets/prod/prod.decrypt.private.php
/public/bundles/
/var/
/vendor/
###< symfony/framework-bundle ###

###> phpunit/phpunit ###
/phpunit.xml
.phpunit.result.cache
/coverage/
###< phpunit/phpunit ###

###> lexik/jwt-authentication-bundle ###
/config/jwt/*.pem
###< lexik/jwt-authentication-bundle ###

# Docker
/.env.local
/docker/mysql/data/

# IDE
.idea/
.vscode/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db
EOF

echo "✅ Structure créée avec succès !"

# Instructions pour la suite
cat << 'EOF'

🎯 PROCHAINES ÉTAPES :

1. Copiez tous les fichiers de configuration générés :
   - docker-compose.yml (à la racine)
   - docker/php/Dockerfile
   - docker/nginx/nginx.conf
   - composer.json (à la racine)
   - phpunit.xml.dist (à la racine)
   - Makefile (à la racine)
   - .env (à la racine)

2. Lancez l'installation :
   make install

3. Ou manuellement :
   docker-compose build
   docker-compose up -d
   docker-compose exec fitness_api_app composer install

4. Vérifiez que tout fonctionne :
   make test

🌐 URLs une fois installé :
- API : http://localhost:8080
- PHPMyAdmin : http://localhost:8081

📝 Commandes utiles :
- make help (voir toutes les commandes)
- make bash (accéder au conteneur)
- make test (lancer les tests TDD)
- make logs (voir les logs)

EOF

echo "🎉 Installation terminée ! Suivez les prochaines étapes ci-dessus."
EOF
