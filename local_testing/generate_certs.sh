#!/usr/bin/env bash
set -euo pipefail

parent_dir=$( cd "$(dirname "${BASH_SOURCE[0]}")"; pwd -P )
CERT_DIR="${parent_dir}/certs"
mkdir -p "$CERT_DIR"

# Fake CA
openssl req -x509 -newkey rsa:4096 -days 3650 -nodes \
  -keyout "$CERT_DIR/ca.key" \
  -out "$CERT_DIR/ca.crt" \
  -subj "/CN=fake-ca-for-postgres"

openssl req -newkey rsa:4096 -nodes \
  -keyout "$CERT_DIR/server.key" \
  -out "$CERT_DIR/server.csr" \
  -subj "/CN=image_tracker_postgres"

openssl x509 -req -days 3650 \
  -in "$CERT_DIR/server.csr" \
  -CA "$CERT_DIR/ca.crt" \
  -CAkey "$CERT_DIR/ca.key" \
  -CAcreateserial \
  -out "$CERT_DIR/server.crt"

chmod 600 "$CERT_DIR/server.key"
