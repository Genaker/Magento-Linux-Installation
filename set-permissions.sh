#!/bin/bash

# Find the Magento installation directory
MAGENTO_DIR="$(pwd)"

# Set proper ownership
find ${MAGENTO_DIR} -type f -exec chmod 644 {} \;
find ${MAGENTO_DIR} -type d -exec chmod 755 {} \;

# Set executable permissions for specific directories
chmod -R 775 ${MAGENTO_DIR}/bin
chmod -R 775 ${MAGENTO_DIR}/var
chmod -R 775 ${MAGENTO_DIR}/pub/static
chmod -R 775 ${MAGENTO_DIR}/pub/media
chmod -R 775 ${MAGENTO_DIR}/app/etc

# Set executable permissions for specific files
chmod 775 ${MAGENTO_DIR}/bin/magento

# Set ownership to web server user (adjust www-data to your web server user if different)
chown -R www-data:www-data ${MAGENTO_DIR}

echo "Permissions have been set successfully."
