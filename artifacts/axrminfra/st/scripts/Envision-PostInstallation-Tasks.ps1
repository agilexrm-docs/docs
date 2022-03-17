param([string]$deploymentType="PrivateCloud", [string]$licenseProductId, [string]$azureStorageTableName="AgileXRMGlobalOndemandStorageST",[string]$azureEnvisionAppId="583a4e00-bcf2-4fbb-b346-6c90c376f160", [string]$agilePointServicesAppIdUri ="https://ws.agilexrmonline.com:13487/AgilePointServer", [string]$azStorageAccountName="",[string]$azStorageAccountSharedKey="",[string]$azFileShareName="axrmrepository")


######################################FUNCTIONS################################################################################################

function Get-SA-Connection-String([string]$storageAccountName, [string]$storageAccountSharedKey)
{
	$connectionString = [string]::Format("DefaultEndpointsProtocol=https;AccountName={0};AccountKey={1};EndpointSuffix=core.windows.net",$storageAccountName,$storageAccountSharedKey)
	return $connectionString
}


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
function Set-Envision-Config-Keys()
{
	$targetEnvisionConfigFile = "C:\Program Files\AgilePoint\AgilePoint Envision\envision.config"
	if(!(Test-Path $targetEnvisionConfigFile))
	{	
		Write-Host "Envision config file in $targetEnvisionConfigFile not found!"
		exit -2
	}
	Modify-AppSetings-Key -configFilePath $targetEnvisionConfigFile -keyName "VisioRepositoryEnabled" -keyValue "true";

	if($deploymentType -eq "PrivateCloud")
	{
		Modify-AppSetings-Key -configFilePath $targetEnvisionConfigFile -keyName "BrowserUserDataFolder" -keyValue "%UserProfile%\Documents" -createNode $true;
		Modify-AppSetings-Key -configFilePath $targetEnvisionConfigFile -keyName "FileSystemRepositoryPath" -keyValue "z:\AgileXRM\Models" -createNode $true;
		Modify-AppSetings-Key -configFilePath $targetEnvisionConfigFile -keyName "UserWorkspaceFolder" -keyValue "z:\Users\%UserName%\Models";
		Modify-AppSetings-Key -configFilePath $targetEnvisionConfigFile -keyName "UserWorkspaceTempFolder" -keyValue "%AppData%\AgileXRM\Temp";
		Modify-AppSetings-Key -configFilePath $targetEnvisionConfigFile -keyName "DeploymentType" -keyValue "PrivateCloud";
		Modify-AppSetings-Key -configFilePath $targetEnvisionConfigFile -keyName "AgilePointServerServicesAssembly" -keyValue "Ascentn.Crm.Envision.AzureAD.Services.AgilePointServices, Ascentn.Crm.Envision, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null";

		$azureStorageConnectionString = Get-SA-Connection-String -storageAccountName $azStorageAccountName -storageAccountSharedKey $azStorageAccountSharedKey
		Modify-AppSetings-Key -configFilePath $targetEnvisionConfigFile -keyName "AzureStorageTableName" -keyValue "$azureStorageTableName";
		Modify-AppSetings-Key -configFilePath $targetEnvisionConfigFile -keyName "AzureStorageConnectionString" -keyValue "$azureStorageConnectionString";

		Modify-AppSetings-Key -configFilePath $targetEnvisionConfigFile -keyName "AzureStorageAccountName" -keyValue "";
		Modify-AppSetings-Key -configFilePath $targetEnvisionConfigFile -keyName "AzureRepositoryConnectionString" -keyValue "";

		Modify-AppSetings-Key -configFilePath $targetEnvisionConfigFile -keyName "AzureEnvisionAppId" -keyValue "$azureEnvisionAppId";
		Modify-AppSetings-Key -configFilePath $targetEnvisionConfigFile -keyName "AgileDialogsServerPaaSFormat" -keyValue "";
		Modify-AppSetings-Key -configFilePath $targetEnvisionConfigFile -keyName "AgilePointServerPaaSFormat" -keyValue "";
		Modify-AppSetings-Key -configFilePath $targetEnvisionConfigFile -keyName "AgilePointServicesAppIdUri" -keyValue "$agilePointServicesAppIdUri";
		
		Modify-AppSetings-Key -configFilePath $targetEnvisionConfigFile -keyName "ShowApRibbon" -keyValue "false";
		Modify-AppSetings-Key -configFilePath $targetEnvisionConfigFile -keyName "EnablePaasTokenCache" -keyValue "true";
		Modify-AppSetings-Key -configFilePath $targetEnvisionConfigFile -keyName "UpgradeImagesEnabled" -keyValue "true";
		Modify-AppSetings-Key -configFilePath $targetEnvisionConfigFile -keyName "AllowImportAndExportXML" -keyValue "true";

		Modify-AppSetings-Key -configFilePath $targetEnvisionConfigFile -keyName "Translation_SubscriptionKey" -keyValue "";
		Modify-AppSetings-Key -configFilePath $targetEnvisionConfigFile -keyName "Translation_EndPoint" -keyValue "";
		Modify-AppSetings-Key -configFilePath $targetEnvisionConfigFile -keyName "Translation_Location" -keyValue "";
		
	}
}

