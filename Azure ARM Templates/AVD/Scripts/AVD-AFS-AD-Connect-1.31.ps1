#Configures Azure Files with AD Authentication
#Installs FSLogix GPOs
#This is to be installed on a DC 

<# 
New Azure Server Preperation
Author: Aaron Krytus
Date: 06/23/20
Version: 1.0 (10/6/21) - Taken from ServerPrep.ps1 
Version: 1.1 (10/7/21) - Check for Windows 10 ADMX GPO files
Version: 1.2 (10/27/21) - Fix TLS issues during Invoke-WebRequest
Version: 1.3 (12/15/21) - Added FSLOgix GPO Settings Import and Link - GPO templates are stored in Parachute Dev (parafslogix) Storage Account
Version: 1.31 (3/10/22) - Better error traping and cleaner look
Version: 1.4 (TBA)      - Create Redirection.xml to sysvol (GPO is already updated)
#>

#Force TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function FSLogixGPO {
    #Download and Apply FSLogix GPOs  
    
    Write-Host "`n`nSetting up FSLogix GPOs...`n`n" 

    #Variables
    $OU = Read-Host "Distingushed Name or OU to link GPO"
    $Path = "$HOME\Downloads"
    $ExtractPath = "$HOME\Downloads\FSLogix"
    $fslogixfile = "FSLogix.zip"
    $fslogixurl = "https://aka.ms/fslogix_download" #Download the latest version
    $dnsdomain = (Get-WmiObject win32_computersystem).Domain
    $admxpath = "$Env:LOGONSERVER\sysvol\$dnsdomain\policies\PolicyDefinitions\"
    $admlpath = "$Env:LOGONSERVER\sysvol\$dnsdomain\policies\PolicyDefinitions\en-US\"
    $gpourl = "https://parafslogix.blob.core.windows.net/gpo/FSLogix-GPO-Settings.zip
    " #Preconfigured FSLogix GPO at Parachute Dev Storage
    $gpofile = "FSLogix-GPO-Settings.zip"
    $gponame = "AVD FSLogix Profile Management"
    $gpobackupid = "520944FF-5733-4A86-A533-47F1F98ADDC4" #This is created in the backup.xml file when the backup is performed (Update this if a new backup is performed)
            

    #Download FSLogix Zip file
    Write-Host "`nDownloading FSLogix to $Path...`n"   
    Invoke-WebRequest $fslogixurl -OutFile $Path\$fslogixfile

    #Download GPO Zip File From Azure Dev Storage
    Write-Host "Downloading GPO Settings to $Path...`n"   
    Invoke-WebRequest $gpourl -OutFile $Path\$gpofile

    #Extract FSLogix Zip file
    Write-Host "Extracting $fslogixfile to $ExtractPath\...`n"   
    Expand-Archive -LiteralPath $Path\$fslogixfile -DestinationPath $ExtractPath -Force

    #Extract GPO Zip file
    Write-Host "Extracting $gpofile to $ExtractPath\...`n"   
    Expand-Archive -LiteralPath $Path\$gpofile -DestinationPath $ExtractPath -Force

    #Check if GPO Central Store exists
    Write-Host "Verifying GPO Central Store...."
    if ((!(Test-Path -path $admlpath)) -or (!(Test-Path -path $admxpath))) {
        Write-Host "`nGPO Central Store is missing" -ForegroundColor Yellow
        Write-Host "Creating Central Store directories..."
        if(!(Test-Path -path $admlpath)){New-Item $admlpath -Type Directory} #Create ADML folder
        if(!(Test-Path -path $admxpath)){New-Item $admxpath -Type Directory} #Create ADMX folder
        CentralStore #Install Windows 10 ADMX Templates
        }

    
    #Copy GPO files
    Write-Host "`nCopying FSLogix Templates...."
    Copy-Item -Path "$ExtractPath\fslogix.admx" -Destination $admxpath
    Copy-Item -Path "$ExtractPath\fslogix.adml" -Destination $admlpath
      

    #Import GPO
    Write-Host "`nCreating New GPO - $gponame..."
    if(!(Get-GPO -Name $gponame -ErrorAction SilentlyContinue)){New-GPO -Name $gponame} #Check if GPO already exists. If it doesnt, create it. - Dont display errors if it is missing
    else{Write-Host "`nGPO - $gponame already exists" -ForegroundColor Yellow }
    Import-GPO -BackupId $gpobackupid -TargetName $gponame -Path $ExtractPath

    #Link GPO
    Write-Host "`nLinking New GPO - $gponame..."
    try {New-GPLink -Target $OU -Name $gponame -LinkEnabled Yes -Order 1 -ErrorAction SilentlyContinue}
    catch {Write-Host "`nGPO has already been linked." -ForegroundColor Yellow}
    Set-GPInheritance -Target $OU -IsBlocked Yes #Prevent Inheritance


    #Open Group Policy Editor
    Write-Host "Opening Group Policy Management..."
    Start-Process -FilePath "C:\Windows\System32\mmc.exe" -ArgumentList "C:\Windows\System32\gpmc.msc"

    #GPO Actions to perform
    Write-Host "`n`nVerify GPO '$gponame' is 'Linked' to '$OU' and inheritance is 'Blocked'." -ForegroundColor Yellow
}

