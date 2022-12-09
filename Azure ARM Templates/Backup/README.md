# Introduction 
ARM Templates designed to automate Azure deployments and implement Parachute standards and best practices.
This template is designed to deploy all the default resources needed for every client.

# Resources
This template will deploy the following resources:
    - Backup Policies
      *  Default-Server-Policy
      *  DC-Server-Policy
      *  AVD-Personal-Policy
      *  Azure-Files-Policy

# Build and Deploy
[![Deploy to Azure](https://aka.ms/deploytoazurebutton)]( https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fgithub.com%2Fakrytus%2Fparachute%2Fblob%2Fmain%2FAzure%2520ARM%2520Templates%2FBackup%2FDeploy-BackupPolicies.json)

1.  Open "Deploy a custom deployment" from the Azure Portal
2.  Click "Build your own template in the editor"
3.  Paste the code over existing code
4.  Click "Save"
5.  Fill out the form including {Subscription} and {Resource Group}
6.  Click "Review + Create" (Wait for verification)
7.  Click "Create"


# Contribute
If you notice that there are errors or you have suggestions please submit them to akrytus@parachutetechs.com 
