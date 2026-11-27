#!/usr/bin/env bash
# Copyright 2026 Defense Unicorns
# SPDX-License-Identifier: AGPL-3.0-or-later OR LicenseRef-Defense-Unicorns-Commercial

set -euo pipefail

namespace=${1:?Missing gateway namespace}
service=${2:?Missing gateway Service}
host=${3:?Missing gateway hostname}
marker=${4:?Missing expected response text}
network=${METALLB_TEST_NETWORK:-k3d-uds}
curl_image=docker.io/curlimages/curl:8.17.0@sha256:935d9100e9ba842cdb060de42472c7ca90cfe9a7c96e4dacb55e79e560b3ff40

ip=$(./uds zarf tools kubectl get service "$service" -n "$namespace"   -o 'jsonpath={.status.loadBalancer.ingress[0].ip}')
if [[ -z "$ip" ]]; then
  printf 'Gateway Service %s/%s has no load-balancer IP\n' "$namespace" "$service" >&2
  exit 1
fi
address=$ip
if [[ "$ip" == *:* ]]; then
  address="[$ip]"
fi

if ! response=$(docker run --rm --network "$network" --entrypoint curl "$curl_image"   --fail --silent --show-error --insecure --noproxy '*' --location --max-redirs 3   --max-time 15 --proto '=https' --proto-redir '=https' --resolve "$host:443:$address"   --write-out $'\n%{http_code} %{url_effective}\n' "https://$host/"); then
  printf 'HTTPS probe for %s at %s failed\n' "$host" "$ip" >&2
  exit 1
fi

result=${response##*$'\n'}
body=${response%$'\n'*}
if [[ "$result" != "200 https://$host/"* || "$body" != *"$marker"* ]]; then
  printf 'Expected HTTP 200 from %s at %s with the gateway-specific response\n' "$host" "$ip" >&2
  exit 1
fi

printf 'Verified HTTPS response through %s/%s at %s\n' "$namespace" "$service" "$ip"
