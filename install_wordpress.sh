#!/bin/bash
set -euo pipefail

DB_NAME='${db_name}'
DB_USER='${db_username}'
DB_PASSWORD='${db_password}'
DB_HOST='${db_host}'
WORDPRESS_DIR=/var/www/html
EBS_DEVICE=""

dnf upgrade -y
dnf install -y httpd wget php-fpm php-mysqli php-json php php-devel php-mysqlnd

# Wait until Terraform attaches the separately managed EBS volume.
# On Nitro-based EC2 instances the requested /dev/sdf name is exposed as an
# NVMe device, so detect the additional disk rather than assuming its Linux name.
for attempt in $(seq 1 60); do
  while read -r device; do
    if ! lsblk -nrpo MOUNTPOINT "$device" | grep -qx "/"; then
      EBS_DEVICE="$device"
      break 2
    fi
  done < <(lsblk -dpno NAME,TYPE | awk '$2 == "disk" { print $1 }')
  sleep 5
done

if [ -z "$EBS_DEVICE" ] || [ ! -b "$EBS_DEVICE" ]; then
  echo "Timed out waiting for the additional EBS volume" >&2
  exit 1
fi

if ! blkid "$EBS_DEVICE" >/dev/null 2>&1; then
  mkfs.ext4 "$EBS_DEVICE"
fi

mkdir -p "$WORDPRESS_DIR"
EBS_UUID=$(blkid -s UUID -o value "$EBS_DEVICE")
if ! grep -q "UUID=$EBS_UUID" /etc/fstab; then
  echo "UUID=$EBS_UUID $WORDPRESS_DIR ext4 defaults,nofail 0 2" >> /etc/fstab
fi
mountpoint -q "$WORDPRESS_DIR" || mount "$WORDPRESS_DIR"

cd /tmp
wget -q https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp -a wordpress/. "$WORDPRESS_DIR"/
cp "$WORDPRESS_DIR/wp-config-sample.php" "$WORDPRESS_DIR/wp-config.php"

sed -i "s|database_name_here|$DB_NAME|" "$WORDPRESS_DIR/wp-config.php"
sed -i "s|username_here|$DB_USER|" "$WORDPRESS_DIR/wp-config.php"
sed -i "s|password_here|$DB_PASSWORD|" "$WORDPRESS_DIR/wp-config.php"
sed -i "s|localhost|$DB_HOST|" "$WORDPRESS_DIR/wp-config.php"

chown -R apache:apache "$WORDPRESS_DIR"
find "$WORDPRESS_DIR" -type d -exec chmod 755 {} \;
find "$WORDPRESS_DIR" -type f -exec chmod 644 {} \;
restorecon -RF "$WORDPRESS_DIR" || true

systemctl enable --now httpd
