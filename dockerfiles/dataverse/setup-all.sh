#!/bin/bash

echo "Waiting for Dataverse"
until [ $(curl -w"%{http_code}" --output /dev/null --silent localhost:8080/resources/images/dataverseproject_logo.jpg) -eq "200" ]; do     printf '.';  sleep 5; done

command -v jq >/dev/null 2>&1 || { echo >&2 '`jq` ("sed for JSON") is required, but not installed. Download the binary for your platform from http://stedolan.github.io/jq/ and make sure it is in your $PATH (/usr/bin/jq is fine) and executable with `sudo chmod +x /usr/bin/jq`. On Mac, you can install it with `brew install jq` if you use homebrew: http://brew.sh . Aborting.'; exit 1; }


# Check to see if Dataverse has already been initialized (restart)
len=$(curl --silent http://localhost:8080/api/admin/roles/ | jq '.data | length')
if [ $len -gt 0 ]; then
   echo "Dataverse already initialized"
   exit
fi
   
echo "Initializing Solr"
curl -s http://$SOLR_HOST:$SOLR_PORT/solr/update/json?commit=true -H "Content-type: application/json" -X POST -d "{\"delete\": { \"query\":\"*:*\"}}"

SERVER=http://localhost:8080/api

# Everything + the kitchen sink, in a single script
# - Setup the metadata blocks and controlled vocabulary
# - Setup the builtin roles
# - Setup the authentication providers
# - setup the settings (local sign-in)
# - Create admin user and root dataverse
# - (optional) Setup optional users and dataverses


echo "Setup the metadata blocks"
./setup-datasetfields.sh

echo "Setup the builtin roles"
./setup-builtin-roles.sh

echo "Setup the authentication providers"
./setup-identity-providers.sh

echo "Initialize settings"
echo  "- Allow internal signup"
curl -s -X PUT -d yes "$SERVER/admin/settings/:AllowSignUp"
curl -s -X PUT -d /dataverseuser.xhtml?editMode=CREATE "$SERVER/admin/settings/:SignUpUrl"

curl -s -X PUT -d doi "$SERVER/admin/settings/:Protocol"
curl -s -X PUT -d 10.5072/FK2 "$SERVER/admin/settings/:Authority"
curl -s -X PUT -d EZID "$SERVER/admin/settings/:DoiProvider"
curl -s -X PUT -d / "$SERVER/admin/settings/:DoiSeparator"
curl -s -X PUT -d burrito "$SERVER/admin/settings/BuiltinUsers.KEY"
curl -s -X PUT -d empanada "$SERVER/admin/settings/:BlockedApiKey"
curl -s -X PUT -d localhost-only "$SERVER/admin/settings/:BlockedApiPolicy"
echo

echo "Setting up the admin user (and as superuser)"
adminResp=$(curl -s -H "Content-type:application/json" -X POST -d @data/user-admin.json "$SERVER/builtin-users?password=$ADMIN_PASSWORD&key=burrito")
echo $adminResp
curl -s -X POST "$SERVER/admin/superuser/dataverseAdmin"
echo

echo "Setting up the root dataverse"
adminKey=$(echo $adminResp | jq .data.apiToken | tr -d \")
curl -s -H "Content-type:application/json" -X POST -d @data/dv-root.json "$SERVER/dataverses/?key=$adminKey"
echo
echo "Set the metadata block for Root"
curl -s -X POST -H "Content-type:application/json" -d "[\"citation\"]" $SERVER/dataverses/:root/metadatablocks/?key=$adminKey
echo
echo "Set the default facets for Root"
curl -s -X POST -H "Content-type:application/json" -d "[\"authorName\",\"subject\",\"keywordValue\",\"dateOfDeposit\"]" $SERVER/dataverses/:root/facets/?key=$adminKey
echo

# OPTIONAL USERS AND DATAVERSES
#./setup-optional.sh

#echo "Setup done. Consider running post-install-api-block.sh for blocking the sensitive API."
