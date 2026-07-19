#!/bin/sh

CERT_DIR="/etc/letsencrypt/live/${DOMAIN}"
PRIVKEY="${CERT_DIR}/privkey.pem"
FULLCHAIN="${CERT_DIR}/fullchain.pem"

echo "проверка ssl сертификатов для домена ${DOMAIN} ==="

if [ ! -f "$PRIVKEY" ] || [ ! -f "$FULLCHAIN" ]; then
    echo "сертификаты не найдены, создаем временные заглушки чтобы nginx смог запуститься"
    
    mkdir -p "${CERT_DIR}"
    
    openssl req -x509 -nodes -days 1 -newkey rsa:2048 \
        -keyout "$PRIVKEY" \
        -out "$FULLCHAIN" \
        -subj "/CN=localhost"
        
    echo "временные сертификаты успешно созданы"
else
    echo "реальные ссл сертификаты найдены"
fi

echo "запуск envsubst (генерация конфигурации)"
# Генерируем конфиг напрямую туда, где его ждет Nginx
envsubst '${DOMAIN}' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf

echo "запуск nginx"
exec nginx -g "daemon off;"