function Remove-Old-Stencils-Folders()
{
	$visioPathKey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\App Paths\visio.exe"
	if(! (Test-Path -Path $visioPathKey))
	{
		Write-Error "Visio Path not found in Registry Path $visioPathKey"
		exit -1
	}
	$fullVisioKey =Get-ItemProperty -Path $visioPathKey
	$lcid = [System.Globalization.CultureInfo]::CurrentCulture.LCID;

	$allCultures = [System.Globalization.CultureInfo]::GetCultures([System.Globalization.CultureTypes]::AllCultures)	

	foreach($culture in $allCultures)
	{
		$targetFolder = [string]::Format("{0}{1}\Solutions\AgilePoint", $fullVisioKey.Path, $culture.lcid)
		if(Test-Path -Path $targetFolder)
		{
			Write-Host "Destination Folder $targetFolder found. Deleting..." -foregroundcolor DarkCyan
			Remove-Item -LiteralPath $targetFolder -Force -Recurse
			Write-Host "Folder $targetFolder has been removed" -foregroundcolor DarkGreen

		}
	}
}
function Deploy-License()
{
    $targetLicenseFile = "C:\Program Files\Common Files\Ascentn\AgilePoint Envision.dat"
    $sourceLicenseFile = "C:\Software\Licenses\AgilePoint Envision.dat"

    Write-host "License File $sourceLicenseFile" -ForegroundColor DarkCyan
	if((Test-Path -Path $sourceLicenseFile) -eq $false)
	{
		write-host "License File $sourceLicenseFile Not Found!" 
		return -1;	
	}

    Copy-Item -Path $sourceLicenseFile -Destination $targetLicenseFile -Force

	$regKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products\646847333E6B6414EA35BAB00B035B87\InstallProperties"
	if(Test-Path -Path $regKey)
	{
		Set-ItemProperty -Path $regKey -Name "ProductID" -Value $licenseProductId;
		Write-Host "License Product ID Updated" -ForegroundColor DarkGreen;
	}
	else
	{
		Write-Host "Unable to find $regKey in the registry" -ForegroundColor Magenta;
	}

}

function Remove-WebViewDll-FromOfficeFolder
{
	$officePath = "C:\Program Files\Microsoft Office\root\Office16"
	Get-ChildItem -Path $officePath -Filter "webview2loader*" | Remove-Item -Force -ErrorAction Ignore
}

function Map-Azure-UnitDrive([string]$storageAccountName,[int]$storageAccountPort=445,[string]$storageAccountSharedKey, [string]$fileShareName)
{
	if($storageAccountName -eq "" -or $storageAccountSharedKey -eq "" -or $fileShareName -eq "")
	{
		Write-Host "All or one of the params to configure Models Unit Drive are empty. Please provide values for 'azStorageAccountName', 'azStorageAccountSharedKey' and 'azFileShareName'" -ForegroundColor DarkCyan
		return;
	}

	$computerName = [string]::Format("{0}.file.core.windows.net",$storageAccountName)
	$connectTestResult = Test-NetConnection -ComputerName $computerName -Port $storageAccountPort
	if ($connectTestResult.TcpTestSucceeded) 
	{
		# Save the password so the drive will persist on reboot
        $commandParameters = "cmdkey /add:`"$computerName`" /user:`"localhost\$storageAccountName`" /pass:`"$storageAccountSharedKey`""
		cmd.exe /C $commandParameters
        Write-Host "Parameters: $commandParameters"

		# Mount the drive
        $rootPath = "\\$computerName\$fileShareName"
        Write-Host "Root Path: $rootPath"
		New-PSDrive -Name Z -PSProvider FileSystem -Root $rootPath -Scope Global -Persist

		Write-Host "Repository Unit Drive successfully mapped in the VM!" -ForegroundColor DarkGreen

	} else {
		Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
	}	
}

#################################################END FUNCTIONS#################################################################333

Remove-Old-Stencils-Folders
Set-Envision-Config-Keys
Deploy-License
Remove-WebViewDll-FromOfficeFolder
Map-Azure-UnitDrive -storageAccountName $azStorageAccountName -storageAccountSharedKey $azStorageAccountSharedKey -fileShareName $azFileShareName

exit 0
