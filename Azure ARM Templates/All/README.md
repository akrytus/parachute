# Deploy All Azure Resources

## Purpose
   - Deploy all minimum required Azure resources to a new Azure Subscription
   - This includes Parachute's standards and best practices

## Prerequisites
   1. Azure Subscription
   

## Resources that will be deployed
   1. Virtual Network
      *  Default Subnet
      *  Gateway Subnet
      *  Bastion Subnet
      *  AVD Subnet
   2. Network Security Groups
      *  Default Subnet NSG
      *  Default AVD Subnet
   3. VPN Gateway 
   4. Public IPs
      * Gateway PIP
      * Bastion PIP
   5. Bastion
   6. Local Gateway
      * Connection
   7. Storage Accounts
      * VM Diagnostics
      * AVD Diagnostics
   8. Recovery Services Vault
   9. Backup Policies
      *  Default-Server-Policy
      *  DC-Server-Policy
      *  AVD-Personal-Policy
      *  Azure-Files-Policy
   10. Log Analytics
      * Automation Account
   11. Virtual Machines
      * DC-01
      * DC-02


## Build and Deploy
[![Deploy to Azure](https://aka.ms/deploytoazurebutton)]( https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fakrytus%2Fparachute%2Fmain%2FAzure%2520ARM%2520Templates%2FBackup%2FDeploy-BackupPolicies.json)



1.  Click "**Deploy to Azure**" button
2.  Select "**Subscription**"
3.  Select "**Resource Group**"
4.  Enter your "**Email Address**"
5.  Enter "**Vault Name**"
6.  Click "**Review + Create**" (Wait for verification)
7.  Click "**Create**"


# Warning
Azure WestUS2 is no longer a reliable location.  
   - Virtual Machine sizes are depleated and will become a road block.
   - Azure WestUS3 is my recommandation for new clients, however there are currently some limitations.

Kown WestUS3 limitations:
   - Inventory and Change Tracking using Automation accounts is not available 
        *  Deploying Log Analytics and the Automation Account into WestUS2 is a viable workaround
        *  Location of the resources reporting to Log Analytics is irrelevant and has no impact

# Contribute
If you notice that there are errors or you have suggestions please submit them to akrytus@parachutetechs.com 