function CentralStore {
    #Central Does not exist and need to Install Windows10 Admin Templates
    
    #Variables
    $dnsdomain=(Get-WmiObject win32_computersystem).Domain
    $Path = "$HOME\Downloads" 
    $URL2 = "https://www.microsoft.com/en-us/download/confirmation.aspx?id=48257"
    $Installer2 = "Windows10_ADMX.msi"
    $Extractpath2 = "C:\Program Files (x86)\Microsoft Group Policy\Windows 10\PolicyDefinitions"
    $admxpath = "$Env:LOGONSERVER\sysvol\$dnsdomain\policies\PolicyDefinitions\"
    $admlpath = "$Env:LOGONSERVER\sysvol\$dnsdomain\policies\PolicyDefinitions\en-US\"
    $Error.Clear()
    
    #Download MSI
    Write-Host "`nDownloading Administrative Templates..."
    Invoke-WebRequest $URL2 -OutFile $Path\$Installer2
        
    
    #Install MSI
    Write-Host "Installing Templates..." -NoNewline
    Start-Process msiexec.exe -Args "/I $Path\$Installer2 /q" -Verb RunAs #MSI file requires msiexec.exe

    #Check if install has completed (Status update)
    Start-Sleep -Seconds 5 #Delay to allow time to start installation
    while ($(Get-Process | Where-Object {$_.Name -like "*Installer*"})) {
        Write-Host "." -NoNewline
        Start-Sleep -Seconds 2
        }
    
    #Clean up install files
    Write-Host "Cleaning up installation files..."
    Remove-Item $Path\$Installer2
    
    #Copy ADMX Files
    Write-Host "Copying Administrative Templates...."
    Get-Childitem -Path "$ExtractPath2" -Filter *.admx | Copy-Item -Destination $admxpath
    Get-Childitem -Path "$ExtractPath2\en-US" -Filter *.adml | Copy-Item -Destination $admlpath
       
    
    #Verify if install was a success
    if(!$Error){Write-Host "Administrative Templates Extracted Successfully!" -ForegroundColor Green;return} 
    else{Write-Host "Extraction of Administrative Templates FAILED!" -ForegroundColor Red}

}

