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
	[string]$appUrlSeparator=".",
	[string]$domainUrl="agilexrmonline.com",
	[string]$mainHostName="pool",
	[string]$portalPort="443",
	[string]$azureAdRealm = "https://axrm.agilexrmonline.com",
	[string]$deploymentMode ="MT",
	[string]$deploymentType ="Cloud",
	[string]$localUsersPassword ="Default@1", 
	[string]$waadWcfAppId = "19e4137f-55ae-4dbf-9fbc-e386bbf36304",
	[string]$waadWcfAppIdUri = "https://ws.agilexrmonline.com:13487/AgilePointServer",
	[string]$waadApplicationId = "81c01359-21c1-467f-a3a8-52f5d6721fa0",
	[string]$waadApplicationIdPassword = $null,
	[string]$envisionAppId = "583a4e00-bcf2-4fbb-b346-6c90c376f160",
	[string]$singleTenantCrmOrgUniqueId ="ORGYYYYY" ,
	[string]$singleTenantCrmOrgFullUrl ="https://myorgyyy.crm4.dynamics.com",
	[string]$certificateSubjectName= "CN=agilexrmonline.com",
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
	[bool]$customizeNxPortal = $false

)

Start-Transcript -Path "C:\Temp\PSWStartVM.log"

if (Get-Module -ListAvailable -Name Microsoft.Xrm.Data.PowerShell) 
{
	Write-Host "Module 'Microsoft.Xrm.Data.PowerShell' already installed" -ForegroundColor DarkGreen;
}
else
{
	Write-Host "Module 'Microsoft.Xrm.Data.PowerShell' NOT Found. Installing..." -ForegroundColor DarkCyan;
	Install-Module -Name Microsoft.Xrm.Data.PowerShell -force
}

if (Get-Module -ListAvailable -Name Microsoft.Xrm.Data.PowerShell) 
{
	Write-Host "Module 'SqlServer ' already installed" -ForegroundColor DarkGreen;
}
else
{
	Write-Host "Module 'SqlServer ' NOT Found. Installing..." -ForegroundColor DarkCyan;
	Install-Module -Name SqlServer -force
}

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

$adminPortalAlias = "admin"
$apiAlias = "api"
$externalAlias="external"
$publicAlias ="public"
$portalAlias = "portal"
$hostName = "$mainHostName$regionNumber$poolNumber"

$netTcpRaw = "nettcp.agilexrmonline.com"

$tcpAgilePointUrl = [string]::Format( "tcp://ap-{0}.nx{1}.agilexrmonline.com:13489/AgilePointServer", $poolNumber, $regionNumber);
$nettcpAgilePointUrl = [string]::Format( "net.tcp://{0}{1}{2}.{3}:13488/AgilePointServer/", $hostName,$appUrlSeparator,$apiAlias,$domainUrl);
$nettcpAgilePointUrl = [string]::Format( "net.tcp://{0}:13488/AgilePointServer/", $netTcpRaw)
$apiRestUrl =  [string]::Format( "https://{0}{1}{2}.{3}/AgilePointServer/", $hostName,$appUrlSeparator,$apiAlias,$domainUrl);
$apiWsUrl = [string]::Format( "https://{0}{1}{2}.{3}:13487/AgilePointServer/", $hostName,$appUrlSeparator,$apiAlias,$domainUrl);
$agileXrmUrl = [string]::Format( "https://{0}.{1}", $hostName,$domainUrl);
$agilePointPortalUrl = [string]::Format( "https://{0}{1}{2}.{3}:{4}", $hostName, $appUrlSeparator, $adminPortalAlias, $domainUrl, $portalPort);
$notificationReceiverUrl = [string]::Format("http://{0}:8888/AgileDialogs/NotificationReceiver/NotificationReceiver.svc",$env:computername);
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

$agileXrmWildcardHostName = [string]::Format( "{0}.{1}", "*", $domainUrl);
$adminPortalWildcardHostName = [string]::Format( "{0}{1}{2}.{3}", "*", $appUrlSeparator, $adminPortalAlias, $domainUrl);
$apiWildcardHostName = [string]::Format( "{0}{1}{2}.{3}", "*", $appUrlSeparator, $apiAlias, $domainUrl);
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

$publicAgileXrmWebFolder = "C:\Program Files\AgileXRM\PublicWebApps";
$notificationReceiverPublicUrl = [string]::Format("http://{0}:8889/AgileDialogs/NotificationReceiver/NotificationReceiver.svc",$env:computername);
$agileXrmPublicUrl = [string]::Format( "https://{0}{1}{2}.{3}",  $hostName,$appUrlSeparator,$publicAlias,$domainUrl);
$agileDialogsPublicUrl = "$agileXrmPublicUrl/AgileDialogs";
$processManagerPublicUrl = "$agileXrmPublicUrl/XRMProcessViewer";

