#!/bin/bash

. ./step00.variables.sh

if [ ! -z $userNameUAMILocation1 -a ! -z $rgNameUAMILocation1 ]
then
	echo "Create User-Assigned Managed Identity"
	az deployment group create --subscription "$subscriptionId" -n "UAMI-""$location1" --verbose \
		-g "$rgNameUAMILocation1" --template-file "$templateUami" \
		--parameters \
		location="$location1" \
		tenantId="$tenantId" \
		identityName="$userNameUAMILocation1"

	# Debug
	# identityResourceId="$(az identity show --subscription ""$subscriptionId"" -g ""$rgNameUAMILocation1"" --name ""$userNameUAMILocation1"" -o tsv --query 'id')"
	# echo $identityResourceId
fi
