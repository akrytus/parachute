# Introduction 
ARM Templates designed to automate Azure deployments and implement Parachute standards and best practices.
This template is designed to deploy all the default resources needed for every client.

# Resources
This template will deploy the following resources:
   - Vnet with subnets (Gateway,Bastion,Defualt,AVD)
    

# Warning
Azure WestUS2 is no longer a reliable location.  
   - Virtual Machine sizes are depleated and will become a road block.
   - Azure WestUS3 is my recommandation for new clients, however there are currently some limitations.

Kown WestUS3 limitations:
   - Inventory and Change Tracking using Automation accounts is not available 
        *  Deploying Log Analytics and the Automation Account into WestUS2 is a viable workaround
        *  Location of the resources reporting to Log Analytics is irrelevant and has no impact

# Getting Started
1.	Choose your deployment type (All or individual resources)
    - All will deploy all the resources at once
    - All [custom] will deploy typical bundles of resources at once
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

