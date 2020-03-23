#!/usr/bin/env bash

# Hook script for dns-01 challenge via GoDaddy API
#
# https://developer.godaddy.com/doc
# https://github.com/lukas2511/dehydrated/blob/master/docs/examples/hook.sh

set -e
set -u
set -o pipefail

if [[ -z "${GODADDY_KEY}" ]] || [[ -z "${GODADDY_SECRET}" ]]; then
  echo " - Unable to locate Godaddy credentials in the environment!  Make sure GODADDY_KEY and GODADDY_SECRET environment variables are set"
fi

deploy_challenge() {
  local DOMAIN="${1}" TOKEN_FILENAME="${2}" TOKEN_VALUE="${3}"

  # https://stackoverflow.com/questions/25204179/removing-subdomain-with-bash
  maindomain=$(expr match "$DOMAIN" '.*\.\(.*\..*\)')
  if [ `expr length "$maindomain"` -eq 0 ]
  then
      subdomain=$DOMAIN
      maindomain=$DOMAIN
  else
      subdomain_tmp=${DOMAIN//$maindomain/}
      subdomain=${subdomain_tmp::-1}
  fi

  echo -n " - Setting TXT record with GoDaddy _acme-challenge.${DOMAIN}=${TOKEN_VALUE}"
  curl -X PUT https://api.godaddy.com/v1/domains/${maindomain}/records/TXT/_acme-challenge.${subdomain} \
    -H "Authorization: sso-key ${GODADDY_KEY}:${GODADDY_SECRET}" \
    -H "Content-Type: application/json" \
    -d "[{\"name\": \"_acme-challenge.${subdomain}\", \"ttl\": 600, \"data\": \"${TOKEN_VALUE}\"}]"
  echo
  echo " - Waiting 30 seconds for DNS to propagate."
  sleep 30
}

clean_challenge() {
  local DOMAIN="${1}" TOKEN_FILENAME="${2}" TOKEN_VALUE="${3}"

  # https://stackoverflow.com/questions/25204179/removing-subdomain-with-bash
  maindomain=$(expr match "$DOMAIN" '.*\.\(.*\..*\)')
  if [ `expr length "$maindomain"` -eq 0 ]
  then
      subdomain=$DOMAIN
      maindomain=$DOMAIN
  else
      subdomain_tmp=${DOMAIN//$maindomain/}
      subdomain=${subdomain_tmp::-1}
  fi

  echo -n " - Removing TXT record from GoDaddy _acme-challenge.${DOMAIN}=--removed--"
  curl -X PUT https://api.godaddy.com/v1/domains/${maindomain}/records/TXT/_acme-challenge.${subdomain} \
    -H "Authorization: sso-key ${GODADDY_KEY}:${GODADDY_SECRET}" \
    -H "Content-Type: application/json" \
    -d "[{\"name\": \"_acme-challenge.${subdomain}\", \"ttl\": 600, \"data\": \"--removed--\"}]"
  echo
}

deploy_cert() {
  cp "${KEYFILE}" "${FULLCHAINFILE}" /etc/nginx/ssl/; chown -R nginx: /etc/nginx/ssl
  systemctl reload nginx
}

unchanged_cert() {
  local DOMAIN="${1}" KEYFILE="${2}" CERTFILE="${3}" FULLCHAINFILE="${4}" CHAINFILE="${5}"
  echo "The $DOMAIN certificate is still valid and therefore wasn't reissued."
}

HANDLER="$1"; shift
if [[ "${HANDLER}" =~ ^(deploy_challenge|clean_challenge|deploy_cert|unchanged_cert)$ ]]; then
  "$HANDLER" "$@"
fi