$externalAgileXrmWebFolder = "C:\Program Files\AgileXRM\ExternalWebApps";
$notificationReceiverExternalUrl = [string]::Format("http://{0}:8890/AgileDialogs/NotificationReceiver/NotificationReceiver.svc",$env:computername);
$agileXrmExternalUrl = [string]::Format( "https://{0}{1}{2}.{3}", $hostName,$appUrlSeparator,$externalAlias,$domainUrl);
$agileDialogsExternalUrl = "$agileXrmExternalUrl/AgileDialogs";
$processManagerExternalUrl ="$agileXrmExternalUrl/XRMProcessViewer";

$global:apServiceAccountPassword = $apServiceAccountPassword

$adConnectorName = "AgileDialogs";
$pmConnectorName = "XRMProcessViewer";
$crmConnectorName ="CrmConnector";

$portalInstallationName="DEFAULTTENANT";
$sqlServerAliasName = "SQL400";

###################### FUNCTIONS########################################################################

function Create-Adapter-IP-Addresses()
{
	param([string]$primaryIP="10.0.0.4", [string]$secondaryIP="10.0.0.12")
	
	Write-Host "Create-Adapter-IP-Addresses>> Execution for IP1 $primaryIP and IP2 $secondaryIP" -foregroundcolor DarkCyan
	$MaskBits = 28 # This means subnet mask = 255.255.255.240
	$dnsAddresses = @("168.63.129.16","8.8.8.8")
	$IPType = "IPv4"

	$adapterName = ((Get-NetAdapter | Get-NetIPConfiguration) | ? {$_.IPv4Address.IpAddress -eq $primaryIP}).InterfaceAlias
	if($adapterName -eq "")
	{
		Write-Host "Create-Adapter-IP-Addresses>> AdapterName not found!! Something is wrong"
		return -1;
	}
	
	# Retrieve the network adapter that you want to configure
	$adapter = Get-NetAdapter | ? {$_.Status -eq "up" -and $_.Name -eq $adapterName}
	
	
	if(($adapter | Get-NetIPConfiguration).IPv4Address.IPAddress.Count -eq 2)
	{
		Write-Host "Create-Adapter-IP-Addresses>> 2 IP Addresses have been found in Adapter $adapterName . Exit without touching anything " -foregroundcolor DarkGray
		return;
	}
	
	# Remove any existing IP, gateway from our ipv4 adapter
	If (($adapter | Get-NetIPConfiguration).IPv4Address.IPAddress) {
		$adapter | Remove-NetIPAddress -AddressFamily $IPType -Confirm:$false
	}
	If (($adapter | Get-NetIPConfiguration).Ipv4DefaultGateway) {
		$adapter | Remove-NetRoute -AddressFamily $IPType -Confirm:$false
	}
	
	# Configure the IP address and default gateway
	if($primaryIP -ne $null)
	{
		$adapter | New-NetIPAddress `
			-AddressFamily $IPType `
			-IPAddress $primaryIP `
			-PrefixLength $MaskBits `
			-DefaultGateway $defaultGateway
	}

	if($secondaryIP -ne $null)
	{
		$adapter | New-NetIPAddress `
			-AddressFamily $IPType `
			-IPAddress $secondaryIP `
			-PrefixLength $MaskBits 
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
    $certificate = Get-ChildItem -path cert:\LocalMachine\My | where{ $_.Subject -eq $certificateSubjectName } |  Sort-Object -Property NotAfter -Descending  | Select-Object -First 1;
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

	$command = "http delete sslcert hostnameport=*.api.$domainUrl`:13487";
	Write-Host "Delete-sslcert-entries>> Command to execute: $command";
	$command | netsh;

	$command = "http delete sslcert hostnameport=*.api.$domainUrl`:443";
	Write-Host "Delete-sslcert-entries>> Command to execute: $command";
	$command | netsh;

	$command = "http delete sslcert hostnameport=*.api.$domainUrl`:13499";
	Write-Host "Delete-sslcert-entries>> Command to execute: $command";
	$command | netsh;

	$command = "http delete sslcert hostnameport=pool499.api.agilexrmonline.com:13487";
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
	
	$command = "http delete sslcert hostnameport=*.external.$domainUrl`:443";
	Write-Host "Delete-sslcert-entries>> Command to execute: $command";
	$command | netsh;
	
	$command = "http delete sslcert hostnameport=*.public.$domainUrl`:443";
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
	
	$hostnameport = $wsServiceHostName+":13487";
	$command = "http delete sslcert hostnameport="+$hostnameport;
	Write-Host "Delete-sslcert-entries>> Command to execute: $command";
	$command | netsh;

	$hostnameport = $restServiceHostName+":443";
	$command = "http delete sslcert hostnameport="+$hostnameport;
	Write-Host "Delete-sslcert-entries>> Command to execute: $command";
	$command | netsh;

	$hostnameport = $apiServiceHostName+":13499";
	$command = "http delete sslcert hostnameport="+$hostnameport;
	Write-Host "Delete-sslcert-entries>> Command to execute: $command";
	$command | netsh;

	$hostnameport = $agileXrmHostName+":443";
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
	$hostnameport = $wsServiceHostName+":13487";
	Add-sslcert-entry -hostnameport $hostnameport -certHash $certHash -appId $appId

	$hostnameport = $restServiceHostName+":443";
	Add-sslcert-entry -hostnameport $hostnameport -certHash $certHash -appId $appId

	$hostnameport = $apiServiceHostName+":13499";
	Add-sslcert-entry -hostnameport $hostnameport -certHash $certHash -appId $appId

	$hostnameport = $reportsHostName+":443";
	Add-sslcert-entry -hostnameport $hostnameport -certHash $certHash -appId $appId
	
	$hostnameport = $adminPortalHostName;
	Add-sslcert-entry -hostnameport $hostnameport -certHash $certHash -appId $appId

	$ipport = $primaryNicIpAddress+":443";
	Add-sslcert-entry -property "ipport" -hostnameport $ipport -certHash $certHash -appId $appId

	if($deploymentMode -eq "ST")
	{
    	$hostnameport = $agileXrmHostName+":443"
		Add-sslcert-entry -hostnameport $hostnameport -certHash $certHash -appId $appId

    	$hostnameport = $externalAXrmHostName+":443"
		Add-sslcert-entry -hostnameport $hostnameport -certHash $certHash -appId $appId
	
    	$hostnameport = $publicAXrmHostName+":443"
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
	
		$hostnameport =[string]::Format("*.{0}.{1}:{2}",$apiAlias,$domainUrl,"443")
		Add-sslcert-entry -hostnameport $hostnameport -certHash $certHash -appId $appId

		$hostnameport =[string]::Format("*.{0}.{1}:{2}",$apiAlias,$domainUrl,"13487")
		Add-sslcert-entry -hostnameport $hostnameport -certHash $certHash -appId $appId

		$hostnameport =[string]::Format("*.{0}.{1}:{2}",$apiAlias,$domainUrl,"13499")
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
function Configure-Services-SSLCert()
{
	$certHash = Get-Last-AgileXRM-Online-Cert-Thumbprint;
	#delete
	Delete-sslcert-entries;

    # Add
	Add-sslcert-entries -certHash $certHash;
	
    #Add PrivateKey Read Permission for APService user 	
	
	#Set permissions to AgileXRMOnline Certificate
	[string]$permission_=[System.Security.AccessControl.FileSystemRights]::Read;
	[string]$certStoreLocation_="Localmachine\My";
	[string]$userName_= $env:computername+"\APservice";
	[string]$everyone= "everyone";

	[string]$adminUserName = ".\APService";
	$securePass = ConvertTo-SecureString -String $global:apServiceAccountPassword -AsPlainText -Force;
	$adminCredential = New-Object System.Management.Automation.PSCredential $adminUserName, $securePass

	Invoke-Command -Credential $adminCredential  -ComputerName $env:COMPUTERNAME -ScriptBlock $executionCommand  -ArgumentList $userName_,$permission_,$certStoreLocation_,$certHash;

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
	param([string]$siteName, [string]$hostName="", [string]$ipAddress = "")
	$binding = Get-WebBinding -Name $siteName -Protocol "https";
	if($binding -eq $null)
	{
		Write-Host "Unable to find $siteName for https protocol" -ForegroundColor Magenta;
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

	Write-Host "Update-AppPool-User>> Updating PoolName '$apAppPoolName' for user $fullUserName. Wait..." -ForegroundColor Yellow;
	Import-Module WebAdministration
	
	#Set APservice User password in Given Pool
	$apPool = Get-ItemProperty "iis:\\AppPools\$apAppPoolName" -Name "ProcessModel"
	$apPool.userName = $fullUserName
	$apPool.password = $global:apServiceAccountPassword
	Set-ItemProperty -Path "IIS:\AppPools\$apAppPoolName" -Name "ProcessModel" -Value $apPool

	Write-Host "Update-AppPool-User>> Properties set for ProcessModel" -ForegroundColor DarkGreen;
	
	if($applyAdvancedSettings)
	{
		Write-Host "Update-AppPool-User>>Setting Advanced properties. Wait..." -ForegroundColor DarkCyan;
		#Set Max Memory for pool:
		$totalMemory =  gwmi Win32_OperatingSystem | % {$_.TotalVisibleMemorySize}
		$apPool = Get-ItemProperty "iis:\\AppPools\$apAppPoolName" -Name "Recycling"
		#Memory should be set in kb
		$apPool.periodicRestart.privateMemory = [int][Math]::Round(($totalMemory/2));
		Set-ItemProperty -Path "IIS:\AppPools\$apAppPoolName" -Name "Recycling" -Value $apPool
		Write-Host "Update-AppPool-User>>Advanced properties set." -ForegroundColor DarkGreen
	}
	Start-WebAppPool -Name $apAppPoolName
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
	Write-Host "Function 'Configure-AgilePointPortal' is done";
}
function Configure-AgileXRMSites()
{
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

	if($deploymentType -ne "Cloud")
	{
		Modify-AppSetings-Key -configFilePath "$agileXrmWebFolder\web.config" -keyName "AzureStorageTableName" -keyValue "";	
		Modify-AppSetings-Key -configFilePath "$agileXrmWebFolder\web.config" -keyName "AzureStorageConnectionString" -keyValue "";	
	}
	else
	{
		Modify-AppSetings-Key -configFilePath "$agileXrmWebFolder\web.config" -keyName "AzureStorageTableName" -keyValue "AgileXRMGlobalOndemandStorage";	
		Modify-AppSetings-Key -configFilePath "$agileXrmWebFolder\web.config" -keyName "AzureStorageConnectionString" -keyValue "$azureStorageConnString";	
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
	if($deploymentType -ne "Cloud")
	{
		Modify-AppSetings-Key -configFilePath "$publicAgileXrmWebFolder\web.config" -keyName "AnonymousUser" -keyValue $anonymousUser -createNode $true
		Modify-AppSetings-Key -configFilePath "$publicAgileXrmWebFolder\web.config" -keyName "AzureStorageTableName" -keyValue "";	
		Modify-AppSetings-Key -configFilePath "$publicAgileXrmWebFolder\web.config" -keyName "AzureStorageConnectionString" -keyValue "";	
	}
	else
	{
		Modify-AppSetings-Key -configFilePath "$publicAgileXrmWebFolder\web.config" -keyName "AzureStorageTableName" -keyValue "AgileXRMGlobalOndemandStorage";	
		Modify-AppSetings-Key -configFilePath "$publicAgileXrmWebFolder\web.config" -keyName "AzureStorageConnectionString" -keyValue "$azureStorageConnString";	
	}
	Modify-AppSetings-Key -configFilePath "$publicAgileXrmWebFolder\web.config" -keyName "AllowTestPage" -keyValue "false";	
	
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
		Modify-AppSetings-Key -configFilePath "$externalAgileXrmWebFolder\web.config" -keyName "AzureStorageTableName" -keyValue "AgileXRMGlobalOndemandStorage";	
		Modify-AppSetings-Key -configFilePath "$externalAgileXrmWebFolder\web.config" -keyName "AzureStorageConnectionString" -keyValue "$azureStorageConnString";	
	}
	else
	{
		Modify-AppSetings-Key -configFilePath "$externalAgileXrmWebFolder\web.config" -keyName "AzureStorageTableName" -keyValue "";	
		Modify-AppSetings-Key -configFilePath "$externalAgileXrmWebFolder\web.config" -keyName "AzureStorageConnectionString" -keyValue "";	
	}
	Modify-AppSetings-Key -configFilePath "$externalAgileXrmWebFolder\web.config" -keyName "AllowTestPage" -keyValue "false";	

	#Bindings
	if($deploymentMode -eq "ST")
	{
		Modify-WebSite-Binding -siteName "AgileXRM" -hostName $agileXrmHostName;
		Modify-WebSite-Binding -siteName "AgilePoint" -hostName $rawAdminPortalHostName;
	}
	else
	{
		Modify-WebSite-Binding -siteName "AgileXRM" -ipAddress $primaryNicIpAddress;
	}
	Modify-WebSite-Binding -siteName "AgilePoint.NX.EFormsApp" -hostName $nxAppsHostName;
	Modify-WebSite-Binding -siteName "AgileReports" -hostName $reportsHostName;
	if($deploymentMode -eq "ST")
	{
		Modify-WebSite-Binding -siteName "PublicAgileXRM" -hostName $publicAXrmHostName;
	}
	else
	{
		Modify-WebSite-Binding -siteName "PublicAgileXRM" -ipAddress $thirdNicIpAddress;
	}
	if($deploymentMode -eq "ST")
	{
		Modify-WebSite-Binding -siteName "ExternalAgileXRM" -hostName $externalAXrmHostName
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
	Write-Host "Function 'Configure-AgileXRMSites' is done";
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
	$node.SetAttribute("PortalURL", $agilePointPortalUrl)

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

	if($deploymentMode -ne "ST")
	{
		Write-Host "Configure-AgilePointService-ServicesAddresses only applies to Single Tenant Deployments and current setup is $deploymentMode" -ForegroundColor Magenta
		return
	}
	[xml]$file = Get-Content $configFilePath;

	$wcfServicesNames = @("Ascentn.AgilePoint.WCFService.WcfWorkFlow","Ascentn.AgilePoint.WCFService.WcfAdmin", "Ascentn.AgilePoint.WCFService.WcfEventServices",
			"Ascentn.AgilePoint.WCFService.WcfDataServices","Ascentn.AgilePoint.WCFService.WcfExtensionServices","Ascentn.AgilePoint.WCFService.CrossDomainService", 
			"Ascentn.AgilePoint.WCFService.WcfDataEntity", "Ascentn.Crm.Connector.Services.Wcf.LicenseCheckingService","Ascentn.Crm.AgileDialogsConnector.AgileDialogsConnectorService")
	
	$restServicesNames = @("Ascentn.AgilePoint.WCFService.RESTWorkFlow", "Ascentn.AgilePoint.WCFService.RESTAdmin", "Ascentn.AgilePoint.WCFService.RESTEventServices",
		"Ascentn.AgilePoint.WCFService.RESTDataServices","Ascentn.AgilePoint.WCFService.RESTExtensionServices","Ascentn.AgilePoint.WCFService.RESTDataEntity",
			"Ascentn.Crm.Connector.Services.RestLicenseCheckingService","AgilePoint.Xrm.MetadataConnector.MetadataService","AgilePoint.AgileConnector.ProcessManager.Services.ProcessViewerHtml5Service")

	$file = Update-baseAddress-Attribute -file $file -serviceNames $wcfServicesNames -urlValue $nettcpAgilePointUrl -protocolSearchFilter "net.tcp://"
	$file = Update-baseAddress-Attribute -file $file -serviceNames $wcfServicesNames -urlValue $apiWsUrl 
	$file = Update-baseAddress-Attribute -file $file -serviceNames $restServicesNames -urlValue $apiRestUrl
	
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

	#WAAD
	Modify-AppSetings-Key -configFilePath "$agilePointServerInstanceFolder\bin\Ascentn.AgilePoint.WCFService.exe.config" -keyName "WCFServiceClientID" -keyValue $waadWcfAppId;
	Modify-AppSetings-Key -configFilePath "$agilePointServerInstanceFolder\bin\Ascentn.AgilePoint.WCFService.exe.config" -keyName "WFCServiceAudienceUrl" -keyValue $waadWcfAppIdUri;

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
		$domainName = [string]::Format("WinNT://{0}",$env:computername);
		$node = $file.SelectSingleNode("descendant::domain");
		$node.SetAttribute("name", $domainName);
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

	$file.Save($appEntryXML);
	Write-Host "Update-netflow-Cfg-File>> Done" -ForegroundColor DarkGreen;
}
function Remove-Old-AgileXRMOnline-Certs()
{
    $certStore = "cert:\LocalMachine\My";
	$agileXRMCerts = Get-ChildItem -Path $certStore -Recurse | select Subject, FriendlyName, Thumbprint, NotAfter |  where-object { $_.Subject -eq  $certificateSubjectName};
	if (($agileXRMCerts.Count -ne $null) -and ($agileXRMCerts.Count -gt 0) )
	{
	   Write-Host "Remove-Old-AgileXRMOnline-Certs>> Removing Old Certificates...."
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
		Write-Host "Create Local Envision User doesn't apply to Cloud Deployments" -ForegroundColor DarkGray;
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
	param([Microsoft.Azure.Commands.Network.Models.PSNetworkInterface]$networkInterface)

	Write-Host "Get-NIC-IpAddresses>> Ipconfiguration found in NIC: " $networkInterface.IpConfigurations.Count -foregroundcolor DarkCyan
	if($networkInterface.IpConfigurations.Count -eq 2)
	{
		Write-Host "Get-NIC-IpAddresses>> 2 IpConfigurations found"
		foreach($nicConfig in $networkInterface.IpConfigurations)
		{
			if($nicConfig.PrivateIpAddressVersion -eq "IPv4")
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
		}
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


	#Create Connectors Records
	Insert-AD-Connector -sqlInstance $sqlServer -agileDialogsURL $agileDialogsUrl -agileDialogsExternalURL $agileDialogsExternalUrl;
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

	$queryOutput = Invoke-Sqlcmd -ServerInstance $sqlServer -Database $masterPortalDB -Username $dbUserName -Password $dbUserPassword -Query $portalDeploymentCheckQuery -ErrorAction Ignore; 
	if($queryOutput -eq $null)
	{
		Write-Host "No 'Settings_ShellDescriptorRecord' Record is found. Portal has not been deployed" -ForegroundColor DarkCyan;
		
		return -1
	}
	else
	{
		$queryOutput = Invoke-Sqlcmd -ServerInstance $sqlServer -Database $masterPortalDB -Username $dbUserName -Password $dbUserPassword -Query $portalSettingsQuery -ErrorAction Ignore; 
		
		if($queryOutput -eq $null)
		{
			Write-Host "Portal Setting Record is NOT found " -ForegroundColor DarkCyan;
			return -2;
		}
		else
		{
			$queryOutput = Invoke-Sqlcmd -ServerInstance $sqlServer -Database $masterPortalDB -Username $dbUserName -Password $dbUserPassword -Query $provisioningStatusQuery -ErrorAction Ignore; 
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
	$queryOutput = Invoke-Sqlcmd -ServerInstance $sqlServer -Database $masterPortalDB -Username $dbUserName -Password $dbUserPassword -Query $query

	if($queryOutput -eq $null)
	{
		Write-Host "Inserting Record in table 'AgilePoint_Portal_Core_ShellSettingsRecord' from '$masterPortalDB'...."
		$insertQuery = "INSERT INTO [$masterPortalDB].[dbo].[AgilePoint_Portal_Core_ShellSettingsRecord] (  [Name],  [ConnectionString],  [DataProvider],  [Status],  [CreatedOn],  [LastModifiedOn])  VALUES ( '$portalInstallationName',   'Data Source=$sqlServer;Initial Catalog=$singlePortalDB;Persist Security Info=True;User ID=$dbUserName;Password=$dbUserPassword',  'Microsoft SQL Server',  'Active',getdate(),getdate())"
		$insertOutput = Invoke-Sqlcmd -ServerInstance $sqlServer -Database $masterPortalDB -Username $dbUserName -Password $dbUserPassword -Query $insertQuery
		Write-Host "Record successfully inserted in table 'AgilePoint_Portal_Core_ShellSettingsRecord' from '$masterPortalDB'" -ForegroundColor DarkGreen
	}
	else
	{
		Write-Host "Record in table 'AgilePoint_Portal_Core_ShellSettingsRecord' from '$masterPortalDB' already exists. Updating..." -ForegroundColor DarkCyan
		$updateQuery = "UPDATE [$masterPortalDB].[dbo].[AgilePoint_Portal_Core_ShellSettingsRecord] SET [ConnectionString] = 'Data Source=$sqlServer;Initial Catalog=$singlePortalDB;Persist Security Info=True;User ID=$dbUserName;Password=$dbUserPassword',[DataProvider] = 'Microsoft SQL Server' WHERE NAME = '$portalInstallationName'"
		$udpateOutput = Invoke-Sqlcmd -ServerInstance $sqlServer -Database $masterPortalDB -Username $dbUserName -Password $dbUserPassword -Query $updateQuery
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

	$argumentList = @("setup","/SiteName:""NXone""","/AdminUsername:""$apServiceAccountUser""","/AdminPassword:""$parsedApServiceAccountPassword""","/DatabaseProvider:""SQLServer""","/Recipe:""AgilePoint - Master""","/DatabaseConnectionString:""Data Source=$sqlInstance;Initial Catalog=$masterPortalDB;Persist Security Info=True;User ID=$dbUserName;Password=$parsedDbUserPassword;""","/verbose:true");
	
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
	param([string]$connectorName, [string]$connectorConfig, [string]$sqlInstance, [bool]$recreateRecord=$false)

	if(($connectorName -ne $adConnectorName) -and ($connectorName -ne $pmConnectorName) -and ($connectorName -ne $crmConnectorName))
	{
		throw "Unknown '$connectorName' parameter value"
	}
	
	$dbConnection = Test-Db-Connection -sqlInstanceName $sqlInstance -sqlDbName $singleApDB -sqlUserName $dbUserName -sqlUserPassword $dbUserPassword;
	if($recreateRecord)
	{
		Write-Host "Deleting record first...." 
		$deleteQuery = [string]::Format("DELETE FROM [dbo].[WF_INTEGRATED_APPS] where APP_NAME='{0}'", $connectorName)
		$deleteCommand = Invoke-Sqlcmd -ServerInstance $sqlInstance -Database $singleApDB -Username $dbUserName -Password $dbUserPassword -Query $deleteQuery
	}

	$insertQuery = [string]::Format("INSERT INTO [dbo].[WF_INTEGRATED_APPS]([APP_NAME],[CFG_XML],[Created_DATE],[CREATED_BY]) VALUES('{0}','{1}', getdate(), '$apServiceAccountDomain\$apServiceAccountUser')", $connectorName, $connectorConfig)
	$updateQuery = [string]::Format("UPDATE [dbo].[WF_INTEGRATED_APPS] SET [CFG_XML]= '{1}' WHERE [APP_NAME] ='{0}'", $connectorName, $connectorConfig)
	$query= "Select * FROM [$singleApDB].[dbo].[WF_INTEGRATED_APPS] WHERE APP_NAME = '$connectorName'"
	$queryOutput = Invoke-Sqlcmd -ServerInstance $sqlInstance -Database $singleApDB -Username $dbUserName -Password $dbUserPassword -Query $query
	if($queryOutput -eq $null)
	{
		Write-Host "Inserting Connector '$connectorName' Record in table 'WF_INTEGRATED_APPS' ...."
		$insertOutput = Invoke-Sqlcmd -ServerInstance $sqlInstance -Database $singleApDB -Username $dbUserName -Password $dbUserPassword -Query $insertQuery
		Write-Host "Record successfully INSERTED in table 'WF_INTEGRATED_APPS' " -ForegroundColor DarkGreen
	}
	else
	{
		Write-Host "Record for connector '$connectorName' already exists in table 'WF_INTEGRATED_APPS'. Updating... " -ForegroundColor DarkCyan
		$insertOutput = Invoke-Sqlcmd -ServerInstance $sqlInstance -Database $singleApDB -Username $dbUserName -Password $dbUserPassword -Query $updateQuery
		Write-Host "Record successfully UPDATED in table 'WF_INTEGRATED_APPS' " -ForegroundColor DarkGreen
	}
}

function Insert-AD-Connector()
{
	param($sqlInstance, $agileDialogsURL, $agileDialogsExternalURL)
	
	$connectorConfig = [string]::Format("<?xml version=""1.0"" encoding=""utf-8""?><ConnectorConfiguration xmlns:xsd=""http://www.w3.org/2001/XMLSchema"" xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance""><AgileDialogsUrl>{0}</AgileDialogsUrl><AgileDialogsExternalConnectorUrl>{1}</AgileDialogsExternalConnectorUrl></ConnectorConfiguration>",$agileDialogsURL, $agileDialogsExternalURL)

	Insert-ConnectorRecord -connectorName $adConnectorName -sqlInstance $sqlInstance -connectorConfig $connectorConfig
}

function Insert-PM-Connector()
{
	param($sqlInstance, $processManagerURL)
	
	$connectorConfig = [string]::Format("<?xml version=""1.0"" encoding=""utf-8""?><ProcessManagerConnectorConfiguration xmlns:xsd=""http://www.w3.org/2001/XMLSchema"" xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance""><AppFilterName>*</AppFilterName><ServerUrl>{0}/signalr/hubs</ServerUrl><ProcessManagerConnectorServerHubUrl /><SignalRClientEnabled>true</SignalRClientEnabled><SignalRServerEnabled>false</SignalRServerEnabled></ProcessManagerConnectorConfiguration>",$processManagerURL)

	Insert-ConnectorRecord -connectorName $pmConnectorName -sqlInstance $sqlInstance -connectorConfig $connectorConfig
}

function Insert-CRM-Connector()
{
	param($sqlInstance, $azureAppId, $azureAppSecretKey, $d365UniqueName, $d365Url)

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

	Insert-ConnectorRecord -connectorName $crmConnectorName -sqlInstance $sqlInstance -connectorConfig $connectorConfig
}

function Test-Db-Connection()
{
	param([string]$sqlInstanceName, [string]$sqlInstancePort="1433", [string]$sqlDbName,[string]$sqlUserName, [string]$sqlUserPassword)

	Write-Host "Testing DB $sqlDbName in instance $sqlInstanceName..."

	$connectionString = [string]::Format("Server=tcp:{0},{1};Initial Catalog={4};Persist Security Info=False;User ID={2};Password={3};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;", $sqlInstanceName,$sqlInstancePort,$sqlUserName,$sqlUserPassword, $sqlDbName)

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
		Disable-ScheduledTask -TaskName $taskName
		Stop-ScheduledTask -TaskName $taskName
		Get-ScheduledTask -TaskName $taskName
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
	$queryOutput = Invoke-Sqlcmd -ServerInstance $sqlServer -Database $singleApDB -Username $dbUserName -Password $dbUserPassword -Query $query
	
	
	if($queryOutput -eq $null)
	{
		Write-Host "Inserting Record in table 'WF_REG_USERS' from '$singleApDB'...."
		$insertQuery = "INSERT INTO [$singleApDB].[dbo].[WF_REG_USERS] ([USER_NAME_UPCASE], [USER_NAME], [FULL_NAME], [LOCALE], [DISABLED], [REGISTERED_DATE])  VALUES ( '$userAlias', '$userAliasUppercase',  'ST Tenant Admin User', 'es-us','NO',getdate())"
		$insertOutput = Invoke-Sqlcmd -ServerInstance $sqlServer -Database $singleApDB -Username $dbUserName -Password $dbUserPassword -Query $insertQuery
		Write-Host "Record successfully inserted in table 'WF_REG_USERS' from '$singleApDB'" -ForegroundColor DarkGreen
	}
	else
	{
		Write-Host "Record in table 'WF_REG_USERS' from '$singleApDB' already exists. Updating..." -ForegroundColor DarkCyan
		$updateQuery = "UPDATE [$singleApDB].[dbo].[WF_REG_USERS] SET [USER_NAME_UPCASE]='$userAliasUppercase', [USER_NAME]='$userAlias', [FULL_NAME]='ST Tenant Admin User' WHERE [USER_NAME] = '$userAlias'"
		$udpateOutput = Invoke-Sqlcmd -ServerInstance $sqlServer -Database $singleApDB -Username $dbUserName -Password $dbUserPassword -Query $updateQuery
		Write-Debug-Message -functionName "Upsert-TenantAdminUser" -message "Record Content: $queryOutput"
	}

	$query="SELECT * FROM WF_ASSIGNED_OBJECTS where (WF_ASSIGNED_OBJECTS.ROLE_NAME = N'ADMINISTRATORS') and (WF_ASSIGNED_OBJECTS.ASSIGNEE = N'$userAliasUppercase') and (WF_ASSIGNED_OBJECTS.ASSIGNEE_TYPE = 'User') and (WF_ASSIGNED_OBJECTS.OBJECT_ID = '00000000000000000000000000000000')"
	$queryOutput = Invoke-Sqlcmd -ServerInstance $sqlServer -Database $singleApDB -Username $dbUserName -Password $dbUserPassword -Query $query
	if($queryOutput -eq $null)
	{
		Write-Host "Inserting Record in table 'WF_ASSIGNED_OBJECTS' from '$singleApDB'...."
		$insertQuery = "INSERT INTO [$singleApDB].[dbo].[WF_ASSIGNED_OBJECTS] ([ROLE_NAME],[ASSIGNEE], [ASSIGNEE_TYPE], [OBJECT_ID], [OBJECT_TYPE], [CREATED_DATE], [CREATED_BY])  VALUES ( 'ADMINISTRATORS', '$userAliasUppercase',  'User', '00000000000000000000000000000000','All',getdate(),'$userAliasUppercase')"
		$insertOutput = Invoke-Sqlcmd -ServerInstance $sqlServer -Database $singleApDB -Username $dbUserName -Password $dbUserPassword -Query $insertQuery
		Write-Host "Record successfully inserted in table 'WF_ASSIGNED_OBJECTS' from '$singleApDB'" -ForegroundColor DarkGreen
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
	$udpateOutput = Invoke-Sqlcmd -ServerInstance $sqlServer -Database $singleApDB -Username $dbUserName -Password $dbUserPassword -Query $updateQuery
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


######################END FUNCTIONS########################################################################

if($deploymentMode -eq "MT")
{
	Write-Host "This is a Multitenant Deployment. Detecting network configuration..." -foregroundcolor darkCyan

	#Connection Details with Service Principal
	$securePass = ConvertTo-SecureString -String $svcPrincipalSecretKey -AsPlainText -Force;
	$adminCredential = New-Object System.Management.Automation.PSCredential $svcPrincipalAppId, $securePass
	Connect-AzAccount -Credential $adminCredential -Tenant $tenantId -ServicePrincipal

	$targetNicName = $publicNicName
	#Configure VM Network Adapters
	$networkInterface = Get-NetworkInterface -nicName $targetNicName
	$result = Get-NIC-IpAddresses -networkInterface $networkInterface
	Write-Host "Result from Get-NIC-IpAddresses '$result' Expected is '0' " -foregroundcolor DarkCyan
	Write-Host "PrimaryNic IP Address 1: $global:primaryNicIpAddress1" -foregroundcolor DarkGreen
	Write-Host "PrimaryNic IP Address 2: $global:primaryNicIpAddress2" -foregroundcolor DarkGreen

	if( ($global:primaryNicIpAddress1 -ne $null) -and ($global:primaryNicIpAddress2 -ne $null))
	{
		Create-Adapter-IP-Addresses -primaryIP $global:primaryNicIpAddress1 -secondaryIP $global:primaryNicIpAddress2
	}
}
#Retrieve VM IP Addresses

if($deploymentMode -eq "ST")
{
	$ipAddresses = Get-IP-Addresses -interfaceAlias "Ethernet*";
	$primaryNicIpAddress = $ipAddresses;
}
else
{
	$networkInterface = Get-NetworkInterface -nicName $primaryNicName 
	$result = Get-NIC-IpAddress -networkInterface $networkInterface
	if ($result -ne "0")
	{
		Write-Error "Error Geting AXRM Main Adapter Address" -Category InvalidResult		
	}
	$primaryNicIpAddress = $global:outputNicIpAddress;
}

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

if($deploymentMode -eq "ST")
{
	$thirdNicIpAddress = $primaryNicIpAddress;
	$fourthNicIpAddress = $primaryNicIpAddress;
}
else
{
	$thirdNicIpAddress = $global:primaryNicIpAddress1;
	$fourthNicIpAddress = $global:primaryNicIpAddress2;
}

if($deploymentMode -eq "ST")
{
	$fifthNicIpAddress = $primaryNicIpAddress;
}
else
{	
	$networkInterface = Get-NetworkInterface -nicName $portalNicName 
	$result = Get-NIC-IpAddress -networkInterface $networkInterface
	if ($result -ne "0")
	{
		Write-Error "Error Geting PORTAL Adapter Address" -Category InvalidResult		
	}
	$fifthNicIpAddress = $global:outputNicIpAddress;
}

Write-Host "1st IP: $primaryNicIpAddress" -f DarkGreen;
Write-Host "2nd IP: $secondaryNicIpAddress" -f DarkGreen;
Write-Host "3rd IP: $thirdNicIpAddress" -f DarkGreen;
Write-Host "4th IP: $fourthNicIpAddress" -f DarkGreen;
Write-Host "5th IP: $fifthNicIpAddress" -f DarkGreen;

Disable-NetflowFile-TaskScheduler;
Check-APService-Password;
Remove-Old-AgileXRMOnline-Certs;
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
if($deploymentMode -eq "ST")
{
	$dbConnection = Test-Db-Connection -sqlInstanceName $sqlServer -sqlDbName $singleApDB -sqlUserName $dbUserName -sqlUserPassword $dbUserPassword 
}

Start-Services;

Apply-Post-Installation;

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
