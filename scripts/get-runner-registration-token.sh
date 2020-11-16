#!/bin/bash -e -u -o pipefail
# $1 GH domain
# $2 GH scope ('myorg', 'myorg/myrepo', 'user/repo'…)

declare API_ENDPOINT="https://api.github.com"
[[ "$1" == "github.com" ]] || {
  API_ENDPOINT="https://$1/api/v3"
}

declare SCOPE="repos"
[[ "$X" =~ / ]] || {
  SCOPE="orgs"
}

exec curl -fsSLX POST "$API_ENDPOINT/$SCOPE/$2/actions/runners/registration-token" \
  -H "accept: application/vnd.github.v3+json" \
  -H "authorization: token $GITHUB_REGISTRATION_TOKEN" \
  | jq -r '.token'
