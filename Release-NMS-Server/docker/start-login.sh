#!/bin/sh
# Writes login.json from the environment and starts the login server.
set -e
mkdir -p /data/login
cd /data/login
cp /opt/vf/login/login_opcodes*.conf .

cat > login.json <<EOF
{
  "database": {"host": "db", "port": 3306, "db": "${LOGIN_DB_NAME}", "user": "root", "password": "${DB_ROOT_PASSWORD}"},
  "account": {"auto_create_accounts": ${LOGIN_AUTO_CREATE_ACCOUNTS}},
  "worldservers": {"unregistered_allowed": true, "show_player_count": false, "dev_test_servers_list_bottom": false,
                   "special_character_start_list_bottom": false, "reject_duplicate_servers": false},
  "world_configuration": {"address": "0.0.0.0", "listen_port": 5998},
  "web_api": {"enabled": false, "port": 6000},
  "security": {"mode": 14, "allow_password_login": true, "allow_token_login": false},
  "logging": {"trace": false, "world_trace": false, "dump_packets_in": false, "dump_packets_out": false},
  "client_configuration": {"titanium_port": 5998, "titanium_opcodes": "login_opcodes.conf",
                           "sod_port": 5999, "sod_opcodes": "login_opcodes_sod.conf",
                           "display_expansions": true, "max_expansions_mask": 524287}
}
EOF
chmod 600 login.json

exec /opt/vf/bin/loginserver
