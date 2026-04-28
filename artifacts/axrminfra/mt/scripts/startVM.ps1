### AgileXRMVersion 8.0.26117.20500
Param(
	[string]$apServiceAccountDomain ="INTERNAL",
	[string]$apServiceAccountUser ="apservice",
	$apServiceAccountPassword=$null,
	[string]$regionNumber="4",
	[string]$poolNumber="00",
	[string]$redisAccessKey = "",
	[string]$azureServiceBusConnectionString="",
	[string]$defaultGateway = "10.0.0.1",
	[string]$sqlServer="",
	[string]$sqlServerPort="1433",
	[validateSet('.','-')][string]$appUrlSeparator=".",
	[string]$domainUrl="agilexrmonline.com",
	[string]$mainHostName="pool",
	[string]$portalPort="443",
	[string]$tcpServicePort="13488",
	[string]$wcfServicePort="13487",
	[string]$restServicePort="443",
	[string]$regularSitePort="443",
	[string]$publicSitePort="443",
	[string]$externalSitePort="443",
	[string]$azureAdRealm = "https://axrm.agilexrmonline.com",
	[validateSet('MT','ST')][string]$deploymentMode ="MT",
	[validateSet('Cloud','PrivateCloud')][string]$deploymentType ="Cloud",
	[string]$localUsersPassword ="Default@1", 
	[string]$waadWcfAppId = "19e4137f-55ae-4dbf-9fbc-e386bbf36304",
	[string]$waadWcfAppIdUri = "https://ws.agilexrmonline.com:13487/AgilePointServer",
	[string]$waadApplicationId = "81c01359-21c1-467f-a3a8-52f5d6721fa0",
	[string]$waadApplicationIdPassword = $null,
	[string]$envisionAppId = "583a4e00-bcf2-4fbb-b346-6c90c376f160",
	[string]$singleTenantCrmOrgUniqueId ="ORGYYYYY" ,
	[string]$singleTenantCrmOrgFullUrl ="https://myorgyyy.crm4.dynamics.com",
	[string]$certificateSubjectName= "CN=agilexrmonline.com",
	[string]$certificateApiSubjectName= "",
	[string]$certificateAdminPortalSubjectName= "",
	[string]$singleTenantAdminUser ="apservice",
	[string]$anonymousUser,
	[string]$customStorageAzureConnString,
	[string]$azureStorageConnString,
	[string]$azureStorageTableName="AgileXRMGlobalOndemandStorage",
	$poolNotificationMailbox=$null,
	[string]$senderMailBox="notification@agilexrmonline.com",
	[string]$mailServer="smtp.office365.com:587:ssl",
	[string]$smtpService,
	[string]$tenantId = "b77e219c-0e95-404c-b671-4e48f654b3a4",
	[string]$subscriptionId ="84fe0ef0-3952-4108-ad59-48e33047bc69",
	[bool]$isScaleSet = $true,
	[string]$scaleSetName = "axrm498vmss",
	[string]$primaryNicName ="scaleSetLBNIC",
	[string]$apiNicName ="scaleSetLBNIC2",
	[string]$publicNicName ="scaleSetLBNIC3",
	[string]$portalNicName ="scaleSetLBNIC4",	
	[string]$resourceGroupName ="AgileXRMOnline",
	$svcPrincipalAppId=$null,
	$svcPrincipalSecretKey=$null,
	$autoRestart=$true,
	$singleApDB = "SingleAPDB",
	$masterPortalDB = "MasterPortalDB",
	$singlePortalDB = "SinglePortalDB",
	[string]$dbUserName="apservice",
	[string]$dbUserPassword="",
	[bool]$isSqlAzure = $false,
	[bool]$customizeNxPortal = $false,
	[string]$sqlServerAliasName = "SQL400",
	[bool]$useCustomURLs = $false,
	[string]$regularSiteSubdomain ="",
	[string]$apiSiteSubdomain ="",
	[string]$adminPortalSiteSubdomain ="",
	[string]$publicSiteSubdomain ="",
	[string]$externalSiteSubdomain ="",
	[string]$dnsTenantId,
	[string]$dnsClientId,
	[string]$dnsClientSecret,
	[string]$stoManFunctionUrl,
	[string]$stoManFunctionKey,
	[validateSet('AzureTableStorage','Dataverse')][string]$mtRepoType="AzureTableStorage",
	[string]$dvRepoUrl,
	[string]$dvRepoClientId,
	[string]$dvRepoClientSecret,
	[string]$dvRepoOrgUnqName,
	[string]$dvRepoPoolId
)
$now = Get-Date -Format "yyyyMMddHHmmss"
$transcriptFileName = [string]::Format("PSWStartVM_{0}.log",$now)
$transcriptFilePath = Join-Path "C:\Temp" $transcriptFileName
Start-Transcript -Path $transcriptFilePath

if (Get-Module -ListAvailable -Name Microsoft.Xrm.Data.PowerShell) 
{
	Write-Host "Module 'Microsoft.Xrm.Data.PowerShell' already installed" -ForegroundColor DarkGreen;
}
else
{
	Write-Host "Module 'Microsoft.Xrm.Data.PowerShell' NOT Found. Installing..." -ForegroundColor DarkCyan;
	Install-Module -Name Microsoft.Xrm.Data.PowerShell -force
}

if (Get-Module -ListAvailable -Name SqlServer) 
{
	Write-Host "Module 'SqlServer ' already installed" -ForegroundColor DarkGreen;
}
else
{
	Write-Host "Module 'SqlServer ' NOT Found. Installing..." -ForegroundColor DarkCyan;
	Install-Module -Name SqlServer -force
}

Write-Host "Importing Module 'ServerManager' ..." -ForegroundColor DarkCyan;
Import-Module ServerManager
if(Get-WindowsFeature -Name Web-Scripting-Tools)
{
	Write-Host "Feature 'Web-Scripting-Tools' already installed" -ForegroundColor DarkGreen;
}
else
{
	Write-Host "Feature 'Web-Scripting-Tools' NOT Found. Installing..." -ForegroundColor DarkCyan;
	Install-WindowsFeature web-scripting-tools
}

Write-Host "Importing Module 'IISAdministration' ..." -ForegroundColor DarkCyan;
Import-Module IISAdministration

if($svcPrincipalAppId -eq $null)
{
	write-host "ServicePrincipal ID is Null" -foregroundcolor DarkCyan
	$svcPrincipalAppId = $waadApplicationId
}
if($svcPrincipalSecretKey -eq $null)
{
	write-host "ServicePrincipal KEY is Null" -foregroundcolor DarkCyan
	$svcPrincipalSecretKey = $waadApplicationIdPassword
}
if($deploymentMode -eq "ST")
{
 	$regionNumber=""
	$poolNumber=""
} 

#Global Parameters
$global:debugMode = $false
$internalDomainValue = "INTERNAL"

#Script Parameters
$currentVmSSInstance = "$env:ComputerName"
[bool]$vmBelongsToDomain =  $apServiceAccountDomain.ToLower() -ne $internalDomainValue.ToLower()

[string]$global:primaryNicIpAddress1 = $null
[string]$global:primaryNicIpAddress2 = $null
[System.Collections.Generic.List[string]]$global:primaryNicIpAddresses= $null;

$adminPortalAlias = "admin"
$apiAlias = "api"
$externalAlias="external"
$publicAlias ="public"
$portalAlias = "portal"
$hostName = "$mainHostName$regionNumber$poolNumber"

$netTcpRaw = "nettcp.$domainUrl"

$tcpAgilePointUrl = [string]::Format( "tcp://ap-{0}.nx{1}.agilexrmonline.com:13489/AgilePointServer", $poolNumber, $regionNumber);
$nettcpAgilePointUrl = [string]::Format( "net.tcp://{0}{1}{2}.{3}:{4}/AgilePointServer/", $hostName,$appUrlSeparator,$apiAlias,$domainUrl,$tcpServicePort);
$nettcpAgilePointUrl = [string]::Format( "net.tcp://{0}:{1}/AgilePointServer/", $netTcpRaw,$tcpServicePort)
$apiRestUrl =  [string]::Format( "https://{0}{1}{2}.{3}:{4}/AgilePointServer/", $hostName,$appUrlSeparator,$apiAlias,$domainUrl,$restServicePort);
$apiWsUrl = [string]::Format( "https://{0}{1}{2}.{3}:{4}/AgilePointServer/", $hostName,$appUrlSeparator,$apiAlias,$domainUrl,$wcfServicePort);
$agileXrmUrl = [string]::Format( "https://{0}.{1}:{2}", $hostName,$domainUrl,$regularSitePort);
$agilePointPortalUrl = [string]::Format( "https://{0}{1}{2}.{3}:{4}", $hostName, $appUrlSeparator, $adminPortalAlias, $domainUrl, $portalPort);
$notificationReceiverUrl = [string]::Format("http://{0}:8888/AgileDialogs/NotificationReceiver/NotificationReceiver.svc",$env:computername);
$agileXrmPublicUrl = [string]::Format( "https://{0}{1}{2}.{3}:{4}",  $hostName,$appUrlSeparator,$publicAlias,$domainUrl,$publicSitePort);
$agileXrmExternalUrl = [string]::Format( "https://{0}{1}{2}.{3}:{4}", $hostName,$appUrlSeparator,$externalAlias,$domainUrl,$externalSitePort);

if($useCustomURLs -eq $true)
{
	if($regularSiteSubdomain -eq "")
	{
		Write-Host "Unable to find URL SubDomain. Set parameter `$regularSiteSubdomain." -ForegroundColor Magenta;
	}
	if($adminPortalSiteSubdomain -eq "")
	{
		Write-Host "Unable to find URL SubDomain. Set parameter `$adminPortalSiteSubdomain." -ForegroundColor Magenta;
	}
	if($apiSiteSubdomain -eq "")
	{
		Write-Host "Unable to find URL SubDomain. Set parameter `$apiSiteSubdomain." -ForegroundColor Magenta;
	}
	if($publicSiteSubdomain -eq "")
	{
		Write-Host "Unable to find URL SubDomain. Set parameter `$publicSiteSubdomain." -ForegroundColor Magenta;
	}
	if($externalSiteSubdomain -eq "")
	{
		Write-Host "Unable to find URL SubDomain. Set parameter `$externalSiteSubdomain." -ForegroundColor Magenta;
	}
	
	$apiRestUrl =  [string]::Format( "https://{0}.{1}:{2}/AgilePointServer/", $apiSiteSubdomain,$domainUrl,$restServicePort);
	$apiWsUrl = [string]::Format( "https://{0}.{1}:{2}/AgilePointServer/", $apiSiteSubdomain,$domainUrl,$wcfServicePort);

	$agileXrmUrl = [string]::Format( "https://{0}.{1}:{2}", $regularSiteSubdomain,$domainUrl,$regularSitePort);
	$agilePointPortalUrl = [string]::Format( "https://{0}.{1}:{2}", $adminPortalSiteSubdomain, $domainUrl, $portalPort);
	
	$agileXrmPublicUrl = [string]::Format( "https://{0}.{1}:{2}",  $publicSiteSubdomain,$domainUrl,$publicSitePort);
	$agileXrmExternalUrl = [string]::Format( "https://{0}.{1}:{2}", $externalSiteSubdomain,$domainUrl,$externalSitePort);
}

##Regular Site
$agileDialogsUrl = "$agileXrmUrl/AgileDialogs";
$processManagerUrl = "$agileXrmUrl/XRMProcessViewer";

$reportsPortalUrl = [string]::Format( "https://pool{1}{0}.reports.agilexrmonline.com/AgileReports", $poolNumber, $regionNumber);
$docsApiUrl = $apiRestUrl+"docs";

$rawAdminPortalHostName = [string]::Format( "{0}{1}{2}.{3}",  $hostName,$appUrlSeparator,$adminPortalAlias,$domainUrl);
$adminPortalHostName = [string]::Format( "{0}{1}{2}.{3}:{4}",  $hostName,$appUrlSeparator,$adminPortalAlias,$domainUrl, $portalPort);
$agileXrmHostName = [string]::Format( "{0}.{1}", $hostName,$domainUrl);
$wsServiceHostName = [string]::Format( "{0}{1}{2}.{3}", $hostName,$appUrlSeparator,$apiAlias,$domainUrl);
$apiServiceHostName = [string]::Format( "{0}{1}{2}.{3}", $hostName,$appUrlSeparator,$apiAlias,$domainUrl);
$publicAXrmHostName = [string]::Format( "{0}{1}{2}.{3}", $hostName,$appUrlSeparator,$publicAlias,$domainUrl);
$externalAXrmHostName = [string]::Format( "{0}{1}{2}.{3}", $hostName,$appUrlSeparator,$externalAlias,$domainUrl);

if($useCustomURLs -eq $true)
{
	$rawAdminPortalHostName = [string]::Format( "{0}.{1}",  $adminPortalSiteSubdomain,$domainUrl);
	$adminPortalHostName = [string]::Format( "{0}.{1}:{2}",  $adminPortalSiteSubdomain,$domainUrl, $portalPort);
	$agileXrmHostName = [string]::Format( "{0}.{1}", $regularSiteSubdomain,$domainUrl);
	$wsServiceHostName = [string]::Format( "{0}.{1}", $apiSiteSubdomain,$domainUrl);
	$apiServiceHostName = [string]::Format( "{0}.{1}", $apiSiteSubdomain,$domainUrl);
	$publicAXrmHostName = [string]::Format( "{0}.{1}", $publicSiteSubdomain,$domainUrl);
	$externalAXrmHostName = [string]::Format( "{0}.{1}", $externalSiteSubdomain,$domainUrl);
	$netTcpRaw = [string]::Format("{0}.{1}", $apiSiteSubdomain,$domainUrl);
	$nettcpAgilePointUrl = [string]::Format( "net.tcp://{0}:{1}/AgilePointServer/", $netTcpRaw,$tcpServicePort);
}

## Following URLs are for MultiTenant (MT) Deployments only
$agileXrmWildcardHostName = [string]::Format( "{0}.{1}", "*", $domainUrl);
$adminPortalWildcardHostName = [string]::Format( "{0}{1}{2}.{3}", "*", $appUrlSeparator, $adminPortalAlias, $domainUrl);
$apiWildcardHostName = [string]::Format( "{0}{1}{2}.{3}", "*", $appUrlSeparator, $apiAlias, $domainUrl);
$apiWsWildcardHostName = [string]::Format( "{0}{1}{2}.{3}:{4}", "*", $appUrlSeparator, $apiAlias, $domainUrl,$wcfServicePort);
$publicWildcardHostName = [string]::Format( "{0}{1}{2}.{3}", "*", $appUrlSeparator, $publicAlias, $domainUrl);
$externalWildcardHostName = [string]::Format( "{0}{1}{2}.{3}", "*", $appUrlSeparator, $externalAlias, $domainUrl);
$portalWildcardHostName = [string]::Format( "{0}{1}{2}.{3}", "*", $appUrlSeparator, $portalAlias, $domainUrl);


$restServiceHostName = $apiServiceHostName;
$reportsHostName = [string]::Format( "pool{1}{0}.reports.agilexrmonline.com", $poolNumber, $regionNumber);
$nxAppsHostName = [string]::Format( "nav{1}{0}.agilexrmonline.com", $poolNumber, $regionNumber);

$agilePointPortalWebFolder = "C:\Program Files\AgilePoint\AgilePointWebApplication\AgilePointPortal";
$agilePointServerInstanceFolder = "C:\Program Files\AgilePoint\AgilePointServerInstance";
$agileXrmWebFolder = "C:\Program Files\AgileXRM\WebApps";
$agilePointServer = "C:\Program Files\AgilePoint\AgilePointServer"
$appId = "{c929c857-e10a-48c4-b123-5713faba528e}";

##Public Site
$publicAgileXrmWebFolder = "C:\Program Files\AgileXRM\PublicWebApps";
$notificationReceiverPublicUrl = [string]::Format("http://{0}:8889/AgileDialogs/NotificationReceiver/NotificationReceiver.svc",$env:computername);
$agileDialogsPublicUrl = "$agileXrmPublicUrl/AgileDialogs";
$processManagerPublicUrl = "$agileXrmPublicUrl/XRMProcessViewer";

##External Site
$externalAgileXrmWebFolder = "C:\Program Files\AgileXRM\ExternalWebApps";
$notificationReceiverExternalUrl = [string]::Format("http://{0}:8890/AgileDialogs/NotificationReceiver/NotificationReceiver.svc",$env:computername);
$agileDialogsExternalUrl = "$agileXrmExternalUrl/AgileDialogs";
$processManagerExternalUrl ="$agileXrmExternalUrl/XRMProcessViewer";

$global:apServiceAccountPassword = $apServiceAccountPassword

$adConnectorName = "AgileDialogs";
$pmConnectorName = "XRMProcessViewer";
$crmConnectorName ="CrmConnector";
$tenantManagerConnectorName = "AgileXRMTenantManager"
$azuOperationConnectorName ="AzureOperationsConnector"
$orchardConnectorName = "OrchardCMS"
$allowedConnectors = @($adConnectorName,$pmConnectorName,$crmConnectorName,$tenantManagerConnectorName,$azuOperationConnectorName,$orchardConnectorName)

$backupFilesScript = "C:\tools\scripts\BackupAllConfigFiles_and_selected_Logs.ps1"

$portalInstallationName="DEFAULTTENANT";

if($certificateApiSubjectName -eq "")
{
	$certificateApiSubjectName = $certificateSubjectName;
}
if($certificateAdminPortalSubjectName -eq "")
{
	$certificateAdminPortalSubjectName = $certificateSubjectName;
}

###################### FUNCTIONS########################################################################

