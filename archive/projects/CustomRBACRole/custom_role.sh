#!/bin/bash

az role definition create --role-definition '{ \
    "Name": "DevTest Labs User with VM Control", \
  "RoleType": "CustomRole",
    "Description": "DevTest Labs Custom Role", \
    "AssignableScopes": ["/subscriptions/PROVIDE_YOUR_SUBSCRIPTION_ID_HERE"], \
    "Actions": [ \

    "Microsoft.Authorization/*/read", \
    "Microsoft.Compute/availabilitySets/read", \
    "Microsoft.Compute/virtualMachines/*/read", \
    "Microsoft.Compute/virtualMachines/deallocate/action", \
    "Microsoft.Compute/virtualMachines/read", \
    "Microsoft.Compute/virtualMachines/restart/action", \
    "Microsoft.Compute/virtualMachines/start/action", \
    "Microsoft.DevTestLab/*/read", \
    "Microsoft.DevTestLab/labs/claimAnyVm/action", \
    "Microsoft.DevTestLab/labs/createEnvironment/action", \
    "Microsoft.DevTestLab/labs/ensureCurrentUserProfile/action", \
    "Microsoft.DevTestLab/labs/formulas/delete", \
    "Microsoft.DevTestLab/labs/formulas/read", \
    "Microsoft.DevTestLab/labs/formulas/write", \
    "Microsoft.DevTestLab/labs/policySets/evaluatePolicies/action", \
    "Microsoft.DevTestLab/labs/virtualMachines/claim/action", \
    "Microsoft.DevTestLab/labs/virtualmachines/listApplicableSchedules/action", \
    "Microsoft.DevTestLab/labs/virtualMachines/getRdpFileContents/action", \
    "Microsoft.Network/loadBalancers/backendAddressPools/join/action", \
    "Microsoft.Network/loadBalancers/inboundNatRules/join/action", \
    "Microsoft.Network/networkInterfaces/*/read", \
    "Microsoft.Network/networkInterfaces/join/action", \
    "Microsoft.Network/networkInterfaces/read", \
    "Microsoft.Network/networkInterfaces/write", \
    "Microsoft.Network/publicIPAddresses/*/read", \
    "Microsoft.Network/publicIPAddresses/join/action", \
    "Microsoft.Network/publicIPAddresses/read", \
    "Microsoft.Network/virtualNetworks/subnets/join/action", \
    "Microsoft.Resources/deployments/operations/read", \
    "Microsoft.Resources/deployments/read", \
    "Microsoft.Resources/subscriptions/resourceGroups/read", \
    "Microsoft.Storage/storageAccounts/listKeys/action", \
    "Microsoft.DevTestLab/labs/virtualMachines/Start/action", \
    "Microsoft.DevTestLab/labs/virtualMachines/Stop/action", \
    "Microsoft.DevTestLab/labs/virtualMachines/Restart/action" \
    ] \
}'

az role definition list --custom-role-only true --query "[].roleName"