function AVDAFS {
    #Connect Azure Files to AD for authentication
    #Download AzFilesHybrid PS Module and install
    #Run Join-AzStorageAccountForAuth to authenticate to the Storage account using AD
  
    
    #Verify if AzHybrid Module has already been installed
    if(Get-Module -Name AzFilesHybrid){
        Write-Host "AzFilesHybrid Module already installed" -ForegroundColor Cyan
    }
    else {
        #Download and install AzFilesHybrid module
        Write-Host "`n`nSetting up AZ Files PS Module..."

        #Variables 
        $Path = "$HOME\Downloads"
        $ExtractPath = "$HOME\Downloads"
        $Script = "$ExtractPath\CopyToPSPath.ps1"
        $Installer = "AzFilesHybrid.zip"
        $URL = "https://github.com/Azure-Samples/azure-files-samples/releases/download/v0.2.3/AzFilesHybrid.zip"
     
        #Download file
        Write-Host "`n`nDownloading $Installer to $Path...`n"   
        Invoke-WebRequest $URL -OutFile $Path\$Installer
     
        #Extracting Zip file 
        Write-Host "Extracting $Installer to $ExtractPath\...`n"   
        Expand-Archive -LiteralPath $Path\$Installer -DestinationPath $ExtractPath -Force

        #Create Module Directory if it doesnt exist
        $psModPath = $env:PSModulePath.Split(";")[0]
        if (!(Test-Path -Path $psModPath)) {
            New-Item -Path $psModPath -ItemType Directory | Out-Null
        }
     
        #Read in AzFileHybrid Module and get version
        $psdFile = Import-PowerShellDataFile -Path "$ExtractPath\AzFilesHybrid.psd1" 
        $desiredModulePath = "$psModPath\AzFilesHybrid\$($psdFile.ModuleVersion)\"
  
        #Create Folder with Module Version as the name
        if (!(Test-Path -Path $desiredModulePath)) {
            New-Item -Path $desiredModulePath -ItemType Directory | Out-Null
        }

        #Copy PS Modules to \WindowsPowerShell\Modules\azfileshybrid\<version>
        Write-Host "Copying Files...."
        Copy-Item -Path "$ExtractPath\AzFilesHybrid.psd1" -Destination $desiredModulePath
        Copy-Item -Path "$ExtractPath\AzFilesHybrid.psm1" -Destination $desiredModulePath

        #Remove PS Modules
        Write-Host "Deleting files..."
        Remove-Item -Path "$ExtractPath\AzFilesHybrid.psd1"
        Remove-Item -Path "$ExtractPath\AzFilesHybrid.psm1"
        Remove-Item -Path "$ExtractPath\CopyToPSPath.ps1"
    
        #Import New Module
        Write-Host "`nImporting AZ Modules..."
        Import-Module -Name AzFilesHybrid -Force

    }

    #Collect Information
    Write-Host "`n`nSetting up AzureFiles..."
    $sub = Read-Host "Subscription Id"
    $rg = Read-Host "Resource Group"
    $storage = Read-Host "Storage Account"
    Get-ADOrganizationalUnit -Filter 'Name -like "wvd"'
    Write-host "`nExample: OU=AVD,OU=Computers,DC=parachutetech,DC=local)" -ForegroundColo Gray
    $OU = Read-Host "AVD OU Distinguished Name"

    #Connect to Azure AD
    Connect-AzAccount
    Select-AzSubscription -SubscriptionId $sub

    #Connect Storage with AD Authentication
    try{
        Join-AzStorageAccountForAuth -ResourceGroupName $rg -StorageAccountName $storage -DomainAccountType "ComputerAccount" -OrganizationalUnitDistinguishedName $OU
        Write-Host "Azure Storage and been connected AD" -ForegroundColor Green
        Return
    }
    catch{
        Write-Host "Connecting Azure Storage AD has failed!" -ForegroundColor Red
    }
}

#AVD Azure Files
$yn = Read-Host "`n`nConfigure AzureFiles with AD (y/n)"
if($yn -eq "y"){AVDAFS}

#AVD FSLogix Profiles
$yn = Read-Host "`n`nInstall FSLogix GPOs (y/n)"
if($yn -eq "y"){FSLogixGPO}

#------------------------
#Completed
#------------------------
Write-Host "`n`nAVD Setup has been completed!!!!" -ForegroundColor Green