function Create-Adapter-IP-Addresses()
{
	param([System.Collections.Generic.List[string]]$ipAddresess)

	Write-Host "Create-Adapter-IP-Addresses>> Execution for IPs $ipAddresess" -foregroundcolor DarkCyan
	$dnsAddresses = @("168.63.129.16","8.8.8.8")
	$IPType = "IPv4"
	$primaryIP = $ipAddresess[0]

	Write-Host "Create-Adapter-IP-Addresses>> primary IP in adapter $primaryIP"
	$adapterName = ((Get-NetAdapter | Get-NetIPConfiguration) | ? {$_.IPv4Address.IpAddress -eq $primaryIP}).InterfaceAlias
	if($adapterName -eq "")
	{
		Write-Host "Create-Adapter-IP-Addresses>> AdapterName not found!! Something is wrong"
		return -1;
	}
	
	# Retrieve the network adapter that you want to configure
	$adapter = Get-NetAdapter | ? {$_.Status -eq "up" -and $_.Name -eq $adapterName}
	
	
	if(($adapter | Get-NetIPConfiguration).IPv4Address.IPAddress.Count -ge 2)
	{
		Write-Host "Create-Adapter-IP-Addresses>> 2 or more IP Addresses have been found in Adapter $adapterName . Exit without touching anything " -foregroundcolor DarkGray
		return;
	}

	#Before to recreate, save current PrefixLength:
	$prefixLength = ($adapter | Get-NetIPConfiguration).IPv4Address.PrefixLength.ToString();
	
	# Remove any existing IP, gateway from our ipv4 adapter
	If (($adapter | Get-NetIPConfiguration).IPv4Address.IPAddress) {
		$adapter | Remove-NetIPAddress -AddressFamily $IPType -Confirm:$false
	}
	If (($adapter | Get-NetIPConfiguration).Ipv4DefaultGateway) {
		$adapter | Remove-NetRoute -AddressFamily $IPType -Confirm:$false
	}
	
	# Configure the IP address and default gateway
	foreach($ipValue in $ipAddresess)
	{
		if($ipValue -ne $null)
		{
			if($primaryIP -eq $ipValue)
			{
				Write-Host "Create-Adapter-IP-Addresses>> Primary AdapterName found! IP: $ipValue"
				$adapter | New-NetIPAddress `
					-AddressFamily $IPType `
					-IPAddress $ipValue `
					-PrefixLength $prefixLength `
					-DefaultGateway $defaultGateway
			}
			else
			{
				Write-Host "Create-Adapter-IP-Addresses>> NOT Primary AdapterName found! IP: $ipValue"
				$adapter | New-NetIPAddress `
					-AddressFamily $IPType `
					-IPAddress $ipValue `
					-PrefixLength $prefixLength 
			}
		}
	}
	
	# Configure the DNS client server IP addresses
	$adapter | Set-DnsClientServerAddress -ServerAddresses $dnsAddresses
}

#Write-Host "APSP: $apServiceAccountPassword";
function Get-IP-Addresses()
{
	param([string]$interfaceAlias="Ethernet*")
	$ipAddressesRaw = Get-NetIPAddress | ? AddressFamily -eq IPv4 | ? InterfaceAlias -like $interfaceAlias | Sort-Object IPAddress | select IPAddress;

	if(($deploymentMode -eq "ST") -and ($ipAddressesRaw.Count -ne $null))
	{
	   Write-Host "Get-IP-Addresses>> Single Tenant has been requested but several NICs have been found" -ForegroundColor yellow;
	   Write-Output "Get-IP-Addresses>> Single Tenant has been requested but several NICs have been found" 
	}

	$ipAddressString =[system.String]::Join("|", $ipAddressesRaw.IPAddress)
	$ipAddresses = $ipAddressString.Split("|") |  Sort { [version]$_ };
	return $ipAddresses
}

$executionCommand = {
param(    [string]$userName, [string]$permission,[string]$certStoreLocation,[string]$certThumbprint)
        
    Write-Host "UserName: $userName"
    Write-Host "CertStore: $certStoreLocation"
    Write-Host "Thumbprint: $certThumbprint"

    # check if certificate is already installed
    $certificateInstalled = Get-ChildItem cert:$certStoreLocation | Where thumbprint -eq $certThumbprint
    # download & install only if certificate is not already installed on machine
    if ($certificateInstalled -eq $null)
    {
        $message="Certificate with thumbprint:"+$certThumbprint+" does not exist at "+$certStoreLocation
        Write-Host $message -ForegroundColor Red
        exit 1;
    }else{
        try
        {
	    Write-Host "Cert has been found. Trying to find file..."
            $rule = new-object System.Security.AccessControl.FileSystemAccessRule ($userName, $permission, [System.Security.AccessControl.AccessControlType]::Allow)
            $root = "c:\programdata\microsoft\crypto\rsa\machinekeys"
            $l = ls Cert:$certStoreLocation
            $l = $l |? {$_.thumbprint -like $certThumbprint}
            $l |%{
                $keyname = $_.privatekey.cspkeycontainerinfo.uniquekeycontainername
                $p = [io.path]::combine($root, $keyname)
                if ([io.file]::exists($p))
                {
                    Write-Host "File Found! Trying to set permission...";
                    $acl = get-acl -path $p
                    $acl.addaccessrule($rule)
                    echo $p
                    set-acl -Path $p -AclObject $acl
                    Write-Host "Permission successfully set!";

                }
                else
                {
                    Write-Host "file Not Found!";
                }
            }
        }
        catch 
        {
            Write-Host "Caught an exception:" -ForegroundColor Red
            Write-Host "$($_.Exception)" -ForegroundColor Red
            exit 1;
        }    
    }
    exit $LASTEXITCODE
};

function Fix-Secondary-NetworkAdapter()
{
	$nicName = "Ethernet 2";
	$defaultGateway = "10.0.0.1";
	$interface = Get-NetIPAddress | ? AddressFamily -eq IPv4 | ? InterfaceAlias -eq $nicName;
	$currentIp = $interface.IPAddress;
	$currentPrefixLength = $interface.PrefixLength;
	$currentInterfaceIndex = $interface.InterfaceIndex;
	Write-Host "Updating $nicName with values: $currentIp | $currentPrefixLength | $currentInterfaceIndex";

	Set-NetIPInterface -InterfaceIndex $currentInterfaceIndex -Dhcp Disabled -AddressFamily IPv4; 

	Remove-NetIPAddress -InterfaceIndex $currentInterfaceIndex -AddressFamily IPv4;
	New-NetIPAddress -InterfaceIndex $currentInterfaceIndex -IPAddress $currentIp -PrefixLength $currentPrefixLength -DefaultGateway $defaultGateway -PolicyStore "ActiveStore";
	Set-DnsClientServerAddress -InterfaceIndex $currentInterfaceIndex -ServerAddresses ("168.63.129.16");
}

function Fix-NetworkAdapters-Gateway()
{
	$adapters = Get-NetAdapter
	
	foreach($adapter in $adapters)
	{
		$adapterRsc = Get-NetAdapterRsc -Name $adapter.Name -ErrorAction Ignore
		
		if($adapterRsc -eq $null -or $adapterRsc.IPv4OperationalState -eq $false)
		{
			Write-Host "Interface skipped!. No IpConfig has been found for adapter with InterfaceIndex equals to: "+ $adapter.InterfaceIndex -f Magenta;
			continue;
		}
		$netRoute = Get-NetRoute -InterfaceIndex $adapter.InterfaceIndex -NextHop $defaultGateway -ErrorAction Ignore;
		if($netRoute -eq $null)
		{
			New-NetRoute -InterfaceIndex $adapter.InterfaceIndex  -DestinationPrefix "0.0.0.0/0" -NextHop $defaultGateway;
			Write-Host "Default gateway created in Interface"+ $adapter.InterfaceIndex -f DarkGreen;
		}
		else
		{
			Write-Host "Default gateway already exists in Interface "+$adapter.InterfaceIndex;
		}
	}
}

function Update-SwaggerConfiguration()
{
	param([string]$configFilePath="")
	if($configFilePath -eq "" -or $configFilePath -eq $null )
	{
		Write-Host "File Path can't be null" -ForegroundColor Magenta;
		return;
	}
	if(!(Test-Path -Path $configFilePath))
	{
		Write-Host "Unable to find document: $configFilePath" -ForegroundColor Magenta;
		return;
	}
	$messageText = "";
	[xml]$file = Get-Content $configFilePath;
	$node1 = $file.SelectSingleNode("descendant::system.serviceModel/services/service[@name=""SwaggerWcf.SwaggerWcfEndpoint""]/endpoint[@contract=""SwaggerWcf.ISwaggerWcfEndpoint""]");
	if($node1 -eq $null)
	{
		Write-Host "Unable to find swagger endpoint node in document $configFilePath" -ForegroundColor Magenta;
	}
	else
	{
		$node1.SetAttribute("address", $docsApiUrl);
		$messageText += "Swagger endpoint address in document $configFilePath succesfully update with value: $docsApiUrl `n";
	}
	
	$node2 = $file.SelectSingleNode("descendant::swaggerwcf/settings/setting[@name=""Host""]");

	if($node2 -eq $null)
	{
		Write-Host "Unable to find swagger setting node in document $configFilePath" -ForegroundColor Magenta;
	}
	else
	{
		$node2.SetAttribute("value", $apiServiceHostName);
		$messageText += "Swagger setting node in document $configFilePath succesfully update with value: $apiServiceHostName `n";
	}

	$file.Save($configFilePath);
	Write-Host $messageText -ForegroundColor DarkGreen;
}

function Configure-Ws-Http-Binding()
{
	param([string]$configFilePath="")
	if($configFilePath -eq "" -or $configFilePath -eq $null )
	{
		Write-Host "File Path can't be null" -ForegroundColor Magenta;
		return;
	}
	if(!(Test-Path -Path $configFilePath))
	{
		Write-Host "Unable to find document: $configFilePath" -ForegroundColor Magenta;
		return;
	}
	$credentialType = "Windows"
	if($deploymentType -eq "Cloud" -or $deploymentType -eq "PrivateCloud" )
	{
		$credentialType = "None"
	}

	$messageText = "";
	[xml]$file = Get-Content $configFilePath;

	$node1 = $file.SelectSingleNode("descendant::wsHttpBinding/binding[@name=""AgilePointWsHttpBinding""]/security/transport");
	if($node1 -eq $null)
	{
		Write-Host "Unable to find transport node in wsHttpBinding node in document $configFilePath" -ForegroundColor Magenta;
	}
	else
	{
		$node1.SetAttribute("clientCredentialType", $credentialType);
		$node1.SetAttribute("proxyCredentialType", $credentialType);
		$messageText += "Transport mode succesfully updated in document $configFilePath succesfully update with value: $credentialType `n";
	}
	$file.Save($configFilePath);
	Write-Host $messageText -ForegroundColor DarkGreen;
}

function Configure-AzureServiceBus()
{
	param([string]$configFilePath="")
	if($configFilePath -eq "" -or $configFilePath -eq $null )
	{
		Write-Host "File Path can't be null" -ForegroundColor Magenta;
		return;
	}
	if(!(Test-Path -Path $configFilePath))
	{
		Write-Host "Unable to find document: $configFilePath" -ForegroundColor Magenta;
		return;
	}
	[xml]$file = Get-Content $configFilePath;
	$keysHash  = @{"topicPrefix" = $hostName;"connectionString" = $azureServiceBusConnectionString};
	$messageText = "";
	foreach($key in $keysHash.Keys)
	{
		$node = $file.SelectSingleNode("descendant::signalR.Scaleout.AzureServiceBus/add[@key=""$key""]");
		if($node -eq $null)
		{
			Write-Host "Unable to find node $key in document $configFilePath" -ForegroundColor Magenta;
			continue;
		}
		$keyValue = $keysHash.Get_Item($key);
		$node.SetAttribute("value", $keyValue);
		$messageText += "Key $key in document $configFilePath Succesfully update with value: $keyValue`n"; 
	}
	if(($azureServiceBusConnectionString -eq $null) -or ($azureServiceBusConnectionString -eq "") )
	{
		$node = $file.SelectSingleNode("descendant::unity/container/register[@type=""AgilePoint.SignalR.Scaleout.Contracts.IScaleoutManager, AgilePoint.SignalR.Scaleout.Contracts""]");
		if($node -ne $null)
		{
			$parentNode = $file.SelectSingleNode("descendant::unity/container")
			$parentNode.RemoveChild($node)
			Write-Host "'register' node for Azure Service Bus has been Removed" -ForegroundColor Magenta
		}
		else
		{
			Write-Host "'register' node for Azure Service Bus is not Found!" -ForegroundColor Magenta
		}
	}
	else
	{
		$node = $file.SelectSingleNode("descendant::unity/container/register[@type=""AgilePoint.SignalR.Scaleout.Contracts.IScaleoutManager, AgilePoint.SignalR.Scaleout.Contracts""]");
		if($node -eq $null)
		{
			Write-Host "'register' node for Azure Service Bus is not Found! Adding..." -ForegroundColor Magenta
			$newItemtoAdd = $file.CreateElement('register')
			$newItemtoAdd.SetAttribute("type","AgilePoint.SignalR.Scaleout.Contracts.IScaleoutManager, AgilePoint.SignalR.Scaleout.Contracts")
			$newItemtoAdd.SetAttribute("mapTo","AgilePoint.SignalR.Scaleout.Forwarding.ForwardingScaleoutManager, AgilePoint.SignalR.Scaleout.Forwarding")
			$lifetimeNode = $file.CreateElement('lifetime')
			$lifetimeNode.SetAttribute("type","singleton")
			$newItemtoAdd.AppendChild($lifetimeNode)
			$parentNode = $file.SelectSingleNode("descendant::unity/container")
			$parentNode.AppendChild($newItemtoAdd)								
			Write-Host "'register' node for Azure Service Bus has been add" -ForegroundColor DarkGreen
		}
	}
	$file.Save($configFilePath);
	Write-Host $messageText -ForegroundColor DarkGreen;
}

function Configure-Site-Custom-Errors()
{
	param([string]$configFilePath="",[ValidateSet('Off', 'RemoteOnly')][string]$errorMode)
	if(!(Test-Path -Path $configFilePath))
	{
		Write-Host "Unable to find document: $configFilePath" -ForegroundColor Magenta;
		return;
	}
	[xml]$file = Get-Content $configFilePath;

	$node = $file.SelectSingleNode("descendant::system.web/customErrors");
	if($node -eq $null)
	{
		Write-Host "Unable to find subnode 'customErrors' for node 'system.web' in document $configFilePath" -ForegroundColor Magenta;
		return;
	}

	$node.SetAttribute("mode", $errorMode);

	$file.Save($configFilePath);
	Write-Host "Custom Error in document $configFilePath succesfully update with value: $errorMode" -ForegroundColor DarkGreen;
}

function Configure-Federation-Connection()
{
	param([string]$configFilePath="",[string]$realm, [string]$endPoint, [string]$subDomain, [string]$issuer = "")
	if(!(Test-Path -Path $configFilePath))
	{
		Write-Host "Unable to find document: $configFilePath" -ForegroundColor Magenta;
		return;
	}
	[xml]$file = Get-Content $configFilePath;

	$node = $file.SelectSingleNode("descendant::federationConfiguration/wsFederation");
	if($node -eq $null)
	{
		Write-Host "Unable to find subnode 'wsFederation' for node 'federationConfiguration' in document $configFilePath" -ForegroundColor Magenta;
		return;
	}

	$endPoints = @("$endPoint","$endPoint/","$endPoint/$subDomain","$endPoint/$subDomain/");

	$node.SetAttribute("reply", "$endPoint/$subDomain");
	if($issuer -ne "")
	{
		$node.SetAttribute("issuer", "$issuer");
	}
	if($realm -ne "")
	{
		$node.SetAttribute("realm", "$realm");
	}

	$node = $file.SelectSingleNode("descendant::securityTokenHandlerConfiguration/audienceUris/add")
	if($node -eq $null)
	{
		Write-Host "Unable to find subnode 'add' for node 'securityTokenHandlerConfiguration/audienceUris' in document $configFilePath" -ForegroundColor Magenta;
		return;
	}

	if($realm -ne "")
	{
		$node.SetAttribute("value", "$realm");
	}

	$file.Save($configFilePath);
	Write-Host "Reply URL in document $configFilePath succesfully update with value: $endpoint/$subDomain" -ForegroundColor DarkGreen;
}

function Get-Last-AgileXRM-Online-Cert-Thumbprint()
{
	param([string]$certSubjectName = $certificateSubjectName)

    $certificate = Get-ChildItem -path cert:\LocalMachine\My | where{ $_.Subject -eq $certSubjectName } |  Sort-Object -Property NotAfter -Descending  | Select-Object -First 1;
	$certHash = $certificate.Thumbprint;
	return $certHash;
}

function Get-Last-AgileXRM-Local-Cert-Thumbprint()
{
    $certificate = Get-ChildItem -path cert:\LocalMachine\My | where{ $_.Subject -like "*agilexrm.local" } |  Sort-Object -Property NotAfter -Descending  | Select-Object -First 1;
	$certHash = $certificate.Thumbprint;
	return $certHash;
}

function Delete-sslcert-entries()
{
	$command = "http delete sslcert ipport=0.0.0.0:443";
	Write-Host "Delete-sslcert-entries>> Command to execute: $command";
	$command | netsh;

	$command = "http delete sslcert hostnameport=*.api.$domainUrl`:$wcfServicePort";
	Write-Host "Delete-sslcert-entries>> Command to execute: $command";
	$command | netsh;

	$command = "http delete sslcert hostnameport=*.api.$domainUrl`:$restServicePort";
	Write-Host "Delete-sslcert-entries>> Command to execute: $command";
	$command | netsh;

	$command = "http delete sslcert hostnameport=*.api.$domainUrl`:13499";
	Write-Host "Delete-sslcert-entries>> Command to execute: $command";
	$command | netsh;

	$command = "http delete sslcert hostnameport=pool499.api.agilexrmonline.com:$wcfServicePort";
	Write-Host "Delete-sslcert-entries>> Command to execute: $command";
	$command | netsh;

	$command = "http delete sslcert hostnameport=pool499.api.agilexrmonline.com:443";
	Write-Host "Delete-sslcert-entries>> Command to execute: $command";
	$command | netsh;

	$command = "http delete sslcert hostnameport=pool499.api.agilexrmonline.com:13499";
	Write-Host "Delete-sslcert-entries>> Command to execute: $command";
	$command | netsh;

	$command = "http delete sslcert hostnameport=nav499.agilexrmonline.com:443";
	Write-Host "Delete-sslcert-entries>> Command to execute: $command";
	$command | netsh;

	$command = "http delete sslcert hostnameport=pool499.reports.agilexrmonline.com:443";
	Write-Host "Delete-sslcert-entries>> Command to execute: $command";
	$command | netsh;
	
	$command = "http delete sslcert hostnameport=pool499.portal.agilexrmonline.com:443";
	Write-Host "Delete-sslcert-entries>> Command to execute: $command";
	$command | netsh;
	
	$command = "http delete sslcert hostnameport=*.external.$domainUrl`:$externalSitePort";
	Write-Host "Delete-sslcert-entries>> Command to execute: $command";
	$command | netsh;
	
	$command = "http delete sslcert hostnameport=*.public.$domainUrl`:$publicSitePort";
	Write-Host "Delete-sslcert-entries>> Command to execute: $command";
	$command | netsh;
	
	$command = "http delete sslcert ipport=10.0.0.4:443";
	Write-Host "Delete-sslcert-entries>> Command to execute: $command";
	$command | netsh;

	$command = "http delete sslcert ipport=10.0.0.6:443";
	Write-Host "Delete-sslcert-entries>> Command to execute: $command";
	$command | netsh;

	$command = "http delete sslcert ipport=10.0.0.7:443";
	Write-Host "Delete-sslcert-entries>> Command to execute: $command";
	$command | netsh;

	$command = "http delete sslcert ipport=10.0.0.8:443";
	Write-Host "Delete-sslcert-entries>> Command to execute: $command";
	$command | netsh;

	$command = "http delete sslcert ipport="+$primaryNicIpAddress+":443";
	Write-Host "Delete-sslcert-entries>> Command to execute: $command";
	$command | netsh;

	$command = "http delete sslcert ipport="+$secondaryNicIpAddress+":443";
	Write-Host "Delete-sslcert-entries>> Command to execute: $command";
	$command | netsh;

	$command = "http delete sslcert ipport="+$thirdNicIpAddress+":443";
	Write-Host "Delete-sslcert-entries>> Command to execute: $command";
	$command | netsh;

	$command = "http delete sslcert ipport="+$fourthNicIpAddress+":443";
	Write-Host "Delete-sslcert-entries>> Command to execute: $command";
	$command | netsh;

	$command = "http delete sslcert ipport="+$fifthNicIpAddress+":443";
	Write-Host "Delete-sslcert-entries>> Command to execute: $command";
	$command | netsh;
	
	$hostnameport = "$wsServiceHostName`:$wcfServicePort";
	$command = "http delete sslcert hostnameport="+$hostnameport;
	Write-Host "Delete-sslcert-entries>> Command to execute: $command";
	$command | netsh;

	$hostnameport = "$restServiceHostName`:$restServicePort";
	$command = "http delete sslcert hostnameport="+$hostnameport;
	Write-Host "Delete-sslcert-entries>> Command to execute: $command";
	$command | netsh;

	$hostnameport = $apiServiceHostName+":13499";
	$command = "http delete sslcert hostnameport="+$hostnameport;
	Write-Host "Delete-sslcert-entries>> Command to execute: $command";
	$command | netsh;

	$hostnameport = "$agileXrmHostName`:$regularSitePort";
	$command = "http delete sslcert hostnameport="+$hostnameport;
	Write-Host "Delete-sslcert-entries>> Command to execute: $command";
	$command | netsh;

	$hostnameport = $reportsHostName+":443";
	$command = "http delete sslcert hostnameport="+$hostnameport;
	Write-Host "Delete-sslcert-entries>> Command to execute: $command";
	$command | netsh;

	$hostnameport = $adminPortalHostName;
	$command = "http delete sslcert hostnameport="+$hostnameport;
	Write-Host "Delete-sslcert-entries>> Command to execute: $command";
	$command | netsh;
}
function Add-sslcert-entry()
{
	param([string]$property="hostnameport",[string]$hostnameport, [string]$certHash, [string]$appId )
   
	$getCommand = "http show sslcert $property=$hostnameport"
	Write-Host "Add-sslcert-entry>> Get Command to execute: $getCommand";

	$getOutput = $getCommand | netsh;
	if(!$getOutput.Contains("The system cannot find the file specified."))
	{
		Write-host "Add-sslcert-entry>> Hostname $hostnameport has been found. Deleting..." -ForegroundColor DarkCyan
		$deleteCommand = "http delete sslcert $property=$hostnameport"
		Write-Host "Add-sslcert-entry>> Delete Command to execute: $deleteCommand"
		$deleteCommand | netsh
	}
	$addCommand = "http add sslcert $property=$hostnameport certhash=$certHash appid=$appId certstorename=My";
	Write-Host "Add-sslcert-entry>> Command to execute: $addCommand";
	$addCommand | netsh;
   
}

function Add-sslcert-entries()
{
	param([string]$certHash)

	$ipport = $primaryNicIpAddress+":443";
	Add-sslcert-entry -property "ipport" -hostnameport $ipport -certHash $certHash -appId $appId

	if($deploymentMode -eq "ST")
	{
    	$hostnameport = "$agileXrmHostName`:$regularSitePort"
		Add-sslcert-entry -hostnameport $hostnameport -certHash $certHash -appId $appId

    	$hostnameport = "$externalAXrmHostName`:$externalSitePort"
		Add-sslcert-entry -hostnameport $hostnameport -certHash $certHash -appId $appId
	
    	$hostnameport = "$publicAXrmHostName`:$publicSitePort"
		Add-sslcert-entry -hostnameport $hostnameport -certHash $certHash -appId $appId
	}
	else
	{
		$hostnameport =[string]::Format("*.{0}:{1}", $domainUrl, "443")
		Add-sslcert-entry -hostnameport $hostnameport -certHash $certHash -appId $appId

		$hostnameport =[string]::Format("*.{0}.{1}:{2}",$externalAlias,$domainUrl,"443")
		Add-sslcert-entry -hostnameport $hostnameport -certHash $certHash -appId $appId
	
		$hostnameport =[string]::Format("*.{0}.{1}:{2}",$publicAlias,$domainUrl,"443")
		Add-sslcert-entry -hostnameport $hostnameport -certHash $certHash -appId $appId

		$ipport = $secondaryNicIpAddress+":443";
		Add-sslcert-entry -property "ipport" -hostnameport $ipport -certHash $certHash -appId $appId

		$ipport = $thirdNicIpAddress+":443";
		Add-sslcert-entry -property "ipport" -hostnameport $ipport -certHash $certHash -appId $appId

		$ipport = $fourthNicIpAddress+":443";
		Add-sslcert-entry -property "ipport" -hostnameport $ipport -certHash $certHash -appId $appId

		$ipport = $fifthNicIpAddress+":443";
		Add-sslcert-entry -property "ipport" -hostnameport $ipport -certHash $certHash -appId $appId
	}

}

function Add-sslcert-APIentries()
{
	param([string]$certHash)

	$hostnameport = "$wsServiceHostName`:$wcfServicePort";
	Add-sslcert-entry -hostnameport $hostnameport -certHash $certHash -appId $appId

	$hostnameport = "$restServiceHostName`:$restServicePort";
	Add-sslcert-entry -hostnameport $hostnameport -certHash $certHash -appId $appId

	$hostnameport = $apiServiceHostName+":13499";
	Add-sslcert-entry -hostnameport $hostnameport -certHash $certHash -appId $appId

	if($deploymentMode -ne "ST")
	{
		$hostnameport =[string]::Format("*.{0}.{1}:{2}",$apiAlias,$domainUrl,"443")
		Add-sslcert-entry -hostnameport $hostnameport -certHash $certHash -appId $appId

		$hostnameport =[string]::Format("*.{0}.{1}:{2}",$apiAlias,$domainUrl,$wcfServicePort)
		Add-sslcert-entry -hostnameport $hostnameport -certHash $certHash -appId $appId

		$hostnameport =[string]::Format("*.{0}.{1}:{2}",$apiAlias,$domainUrl,"13499")
		Add-sslcert-entry -hostnameport $hostnameport -certHash $certHash -appId $appId
	}

}

function Add-sslcert-AdminPortalEntries()
{
	param([string]$certHash)

	$hostnameport = $adminPortalHostName;
	Add-sslcert-entry -hostnameport $hostnameport -certHash $certHash -appId $appId

	if($deploymentMode -ne "ST")
	{
		$hostnameport =[string]::Format("*.{0}.{1}:{2}",$adminPortalAlias,$domainUrl,"443")
		Add-sslcert-entry -hostnameport $hostnameport -certHash $certHash -appId $appId
	}
}

function Configure-Services-SSLCert()
{
	$certHash = Get-Last-AgileXRM-Online-Cert-Thumbprint;
	$apiCertHash = Get-Last-AgileXRM-Online-Cert-Thumbprint -certSubjectName $certificateApiSubjectName
	$adminPortalCertHash = Get-Last-AgileXRM-Online-Cert-Thumbprint -certSubjectName $certificateAdminPortalSubjectName

	#delete
	Delete-sslcert-entries;

    # Add
	Add-sslcert-entries -certHash $certHash;
	Add-sslcert-APIentries -certHash $apiCertHash;
	Add-sslcert-AdminPortalEntries -certHash $adminPortalCertHash;
	
    #Add PrivateKey Read Permission for APService user 	
	
	#Set permissions to AgileXRMOnline Certificate
	[string]$permission_=[System.Security.AccessControl.FileSystemRights]::Read;
	[string]$certStoreLocation_="Localmachine\My";
	[string]$userName_= $env:computername+"\APservice";
	[string]$everyone= "everyone";

	[string]$adminUserName = ".\APService";
	if($vmBelongsToDomain)
	{
		$adminUserName = [string]::Format("{0}\{1}",$apServiceAccountDomain, $apServiceAccountUser);
		$userName_ = $adminUserName;
	}
	$securePass = ConvertTo-SecureString -String $global:apServiceAccountPassword -AsPlainText -Force;
	$adminCredential = New-Object System.Management.Automation.PSCredential $adminUserName, $securePass

	Invoke-Command -Credential $adminCredential -ComputerName $env:COMPUTERNAME -ScriptBlock $executionCommand  -ArgumentList $userName_,$permission_,$certStoreLocation_,$certHash;
	Invoke-Command -Credential $adminCredential -ComputerName $env:COMPUTERNAME -ScriptBlock $executionCommand  -ArgumentList $userName_,$permission_,$certStoreLocation_,$apiCertHash;
	Invoke-Command -Credential $adminCredential -ComputerName $env:COMPUTERNAME -ScriptBlock $executionCommand  -ArgumentList $userName_,$permission_,$certStoreLocation_,$adminPortalCertHash;

	if($deploymentType -eq "Cloud")
	{
		$certHashLocal = Get-Last-AgileXRM-Local-Cert-Thumbprint;
		Invoke-Command -Credential $adminCredential  -ComputerName $env:COMPUTERNAME -ScriptBlock $executionCommand  -ArgumentList $everyone,$permission_,$certStoreLocation_,$certHashLocal;
	}
}

function Configure-AgilePoint-Client()
{
	param([string]$configFilePath,[string]$clientName, $endPoint)
	if(!(Test-Path -Path $configFilePath))
	{
		Write-Host "Unable to find document: $configFilePath" -ForegroundColor Magenta;
		return;
	}

	[xml]$file = Get-Content $configFilePath;
	$node = $file.SelectSingleNode("descendant::client/endpoint[@name=""$clientName""]");
	if($node -eq $null)
	{
		Write-Host "Unable to find node $clientName in document $configFilePath" -ForegroundColor Magenta;
		return;
	}

	$node.SetAttribute("address", $endPoint);

	$file.Save($configFilePath);
	Write-Host "Client $clientName in document $configFilePath succesfully update with value: $endpoint" -ForegroundColor DarkGreen;
}
function Configure-AgilePoint-Services()
{
	param([string]$configFilePath,[string]$serviceName, $endPoints)
	if(!(Test-Path -Path $configFilePath))
	{
		Write-Host "Unable to find document: $configFilePath" -ForegroundColor Magenta;
		return;
	}

	[xml]$file = Get-Content $configFilePath;
	$node = $file.SelectSingleNode("descendant::service[@name=""$serviceName""]");
	if($node -eq $null)
	{
		Write-Host "Unable to find node $serviceName in document $configFilePath" -ForegroundColor Magenta;
		return;
	}
	$node.host.baseAddresses.RemoveAll();

	foreach($endPoint in $endPoints)
	{
		$myNode = $file.CreateElement("add");
		$myNode.SetAttribute("baseAddress", $endPoint);
		$node.host.FirstChild.AppendChild($myNode);
	}

	$file.Save($configFilePath);
	Write-Host "Key $keyName in document $configFilePath Succesfully update with value: $keyValue" -ForegroundColor DarkGreen;
}

#Ascentn.AgilePoint.WCFService.exe.config

function Modify-AppSetings-Key()
{
	param([string]$configFilePath, [string]$keyName, [string]$keyValue, [bool]$createNode=$false)
	if(!(Test-Path -Path $configFilePath))
	{
		Write-Host "Unable to find document: $configFilePath" -ForegroundColor Magenta;
		return;
	}

	[xml]$file = Get-Content $configFilePath;
	
	$node = $file.SelectSingleNode("descendant::add[@key=""$keyName""]");
	if($node -eq $null)
	{
		Write-Host "Unable to find node $keyName in document $configFilePath" -ForegroundColor Magenta;
		if($createNode)
		{
			$addNode = $file.CreateNode("element","add","")
			$addNode.SetAttribute("key",$keyName)
			$addNode.SetAttribute("value",$keyValue)
			$file.configuration.appSettings.AppendChild($addNode)
		}
		else
		{
			return;
		}
	}
	else
	{
		$node.SetAttribute("value", $keyValue)
	}

	
	$file.Save($configFilePath);
	Write-Host "Key $keyName in document $configFilePath Succesfully update with value: $keyValue" -ForegroundColor DarkGreen;
}

function Configure-OrgUrl-Section()
{
	param([string]$configFilePath, [string]$orgUniqueId ="ORGXXXXX", [string]$orgFullUrl = "https://myorg.crm4.dynamics.com")

	if($deploymentType -ne "PrivateCloud")
	{
		Write-Host "Configure-OrgUrl-Section only applies to Private Cloud and this setup is for : $deploymentType" -ForegroundColor Magenta;
		return;
	}
	if(!(Test-Path -Path $configFilePath))
	{
		Write-Host "Unable to find document: $configFilePath" -ForegroundColor Magenta;
		return;
	}

	$sectionName = "AgileXRM.OrganizationUrls"

	[xml]$file = Get-Content $configFilePath;
	$orgUrlsSection =  $file.SelectSingleNode("descendant::section[@name=""$sectionName""]")
	if($orgUrlsSection -eq $null)
	{
		$sectionNode =$file.CreateNode("element","section","")
		$sectionNode.SetAttribute("name",  $sectionName)
		$sectionNode.SetAttribute("type", "System.Configuration.NameValueSectionHandler")

		$configSectionsNode = $file.configuration.configSections

		if($configSectionsNode -eq $null)
		{
			Write-host "configSections node not found" -ForegroundColor Magenta
			$configSectionsNode = $file.CreateNode("element","configSections","")
			$file.configuration.PrependChild($configSectionsNode)
		}
		$configSectionsNode.AppendChild($sectionNode)
		$file.configuration.PrependChild($configSectionsNode)
	}

	$axrmOrgsNodeName = "AgileXRM.OrganizationUrls"
	$axrmOrgsNode = $file.configuration.SelectSingleNode($axrmOrgsNodeName)
	if($axrmOrgsNode -eq $null)
	{
		Write-host "AgileXRM.OrganizationUrls node not found" -ForegroundColor Magenta
		$axrmOrgsNode = $file.CreateNode("element",$axrmOrgsNodeName,"")
		$file.configuration.AppendChild($axrmOrgsNode)
	}
	else
	{
		$axrmOrgsNode.RemoveAll();
	}

	$orgsUniqueId = $orgUniqueId.split(";");
	$orgsFullUrl = $orgFullUrl.split(";");
	for ($counter=0; $counter -lt $orgsUniqueId.Length; $counter++)
	{
		$currentOrgUniqueId = $orgsUniqueId[$counter];
		$currentOrgFullUrl =  $orgsFullUrl[$counter]; 
		
		$addOrgNode = $axrmOrgsNode.SelectSingleNode("descendant::add[@key=""$currentOrgUniqueId""]");
		if($addOrgNode -ne $null)
		{
			$addOrgNode.SetAttribute("value", $currentOrgFullUrl)
		}
		else
		{
			$addOrgNode = $file.CreateNode("element","add","")
			$addOrgNode.SetAttribute("key",$currentOrgUniqueId)
			$addOrgNode.SetAttribute("value",$currentOrgFullUrl)
			$axrmOrgsNode.AppendChild($addOrgNode)
			$file.configuration.AppendChild($axrmOrgsNode)
		}
	}

	$file.Save($configFilePath);
}

function Configure-AgileDialogs-EnvisionService()
{
	param([string]$configFilePath)
	if(!(Test-Path -Path $configFilePath))
	{
		Write-Host "Unable to find document: $configFilePath" -ForegroundColor Magenta;
		return;
	}
	$behaviorConfiguration = "CommonServiceBehavior"
	$binding = "basicHttpBinding"
	$bindingConfiguration ="basicHttpsEnvision"
	if($deploymentType -eq "Cloud" -or  $deploymentType -eq "PrivateCloud" )
	{
		$behaviorConfiguration = "EnvisionBearerTokenBehavior";
		$binding = "wsHttpBinding"
		$bindingConfiguration ="EnvisionWsHttpsBinding"
	}

	[xml]$file = Get-Content $configFilePath;
	$serviceNode = $file.SelectSingleNode("descendant::service[@name=""AgileDialogsWeb.Envision.EnvisionService""]");
	$serviceNode.SetAttribute("behaviorConfiguration", $behaviorConfiguration)

	$endPointNode = $file.SelectSingleNode("descendant::endpoint[@name=""envisionSvcEp""]");
	$endPointNode.SetAttribute("binding", $binding)
	$endPointNode.SetAttribute("bindingConfiguration", $bindingConfiguration)

	#Temp Workaround for Single Tenant Environments	
	$basicBindingNode = $file.SelectSingleNode("descendant::binding[@name=""basicHttpsEnvision""]")
	$basicBindingNode.security.transport.SetAttribute("clientCredentialType", "None")

	$file.Save($configFilePath);
}

function Set-SQLServer-Alias-Instance()
{
	param([string]$sqlServerAliasPath )
	
	if($sqlServer -eq "")
	{
         $sqlServer = "SQLW$regionNumber$poolNumber-VM";
	}
	$dataBaseValue = "DBMSSOCN,$sqlServer,$sqlServerPort";

	if(Test-Path -Path $sqlServerAliasPath)
	{
		Set-ItemProperty -Path $sqlServerAliasPath -Name $sqlServerAliasName -Value $dataBaseValue
		Write-Host "SQL Server Alias Path $sqlServerAliasPath successfully changed!";
	}
	else
	{
		Write-Host "Unable to find $sqlServerAliasPath in the registry" -ForegroundColor DarkYellow;
	}

}

function Modify-XML-Node()
{
	param([string]$xmlFilePath, [string]$nodePath, [string]$nodeName, [string]$nodeValue)
	if(!(Test-Path -Path $xmlFilePath))
	{
		Write-Host "Unable to find document: $xmlFilePath" -ForegroundColor Magenta;
		return;
	}

	[xml]$file = Get-Content $xmlFilePath;
	$node = $file.SelectSingleNode("descendant::Property[Name=""$nodeName""]");
	$node.Value = $nodeValue;
	$file.Save($xmlFilePath);
	Write-Host "Document $xmlFilePath node '$nodeName' succesfully updated with value: $nodeValue" -ForegroundColor DarkGreen;
}

function Modify-WebSite-Binding()
{
	param([string]$siteName, [string]$hostName="", [string]$ipAddress = "", [string]$bindingPort = "")
	$binding = Get-WebBinding -Name $siteName -Protocol "https";
	if($binding -eq $null)
	{
		Write-Warning "Unable to find $siteName for https protocol";
		return;
	}
	$currentBindingInfo = $binding.bindingInformation;
	$parameters = $binding.bindingInformation.Split(':');
	$sslFlagsValue ="1"

	if(!($ipAddress -eq ""))
	{
		$parameters[0] = $ipAddress;
		$parameters[2] = "";
		$sslFlagsValue ="0"
	}
	if(!($hostName -eq ""))
	{
		$parameters[0] = "";
		$parameters[2] = $hostName;
		$sslFlagsValue ="1"
	}
	if(!($bindingPort -eq ""))
	{
		$parameters[1] = $bindingPort;
	}
	
	$bindingInfo = 	[string]::Join(':',$parameters);
	Set-WebBinding -Name $siteName -BindingInformation $currentBindingInfo -PropertyName "sslFlags" -Value $sslFlagsValue ;
	Set-WebBinding -Name $siteName -BindingInformation $currentBindingInfo -PropertyName "BindingInformation" -Value $bindingInfo ;
	Write-Host "Site $siteName has been successfully modified with binding value $bindingInfo !" -ForegroundColor DarkGreen;
}

function Update-AppImpersonationEntry-File()
{
	#Update AppImpersonationEntry XML File
	$appEntryXML = "$agilePointServerInstanceFolder\bin\AppImpersonationEntry.xml"
	$newIdentity = "$env:COMPUTERNAME\$apServiceAccountUser"
	$defaultIdentity = "$apServiceAccountDomain\$apServiceAccountUser"
	$singleTenantAdmin = "$apServiceAccountDomain\$singleTenantAdminUser"
	$singleTenantAdminLocalMachine = "$env:COMPUTERNAME\$singleTenantAdminUser"
	$appNames = @("TenantRouter-Plugin", "AgileDialogs", "XRMProcessViewer", "AgilePoint.NX.EFormsApp", "CRMIntegration", "AgilePoint Envision", "SPSIntegration")


	$identities = @($defaultIdentity)

	if($vmBelongsToDomain -ne $true)
	{
		$identities+=$newIdentity
	}

	if($deploymentMode -eq "ST" -and $singleTenantAdminUser.ToLower() -ne $apServiceAccountUser.ToLower() )
	{
		$identities+=$singleTenantAdmin
		if($vmBelongsToDomain -ne $true)
		{
			$identities+=$singleTenantAdminLocalMachine
		}
	}

	[xml]$file = Get-Content $appEntryXML

	foreach($appName in $appNames)
	{
		$node = $file.ApplicationEntries.Application | where {$_.Name -eq $appName}
		if($node -ne $null)
		{
			$node.Impersonator = [string]::Join(";", $identities)
			Write-Host "Node '$appName' is found and updated!" -ForegroundColor DarkGreen;
		}
		else
		{
			Write-Host "Node '$appName' has not found!!" -ForegroundColor Yellow;
		}
	}

	$file.Save($appEntryXML);
	Write-Host "Function 'Update-AppImpersonationEntry-File' is done";
}

function Update-AppPool-User()
{
	param([string]$apAppPoolName = "AgilePointAppPool", [string]$fullUserName = "$apServiceAccountDomain\$apServiceAccountUser", [bool]$applyAdvancedSettings=$true)

	#Perform iisreset to avoid issues with error 'Keyset does not exist', tha forces generate Crypto/RSA files again
	iisreset

	Write-Host "Update-AppPool-User>> Updating PoolName '$apAppPoolName' for user $fullUserName. Wait..." -ForegroundColor Yellow;
	
	Update-IISAppPoolConfigAttribute -appPoolName $apAppPoolName -elementName "processModel" -attributeName "userName" -attributeValue $fullUserName
	Update-IISAppPoolConfigAttribute -appPoolName $apAppPoolName -elementName "processModel" -attributeName "password" -attributeValue $global:apServiceAccountPassword
	Update-IISAppPoolConfigAttribute -appPoolName $apAppPoolName -elementName "processModel" -attributeName "identitytype" -attributeValue "SpecificUser"
	Write-Host "Update-AppPool-User>> Properties set for ProcessModel" -ForegroundColor DarkGreen;
	
	if($applyAdvancedSettings)
	{
		Write-Host "Update-AppPool-User>>Setting Advanced properties. Wait..." -ForegroundColor DarkCyan;
		#Set Max Memory for pool:
		$totalMemory =  Get-WmiObject -Class Win32_OperatingSystem | % {$_.TotalVisibleMemorySize}
		$appPool = Get-IISConfigSection -SectionPath "system.applicationHost/applicationPools" | Get-IISConfigCollection  | Get-IISConfigCollectionElement -ConfigAttribute @{"name"="AgilePointAppPool"}
		if($appPool -eq $null)
		{
			Write-Warning "Unable to find any pool with name '$appPoolName'. Ensure your config is right otherwise ignore this message";
		}
		else
		{
			$periodicRestart = Get-IISConfigElement -ConfigElement $appPool -ChildElementName "Recycling" | Get-IISConfigElement -ChildElementName "periodicRestart"
			Set-IISConfigAttributeValue -ConfigElement $periodicRestart -AttributeName "privateMemory" -AttributeValue ([int][Math]::Round(($totalMemory/2))) 
			Write-Host "Update-AppPool-User>>Advanced properties set." -ForegroundColor DarkGreen
		}
	}
	if(Test-Path IIS:\AppPools\$apAppPoolName)
	{
		Start-WebAppPool -Name $apAppPoolName -ErrorAction Continue
	}
}

function Update-IISAppPoolConfigAttribute([string]$appPoolName, [string]$elementName, [string]$attributeName, [string]$attributeValue)
{
	$appPool = Get-IISConfigSection -SectionPath "system.applicationHost/applicationPools" | Get-IISConfigCollection  | Get-IISConfigCollectionElement -ConfigAttribute @{"name"=$appPoolName}
	if($appPool -eq $null)
	{
		Write-Warning "Unable to find any pool with name '$appPoolName'. Ensure your config is right otherwise ignore this message";
		return;
	}
    $element = Get-IISConfigElement -ConfigElement $appPool -ChildElementName $elementName
	Set-IISConfigAttributeValue -ConfigElement $element -AttributeName $attributeName -AttributeValue $attributeValue
}

function Start-Services()
{
	# Start W3SVC Service
	$webService = Get-Service -Name "W3SVC"
	Set-Service -Name $webService.Name -Status Running -StartMode Automatic

	#Start AgilePoint Service
	$apService = Get-Service -Name "AgilePointServerInstance"
	Set-Service -Name $apService.Name -Status Running -StartMode Automatic
}

function Check-AP-Service-Status()
{
	Write-Host "Checking AP Service Status....";
	$apService = Get-Service -Name "AgilePointServerInstance"
	return $apService.Status -eq "Running";
}

function Update-Hosts-File()
{
	$path = "$env:windir\System32\drivers\etc\hosts";

	(Get-Content $path ) | Select-String -Pattern "10.0"  -NotMatch | Select-String -Pattern "127.0.0.1" -NotMatch |  Set-Content $path
	Add-Content $path "127.0.0.1 $netTcpRaw"
	Add-Content $path "127.0.0.1 $rawAdminPortalHostName"

	if($deploymentMode -eq "ST")
	{
		Add-Content $path "127.0.0.1 $agileXrmHostName"
		Add-Content $path "127.0.0.1 $apiServiceHostName"
		Add-Content $path "127.0.0.1 $publicAXrmHostName"
		Add-Content $path "127.0.0.1 $externalAXrmHostName"
	}
	else
	{
		Add-Content $path "$primaryNicIpAddress $agileXrmHostName"
		Add-Content $path "$secondaryNicIpAddress $apiServiceHostName"
		Add-Content $path "$thirdNicIpAddress $publicAXrmHostName"
		Add-Content $path "$fourthNicIpAddress $externalAXrmHostName"
	}
	
	Write-Host "Function 'Update-Hosts-File' is done";

}

function Disable-Envision-AllowedMismatch()
{
	$agileXrmExtenderPath = "HKLM:\SOFTWARE\AgileXRM\AgileXrmExtender";
	if(Test-Path -Path $agileXrmExtenderPath)
	{
		Set-ItemProperty -Path $agileXrmExtenderPath -Name "AllowAgileXrmVersionMismatch" -Value "0";
		Write-Host "Envision Allow Mismatch has been disabled!";
	}
	else
	{
		Write-Host "Unable to find $agileXrmExtenderPath in the registry" -ForegroundColor DarkYellow;
	}
}

function Configure-AgilePointPortal()
{
	Modify-XML-Node -xmlFilePath "$agilePointPortalWebFolder\Modules\AgilePoint.Portal.AppBuilder\Content\FD.Settings.xml" -nodePath "" -nodeName "APIURL" -nodeValue $apiRestUrl ;
	Modify-XML-Node -xmlFilePath "$agilePointPortalWebFolder\Modules\AgilePoint.Portal.AppBuilder\Content\PD.Settings.xml" -nodePath "" -nodeName "AgilePointServerURL" -nodeValue $apiRestUrl ;
	Modify-XML-Node -xmlFilePath "$agilePointPortalWebFolder\Modules\AgilePoint.Portal.WorkCenter\Content\tl.settings.xml" -nodePath "" -nodeName "SERVER_URL" -nodeValue $apiRestUrl ;
	Modify-XML-Node -xmlFilePath "$agilePointPortalWebFolder\Modules\AgilePoint.Portal.Manage\Content\em.settings.xml" -nodePath "" -nodeName "APIUrl" -nodeValue $apiRestUrl ;
	if($deploymentMode -eq "ST" -and !$vmBelongsToDomain)
	{
		Modify-AppSetings-Key -configFilePath "$agilePointPortalWebFolder\web.config" -keyName "ADDomainName" -keyValue "$env:COMPUTERNAME" ;
	}
	else
	{
		Modify-AppSetings-Key -configFilePath "$agilePointPortalWebFolder\web.config" -keyName "ADDomainName" -keyValue "$apServiceAccountDomain" ;
	}

	Modify-AppSetings-Key -configFilePath "$agilePointPortalWebFolder\web.config" -keyName "AgilePointServerUrl" -keyValue "$apiRestUrl" ;
	Modify-AppSetings-Key -configFilePath "$agilePointPortalWebFolder\web.config" -keyName "AgilePointServerWsHttpUrl" -keyValue "$apiWsUrl" ;
	Modify-AppSetings-Key -configFilePath "$agilePointPortalWebFolder\web.config" -keyName "ReportsExternalAppPath" -keyValue "$reportsPortalUrl" ;
	Modify-AppSetings-Key -configFilePath "$agilePointPortalWebFolder\web.config" -keyName "AgilePointServerDocumentUrl" -keyValue "$docsApiUrl" ;
	Modify-AppSetings-Key -configFilePath "$agilePointPortalWebFolder\web.config" -keyName "PortalUrl" -keyValue "$agilePointPortalUrl" ;

	Modify-AppSetings-Key -configFilePath "$agilePointPortalWebFolder\web.config" -keyName "ActiveAuthProviders" -keyValue "ActiveDirectory;WAAD" 
	Modify-AppSetings-Key -configFilePath "$agilePointPortalWebFolder\web.config" -keyName "ida:ClientID" -keyValue $waadApplicationId -createNode $true
	Modify-AppSetings-Key -configFilePath "$agilePointPortalWebFolder\web.config" -keyName "ida:WCFClientID" -keyValue $waadWcfAppId  -createNode $true
	Modify-AppSetings-Key -configFilePath "$agilePointPortalWebFolder\web.config" -keyName "ida:WCFAppID" -keyValue $waadWcfAppIdUri -createNode $true
	Modify-AppSetings-Key -configFilePath "$agilePointPortalWebFolder\web.config" -keyName "ida:Authority" -keyValue "https://login.windows.net/{0}"  -createNode $true
	Modify-AppSetings-Key -configFilePath "$agilePointPortalWebFolder\web.config" -keyName "ida:GraphAPI" -keyValue "https://graph.windows.net"  -createNode $true
	Modify-AppSetings-Key -configFilePath "$agilePointPortalWebFolder\web.config" -keyName "ida:graphApiTarget" -keyValue "msgraph"  -createNode $true
	Modify-AppSetings-Key -configFilePath "$agilePointPortalWebFolder\web.config" -keyName "ida:msGraphResource" -keyValue "https://graph.microsoft.com/"  -createNode $true
	Modify-AppSetings-Key -configFilePath "$agilePointPortalWebFolder\web.config" -keyName "ida:msGraphAPIURL" -keyValue "https://graph.microsoft.com/v1.0/"  -createNode $true

	if($waadApplicationIdPassword -ne $null)
	{
		Modify-AppSetings-Key -configFilePath "$agilePointPortalWebFolder\web.config" -keyName "ida:Password" -keyValue "$waadApplicationIdPassword" ;
	}
	
	if($deploymentMode -eq "MT")
	{
		if($isSqlAzure -eq $false)
		{
			Write-Host "Configuring Portal's 'setting.txt' file NO Azure SQL..." -ForegroundColor Magenta
			$currentDBConnectionString="DataConnectionString: Server=$sqlServerAliasName;database=$masterPortalDB;Integrated security=SSPI"
		}
		else
		{
			Write-Host "Configuring Portal's 'setting.txt' file Azure SQL..." -ForegroundColor Magenta
			$azureInstanceName = $sqlServer.Split(".")[0];
			$currentDBConnectionString = [string]::Format("DataConnectionString: Server={0};database={1};User ID={2};Password={3}", $sqlServerAliasName, $masterPortalDB, "$dbUserName@$azureInstanceName", $dbUserPassword);
		}

		$settingsFile = "$agilePointPortalWebFolder\Config\settings.txt"

		$output = Get-Content $settingsFile | Foreach-Object {$_ -replace '^DataConnectionString:.+$', $currentDBConnectionString}
		$output | Set-Content $settingsFile

		Write-Host "Portal's 'setting.txt' file configured!" -ForegroundColor DarkGreen
	}
	
	Write-Host "Function 'Configure-AgilePointPortal' is done";
}
function Configure-AgileXRMSites()
{
	Set-WebConfigurationProperty -pspath "MACHINE/WEBROOT/APPHOST" -filter "system.webServer/security/requestFiltering/requestLimits" -Name "maxUrl" -value 20480
	Set-WebConfigurationProperty -pspath "MACHINE/WEBROOT/APPHOST" -filter "system.webServer/security/requestFiltering/requestLimits" -Name "maxQueryString" -value 20480

	Get-WebConfigurationProperty -pspath "MACHINE/WEBROOT/APPHOST" -filter "system.webServer/security/requestFiltering/requestLimits" -Name "maxUrl"
	Get-WebConfigurationProperty -pspath "MACHINE/WEBROOT/APPHOST" -filter "system.webServer/security/requestFiltering/requestLimits" -Name "maxQueryString"

	if($deploymentType -eq "Cloud")
	{
		$cacheType = "REDIS"
		$accessKey = $redisAccessKey;
		$storageType = "AzureFileStorage";
		$signFetchXML = "true";
	}
	else
	{
		$cacheType = "MEMORY"
		$accessKey = "";
		$storageType = "Local";
		$signFetchXML = "false"
	}
	#Regular Site
	Modify-AppSetings-Key -configFilePath "$agileXrmWebFolder\web.config" -keyName "AgileDialogsUrl" -keyValue "$agileDialogsUrl" ;
	Modify-AppSetings-Key -configFilePath "$agileXrmWebFolder\web.config" -keyName "ProcessViewerUrl" -keyValue "$processManagerUrl" ;
	Modify-AppSetings-Key -configFilePath "$agileXrmWebFolder\web.config" -keyName "ApplicationCacheType" -keyValue "$cacheType" ;
	Modify-AppSetings-Key -configFilePath "$agileXrmWebFolder\web.config" -keyName "RedisAccessKey" -keyValue "$accessKey" ;
	Modify-AppSetings-Key -configFilePath "$agileXrmWebFolder\web.config" -keyName "DeploymentType" -keyValue "$deploymentType" ;
	Modify-AppSetings-Key -configFilePath "$agileXrmWebFolder\web.config" -keyName "CustomizationStorageType" -keyValue "$storageType" ;
	if($storageType -eq "Local")
	{
		Modify-AppSetings-Key -configFilePath "$agileXrmWebFolder\web.config" -keyName "CustomizationStorageAzureConnectionString" -keyValue "" ;
		Modify-AppSetings-Key -configFilePath "$agileXrmWebFolder\web.config" -keyName "CustomizationStorageAzureShareName" -keyValue "" ;
	}
	else
	{
		Modify-AppSetings-Key -configFilePath "$agileXrmWebFolder\web.config" -keyName "CustomizationStorageAzureConnectionString" -keyValue "$customStorageAzureConnString" ;
		Modify-AppSetings-Key -configFilePath "$agileXrmWebFolder\web.config" -keyName "CustomizationStorageAzureShareName" -keyValue "agiledialogs" ;
	}

	Configure-OrgUrl-Section -configFilePath "$agileXrmWebFolder\web.config"  -orgUniqueId $singleTenantCrmOrgUniqueId -orgFullUrl $singleTenantCrmOrgFullUrl

	Modify-AppSetings-Key -configFilePath "$agileXrmWebFolder\web.config" -keyName "AzureApplicationId" -keyValue "$waadApplicationId" -createNode $true
	Modify-AppSetings-Key -configFilePath "$agileXrmWebFolder\web.config" -keyName "AzureClientSecret" -keyValue "$waadApplicationIdPassword" -createNode $true
	if($deploymentMode -eq "ST")
	{
		Modify-AppSetings-Key -configFilePath "$agileXrmWebFolder\web.config" -keyName "IsMultiTenant" -keyValue "false" -createNode $true
	}

	if($deploymentMode -eq "MT")
	{
		Modify-AppSetings-Key -configFilePath "$agileXrmWebFolder\web.config" -keyName "IsMultiTenant" -keyValue "true" -createNode $true
	}

	if($deploymentType -ne "Cloud")
	{
		Modify-AppSetings-Key -configFilePath "$agileXrmWebFolder\web.config" -keyName "AzureStorageTableName" -keyValue "";	
		Modify-AppSetings-Key -configFilePath "$agileXrmWebFolder\web.config" -keyName "AzureStorageConnectionString" -keyValue "";	
	}
	else
	{
		Modify-AppSetings-Key -configFilePath "$agileXrmWebFolder\web.config" -keyName "TenantRepositoryType" -keyValue "$mtRepoType" -createNode $true;
		
		if($mtRepoType -eq "AzureTableStorage")
		{
			Modify-AppSetings-Key -configFilePath "$agileXrmWebFolder\web.config" -keyName "AzureStorageTableName" -keyValue "$azureStorageTableName";
			Modify-AppSetings-Key -configFilePath "$agileXrmWebFolder\web.config" -keyName "AzureStorageConnectionString" -keyValue "$azureStorageConnString";	
		}
		elseif($mtRepoType -eq "Dataverse")
		{
			Modify-AppSetings-Key -configFilePath "$agileXrmWebFolder\web.config" -keyName "DataverseRepositoryUrl" -keyValue "$dvRepoUrl" -createNode $true;	
			Modify-AppSetings-Key -configFilePath "$agileXrmWebFolder\web.config" -keyName "DataverseEnvironmentUniqueName" -keyValue "$dvRepoOrgUnqName" -createNode $true;	
			Modify-AppSetings-Key -configFilePath "$agileXrmWebFolder\web.config" -keyName "DataverseRepositoryClientId" -keyValue "$dvRepoClientId" -createNode $true;	
			Modify-AppSetings-Key -configFilePath "$agileXrmWebFolder\web.config" -keyName "DataverseRepositoryClientSecret" -keyValue "$dvRepoClientSecret" -createNode $true;	
			Modify-AppSetings-Key -configFilePath "$agileXrmWebFolder\web.config" -keyName "DataverseRepositoryRestrictToPool" -keyValue "true" -createNode $true;	
			Modify-AppSetings-Key -configFilePath "$agileXrmWebFolder\web.config" -keyName "DataverseRepositoryPoolId" -keyValue "$dvRepoPoolId" -createNode $true;	
		}
	}

	Modify-AppSetings-Key -configFilePath "$agileXrmWebFolder\web.config" -keyName "AllowTestPage" -keyValue "true";	
	
	Modify-AppSetings-Key -configFilePath "$agileXrmWebFolder\AgileDialogs\web.config" -keyName "MyNotificationsServiceUrl" -keyValue $notificationReceiverUrl ;
	Modify-AppSetings-Key -configFilePath "$agileXrmWebFolder\AgileDialogs\web.config" -keyName "SignFetchXml" -keyValue $signFetchXML ;
	
	Modify-AppSetings-Key -configFilePath "$agileXrmWebFolder\AgileDialogs\web.config" -keyName "EnvisionAppId" -keyValue $envisionAppId ;
	
	Configure-AgileDialogs-EnvisionService -configFilePath "$agileXrmWebFolder\AgileDialogs\web.config"

 	Configure-AzureServiceBus -configFilePath "$agileXrmWebFolder\XRMProcessViewer\web.config";
	Configure-Federation-Connection -configFilePath "$agileXrmWebFolder\AgileDialogs\web.config" -realm "$azureAdRealm" -endPoint "$agileXrmUrl" -subDomain "AgileDialogs"
	Configure-Federation-Connection -configFilePath "$agileXrmWebFolder\XRMProcessViewer\web.config" -realm "$azureAdRealm" -endPoint "$agileXrmUrl" -subDomain "XRMProcessViewer"

	Update-client-userPrincipalName -configFilePath "$agileXrmWebFolder\web.config"
	Update-client-userPrincipalName -configFilePath "$agileXrmWebFolder\AgileDialogs\web.config"
	Update-client-userPrincipalName -configFilePath "$agileXrmWebFolder\XRMProcessViewer\web.config"


	#Public Site
	Modify-AppSetings-Key -configFilePath "$publicAgileXrmWebFolder\web.config" -keyName "AgileDialogsUrl" -keyValue "$agileDialogsPublicUrl" ;
	Modify-AppSetings-Key -configFilePath "$publicAgileXrmWebFolder\web.config" -keyName "ProcessViewerUrl" -keyValue "$processManagerPublicUrl" ;
	Modify-AppSetings-Key -configFilePath "$publicAgileXrmWebFolder\web.config" -keyName "ApplicationCacheType" -keyValue "$cacheType" ;
	Modify-AppSetings-Key -configFilePath "$publicAgileXrmWebFolder\web.config" -keyName "RedisAccessKey" -keyValue "$accessKey" ;
	Modify-AppSetings-Key -configFilePath "$publicAgileXrmWebFolder\web.config" -keyName "DeploymentType" -keyValue "$deploymentType" ;
	Modify-AppSetings-Key -configFilePath "$publicAgileXrmWebFolder\web.config" -keyName "CustomizationStorageType" -keyValue "$storageType" ;
	Modify-AppSetings-Key -configFilePath "$publicAgileXrmWebFolder\web.config" -keyName "IsPublicSite" -keyValue "true" -createNode $true;
	Modify-AppSetings-Key -configFilePath "$publicAgileXrmWebFolder\web.config" -keyName "AzureApplicationId" -keyValue "$waadApplicationId" -createNode $true
	Modify-AppSetings-Key -configFilePath "$publicAgileXrmWebFolder\web.config" -keyName "AzureClientSecret" -keyValue "$waadApplicationIdPassword" -createNode $true

	if($storageType -eq "Local")
	{
		Modify-AppSetings-Key -configFilePath "$publicAgileXrmWebFolder\web.config" -keyName "CustomizationStorageAzureConnectionString" -keyValue "" ;
		Modify-AppSetings-Key -configFilePath "$publicAgileXrmWebFolder\web.config" -keyName "CustomizationStorageAzureShareName" -keyValue "" ;
	}
	else
	{
		Modify-AppSetings-Key -configFilePath "$publicAgileXrmWebFolder\web.config" -keyName "CustomizationStorageAzureConnectionString" -keyValue "$customStorageAzureConnString" ;
		Modify-AppSetings-Key -configFilePath "$publicAgileXrmWebFolder\web.config" -keyName "CustomizationStorageAzureShareName" -keyValue "agiledialogs" ;
	}

	if($deploymentMode -eq "ST")
	{
		Modify-AppSetings-Key -configFilePath "$publicAgileXrmWebFolder\web.config" -keyName "IsMultiTenant" -keyValue "false" -createNode $true
	}
	if($deploymentMode -eq "MT")
	{
		Modify-AppSetings-Key -configFilePath "$publicAgileXrmWebFolder\web.config" -keyName "IsMultiTenant" -keyValue "true" -createNode $true
	}
	if($deploymentType -ne "Cloud")
	{
		Modify-AppSetings-Key -configFilePath "$publicAgileXrmWebFolder\web.config" -keyName "AnonymousUser" -keyValue $anonymousUser -createNode $true
		Modify-AppSetings-Key -configFilePath "$publicAgileXrmWebFolder\web.config" -keyName "AzureStorageTableName" -keyValue "";	
		Modify-AppSetings-Key -configFilePath "$publicAgileXrmWebFolder\web.config" -keyName "AzureStorageConnectionString" -keyValue "";	
	}
	else
	{
		Modify-AppSetings-Key -configFilePath "$publicAgileXrmWebFolder\web.config" -keyName "TenantRepositoryType" -keyValue "$mtRepoType" -createNode $true;
		
		if($mtRepoType -eq "AzureTableStorage")
		{
			Modify-AppSetings-Key -configFilePath "$publicAgileXrmWebFolder\web.config" -keyName "AzureStorageTableName" -keyValue "$azureStorageTableName";
			Modify-AppSetings-Key -configFilePath "$publicAgileXrmWebFolder\web.config" -keyName "AzureStorageConnectionString" -keyValue "$azureStorageConnString";	
		}
		elseif($mtRepoType -eq "Dataverse")
		{
			Modify-AppSetings-Key -configFilePath "$publicAgileXrmWebFolder\web.config" -keyName "DataverseRepositoryUrl" -keyValue "$dvRepoUrl" -createNode $true;	
			Modify-AppSetings-Key -configFilePath "$publicAgileXrmWebFolder\web.config" -keyName "DataverseEnvironmentUniqueName" -keyValue "$dvRepoOrgUnqName" -createNode $true;	
			Modify-AppSetings-Key -configFilePath "$publicAgileXrmWebFolder\web.config" -keyName "DataverseRepositoryClientId" -keyValue "$dvRepoClientId" -createNode $true;	
			Modify-AppSetings-Key -configFilePath "$publicAgileXrmWebFolder\web.config" -keyName "DataverseRepositoryClientSecret" -keyValue "$dvRepoClientSecret" -createNode $true;	
			Modify-AppSetings-Key -configFilePath "$publicAgileXrmWebFolder\web.config" -keyName "DataverseRepositoryRestrictToPool" -keyValue "true" -createNode $true;	
			Modify-AppSetings-Key -configFilePath "$publicAgileXrmWebFolder\web.config" -keyName "DataverseRepositoryPoolId" -keyValue "$dvRepoPoolId" -createNode $true;	
		}
	}
	Modify-AppSetings-Key -configFilePath "$publicAgileXrmWebFolder\web.config" -keyName "AllowTestPage" -keyValue "false";	
	Configure-Site-Custom-Errors -configFilePath "$publicAgileXrmWebFolder\web.config" -errorMode RemoteOnly
	
	Configure-OrgUrl-Section -configFilePath "$publicAgileXrmWebFolder\web.config"  -orgUniqueId $singleTenantCrmOrgUniqueId -orgFullUrl $singleTenantCrmOrgFullUrl

	Modify-AppSetings-Key -configFilePath "$publicAgileXrmWebFolder\AgileDialogs\web.config" -keyName "MyNotificationsServiceUrl" -keyValue $notificationReceiverPublicUrl ;
	
	Configure-AzureServiceBus -configFilePath "$publicAgileXrmWebFolder\XRMProcessViewer\web.config";
	Configure-Federation-Connection -configFilePath "$publicAgileXrmWebFolder\AgileDialogs\web.config" -realm "$azureAdRealmcom" -endPoint "$agileXrmPublicUrl" -subDomain "AgileDialogs"
	Configure-Federation-Connection -configFilePath "$publicAgileXrmWebFolder\XRMProcessViewer\web.config" -realm "$azureAdRealm" -endPoint "$agileXrmPublicUrl" -subDomain "XRMProcessViewer"

	Update-client-userPrincipalName -configFilePath "$publicAgileXrmWebFolder\web.config"
	Update-client-userPrincipalName -configFilePath "$publicAgileXrmWebFolder\AgileDialogs\web.config"
	Update-client-userPrincipalName -configFilePath "$publicAgileXrmWebFolder\XRMProcessViewer\web.config"

	#External Site
	Modify-AppSetings-Key -configFilePath "$externalAgileXrmWebFolder\web.config" -keyName "AgileDialogsUrl" -keyValue "$agileDialogsExternalUrl" ;
	Modify-AppSetings-Key -configFilePath "$externalAgileXrmWebFolder\web.config" -keyName "FederationMetadataLocation" -keyValue "" ;
	Modify-AppSetings-Key -configFilePath "$externalAgileXrmWebFolder\web.config" -keyName "ApplicationCacheType" -keyValue "$cacheType" ;
	Modify-AppSetings-Key -configFilePath "$externalAgileXrmWebFolder\web.config" -keyName "RedisAccessKey" -keyValue "$accessKey" ;
	Modify-AppSetings-Key -configFilePath "$externalAgileXrmWebFolder\web.config" -keyName "DeploymentType" -keyValue "$deploymentType" ;
	Modify-AppSetings-Key -configFilePath "$externalAgileXrmWebFolder\web.config" -keyName "CustomizationStorageType" -keyValue "$storageType" ;
	Modify-AppSetings-Key -configFilePath "$externalAgileXrmWebFolder\web.config" -keyName "AzureApplicationId" -keyValue "$waadApplicationId" -createNode $true
	Modify-AppSetings-Key -configFilePath "$externalAgileXrmWebFolder\web.config" -keyName "AzureClientSecret" -keyValue "$waadApplicationIdPassword" -createNode $true
	Modify-AppSetings-Key -configFilePath "$externalAgileXrmWebFolder\web.config" -keyName "ProcessViewerUrl" -keyValue "$processManagerExternalUrl"
	
	Modify-AppSetings-Key -configFilePath "$externalAgileXrmWebFolder\AgileDialogs\web.config" -keyName "MyNotificationsServiceUrl" -keyValue $notificationReceiverExternalUrl;
	Configure-Federation-Connection -configFilePath "$externalAgileXrmWebFolder\AgileDialogs\web.config" -realm "$azureAdRealm" -endPoint "$agileXrmExternalUrl" -subDomain "AgileDialogs"
	Configure-OrgUrl-Section -configFilePath "$externalAgileXrmWebFolder\web.config"  -orgUniqueId $singleTenantCrmOrgUniqueId -orgFullUrl $singleTenantCrmOrgFullUrl
	
	Update-client-userPrincipalName -configFilePath "$externalAgileXrmWebFolder\web.config"
	Update-client-userPrincipalName -configFilePath "$externalAgileXrmWebFolder\AgileDialogs\web.config"
	Update-client-userPrincipalName -configFilePath "$externalAgileXrmWebFolder\XRMProcessViewer\web.config"

	if($deploymentMode -eq "ST")
	{
		Modify-AppSetings-Key -configFilePath "$externalAgileXrmWebFolder\web.config" -keyName "IsMultiTenant" -keyValue "false" -createNode $true
	}
	if($deploymentMode -eq "MT")
	{
		Modify-AppSetings-Key -configFilePath "$externalAgileXrmWebFolder\web.config" -keyName "IsMultiTenant" -keyValue "true" -createNode $true
	}

	if($storageType -eq "Local")
	{
		Modify-AppSetings-Key -configFilePath "$externalAgileXrmWebFolder\web.config" -keyName "CustomizationStorageAzureConnectionString" -keyValue "" ;
		Modify-AppSetings-Key -configFilePath "$externalAgileXrmWebFolder\web.config" -keyName "CustomizationStorageAzureShareName" -keyValue "" ;
	}
	else
	{
		Modify-AppSetings-Key -configFilePath "$externalAgileXrmWebFolder\web.config" -keyName "CustomizationStorageAzureConnectionString" -keyValue "$customStorageAzureConnString" ;
		Modify-AppSetings-Key -configFilePath "$externalAgileXrmWebFolder\web.config" -keyName "CustomizationStorageAzureShareName" -keyValue "agiledialogs" ;
	}

	if($deploymentType -eq "PrivateCloud")
	{
		Modify-AppSetings-Key -configFilePath "$externalAgileXrmWebFolder\web.config" -keyName "AzureStorageTableName" -keyValue "$azureStorageTableName";	
		Modify-AppSetings-Key -configFilePath "$externalAgileXrmWebFolder\web.config" -keyName "AzureStorageConnectionString" -keyValue "$azureStorageConnString";	
	}
	elseif($deploymentType -eq "Cloud")
	{
		Modify-AppSetings-Key -configFilePath "$externalAgileXrmWebFolder\web.config" -keyName "TenantRepositoryType" -keyValue "$mtRepoType" -createNode $true;
		
		if($mtRepoType -eq "AzureTableStorage")
		{
			Modify-AppSetings-Key -configFilePath "$externalAgileXrmWebFolder\web.config" -keyName "AzureStorageTableName" -keyValue "$azureStorageTableName";
			Modify-AppSetings-Key -configFilePath "$externalAgileXrmWebFolder\web.config" -keyName "AzureStorageConnectionString" -keyValue "$azureStorageConnString";	
		}
		elseif($mtRepoType -eq "Dataverse")
		{
			Modify-AppSetings-Key -configFilePath "$externalAgileXrmWebFolder\web.config" -keyName "DataverseRepositoryUrl" -keyValue "$dvRepoUrl" -createNode $true;	
			Modify-AppSetings-Key -configFilePath "$externalAgileXrmWebFolder\web.config" -keyName "DataverseEnvironmentUniqueName" -keyValue "$dvRepoOrgUnqName" -createNode $true;	
			Modify-AppSetings-Key -configFilePath "$externalAgileXrmWebFolder\web.config" -keyName "DataverseRepositoryClientId" -keyValue "$dvRepoClientId" -createNode $true;	
			Modify-AppSetings-Key -configFilePath "$externalAgileXrmWebFolder\web.config" -keyName "DataverseRepositoryClientSecret" -keyValue "$dvRepoClientSecret" -createNode $true;	
			Modify-AppSetings-Key -configFilePath "$externalAgileXrmWebFolder\web.config" -keyName "DataverseRepositoryRestrictToPool" -keyValue "true" -createNode $true;	
			Modify-AppSetings-Key -configFilePath "$externalAgileXrmWebFolder\web.config" -keyName "DataverseRepositoryPoolId" -keyValue "$dvRepoPoolId" -createNode $true;	
		}
	}
	else
	{
		Modify-AppSetings-Key -configFilePath "$externalAgileXrmWebFolder\web.config" -keyName "AzureStorageTableName" -keyValue "";	
		Modify-AppSetings-Key -configFilePath "$externalAgileXrmWebFolder\web.config" -keyName "AzureStorageConnectionString" -keyValue "";	
	}
	Modify-AppSetings-Key -configFilePath "$externalAgileXrmWebFolder\web.config" -keyName "AllowTestPage" -keyValue "false";	

	#NetTCP Configurations
	if($deploymentMode -eq "ST")
	{
		Configure-WebConfig-NetTCP-Endpoint-Address -configFilePath "$agileXrmWebFolder\web.config"
		Configure-WebConfig-NetTCP-Endpoint-Address -configFilePath "$publicAgileXrmWebFolder\web.config"
		Configure-WebConfig-NetTCP-Endpoint-Address -configFilePath "$externalAgileXrmWebFolder\web.config"
	}

	#Bindings
	if($deploymentMode -eq "ST")
	{
		Modify-WebSite-Binding -siteName "AgileXRM" -hostName $agileXrmHostName -bindingPort $regularSitePort;
		Modify-WebSite-Binding -siteName "AgilePoint" -hostName $rawAdminPortalHostName -bindingPort $portalPort;
	}
	else
	{
		Modify-WebSite-Binding -siteName "AgileXRM" -ipAddress $primaryNicIpAddress;
		Modify-WebSite-Binding -siteName "AgilePoint" -hostName $adminPortalWildcardHostName;
	}
	Modify-WebSite-Binding -siteName "AgilePoint.NX.EFormsApp" -hostName $nxAppsHostName;
	Modify-WebSite-Binding -siteName "AgileReports" -hostName $reportsHostName;
	if($deploymentMode -eq "ST")
	{
		Modify-WebSite-Binding -siteName "PublicAgileXRM" -hostName $publicAXrmHostName -bindingPort $publicSitePort;
	}
	else
	{
		Modify-WebSite-Binding -siteName "PublicAgileXRM" -ipAddress $thirdNicIpAddress;
	}
	if($deploymentMode -eq "ST")
	{
		Modify-WebSite-Binding -siteName "ExternalAgileXRM" -hostName $externalAXrmHostName -bindingPort $externalSitePort;
	}
	else
	{
		Modify-WebSite-Binding -siteName "ExternalAgileXRM" -ipAddress $fourthNicIpAddress;
	}

	if($deploymentMode -ne "ST")
	{
		Modify-WebSite-Binding -siteName "PortalAgileXRM" -ipAddress $fifthNicIpAddress;
		Update-AppPool-User -apAppPoolName "PortalAppPool" -fullUserName "$internalDomainValue\adminportal" -applyAdvancedSettings $false
	}
	Configure-Services-SSLCert ;
	Update-AppPool-User -apAppPoolName "AgilePointAppPool";
	Update-AppPool-User -apAppPoolName "AgileXRMAppPool";
	Write-Host "Function 'Configure-AgileXRMSites' is done";
}


function Get-EndPointAddress-Subdomain()
{
	param([string]$endpointName)
	$subDomain = $null
	switch($endpointName)
	{
		{($_ -eq "NetTcpBinding_IWCFWorkflowService" )} { $subDomain = "Workflow" }
		{($_ -eq "NetTcpBinding_IWCFAdminService") } { $subDomain = "Admin" }
		{($_ -eq "NetTcpBinding_IWCFEventServices") } { $subDomain = "EventServices" }
		{($_ -eq "NetTcpBinding_IWCFDataServices") } { $subDomain = "DataServices" }
		{($_ -eq "NetTcpBinding_IWCFExtensionService") } { $subDomain = "Extension" }
	}
	return $subDomain
}


function Configure-WebConfig-NetTCP-Endpoint-Address([string]$configFilePath)
{
	if(!(Test-Path -Path $configFilePath))
	{
		Write-Host "[Configure-WebConfig-NetTCP-Endpoint-Address]Unable to find document: $configFilePath" -ForegroundColor Magenta;
		return;
	}

	[xml]$file = Get-Content $configFilePath
	
	$endpointAddressNames = @("NetTcpBinding_IWCFWorkflowService","NetTcpBinding_IWCFAdminService","NetTcpBinding_IWCFEventServices","NetTcpBinding_IWCFDataServices","NetTcpBinding_IWCFExtensionService");

	foreach($endpointAddressName in $endpointAddressNames)
	{
		$node = $file.SelectSingleNode("descendant::configuration/system.serviceModel/client/endpoint[@name=""$endpointAddressName""]");
		$subdomain = Get-EndPointAddress-Subdomain -endpointName $endpointAddressName;
		$fullUrl = [string]::Format("{0}{1}",$nettcpAgilePointUrl,$subDomain);
		$node.SetAttribute("address",$fullUrl);
		Write-Host "[Configure-WebConfig-NetTCP-Endpoint-Address] endpoint: '$endpointAddressName' address updated with '$fullUrl'" -ForegroundColor Magenta;
	}

	$file.Save($configFilePath);
	Write-Host "[Configure-WebConfig-NetTCP-Endpoint-Address] File '$configFilePath' done!" -ForegroundColor DarkGreen;
}

function Configure-AgilePointServerManagerConf()
{
	$appEntryXML = "$agilePointServer\APServerManagerConfig.cfg";
	[xml]$file = Get-Content $appEntryXML

	$node = $file.SelectSingleNode("descendant::Service");
	if($node -eq $null)
	{
		Write-Host "Unable to find node 'Service' in document $appEntryXML" -ForegroundColor Magenta;
		return;
	}
	$node.SetAttribute("PortalURL", $agilePointPortalUrl);
	$node.SetAttribute("PortalDatabase", $masterPortalDB);
	$node.SetAttribute("DefaultDatabase", $singlePortalDB);
	$node.SetAttribute("SSLDomainName", $apiServiceHostName);

	$file.Save($appEntryXML);

	Write-Host "Function 'Configure-AgilePointServerManagerConf' is done";
}
function Get-BaseAddress-Subdomain()
{
	param([string]$serviceName)
	$subDomain = $null
	switch($serviceName)
	{
		{($_ -eq "Ascentn.AgilePoint.WCFService.WcfWorkFlow") -or ($_ -eq "Ascentn.AgilePoint.WCFService.RESTWorkFlow")} { $subDomain = "Workflow" }
		{($_ -eq "Ascentn.AgilePoint.WCFService.WcfAdmin") -or ($_ -eq "Ascentn.AgilePoint.WCFService.RESTAdmin")} { $subDomain = "Admin" }
		{($_ -eq "Ascentn.AgilePoint.WCFService.WcfEventServices") -or ($_ -eq "Ascentn.AgilePoint.WCFService.RESTEventServices")} { $subDomain = "EventServices" }
		{($_ -eq "Ascentn.AgilePoint.WCFService.WcfDataServices") -or ($_ -eq "Ascentn.AgilePoint.WCFService.RESTDataServices")} { $subDomain = "DataServices" }
		{($_ -eq "Ascentn.AgilePoint.WCFService.WcfExtensionServices") -or ($_ -eq "Ascentn.AgilePoint.WCFService.RESTExtensionServices")} { $subDomain = "Extension" }
		{($_ -eq "Ascentn.AgilePoint.WCFService.WcfDataEntity") -or ($_ -eq "Ascentn.AgilePoint.WCFService.RESTDataEntity")} { $subDomain = "DataEntity" }
		{($_ -eq "Ascentn.Crm.Connector.Services.Wcf.LicenseCheckingService") -or ($_ -eq "Ascentn.Crm.Connector.Services.RestLicenseCheckingService")} { $subDomain = "LicenseCheckingService" }
		{($_ -eq "Ascentn.Crm.AgileDialogsConnector.AgileDialogsConnectorService") } { $subDomain = "AgileDialogsConnectorService" }
		{($_ -eq "AgilePoint.AgileConnector.ProcessManager.Services.ProcessViewerHtml5Service") } { $subDomain = "ProcessViewerHtml5Service" }
		{($_ -eq "Ascentn.AgilePoint.WCFService.CrossDomainService") } { $subDomain = "" }
		{($_ -eq "AgilePoint.Xrm.MetadataConnector.MetadataService")} { $subDomain = "MetadataService" }

	}
	return $subDomain
}

function Update-baseAddress-Attribute()
{
	param([xml]$file, $serviceNames, $urlValue, [string]$protocolSearchFilter="https://")
	foreach($serviceName in $serviceNames)
	{
		$baseAddressNode =  $file.SelectSingleNode("descendant::system.serviceModel/services/service[@name=""$serviceName""]/host/baseAddresses/add[starts-with(@baseAddress,""$protocolSearchFilter"")]")
		$subDomain = Get-BaseAddress-Subdomain -serviceName $serviceName
		if($baseAddressNode -ne $null)
		{
			$fullUrl = $urlValue + $subDomain
			$baseAddressNode.SetAttribute("baseAddress", $fullUrl)
			Write-Host "Base Address node for service $serviceName has been updated with $fullUrl" -ForegroundColor DarkGreen
		}
		else
		{
			Write-Host "Base Address node not found for service $serviceName " -ForegroundColor Magenta
		}
	}

	return $file;
}

function Configure-AgilePointService-ServicesAddresses()
{
	param([string]$configFilePath)

	$currentWsUrl = $apiWsUrl;
	$currentRestUrl = $apiRestUrl;
	
	if($deploymentMode -eq "MT")
	{
		Write-Host "Configure-AgilePointService-ServicesAddresses needs to be updated for MultiTenant Environments...." -ForegroundColor Magenta
		$currentWsUrl =  [string]::Format("https://{0}/AgilePointServer/",$apiWsWildcardHostName)
		$currentRestUrl = [string]::Format("https://{0}/AgilePointServer/",$apiWildcardHostName) 
	}
	[xml]$file = Get-Content $configFilePath;

	$wcfServicesNames = @("Ascentn.AgilePoint.WCFService.WcfWorkFlow","Ascentn.AgilePoint.WCFService.WcfAdmin", "Ascentn.AgilePoint.WCFService.WcfEventServices",
			"Ascentn.AgilePoint.WCFService.WcfDataServices","Ascentn.AgilePoint.WCFService.WcfExtensionServices","Ascentn.AgilePoint.WCFService.CrossDomainService", 
			"Ascentn.AgilePoint.WCFService.WcfDataEntity", "Ascentn.Crm.Connector.Services.Wcf.LicenseCheckingService","Ascentn.Crm.AgileDialogsConnector.AgileDialogsConnectorService")
	
	$restServicesNames = @("Ascentn.AgilePoint.WCFService.RESTWorkFlow", "Ascentn.AgilePoint.WCFService.RESTAdmin", "Ascentn.AgilePoint.WCFService.RESTEventServices",
		"Ascentn.AgilePoint.WCFService.RESTDataServices","Ascentn.AgilePoint.WCFService.RESTExtensionServices","Ascentn.AgilePoint.WCFService.RESTDataEntity",
			"Ascentn.Crm.Connector.Services.RestLicenseCheckingService","AgilePoint.Xrm.MetadataConnector.MetadataService","AgilePoint.AgileConnector.ProcessManager.Services.ProcessViewerHtml5Service")

	$file = Update-baseAddress-Attribute -file $file -serviceNames $wcfServicesNames -urlValue $nettcpAgilePointUrl -protocolSearchFilter "net.tcp://"
	$file = Update-baseAddress-Attribute -file $file -serviceNames $wcfServicesNames -urlValue $currentWsUrl 
	$file = Update-baseAddress-Attribute -file $file -serviceNames $restServicesNames -urlValue $currentRestUrl
	
	$file.Save($configFilePath);

}

function Configure-AgilePointService()
{
	$cacheType = "MEMORY"
	$accessKey = "";
	if($deploymentType -eq "Cloud")
	{
		$cacheType = "REDIS"
		$accessKey = $redisAccessKey;
	}
	Modify-AppSetings-Key -configFilePath "$agilePointServerInstanceFolder\bin\Ascentn.AgilePoint.WCFService.exe.config" -keyName "RedisAccessKey" -keyValue $accessKey;
	Modify-AppSetings-Key -configFilePath "$agilePointServerInstanceFolder\bin\Ascentn.AgilePoint.WCFService.exe.config" -keyName "NXPortalUrl" -keyValue $agilePointPortalUrl;
	Modify-AppSetings-Key -configFilePath "$agilePointServerInstanceFolder\bin\Ascentn.AgilePoint.WCFService.exe.config" -keyName "ApplicationCacheType" -keyValue $cacheType;
	if($deploymentType -ne "Cloud")
	{
		Modify-AppSetings-Key -configFilePath "$agilePointServerInstanceFolder\bin\Ascentn.AgilePoint.WCFService.exe.config" -keyName "AzureStorageTableName" -keyValue "";	
		Modify-AppSetings-Key -configFilePath "$agilePointServerInstanceFolder\bin\Ascentn.AgilePoint.WCFService.exe.config" -keyName "AzureStorageConnectionString" -keyValue "";	
	}
	else
	{
		Modify-AppSetings-Key -configFilePath "$agilePointServerInstanceFolder\bin\Ascentn.AgilePoint.WCFService.exe.config" -keyName "AzureStorageTableName" -keyValue $azureStorageTableName;
		Modify-AppSetings-Key -configFilePath "$agilePointServerInstanceFolder\bin\Ascentn.AgilePoint.WCFService.exe.config" -keyName "AzureStorageConnectionString" -keyValue $azureStorageConnString;
	}

	#WAAD
	Modify-AppSetings-Key -configFilePath "$agilePointServerInstanceFolder\bin\Ascentn.AgilePoint.WCFService.exe.config" -keyName "WCFServiceClientID" -keyValue $waadWcfAppId;
	Modify-AppSetings-Key -configFilePath "$agilePointServerInstanceFolder\bin\Ascentn.AgilePoint.WCFService.exe.config" -keyName "WFCServiceAudienceUrl" -keyValue $waadWcfAppIdUri;

	#PowerAutomate Unsubscribe
	Modify-AppSetings-Key -configFilePath "$agilePointServerInstanceFolder\bin\Ascentn.AgilePoint.WCFService.exe.config" -keyName "ServerRESTUrl_ExposedToClients" -keyValue $apiRestUrl;
	
	Configure-AgilePointService-ServicesAddresses -configFilePath "$agilePointServerInstanceFolder\bin\Ascentn.AgilePoint.WCFService.exe.config"
	Update-SwaggerConfiguration -configFilePath "$agilePointServerInstanceFolder\bin\Ascentn.AgilePoint.WCFService.exe.config";
	Configure-Ws-Http-Binding -configFilePath "$agilePointServerInstanceFolder\bin\Ascentn.AgilePoint.WCFService.exe.config"

	Write-Host "Function 'Configure-AgilePointService' is done";
}
function Update-Registry-Keys()
{
	Set-SQLServer-Alias-Instance -sqlServerAliasPath "HKLM:\SOFTWARE\Microsoft\MSSQLServer\Client\ConnectTo";
	Set-SQLServer-Alias-Instance -sqlServerAliasPath "HKLM:\SOFTWARE\WOW6432Node\Microsoft\MSSQLServer\Client\ConnectTo";
	Disable-Envision-AllowedMismatch;
	Write-Host "Update-Registry-Keys>> Done";

}
function Update-netflow-Cfg-File()
{
	#Update netflow.cg XML File
	$appEntryXML = "$agilePointServerInstanceFolder\netflow.cfg"
	if($poolNotificationMailbox -eq $null)
	{
		$poolNotificationMailbox = [string]::Format( "pool{0}{1}.notification@agilexrmonline.com", $regionNumber,$poolNumber);
	}
	[xml]$file = Get-Content $appEntryXML
	
	if($deploymentMode -eq "ST")
	{
		if($isSqlAzure)
		{
			$azureInstanceName = $sqlServer.Split(".")[0];
			$singleApDbConnectingString = [string]::Format("application name=AgilePoint Server;connection lifetime=5;min pool size=10;server={0};database={1};User ID={2};Password={3};", $sqlServerAliasName, $singleApDB, "$dbUserName@$azureInstanceName", $dbUserPassword);
			$node = $file.SelectSingleNode("descendant::database");
			$node.SetAttribute("connectingString", $singleApDbConnectingString);
		}
		else
		{
			if($dbUserName -eq "" -and $dbUserPassword -eq "")
			{
				$singleApDbConnectingString = [string]::Format("Server={0};Initial Catalog={1};Integrated Security=True;Min Pool Size=10;Max Pool Size=100;Load Balance Timeout=5;trusted_Connection=yes",$sqlServerAliasName,$singleApDB)	
				$node = $file.SelectSingleNode("descendant::database");
				$node.SetAttribute("connectingString", $singleApDbConnectingString);
			}
			else
			{
				$singleApDbConnectingString = [string]::Format("application name=AgilePoint Server;connection lifetime=5;Min Pool Size=10;Max Pool Size=100;Load Balance Timeout=5;server={0};database={1};User ID={2};Password={3};", $sqlServerAliasName, $singleApDB, $dbUserName, $dbUserPassword)	
				$node = $file.SelectSingleNode("descendant::database");
				$node.SetAttribute("connectingString", $singleApDbConnectingString);
			}
		}
		$domainName = [string]::Format("WinNT://{0}",$env:computername);
		if($vmBelongsToDomain)
		{
			Write-Host "This VMs is going to be configured with an Domain Account" -ForegroundColor Magenta
			$domainName = "LDAP://$apServiceAccountDomain"
		}
		
		$node = $file.SelectSingleNode("descendant::domain");
		$node.SetAttribute("name", $domainName);
	}
	if($deploymentMode -eq "MT")
	{
		if($isSqlAzure -eq $false)
		{
			$masterApDbConnectingString = [string]::Format("application name=AgilePoint Server;connection lifetime=5;Max Pool Size=800;min pool size=10;server={0};database=MasterAPDB;trusted_Connection=yes", $sqlServerAliasName);
			$node = $file.SelectSingleNode("descendant::database");
			$node.SetAttribute("connectingString", $masterApDbConnectingString);
		}
		else
		{
			$azureInstanceName = $sqlServer.Split(".")[0];
			$masterApDbConnectingString = [string]::Format("application name=AgilePoint Server;connection lifetime=5;Max Pool Size=800;min pool size=10;server={0};database={1};User ID={2};Password={3};", $sqlServerAliasName, $singleApDB, "$dbUserName@$azureInstanceName", $dbUserPassword);
			$node = $file.SelectSingleNode("descendant::database");
			$node.SetAttribute("connectingString", $masterApDbConnectingString);
		}
	}

	$node = $file.SelectSingleNode("descendant::notification");
	if($node -eq $null)
	{
		Write-Host "Update-netflow-Cfg-File>>Unable to find node 'notification' in document $appEntryXML" -ForegroundColor Magenta;
		return;
	}

	$node.SetAttribute("sender", $senderMailBox)
	$node.SetAttribute("sysadm", $poolNotificationMailbox)
	$node.SetAttribute("mailServer", $mailServer)
	$node.SetAttribute("smtpService", $smtpService)

	if($smtpService -eq '')
	{
		$node.RemoveAttribute("smtpService");
	}
	$file.Save($appEntryXML);
	Write-Host "Update-netflow-Cfg-File>> Done" -ForegroundColor DarkGreen;
}
function Remove-Old-AgileXRMOnline-Certs()
{
	param([string]$certSubjectName = $certificateSubjectName)

	
    $certStore = "cert:\LocalMachine\My";
	$agileXRMCerts = Get-ChildItem -Path $certStore -Recurse | select Subject, FriendlyName, Thumbprint, NotAfter |  where-object { $_.Subject -eq  $certSubjectName};
	if (($agileXRMCerts.Count -ne $null) -and ($agileXRMCerts.Count -gt 0) )
	{
	   Write-Host "Remove-Old-AgileXRMOnline-Certs>> Removing Old Certificates '$certSubjectName' ...."
	   $selectedCerts = $agileXRMCerts | Sort-Object -Property NotAfter -Descending | Select-Object -Last ($agileXRMCerts.Count -1);
	   foreach($cert in $selectedCerts)
	   {
		  $path = $certStore +"\"+ $cert.Thumbprint;
		  Get-ChildItem $path | Remove-Item;
		  Write-Host "Remove-Old-AgileXRMOnline-Certs>> Certificate in Path $path has been removed" -f DarkGreen;
	   }
	}
}
function Create-WinNT-User()
{
	param([string]$userName,[string]$userPassword,[string]$userFirstName,[string]$userLastName ,[string]$userDescription)
	$ADS_UF_PASSWD_CANT_CHANGE = 0x40
	$ADS_UF_DONT_EXPIRE_PASSWD = 0x10000
	$user = [pscustomobject]@{
			userName = $userName
			Password = $userPassword
			firstname = $userFirstName
			lastname = $userLastName	
			fullname = "$firstname $lastname"
			description = $userDescription
	}

	Write-Host "----------------------" -foregroundcolor darkCyan
	Write-Host $user.username -foregroundcolor darkCyan
	
	# Check to see if user exists already, if it does not, create it 

	$localUser  = Get-LocalUser -Name $user.username -ErrorAction Ignore
	if ($localUser -ne $null)
	{
	    write-host "Already exists!"
	    $username = $user.username
	    $objUser = [ADSI]"WinNT://$Env:COMPUTERNAME/$username"
	    $objUser.setPassword($user.password)
	    $objUser.setinfo()
	    write-host "Password changed." -foregroundcolor darkGreen
	}
	else 
	{
	    $objOU = [ADSI]"WinNT://."
	    $objUser = $objOU.Create("User", $user.username)
	    $objUser.setPassword($user.password)
	    $objUser.setinfo()
	
	    #Description
	    $objUser.Description = $user.description
	    #FullName
	    $objUser.FullName = $user.fullname
	    #Reset User must change password at next logon
	    $objUser.PasswordExpired = 0
	    #Password never expires
	    $objUser.userflags = $objUser.userflags[0] -bor ($ADS_UF_DONT_EXPIRE_PASSWD + $ADS_UF_PASSWD_CANT_CHANGE)
	    #Commit changes
	    $objUser.SetInfo()
		write-host "****Created****" -foregroundcolor darkGreen
	}
}

function Create-Local-Users()
{
	if($deploymentType -eq "Cloud")
	{
		
		$multiTenantAxrmUser = "xrm.system"
		$multiTenantAxrmPass = $dvRepoPoolId
		
		Create-WinNT-User -userName $multiTenantAxrmUser -userPassword $multiTenantAxrmPass -userFirstName "AgileXRM Multi-Tenant" -userLastName "System Admin User" -userDescription "AgileXRM Multi-Tenant System User created to connect from Tenant Deployment system to Tenant"

		return;
	}

	if ($singleTenantAdminUser.ToLower() -ne $apServiceAccountUser.ToLower())
	{
		Create-WinNT-User -userName $singleTenantAdminUser -userPassword $localUsersPassword -userFirstName "AgileXRM Tenant" -userLastName "Admin User" -userDescription "Tenant Admin User created to connect from CDS to AP Server"
	}
}
function Get-NetworkInterface()
{
	param([string]$nicName)

	$virtualMachineNIC = $null
	if($isScaleSet)
	{
		Write-Host "Get-NetworkInterface>> ScaleSet is True Configuration found !" -foregroundcolor DarkCyan
		$vmssVms = Get-AzVmssVM -ResourceGroupName $resourceGroupName -VMScaleSetName $scaleSetName 
		if($vmssVms.Count -gt 0)
		{
			Write-Host "Get-NetworkInterface>> VM have been found inside of scale set: $scaleSetName in RG: $resourceGroupName" -foregroundcolor DarkCyan
			foreach($vm in $vmssVms)
			{
				if($vm.OsProfile.ComputerName -eq $currentVmSSInstance)
				{
					Write-Host "Get-NetworkInterface>> VM Found with name $currentVmSSInstance" -foregroundcolor DarkCyan
					Write-Host "Get-NetworkInterface>> VM Index is "+$vm.InstanceID -foregroundcolor DarkCyan
					Write-Host "Get-NetworkInterface>> Searching for NIC $nicName ..." -foregroundcolor DarkCyan
					$primaryNic = $vm.NetworkProfile.NetworkInterfaces | ? {$_.Primary}
					$virtualMachineNIC = Get-AzNetworkInterface -VirtualMachineScaleSetName $scaleSetName -ResourceGroupName $resourceGroupName -VirtualMachineIndex $vm.InstanceID | ? {$_.Name -eq $nicName}
					break
				}
			}
		}
	}
	else
	{
		Write-Host "Get-NetworkInterface>>Just simple NIC for VM found !" -foregroundcolor DarkCyan
		$virtualMachineNIC = Get-AzNetworkInterface -Name $nicName -ResourceGroupName $resourceGroupName
	}
	Write-Host "Get-NetworkInterface>> Returning PrimaryNIC Found" -foregroundcolor DarkGreen
	return $virtualMachineNIC
}

function Get-NIC-IpAddresses()
{
	param([Microsoft.Azure.Commands.Network.Models.PSNetworkInterface]$networkInterface, [int]$numberOfIpsInsideOfNic=2)

	Write-Host "Get-NIC-IpAddresses>> Ipconfiguration found in NIC: " $networkInterface.IpConfigurations.Count -foregroundcolor DarkCyan
	if($networkInterface.IpConfigurations.Count -eq $numberOfIpsInsideOfNic)
	{
		$tempAddressesList = [System.Collections.Generic.List[string]]::new()
		$sortedList = $networkInterface.IpConfigurations | Sort-Object -Property PrivateIpAddress
		Write-Host "Get-NIC-IpAddresses>> $numberOfIpsInsideOfNic IpConfigurations found"
		foreach($nicConfig in $sortedList)
		{
			if($nicConfig.PrivateIpAddressVersion -eq "IPv4")
			{
				if($numberOfIpsInsideOfNic -eq 2)
				{
					Write-Host "Get-NIC-IpAddresses>> IpConfigurations Version IPv4 has been found"
					if($nicConfig.Primary)
					{
						Set-Variable -Name primaryNicIpAddress1 -Value $nicConfig.PrivateIpAddress -Scope Global
						Write-Host "Get-NIC-IpAddresses>>PrimaryNic IP Address 1: $global:primaryNicIpAddress1" -foregroundcolor DarkGreen
					}
					else
					{
						Set-Variable -Name primaryNicIpAddress2 -Value $nicConfig.PrivateIpAddress -Scope Global
						Write-Host "Get-NIC-IpAddresses>>PrimaryNic IP Address 2: $global:primaryNicIpAddress2" -foregroundcolor DarkGreen
					}
				}
				$tempAddressesList.Add($nicConfig.PrivateIpAddress);
			}
		}
		Set-Variable -Name primaryNicIpAddresses -Value $tempAddressesList -Scope Global
		return 0
	}
	return -1
}

function Get-NIC-IpAddress()
{
	param([Microsoft.Azure.Commands.Network.Models.PSNetworkInterface]$networkInterface)

	Write-Host "Get-NIC-IpAddress>> Ipconfiguration found in NIC: " $networkInterface.IpConfigurations.Count -foregroundcolor DarkCyan
	if($networkInterface.IpConfigurations.Count -eq 1)
	{
		Write-Host "Get-NIC-IpAddress>> 1 IpConfiguration found"
		foreach($nicConfig in $networkInterface.IpConfigurations)
		{
			if($nicConfig.PrivateIpAddressVersion -eq "IPv4")
			{
				Write-Host "Get-NIC-IpAddress>> IpConfigurations Version IPv4 has been found"
				if($nicConfig.Primary)
				{
					Set-Variable -Name outputNicIpAddress -Value $nicConfig.PrivateIpAddress -Scope Global
					Write-Host "Get-NIC-IpAddress>>Single IP Address: $global:outputNicIpAddress" -foregroundcolor DarkGreen
				}
			}
		}
		return 0
	}
	return -1
}
function Check-APService-Password()
{
	if (Get-Module -ListAvailable -Name CredentialManager) 
	{
		Write-Host "Module 'CredentialManager" -ForegroundColor DarkGreen;
	}
	else
	{
		Write-Host "Module 'CredentialManager' NOT Found. Installing..." -ForegroundColor DarkCyan;
		Install-Module CredentialManager -force
	}

	[Windows.Security.Credentials.PasswordVault,Windows.Security.Credentials,ContentType=WindowsRuntime]
	if($global:apServiceAccountPassword -eq $null)
	{
		$vault = New-Object Windows.Security.Credentials.PasswordVault
		$apServiceUser = $vault.Retrieve("https://ap.axrm.com","apservice")
		if($apServiceUser -eq $null)
		{
			throw "Unable to retrieve APService Password from local store"
		}
		if($apServiceUser.Password -eq $null)
		{
			throw "APService Password is null in local store"
		}
		
		$global:apServiceAccountPassword = $apServiceUser.Password	
		Write-host 	"APService has been provided from local store";
	}
	else
	{
		Write-host 	"APService has been provided with param";
	}
}
function UpdateDatabasesNaming()
{
	#Update Netflow.cfg
	#Node "database" where attribute vendor="MSSQLDatabase" update attribute connectingString
	
	
	
	
	
}

function Update-client-userPrincipalName()
{
	param([string]$configFilePath="")
	if($configFilePath -eq "" -or $configFilePath -eq $null )
	{
		Write-Host "Update-client-userPrincipalName>> File Path can't be null" -ForegroundColor Magenta;
		return;
	}
	if(!(Test-Path -Path $configFilePath))
	{
		Write-Host "Update-client-userPrincipalName>> Unable to find document: $configFilePath" -ForegroundColor Magenta;
		return;
	}
	[xml]$file = Get-Content $configFilePath;
	
	$nodes = $file.SelectNodes("descendant::client/endpoint/identity/userPrincipalName");
	if($nodes -eq $null)
	{
		Write-Host "Update-client-userPrincipalName>> no 'userPrincipalName' node has been found" -ForegroundColor Magenta;
	}
	foreach($node in $nodes)
	{
		$node.SetAttribute("value", "$apServiceAccountDomain\$apServiceAccountUser");
		Write-Host "Update-client-userPrincipalName>> 'userPrincipalName' updated!" -ForegroundColor Magenta;
	}

	$file.Save($configFilePath);
	Write-Host "Update-client-userPrincipalName>> for '$configFilePath' is done!" -ForegroundColor DarkGreen;
}

function Write-Debug-Message()
{
	param($functionName="Not Reported", $message)
	
	if($global:debugMode)
	{
		Write-Warning "<$functionName> Debug Message: $message"
	}
}

function ModifyReadCommittedSnapshot()
{
	param([string]$sqlInstanceName, [string]$sqlDbName,[string]$sqlUserName, [string]$sqlUserPassword)
	
	$dbConnection = Test-Db-Connection -sqlInstanceName $sqlInstanceName -sqlDbName "master" -sqlUserName $sqlUserName -sqlUserPassword $sqlUserPassword;
	Write-Host "Modifying $sqlDbName READ_COMMITED_SNAPSHOT ..." 
	$alterQuery = [string]::Format("ALTER DATABASE {0} SET READ_COMMITTED_SNAPSHOT OFF WITH ROLLBACK IMMEDIATE", $sqlDbName)
	
	ExecuteSQL -ServerInstance $sqlInstanceName -Database $sqlDbName -Username $sqlUserName -Password $sqlUserPassword -Query $alterQuery
}

function Apply-Post-Installation()
{
	if($deploymentMode -ne "ST")
	{
		Write-Host "This is NOT a Single Tenant Deployment. 'Apply-Post-Installation' configuration doesn't apply" -foregroundcolor darkCyan
		return;
	}
	

	#X - Check AP Service is Up & Running (Check Connection to Some Servcice)
	$isApServiceUpAndRunning = Check-AP-Service-Status;
	if(! $isApServiceUpAndRunning)
	{
		Write-Error "Service is not running. Provisioning has failed. Please review and reexecute";
		exit -1;
	}
	
	#X - Check DB Connection to MasterPortalDB
	$dbConnection = Test-Db-Connection -sqlInstanceName $sqlServer -sqlDbName $masterPortalDB -sqlUserName $dbUserName -sqlUserPassword $dbUserPassword 

	#X - Check DB Connection to SinglePortalDB
	$dbConnection = Test-Db-Connection -sqlInstanceName $sqlServer -sqlDbName $singlePortalDB -sqlUserName $dbUserName -sqlUserPassword $dbUserPassword 

	#x - Create NX Portal Orchard
	$attemp = 0;
	$nxPortalStatus = Create-NX-Portal-Orchard;
	Write-Host "Create NX Portal Status is $nxPortalStatus" -ForegroundColor DarkCyan;
	while ($nxPortalStatus -ne 0 -and $attemp -lt 15)
	{
		$nxPortalStatus = Create-NX-Portal-Orchard;
		Write-Host "--Attemp $attemp .Create NX Portal Status is $nxPortalStatus" -ForegroundColor DarkCyan;
		$attemp++;
		Start-Sleep -Milliseconds 5000;
	}

	#X - Provide Portal (login -?-)

	$notiReceiverUrl =""
	if($deploymentType -ne "Cloud")
	{
		# Only applies for MEMORY CACHE (now is configured only for "CLOUD")
		$notiReceiverUrl = $notificationReceiverUrl;
	}

	#Create Connectors Records
	Insert-AD-Connector -sqlInstance $sqlServer -agileDialogsURL $agileDialogsUrl -agileDialogsExternalURL $agileDialogsExternalUrl -agileDialogsPublicUrl $agileDialogsPublicUrl -notiReceiverUrl $notiReceiverUrl;
	Insert-PM-Connector -sqlInstance $sqlServer -processManagerURL $processManagerUrl;
	Insert-CRM-Connector -sqlInstance $sqlServer -azureAppId $waadApplicationId -azureAppSecretKey $waadApplicationIdPassword -d365UniqueName $singleTenantCrmOrgUniqueId -d365Url $singleTenantCrmOrgFullUrl;
	
	if ($singleTenantAdminUser.ToLower() -ne $apServiceAccountUser.ToLower())
	{
		Upsert-TenantAdminUser
	}
}
function Check-NX-Portal-Status()
{
	$provisioningStatusQuery = "SELECT * FROM [dbo].[AgilePoint_Portal_Core_ProvisionInfoRecord] WHERE TenantName='$portalInstallationName'"; 
	$portalDeploymentCheckQuery="SELECT count(*) FROM [dbo].[Settings_ShellDescriptorRecord]";
	$portalSettingsQuery= "SELECT * FROM [$masterPortalDB].[dbo].[AgilePoint_Portal_Core_ShellSettingsRecord] WHERE NAME = '$portalInstallationName'"

	$queryOutput = ExecuteSQL -ServerInstance $sqlServer -Database $masterPortalDB -Username $dbUserName -Password $dbUserPassword -Query $portalDeploymentCheckQuery -ErrorAction Ignore; 

	if($queryOutput -eq $null)
	{
		Write-Host "No 'Settings_ShellDescriptorRecord' Record is found. Portal has not been deployed" -ForegroundColor DarkCyan;
		
		return -1
	}
	else
	{
		$queryOutput = ExecuteSQL -ServerInstance $sqlServer -Database $masterPortalDB -Username $dbUserName -Password $dbUserPassword -Query $portalSettingsQuery -ErrorAction Ignore; 
		
		if($queryOutput -eq $null)
		{
			Write-Host "Portal Setting Record is NOT found " -ForegroundColor DarkCyan;
			return -2;
		}
		else
		{
			$queryOutput = ExecuteSQL -ServerInstance $sqlServer -Database $masterPortalDB -Username $dbUserName -Password $dbUserPassword -Query $provisioningStatusQuery -ErrorAction Ignore; 
			if($queryOutput -eq $null)
			{
				Write-Host "Provisioning Record is NOT found" -ForegroundColor DarkCyan;
				return -3;
			}
			else
			{
				$portalStatus = $queryOutput.Status;
				$portalProgress = $queryOutput.Progress;
				if($portalStatus.ToLower() -ne "completed")
				{
					Write-Host "Provisioning Record is found but status is '$portalStatus' and progress is '$portalProgress'" -ForegroundColor DarkCyan;
				}
			}
		}
	}
	return 0;
}

function Upsert-NX-Portal-ShellSettingRecord()
{
	
	$dbConnection = Test-Db-Connection -sqlInstanceName $sqlServer -sqlDbName $masterPortalDB -sqlUserName $dbUserName -sqlUserPassword $dbUserPassword 
	$query= "SELECT * FROM [$masterPortalDB].[dbo].[AgilePoint_Portal_Core_ShellSettingsRecord] WHERE NAME = '$portalInstallationName'"
	$queryOutput = ExecuteSQL -ServerInstance $sqlServer -Database $masterPortalDB -Username $dbUserName -Password $dbUserPassword -Query $query
	$userSection ="User ID=$dbUserName;Password=$dbUserPassword";
	if($dbUserName -eq "" -and $dbUserPassword -eq "")
	{
		$userSection ="trusted_Connection=yes";
	}

	if($queryOutput -eq $null)
	{
		Write-Host "Inserting Record in table 'AgilePoint_Portal_Core_ShellSettingsRecord' from '$masterPortalDB'...."

		
		$insertQuery = "INSERT INTO [$masterPortalDB].[dbo].[AgilePoint_Portal_Core_ShellSettingsRecord] (  [Name],  [ConnectionString],  [DataProvider],  [Status],  [CreatedOn],  [LastModifiedOn])  VALUES ( '$portalInstallationName',   'Data Source=$sqlServer;Initial Catalog=$singlePortalDB;Persist Security Info=True;$userSection',  'Microsoft SQL Server',  'Active',getdate(),getdate())"
		$insertOutput = ExecuteSQL -ServerInstance $sqlServer -Database $masterPortalDB -Username $dbUserName -Password $dbUserPassword -Query $insertQuery
		Write-Host "Record successfully inserted in table 'AgilePoint_Portal_Core_ShellSettingsRecord' from '$masterPortalDB'" -ForegroundColor DarkGreen
	}
	else
	{
		Write-Host "Record in table 'AgilePoint_Portal_Core_ShellSettingsRecord' from '$masterPortalDB' already exists. Updating..." -ForegroundColor DarkCyan
		$updateQuery = "UPDATE [$masterPortalDB].[dbo].[AgilePoint_Portal_Core_ShellSettingsRecord] SET [ConnectionString] = 'Data Source=$sqlServer;Initial Catalog=$singlePortalDB;Persist Security Info=True;$userSection',[DataProvider] = 'Microsoft SQL Server' WHERE NAME = '$portalInstallationName'"
		$udpateOutput = ExecuteSQL -ServerInstance $sqlServer -Database $masterPortalDB -Username $dbUserName -Password $dbUserPassword -Query $updateQuery
		Write-Debug-Message -functionName "Upsert-NX-Portal-ShellSettingRecord" -message "Record Content: $queryOutput"
	}
	
}

function Create-NX-Portal-Orchard()
{
	#Test MasterPortal DB Connection
	$dbConnection = Test-Db-Connection -sqlInstanceName $sqlServer -sqlDbName $masterPortalDB -sqlUserName $dbUserName -sqlUserPassword $dbUserPassword;
	$nxPortalStatus = Check-NX-Portal-Status;
	if($nxPortalStatus -eq 0)
	{
		Write-Host "NX Portal has already provided. Just Skip" -ForegroundColor Magenta;
	}
	if($nxPortalStatus -eq -1)
	{
		Write-Host "NX Portal needs to be provided..." -ForegroundColor Magenta;
		$sqlInstance = [string]::Format("{0}:{1}", $sqlServer,$sqlServerPort)
		Execute-NX-Portal-Recipe -sqlInstance $sqlServer;
	}
	if($nxPortalStatus -eq -2)
	{
		Upsert-NX-Portal-ShellSettingRecord
	}
	if($nxPortalStatus -eq -3)
	{
		#Provisioning Portal for the First Time
		Write-Host "NX Portal web request '$agilePointPortalUrl'...." -ForegroundColor Magenta;
		$responsePortal = Invoke-WebRequest -Uri $agilePointPortalUrl -UseBasicParsing
		$statusCode = $responsePortal.StatusCode
		Write-Host "NX Portal web request status Code: $statusCode" -ForegroundColor DarkGreen;
	}
	
	if($nxPortalStatus -eq -4)
	{
		#Status should be updated. Let's wait a while
		Write-Host "Provisioning has not been Started. Log into the Portal with Active Credential..." -ForegroundColor DarkCyan
		$urlLoginRequest = "$agilePointPortalUrl/login/ActiveDirectory?ReturnUrl=%2F"
		$Body = @{
			domain=$apServiceAccountDomain
			userNameOrEmail=$apServiceAccountUser
			password=$apServiceAccountPassword};
	
		Write-Debug-Message -functionName "Create-NX-Portal-Orchard" -message "Login Body: $Body"
		Write-Debug-Message -functionName "Create-NX-Portal-Orchard" -message "Login URL Request: $urlLoginRequest"

		$contentType = 'application/x-www-form-urlencoded' 
		
		$loginResponse = Invoke-WebRequest -Uri $urlLoginRequest -Body $Body -Method POST -ContentType $contentType
		$loginStatusCode = $loginResponse.StatusCode

		Write-Host "Login Response Status Code: $loginStatusCode" -ForegroundColor DarkCyan
		Start-Sleep -Seconds 30
	}

	if($nxPortalStatus -eq -5)
	{
		#Status should be updated. Let's wait a while
		Write-Host "Provisioning is on their way. Let't wait a while..." -ForegroundColor DarkCyan
		Start-Sleep -Seconds 30
	}
	
	return $nxPortalStatus;
}

function Execute-NX-Portal-Recipe()
{
	param([string]$sqlInstance)

	$exeFile = "$agilePointPortalWebFolder\bin\orchard.exe"
	
	$parsedDbUserPassword = $dbUserPassword.Replace('"','\"');
	$parsedApServiceAccountPassword = $apServiceAccountPassword.Replace('"','\"')

	$dbConnectionString = "/DatabaseConnectionString:""Data Source=$sqlInstance;Initial Catalog=$masterPortalDB;Persist Security Info=True;User ID=$dbUserName;Password=$parsedDbUserPassword;""";
	if($dbUserName -eq "" -and $dbUserPassword -eq "")
	{
		#trusted_Connection=yes
		$dbConnectionString = "/DatabaseConnectionString:""Data Source=$sqlInstance;Initial Catalog=$masterPortalDB;Persist Security Info=True;trusted_Connection=yes;""";
	}

	$argumentList = @("setup","/SiteName:""NXone""","/AdminUsername:""$apServiceAccountUser""","/AdminPassword:""$parsedApServiceAccountPassword""","/DatabaseProvider:""SQLServer""","/Recipe:""AgilePoint - Master""",$dbConnectionString,"/verbose:true");
	Write-Debug-Message -functionName "Execute-NX-Portal-Recipe" -message "Argument List: $argumentList"

	$settingsFile = "$agilePointPortalWebFolder\Config\settings.txt"

	if(Test-Path $settingsFile)
	{
		Remove-Item $settingsFile
	}

	& $exeFile $argumentList
}


function Insert-ConnectorRecord()
{
	param([string]$connectorName, [string]$connectorConfig, [string]$sqlInstance, [bool]$recreateRecord=$false, [bool]$updateRecord=$true)

	if(!$allowedConnectors.Contains($connectorName))
	{
		throw "Unknown '$connectorName' parameter value"
	}

	$dbConnection = Test-Db-Connection -sqlInstanceName $sqlInstance -sqlDbName $singleApDB -sqlUserName $dbUserName -sqlUserPassword $dbUserPassword;
	if($recreateRecord)
	{
		Write-Host "Deleting record first...." 
		$deleteQuery = [string]::Format("DELETE FROM [dbo].[WF_INTEGRATED_APPS] where APP_NAME='{0}'", $connectorName)
		$deleteCommand = ExecuteSQL -ServerInstance $sqlInstance -Database $singleApDB -Username $dbUserName -Password $dbUserPassword -Query $deleteQuery
	}

	$insertQuery = [string]::Format("INSERT INTO [dbo].[WF_INTEGRATED_APPS]([APP_NAME],[CFG_XML],[Created_DATE],[CREATED_BY]) VALUES('{0}','{1}', getdate(), '$apServiceAccountDomain\$apServiceAccountUser')", $connectorName, $connectorConfig)
	$updateQuery = [string]::Format("UPDATE [dbo].[WF_INTEGRATED_APPS] SET [CFG_XML]= '{1}' WHERE [APP_NAME] ='{0}'", $connectorName, $connectorConfig)
	$query= "Select * FROM [$singleApDB].[dbo].[WF_INTEGRATED_APPS] WHERE APP_NAME = '$connectorName'"
	$queryOutput = ExecuteSQL -ServerInstance $sqlInstance -Database $singleApDB -Username $dbUserName -Password $dbUserPassword -Query $query
	if($queryOutput -eq $null)
	{
		Write-Host "Inserting Connector '$connectorName' Record in table 'WF_INTEGRATED_APPS' ...."
		$insertOutput = ExecuteSQL -ServerInstance $sqlInstance -Database $singleApDB -Username $dbUserName -Password $dbUserPassword -Query $insertQuery
		Write-Host "Record successfully INSERTED in table 'WF_INTEGRATED_APPS' " -ForegroundColor DarkGreen
	}
	elseif($updateRecord -eq $true)
	{
		Write-Host "Record for connector '$connectorName' already exists in table 'WF_INTEGRATED_APPS'. Updating... " -ForegroundColor DarkCyan
		$insertOutput = ExecuteSQL -ServerInstance $sqlInstance -Database $singleApDB -Username $dbUserName -Password $dbUserPassword -Query $updateQuery
		Write-Host "Record successfully UPDATED in table 'WF_INTEGRATED_APPS' " -ForegroundColor DarkGreen
	}
	else
	{
		Write-Host "Record for connector '$connectorName' skipped" -ForegroundColor Magenta
	}
}

function Insert-AD-Connector()
{
	param($sqlInstance, $agileDialogsURL, $agileDialogsExternalURL, $agileDialogsPublicUrl, $notiReceiverUrl,$updateRecord=$true)
	
	$connectorConfig = [string]::Format("<?xml version=""1.0"" encoding=""utf-8""?><ConnectorConfiguration xmlns:xsd=""http://www.w3.org/2001/XMLSchema"" xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance""><AgileDialogsUrl>{0}</AgileDialogsUrl><AgileDialogsExternalConnectorUrl>{1}</AgileDialogsExternalConnectorUrl><AgileDialogsPublicConnectorUrl>{2}</AgileDialogsPublicConnectorUrl><AgileDialogsNotificationReceiverURL>{3}</AgileDialogsNotificationReceiverURL></ConnectorConfiguration>",$agileDialogsURL, $agileDialogsExternalURL, $agileDialogsPublicUrl, $notiReceiverUrl)

	Insert-ConnectorRecord -connectorName $adConnectorName -sqlInstance $sqlInstance -connectorConfig $connectorConfig -updateRecord $updateRecord
}

function Insert-PM-Connector()
{
	param($sqlInstance, $processManagerURL, $updateRecord=$true)
	
	$connectorConfig = [string]::Format("<?xml version=""1.0"" encoding=""utf-8""?><ProcessManagerConnectorConfiguration xmlns:xsd=""http://www.w3.org/2001/XMLSchema"" xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance""><AppFilterName>*</AppFilterName><ServerUrl>{0}/signalr/hubs</ServerUrl><ProcessManagerConnectorServerHubUrl /><SignalRClientEnabled>true</SignalRClientEnabled><SignalRServerEnabled>false</SignalRServerEnabled></ProcessManagerConnectorConfiguration>",$processManagerURL)

	Insert-ConnectorRecord -connectorName $pmConnectorName -sqlInstance $sqlInstance -connectorConfig $connectorConfig -updateRecord $updateRecord
}

function Insert-CRM-Connector()	
{
	param($sqlInstance, $azureAppId, $azureAppSecretKey, $d365UniqueName, $d365Urlj, $updateRecord=$true)

	$orgsUniqueId = $d365UniqueName.split(";");
	$orgsFullUrl = $d365Url.split(";");
	$crmConnectorDataFormat = "<NameValue><Name>{0}</Name><Value xsi:type=""xsd:string"">{1}</Value></NameValue>";
	$crmConnectorData="";
	$counter=0
	for ($counter=0; $counter -lt $orgsUniqueId.Length; $counter++)
	{
		$crmConnectorData += [string]::Format($crmConnectorDataFormat, $orgsUniqueId[$counter] ,$orgsFullUrl[$counter] );
	}

	$connectorConfig = [string]::Format("<?xml version=""1.0"" encoding=""utf-8""?><ConnectorConfiguration xmlns:xsd=""http://www.w3.org/2001/XMLSchema"" xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance""><DefaultServerUrl /><LogOnAsOtherUser>false</LogOnAsOtherUser><CrmDomain /><CrmUsername /><CrmPassword /><LogExceptionsToCrm>true</LogExceptionsToCrm><LicenseSynchronizerStartHour>0</LicenseSynchronizerStartHour><RetrierConfiguration><MaxNumberOfRetries>10</MaxNumberOfRetries><WaitTimeForRetry>500</WaitTimeForRetry></RetrierConfiguration><DeploymentType>PrivateCloud</DeploymentType><AzureClientSecret>{1}</AzureClientSecret><AzureApplicationId>{0}</AzureApplicationId><OrganizationUrls>{2}</OrganizationUrls></ConnectorConfiguration>",$azureAppId,$azureAppSecretKey, $crmConnectorData)

	Insert-ConnectorRecord -connectorName $crmConnectorName -sqlInstance $sqlInstance -connectorConfig $connectorConfig -updateRecord $updateRecord
}

function Insert-CRM-MT-Connector()
{
	param($sqlInstance, $azureAppId, $azureAppSecretKey, $d365UniqueName, $d365Url)
	
	$repoSection = "<TenantRepositoryType>$mtRepoType</TenantRepositoryType>"
	if($mtRepoType -eq "AzureTableStorage")
	{
		$repoSection += "<AzureStorageTableName>$azureStorageTableName</AzureStorageTableName><AzureStorageConnectionString>$azureStorageConnString</AzureStorageConnectionString>"
	}
	elseif ($mtRepoType -eq "Dataverse")
	{
		$repoSection += "<DataverseRepositoryUrl>$dvRepoUrl</DataverseRepositoryUrl><DataverseRepositoryClientId>$dvRepoClientId</DataverseRepositoryClientId><DataverseRepositoryClientSecret>$dvRepoClientSecret</DataverseRepositoryClientSecret><DataverseRepositoryOrganizationName>$dvRepoOrgUnqName</DataverseRepositoryOrganizationName><DataverseRepositoryPoolId>$dvRepoPoolId</DataverseRepositoryPoolId>"
	}

	$crmConnectorConfig = "<?xml version=""1.0"" encoding=""utf-8""?><ConnectorConfiguration xmlns:xsd=""http://www.w3.org/2001/XMLSchema"" xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance""><DefaultServerUrl /><LogOnAsOtherUser>false</LogOnAsOtherUser><CrmDomain /><CrmUsername /><CrmPassword /><LogExceptionsToCrm>true</LogExceptionsToCrm><LicenseSynchronizerStartHour>0</LicenseSynchronizerStartHour><RetrierConfiguration><MaxNumberOfRetries>5</MaxNumberOfRetries><WaitTimeForRetry>150</WaitTimeForRetry></RetrierConfiguration><DeploymentType>$deploymentType</DeploymentType><AzureClientSecret>$waadApplicationIdPassword</AzureClientSecret><AzureApplicationId>$waadApplicationId</AzureApplicationId><EnableCustomAttributesForTeamsMembers>true</EnableCustomAttributesForTeamsMembers><IsProd>false</IsProd><EnvironmentType>DEV</EnvironmentType>$repoSection</ConnectorConfiguration>"

	Insert-ConnectorRecord -connectorName $crmConnectorName -sqlInstance $sqlInstance -connectorConfig $crmConnectorConfig -updateRecord $false
	
}

function Insert-AzuOpe-Connector()
{
	param($sqlInstance)
	$serviceUrl = [string]::Format("https://{0}:{1}",$apiServiceHostName,"13499")
	
	$connectorConfigData = @{ServiceUrl=$serviceUrl
						AzureStorageConnectionString=$customStorageAzureConnString
						ValidAudienceAzureAppId=$envisionAppId
						RepositoryType=1} | ConvertTo-JSON
	
	Insert-ConnectorRecord -connectorName $azuOperationConnectorName -sqlInstance $sqlInstance -connectorConfig $connectorConfigData -updateRecord $false
	
}

function Insert-TM-Connnector()
{
	param($sqlInstance)
	
	$connectorConfig = "<?xml version=""1.0"" encoding=""utf-8""?><TenantManagerConnectorConfiguration xmlns:xsd=""http://www.w3.org/2001/XMLSchema"" xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance""><EnableDnsManagement>true</EnableDnsManagement><DnsProviderConfig xsi:type=""AzureDnsOptions""><DnsZoneName>$domainUrl</DnsZoneName><TenantId>$dnsTenantId</TenantId><ClientId>$dnsClientId</ClientId><ClientSecret>$dnsClientSecret</ClientSecret><SubscriptionId/><ResourceGroupName/></DnsProviderConfig><AdminAddress>$rawAdminPortalHostName</AdminAddress><EngineApiAddress>$apiServiceHostName</EngineApiAddress><InternalWebAppsAddress>$agileXrmHostName</InternalWebAppsAddress><ExternalWebAppsAddress>$externalAXrmHostName</ExternalWebAppsAddress><PublicWebAppsAddress>$publicAXrmHostName</PublicWebAppsAddress><EnableBlobStorageManagement>true</EnableBlobStorageManagement><StorageMangementFunctionUrl>$stoManFunctionUrl</StorageMangementFunctionUrl><StorageMangementFunctionKey>$stoManFunctionKey</StorageMangementFunctionKey></TenantManagerConnectorConfiguration>"

	Insert-ConnectorRecord -connectorName $tenantManagerConnectorName -sqlInstance $sqlInstance -connectorConfig $connectorConfig -updateRecord $false
}

function Insert-Orchard-Connector
{
	param($sqlInstance)
	
	$masterPortalDbConnString="Server=$sqlServerAliasName;database=$masterPortalDB;Integrated security=SSPI";
	if($isSqlAzure)
	{
		$azureInstanceName = $sqlServer.Split(".")[0];
		$masterPortalDbConnString = [string]::Format("Server={0};database={1};User ID={2};Password={3}", $sqlServerAliasName, $masterPortalDB, "$dbUserName@$azureInstanceName", $dbUserPassword);		
	}
	
	$connectorConfig = "<?xml version=""1.0"" encoding=""utf-8""?><APCConfiguration xmlns:xsd=""http://www.w3.org/2001/XMLSchema"" xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance""><CMSDatabaseConnectionString>$masterPortalDbConnString</CMSDatabaseConnectionString><CMSServiceURL /><CMSDBVendor>MSSQLDatabase</CMSDBVendor></APCConfiguration>"

	Insert-ConnectorRecord -connectorName $orchardConnectorName -sqlInstance $sqlInstance -connectorConfig $connectorConfig -updateRecord $false
}

function Test-Db-Connection()
{
	param([string]$sqlInstanceName, [string]$sqlInstancePort=$sqlServerPort, [string]$sqlDbName,[string]$sqlUserName, [string]$sqlUserPassword)

	Write-Host "Testing DB $sqlDbName in instance '$sqlInstanceName' with port '$sqlInstancePort' ..."

	$connectionString = [string]::Format("Server=tcp:{0},{1};Initial Catalog={4};Persist Security Info=False;User ID={2};Password={3};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;", $sqlInstanceName,$sqlInstancePort,$sqlUserName,$sqlUserPassword, $sqlDbName)
	if($sqlUserName -eq "" -and $sqlUserPassword -eq "")
	{
		$connectionString = [string]::Format("Server=tcp:{0},{1};Initial Catalog={2};Integrated Security=True;Min Pool Size=10;Max Pool Size=100;Load Balance Timeout=5;trusted_Connection=yes",$sqlInstanceName,$sqlInstancePort,$sqlDbName)
	}

	Write-Debug-Message -functionName "Test-Db-Connection" -message $connectionString

	$sqlConnection = New-Object System.Data.SqlClient.SqlConnection $connectionString

	try
	{
		$sqlConnection.Open()
		if($sqlConnection.State -eq "Open")
		{
			Write-Host "DB $sqlDbName in instance $sqlInstanceName is Up and Running" -ForegroundColor DarkGreen
			return $true
		}
		else
		{
			Write-Host "DB $sqlDbName is not yet ready. Let's retry in 5 seconds" -ForegroundColor Yellow
			Start-Sleep -Seconds 5
			return Test-Db-Connection -sqlInstanceName $sqlInstanceName -sqlInstancePort $sqlInstancePort -sqlDbName $sqlDbName -sqlUserName $sqlUserName -sqlUserPassword $sqlUserPassword
		}
	}
	catch
	{
		$message = $_
		Write-Debug-Message -functionName "Test-Db-Connection" -message $message 
		Write-Host "DB $sqlDbName is not yet ready. Let's retry in 10 seconds" -ForegroundColor Yellow
		Start-Sleep -Seconds 10
		return Test-Db-Connection -sqlInstanceName $sqlInstanceName -sqlInstancePort $sqlInstancePort -sqlDbName $sqlDbName -sqlUserName $sqlUserName -sqlUserPassword $sqlUserPassword
	}
	finally
	{
		$sqlConnection.Close()
	}
}

function Disable-NetflowFile-TaskScheduler()
{
	if($deploymentMode -eq "ST")
	{
		Write-Host "Disabling Task Scheduler for netflow file..." -ForegroundColor DarkCyan
		$taskName = "Update netflow.cfg"
		Disable-ScheduledTask -TaskName $taskName -ErrorAction Ignore
		Stop-ScheduledTask -TaskName $taskName -ErrorAction Ignore
		Get-ScheduledTask -TaskName $taskName -ErrorAction Ignore
		Write-Host "Task Scheduler for netflow file has been disabled!" -ForegroundColor DarkGreen
	}
	else
	{
		Write-Host "Disable-NetflowFile-TaskScheduler ONLY Applies to ST deployments" -ForegroundColor Magenta
	}
}

function Upsert-TenantAdminUser()
{
	$userAlias = [string]::Format("{0}\{1}",$internalDomainValue,$singleTenantAdminUser)
	$userAliasUppercase = $userAlias.ToUpper()

	$dbConnection = Test-Db-Connection -sqlInstanceName $sqlServer -sqlDbName $singleApDB -sqlUserName $dbUserName -sqlUserPassword $dbUserPassword 
	$query= "SELECT * FROM [$singleApDB].[dbo].[WF_REG_USERS] WHERE [USER_NAME_UPCASE] = '$userAliasUppercase'"
	$queryOutput = ExecuteSQL -ServerInstance $sqlServer -Database $singleApDB -Username $dbUserName -Password $dbUserPassword -Query $query
	
	
	if($queryOutput -eq $null)
	{
		Write-Host "Inserting Record in table 'WF_REG_USERS' from '$singleApDB'...."
		$insertQuery = "INSERT INTO [$singleApDB].[dbo].[WF_REG_USERS] ([USER_NAME_UPCASE], [USER_NAME], [FULL_NAME], [LOCALE], [DISABLED], [REGISTERED_DATE])  VALUES ( '$userAlias', '$userAliasUppercase',  'ST Tenant Admin User', 'es-us','NO',getdate())"
		$insertOutput = ExecuteSQL -ServerInstance $sqlServer -Database $singleApDB -Username $dbUserName -Password $dbUserPassword -Query $insertQuery
		Write-Host "Record successfully inserted in table 'WF_REG_USERS' from '$singleApDB'" -ForegroundColor DarkGreen
	}
	else
	{
		Write-Host "Record in table 'WF_REG_USERS' from '$singleApDB' already exists. Updating..." -ForegroundColor DarkCyan
		$updateQuery = "UPDATE [$singleApDB].[dbo].[WF_REG_USERS] SET [USER_NAME_UPCASE]='$userAliasUppercase', [USER_NAME]='$userAlias', [FULL_NAME]='ST Tenant Admin User' WHERE [USER_NAME] = '$userAlias'"
		$udpateOutput = ExecuteSQL -ServerInstance $sqlServer -Database $singleApDB -Username $dbUserName -Password $dbUserPassword -Query $updateQuery
		Write-Debug-Message -functionName "Upsert-TenantAdminUser" -message "Record Content: $queryOutput"
	}

	$query="SELECT * FROM WF_ASSIGNED_OBJECTS where (WF_ASSIGNED_OBJECTS.ROLE_NAME = N'ADMINISTRATORS') and (WF_ASSIGNED_OBJECTS.ASSIGNEE = N'$userAliasUppercase') and (WF_ASSIGNED_OBJECTS.ASSIGNEE_TYPE = 'User') and (WF_ASSIGNED_OBJECTS.OBJECT_ID = '00000000000000000000000000000000')"
	$queryOutput = ExecuteSQL -ServerInstance $sqlServer -Database $singleApDB -Username $dbUserName -Password $dbUserPassword -Query $query
	if($queryOutput -eq $null)
	{
		Write-Host "Inserting Record in table 'WF_ASSIGNED_OBJECTS' from '$singleApDB'...."
		$insertQuery = "INSERT INTO [$singleApDB].[dbo].[WF_ASSIGNED_OBJECTS] ([ROLE_NAME],[ASSIGNEE], [ASSIGNEE_TYPE], [OBJECT_ID], [OBJECT_TYPE], [CREATED_DATE], [CREATED_BY])  VALUES ( 'ADMINISTRATORS', '$userAliasUppercase',  'User', '00000000000000000000000000000000','All',getdate(),'$userAliasUppercase')"
		$insertOutput = ExecuteSQL -ServerInstance $sqlServer -Database $singleApDB -Username $dbUserName -Password $dbUserPassword -Query $insertQuery
		Write-Host "Record successfully inserted in table 'WF_ASSIGNED_OBJECTS' from '$singleApDB'" -ForegroundColor DarkGreen
	}
}

function Upsert-XrmSystemUser()
{
	param([string]$xrmSystemUser="xrm.system")
	$userAlias = [string]::Format("{0}\{1}",$internalDomainValue,$xrmSystemUser)
	$userAliasUppercase = $userAlias.ToUpper()
	$userFullName = "MT AXRM System Admin User"

	$dbConnection = Test-Db-Connection -sqlInstanceName $sqlServer -sqlDbName $singleApDB -sqlUserName $dbUserName -sqlUserPassword $dbUserPassword 
	$query= "SELECT * FROM [$singleApDB].[dbo].[WF_REG_USERS] WHERE [USER_NAME_UPCASE] = '$userAliasUppercase'"
	$queryOutput = ExecuteSQL -ServerInstance $sqlServer -Database $singleApDB -Username $dbUserName -Password $dbUserPassword -Query $query
	
	if($queryOutput -eq $null)
	{
		Write-Host "Inserting Record in table 'WF_REG_USERS' from '$singleApDB'...."
		$insertQuery = "INSERT INTO [$singleApDB].[dbo].[WF_REG_USERS] ([USER_NAME_UPCASE], [USER_NAME], [FULL_NAME], [LOCALE], [DISABLED], [REGISTERED_DATE])  VALUES ( '$userAlias', '$userAliasUppercase', '$userFullName', 'es-us','NO',getdate())"
		$insertOutput = ExecuteSQL -ServerInstance $sqlServer -Database $singleApDB -Username $dbUserName -Password $dbUserPassword -Query $insertQuery
		Write-Host "Record successfully inserted in table 'WF_REG_USERS' from '$singleApDB'" -ForegroundColor DarkGreen
	}
	else
	{
		Write-Host "Record in table 'WF_REG_USERS' from '$singleApDB' already exists. Updating..." -ForegroundColor DarkCyan
		$updateQuery = "UPDATE [$singleApDB].[dbo].[WF_REG_USERS] SET [USER_NAME_UPCASE]='$userAliasUppercase', [USER_NAME]='$userAlias', [FULL_NAME]='$userFullName' WHERE [USER_NAME] = '$userAlias'"
		$udpateOutput = ExecuteSQL -ServerInstance $sqlServer -Database $singleApDB -Username $dbUserName -Password $dbUserPassword -Query $updateQuery
		Write-Debug-Message -functionName "Upsert-TenantAdminUser" -message "Record Content: $queryOutput"
	}

	$query = "SELECT * FROM [MasterAPDB].[dbo].[WF_GROUP_MEMBERS] where MEMBER = N'$userAliasUppercase'";
	
	$queryOutput = ExecuteSQL -ServerInstance $sqlServer -Database $singleApDB -Username $dbUserName -Password $dbUserPassword -Query $query
	if($queryOutput -eq $null)
	{
		Write-Host "Inserting Record in table 'WF_GROUP_MEMBERS' from '$singleApDB'...."
		$createdBy = [string]::Format("{0}\{1}",$apServiceAccountDomain ,$apServiceAccountUser);

		$insertQuery = "INSERT INTO [$singleApDB].[dbo].[WF_GROUP_MEMBERS] ([NAME],[DESCRIPTION],[CREATED_DATE],[CREATED_BY],[ENABLED],[MEMBER]) VALUES ('GLOBAL ADMINISTRATORS', '', getdate(), '$createdBy','Yes','$userAliasUppercase')"
		$insertOutput = ExecuteSQL -ServerInstance $sqlServer -Database $singleApDB -Username $dbUserName -Password $dbUserPassword -Query $insertQuery

		Write-Host "Record successfully inserted in table 'WF_GROUP_MEMBERS' from '$singleApDB'" -ForegroundColor DarkGreen
	}
	else
	{
		Write-Host "Record for AXRM System User already exists in 'WF_GROUP_MEMBERS' from '$singleApDB'. Skipped!" -ForegroundColor Magenta
	}
}

function Modify-Role-Access-Rights($roleName ="Administrators")
{
	if($deploymentMode -eq "MT")
	{
		Write-Host "Modify-Role-Access-Rights doesn't apply to 'MT' deployments. Skipped." -ForegroundColor Magenta
		return;
	}

	if($roleName -eq "" -or $roleName -eq $null)
	{
		Write-Host "Parameter 'roleName' can't be empty to update access Rights." -ForegroundColor Magenta
		return;
	}

	$accessRightFlags="YYYNYNYYYYYYYYYYYYYYNYYYYYYYYNNNNNNYYNYYYNYYYYYYYYYYYYYYYYYYYYYYYYYYYYNNNNNNNNYNYNNNNYNNNNYYNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN"

	$dbConnection = Test-Db-Connection -sqlInstanceName $sqlServer -sqlDbName $singleApDB -sqlUserName $dbUserName -sqlUserPassword $dbUserPassword 
	Write-Host "Updating AccessRights for Role '$roleName'..." -ForegroundColor DarkCyan
	$updateQuery = [string]::Format("UPDATE [{0}].[dbo].[WF_ROLES] SET [RIGHT_FLAGS]='{1}' WHERE [NAME_UPCASE] = '{2}'", $singleApDB, $accessRightFlags, $roleName.ToUpper());
	$udpateOutput = ExecuteSQL -ServerInstance $sqlServer -Database $singleApDB -Username $dbUserName -Password $dbUserPassword -Query $updateQuery
	Write-Debug-Message -functionName "Modify-Role-Access-Rights" -message "Record Content: $queryOutput"	
	Write-Host "AccessRights has been updated for Role '$roleName'!" -ForegroundColor DarkGreen

}

function Customize-Nx-Portal-For-AgileXRM()
{
	if($customizeNxPortal -eq $false)
	{
		Write-Host "Customizing NX Portal is disabled for this execution. Please set variable 'customizeNxPortal' to true if you want to use this feature" -ForegroundColor Magenta
		return;
	}

	#Web Config Portal Configurations
	Modify-AppSetings-Key -configFilePath "$agilePointPortalWebFolder\web.config" -keyName "AppBuilderAppPath" -keyValue "" ;
	Modify-AppSetings-Key -configFilePath "$agilePointPortalWebFolder\web.config" -keyName "ReportsAppPath" -keyValue "" ;
	Modify-AppSetings-Key -configFilePath "$agilePointPortalWebFolder\web.config" -keyName "ReportsAppPath" -keyValue "" ;
	Modify-AppSetings-Key -configFilePath "$agilePointPortalWebFolder\web.config" -keyName "ReportsAuthMode" -keyValue "" ;
	Modify-AppSetings-Key -configFilePath "$agilePointPortalWebFolder\web.config" -keyName "ReportsExternalAppPath" -keyValue "" ;
	Modify-AppSetings-Key -configFilePath "$agilePointPortalWebFolder\web.config" -keyName "ReportsSecureKeyAppPath" -keyValue "" ;
	Modify-AppSetings-Key -configFilePath "$agilePointPortalWebFolder\web.config" -keyName "sf:AuthorizationEndpoint_sandbox" -keyValue "" ;
	Modify-AppSetings-Key -configFilePath "$agilePointPortalWebFolder\web.config" -keyName "sf:TokenEndpoint_sandbox" -keyValue "" ;
	Modify-AppSetings-Key -configFilePath "$agilePointPortalWebFolder\web.config" -keyName "sf:UserinfoEndpoint_sandbox" -keyValue "" ;
	Modify-AppSetings-Key -configFilePath "$agilePointPortalWebFolder\web.config" -keyName "AmazonRegion" -keyValue "" ;
	Modify-AppSetings-Key -configFilePath "$agilePointPortalWebFolder\web.config" -keyName "SalesEmailID" -keyValue "" ;
	Modify-AppSetings-Key -configFilePath "$agilePointPortalWebFolder\web.config" -keyName "Office365Store" -keyValue "" ;
	Modify-AppSetings-Key -configFilePath "$agilePointPortalWebFolder\web.config" -keyName "AppleStoreUrl" -keyValue "" ;
	Modify-AppSetings-Key -configFilePath "$agilePointPortalWebFolder\web.config" -keyName "WindowsPhoneStoreUrl" -keyValue "" ;
	Modify-AppSetings-Key -configFilePath "$agilePointPortalWebFolder\web.config" -keyName "DemoAppsPackageEnabled" -keyValue "false" ;
	Modify-AppSetings-Key -configFilePath "$agilePointPortalWebFolder\web.config" -keyName "AndroidStoreUrl" -keyValue "" ;
	Modify-AppSetings-Key -configFilePath "$agilePointPortalWebFolder\web.config" -keyName "ShowWelcomePopup" -keyValue "false" ;
	Modify-AppSetings-Key -configFilePath "$agilePointPortalWebFolder\web.config" -keyName "MarketPlaceUrl" -keyValue "" ;
	Modify-AppSetings-Key -configFilePath "$agilePointPortalWebFolder\web.config" -keyName "DocumentationHelpLink" -keyValue "https://docs.agilexrm.com" ;
	Modify-AppSetings-Key -configFilePath "$agilePointPortalWebFolder\web.config" -keyName "FAQHelpLink" -keyValue "" ;
	Modify-AppSetings-Key -configFilePath "$agilePointPortalWebFolder\web.config" -keyName "ShowEvaluationMessage" -keyValue "false" ;
	Modify-AppSetings-Key -configFilePath "$agilePointPortalWebFolder\web.config" -keyName "sf:UserinfoEndpoint" -keyValue "" ;
	Modify-AppSetings-Key -configFilePath "$agilePointPortalWebFolder\web.config" -keyName "SalesforceAppUrl" -keyValue "" ;
	Modify-AppSetings-Key -configFilePath "$agilePointPortalWebFolder\web.config" -keyName "ShowHowToVideos" -keyValue "false" ;
	Modify-AppSetings-Key -configFilePath "$agilePointPortalWebFolder\web.config" -keyName "StatusPageUrl" -keyValue "" ;
	
	#em.settings.xml File Configuration
	Modify-XML-Node -xmlFilePath "$agilePointPortalWebFolder\Modules\AgilePoint.Portal.Manage\Content\em.settings.xml" -nodePath "" -nodeName "Debug" -nodeValue "false" ;
	Modify-XML-Node -xmlFilePath "$agilePointPortalWebFolder\Modules\AgilePoint.Portal.Manage\Content\em.settings.xml" -nodePath "" -nodeName "enableEventServices" -nodeValue "false" ;
	Modify-XML-Node -xmlFilePath "$agilePointPortalWebFolder\Modules\AgilePoint.Portal.Manage\Content\em.settings.xml" -nodePath "" -nodeName "enableDataTracking" -nodeValue "false" ;
	
	#Modify Admin Role Access Rights
	Modify-Role-Access-Rights
}

function ExecuteSQL()
{
	#-ServerInstance $sqlServer -Database $masterPortalDB -Username $dbUserName -Password $dbUserPassword -Query $query
	param([string]$ServerInstance, [string]$Database,[string]$Username, [string]$Password, [string]$Query, [System.Management.Automation.ActionPreference]$ErrorAction)
	
	if($ErrorAction -eq $null)
	{
		$ErrorAction = $ErrorActionPreference
	}
	
	
	if($Username -eq "" -and $Password -eq "")
	{
		$queryOutput = Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database -Query $Query -ErrorAction $ErrorAction
		return $queryOutput
	}
	else
	{
	    $queryOutput = Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database -Username $Username -Password $Password -Query $Query -ErrorAction $ErrorAction
		return $queryOutput
	}
}

function Apply-Post-Installation-For-MT()
{
	if($deploymentMode -ne "MT")
	{
		Write-Host "This is NOT a Multi Tenant Deployment. 'Apply-Post-Installation-For-MT' configuration doesn't apply" -foregroundcolor darkCyan
		return;
	}

	$isApServiceUpAndRunning = Check-AP-Service-Status;
	if(! $isApServiceUpAndRunning)
	{
		Write-Error "Service is not running. Provisioning has failed. Please review and reexecute";
		exit -1;
	}
	
	#X - Check DB Connection to MasterPortalDB
	$dbConnection = Test-Db-Connection -sqlInstanceName $sqlServer -sqlDbName $masterPortalDB -sqlUserName $dbUserName -sqlUserPassword $dbUserPassword 

	#X - Check DB Connection to SinglePortalDB
	$dbConnection = Test-Db-Connection -sqlInstanceName $sqlServer -sqlDbName $singlePortalDB -sqlUserName $dbUserName -sqlUserPassword $dbUserPassword 

	#x - Create NX Portal Orchard
	$attemp = 0;
	$nxPortalStatus = Create-NX-Portal-Orchard;
	Write-Host "Create NX Portal Status is $nxPortalStatus" -ForegroundColor DarkCyan;
	while ($nxPortalStatus -ne 0 -and $attemp -lt 15)
	{
		$nxPortalStatus = Create-NX-Portal-Orchard;
		Write-Host "--Attemp $attemp .Create NX Portal Status is $nxPortalStatus" -ForegroundColor DarkCyan;
		$attemp++;
		Start-Sleep -Milliseconds 5000;
	}
	
	#Create Connectors Records
	Insert-AD-Connector -sqlInstance $sqlServer -agileDialogsURL $agileDialogsUrl -agileDialogsExternalURL $agileDialogsExternalUrl -agileDialogsPublicUrl $agileDialogsPublicUrl -notiReceiverUrl $notiReceiverUrl -updateRecord $false;
	Insert-PM-Connector -sqlInstance $sqlServer -processManagerURL $processManagerUrl -updateRecord $false;
	Insert-CRM-MT-Connector -sqlInstance $sqlServer -azureAppId $waadApplicationId -azureAppSecretKey $waadApplicationIdPassword -d365UniqueName $singleTenantCrmOrgUniqueId -d365Url $singleTenantCrmOrgFullUrl;
	Insert-AzuOpe-Connector -sqlInstance $sqlServer
	Insert-TM-Connnector -sqlInstance $sqlServer
	Insert-Orchard-Connector -sqlInstance $sqlServer
	
	#Upsert AgileXRM System User for Tenant Deployments:
	Upsert-XrmSystemUser;
	
}
function Backup-Config-Files()
{

	if(Test-Path -Path $backupFilesScript)
	{
		Write-Host "Executing '$backupFilesScript' file...." -ForegroundColor DarkCyan;

		$dbAuthSection = ""
		$dbSection="-db1:'$singleApDB' -db2:'$masterPortalDB' -sqlInstance:'$sqlInstance' "
		if($isSqlAzure)
		{
			$azureInstanceName = $sqlServer.Split(".")[0];
			$dbAuthSection = "-dbUserName:'$dbUserName@$azureInstanceName' -dbUserPassword:'$dbUserPass' -isSQLAzure "
		}
		
		try
		{
			Invoke-Expression "& `"$backupFilesScript`" $dbSection $dbAuthSection "
		}
		catch
		{
			Write-Host "Something went wrong during backup config files execution!" -ForegroundColor Magenta;
		}

		Write-Host "'$backupFilesScript' file executed!" -ForegroundColor DarkGreen;
	}
	else
	{
		Write-Host "File $backupFilesScript Not FOUND!" -ForegroundColor Magenta;
	}
}

######################END FUNCTIONS########################################################################
Backup-Config-Files;

$numberOfIpsInsideOfNic = 2
if($deploymentMode -eq "MT")
{
	Write-Host "This is a Multitenant Deployment. Detecting network configuration..." -foregroundcolor darkCyan

	#Connection Details with Service Principal
	if($svcPrincipalAppId -eq $svcPrincipalSecretKey)
	{
		Write-Host "Adding User Identity Manage account to context..."
		Add-AzAccount -Identity -TenantId $tenantId -SubscriptionId $subscriptionId -AccountId $svcPrincipalAppId
	}
	else
	{
		$securePass = ConvertTo-SecureString -String $svcPrincipalSecretKey -AsPlainText -Force;
		$adminCredential = New-Object System.Management.Automation.PSCredential $svcPrincipalAppId, $securePass
		Connect-AzAccount -Credential $adminCredential -Tenant $tenantId -SubscriptionId $subscriptionId -ServicePrincipal
	}
	if($primaryNicName -eq $publicNicName -and $primaryNicName -eq $portalNicName)
	{
		$numberOfIpsInsideOfNic=4
	}
	$targetNicName = $publicNicName
	#Configure VM Network Adapters
	$networkInterface = Get-NetworkInterface -nicName $targetNicName
	$result = Get-NIC-IpAddresses -networkInterface $networkInterface -numberOfIpsInsideOfNic $numberOfIpsInsideOfNic
	Write-Host "Result from Get-NIC-IpAddresses '$result' Expected is '0' " -foregroundcolor DarkCyan
	Write-Host "PrimaryNic IP Address 1: $global:primaryNicIpAddress1" -foregroundcolor DarkGreen
	Write-Host "PrimaryNic IP Address 2: $global:primaryNicIpAddress2" -foregroundcolor DarkGreen

	#if( ($global:primaryNicIpAddress1 -ne $null) -and ($global:primaryNicIpAddress2 -ne $null))
	if ($global:primaryNicIpAddresses -ne $null) 
	{
		Create-Adapter-IP-Addresses -ipAddresess $global:primaryNicIpAddresses
	}
}
#Retrieve VM IP Addresses

#Internal Site IP (1st)
if($deploymentMode -eq "ST")
{
	$ipAddresses = Get-IP-Addresses -interfaceAlias "Ethernet*";
	$primaryNicIpAddress = $ipAddresses;
}
else
{
	if($numberOfIpsInsideOfNic -eq "2")
	{
		$networkInterface = Get-NetworkInterface -nicName $primaryNicName 
		$result = Get-NIC-IpAddress -networkInterface $networkInterface
		if ($result -ne "0")
		{
			Write-Error "Error Geting AXRM Main Adapter Address" -Category InvalidResult		
		}
		$primaryNicIpAddress = $global:outputNicIpAddress;
	}
	else
	{
		$primaryNicIpAddress = $global:primaryNicIpAddresses[0];
	}
}

#API IP (2nd)
if($deploymentMode -eq "ST")
{
	$secondaryNicIpAddress = $primaryNicIpAddress;
}
else
{
	$networkInterface = Get-NetworkInterface -nicName $apiNicName 
	$result = Get-NIC-IpAddress -networkInterface $networkInterface
	if ($result -ne "0")
	{
		Write-Error "Error Geting API Adapter Address" -Category InvalidResult		
	}
	$secondaryNicIpAddress = $global:outputNicIpAddress;
}

#Public Site IP (3rd)
#External Site IP (4th)
if($deploymentMode -eq "ST")
{
	$thirdNicIpAddress = $primaryNicIpAddress;
	$fourthNicIpAddress = $primaryNicIpAddress;
}
else
{
	if($numberOfIpsInsideOfNic -eq "2")
	{
		$thirdNicIpAddress = $global:primaryNicIpAddress1;
		$fourthNicIpAddress = $global:primaryNicIpAddress2;
	}
	else
	{
		$thirdNicIpAddress = $global:primaryNicIpAddresses[1];
		$fourthNicIpAddress = $global:primaryNicIpAddresses[2];
	}
}

#Portal Site IP (5th)
if($deploymentMode -eq "ST")
{
	$fifthNicIpAddress = $primaryNicIpAddress;
}
else
{	
	if($numberOfIpsInsideOfNic -eq "2")
	{
		$networkInterface = Get-NetworkInterface -nicName $portalNicName 
		$result = Get-NIC-IpAddress -networkInterface $networkInterface
		if ($result -ne "0")
		{
			Write-Error "Error Geting PORTAL Adapter Address" -Category InvalidResult		
		}
		$fifthNicIpAddress = $global:outputNicIpAddress;
	}
	else
	{
		$fifthNicIpAddress = $global:primaryNicIpAddresses[3];
	}
}

Write-Host "1st IP: $primaryNicIpAddress" -f DarkGreen;
Write-Host "2nd IP: $secondaryNicIpAddress" -f DarkGreen;
Write-Host "3rd IP: $thirdNicIpAddress" -f DarkGreen;
Write-Host "4th IP: $fourthNicIpAddress" -f DarkGreen;
Write-Host "5th IP: $fifthNicIpAddress" -f DarkGreen;

Disable-NetflowFile-TaskScheduler;
Check-APService-Password;
Remove-Old-AgileXRMOnline-Certs;
Remove-Old-AgileXRMOnline-Certs -certSubjectName $certificateAdminPortalSubjectName;
Remove-Old-AgileXRMOnline-Certs -certSubjectName $certificateApiSubjectName;

Configure-AgilePointService;
Configure-AgilePointPortal;
Configure-AgilePointServerManagerConf;
Configure-AgileXRMSites;
Update-Registry-Keys;

Update-AppImpersonationEntry-File;
Update-netflow-Cfg-File;
Update-Hosts-File;
Fix-NetworkAdapters-Gateway
Create-Local-Users

#Force Machine Local Time to "UTC"
Set-TimeZone -Id "UTC" -PassThru

# Check DB Connection to SingleApDB
if($isSqlAzure)
{
	$dbConnection = Test-Db-Connection -sqlInstanceName $sqlServer -sqlDbName $singleApDB -sqlUserName $dbUserName -sqlUserPassword $dbUserPassword 

    #X - Modify SingleAPDB "READ_COMMITED_SNAPSHOT" property
	ModifyReadCommittedSnapshot -sqlInstanceName $sqlServer -sqlDbName $singleApDB -sqlUserName $dbUserName -sqlUserPassword $dbUserPassword
}

Start-Services;

Apply-Post-Installation;
Apply-Post-Installation-For-MT;

Customize-Nx-Portal-For-AgileXRM

Stop-Transcript

if($autoRestart)
{
	Restart-Computer -Force;
}
else
{
	$title    = 'Server needs to reboot. Before to proceed check there are no errors and proceed to reboot'
	$question = 'Are you sure you want to proceed now?'
	$choices  = '&Yes', '&No'
	$decision = $Host.UI.PromptForChoice($title, $question, $choices, 0)
	if ($decision -eq 0) 
	{
		Restart-Computer -Force;
	} 
	else 
	{
		Write-Host "Review script execution, fix any parameter(s) and execute script again" -ForegroundColor Yellow
	}
}
