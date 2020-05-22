#!/bin/bash

SignalrConnectionKey="AzureSignalRConnectionString"

az appconfig kv set-keyvault --name $AppConfigName --key $SignalrConnectionKey --secret-identifier $SignalrKvId --yes

# Create a new key-value referencing a value stored in Azure Key Vault
# az appconfig kv set --name $AppConfigName --key $SignalrConnectionKey --content-type "application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8" --value $SignalRConnectionString

# Update Key Vault reference
# az appconfig kv set --name $appConfigName --key $SignalrConnectionKey --value $SignalRConnectionString
