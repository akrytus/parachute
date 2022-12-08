# Introduction 
ARM Templates designed to automate Azure deployments and implement Parachute standards and best practices.
This template is designed to deploy all the default resources needed for every client.

# Resources
This template will deploy the following resources:
    - Storage Accounts 
        * AVD Diagnostics
        * FSLogix File Share (Premium)
    - NSG
        * Locked down specifically for AVD and typical apps
    - Private Endpoints and Links
        * AVD Subnet to FSLogix File Share
        * Default Subnet to FSLogix File Share (Can be removed to increase security)
    - Private DNS 
        * Name resolution for Private Endpoints
    - Log Analytics and Automation Account
        * AVD Automation (ie Shutdown Function)
        * AVD Insights Dashboard

# **Warnings**
Azure WestUS3 Limitations:
    - Linking Log Analytics and Automation Account
        * This affects:
            - Inventory
            - Update Management
            - Change Tracking 
        * Workaround:
            - Install Log Analytics and Automation accounts into WestUS2
                * This requires a new or existing RG in WestUS2
                * Deploy the AVD-Automation and Log Analytics ARM template seperately
            - Note: Location of the resources reporting to Log Analytics is irrelevant and has no impact

# Getting Started
1.	Choose your deployment type (All or individual resources)
    - All will deploy all the resources at once (see limitations above for WESTUS3)
    - Deploy [resource] will deploy individual resources 
2.	Copy the code


# Build and Deploy
1.  Open "Deploy a custom deployment" from the Azure Portal
2.  Click "Build your own template in the editor"
3.  Paste the code over existing code
4.  Click "Save"
5.  Fill out the form including {Subscription} and {Resource Group}
6.  Click "Review + Create" (Wait for verification)
7.  Click "Create"


# Contribute
If you notice that there are errors or you have suggestions please submit them to akrytus@parachutetechs.com 

# **Suggested Updates**
1. Move PrivateDNSZone to the default templates ("Default - Complete.json" and "Deploy-Vnet and NSG.json")
2. Add PrivateEndpoint "<prefix>-Default-FSLogix-Endpoint" to 