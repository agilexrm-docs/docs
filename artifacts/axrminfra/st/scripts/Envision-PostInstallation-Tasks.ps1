param([string]$deploymentType="PrivateCloud", 
[string]$licenseProductId, 
[string]$azureStorageTableName="AgileXRMGlobalOndemandStorageST",
[string]$azureEnvisionAppId="583a4e00-bcf2-4fbb-b346-6c90c376f160", 
[string]$agilePointServicesAppIdUri ="https://ws.agilexrmonline.com:13487/AgilePointServer", 
[string]$azStorageAccountName="",
[string]$azStorageAccountSharedKey="",
[string]$azFileShareName="axrmrepository")

$now = Get-Date -Format "yyyyMMddHHmmss"
$transcriptFileName = [string]::Format("PSWStartVM_{0}.log",$now)
$transcriptFilePath = Join-Path "C:\Temp" $transcriptFileName
Start-Transcript -Path $transcriptFilePath


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

		Modify-AppSetings-Key -configFilePath $targetEnvisionConfigFile -keyName "EnableEnvironmentExplorerImport" -keyValue "true";
		Modify-AppSetings-Key -configFilePath $targetEnvisionConfigFile -keyName "AdvancedConfig" -keyValue "true" -createNode $true;
	
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

function Trust-EnvisionAddIn-ForAllUsers
{
	param([string]$currentPath="")

	$fullPath = "Registry::HKEY_USERS\.DEFAULT\Software\Microsoft\Office\16.0\Visio\Security"

	if (!(Test-Path -Path $fullPath ))
	{
		New-item -Path $fullPath -Force
		New-ItemProperty -Path $fullPath -Name 'VBAWarnings' -Value 1 -PropertyType DWord
		
	}
	else
	{
		Set-ItemProperty -Path $fullPath -Name 'VBAWarnings' -Value 1
	}
}

function Write-LogonScript
{
	if($deploymentType -ne "PrivateCloud")
	{
		Write-Host "Write-LogonScript doesn't apply to NON Private Cloud Environments" -ForegroundColor DarkCyan
		return;
	}

$scripBlock = @'
	param([string]$storageAccountName,[int]$storageAccountPort=445,[string]$storageAccountSharedKey, [string]$fileShareName)
	
	Start-Transcript -Path "c:\temp\PSlog.txt"
	function Trust-EnvisionAddIn
	{
		$fullPath = "Registry::HKEY_CURRENT_USER\Software\Microsoft\Office\16.0\Visio\Security"

		if (!(Test-Path -Path $fullPath ))
		{
			New-item -Path $fullPath -Force
			New-ItemProperty -Path $fullPath -Name 'VBAWarnings' -Value 1 -PropertyType DWord
		}
		else
		{
			Set-ItemProperty -Path $fullPath -Name 'VBAWarnings' -Value 1
		}
	}

	function Deploy-LogonScript([string]$storageAccountName, [string]$storageAccountSharedKey, [string]$fileShareName, [int]$storageAccountPort=445)
	{
		if($storageAccountName -eq "" -or $storageAccountSharedKey -eq "" -or $fileShareName -eq "")
		{
			Write-Host "All or one of the params to configure Models Unit Drive are empty. Please provide values for azStorageAccountName, azStorageAccountSharedKey and azFileShareName" -ForegroundColor DarkCyan
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

	Deploy-LogonScript -storageAccountName $storageAccountName -storageAccountSharedKey $storageAccountSharedKey -fileShareName $fileShareName

	Trust-EnvisionAddIn

	#Deploy GPO Policy to simplify Visio UX
	Start-Process -FilePath "C:\AgileXRM\gpo\DeployGPOLocally.cmd" -WorkingDirectory "C:\AgileXRM\gpo"

	Stop-Transcript
'@

	# paths
	$gpRoot = "${env:SystemRoot}\System32\GroupPolicy"
		
	$fileNamePath = Join-Path $gpRoot "User\Scripts\Logon";
	
	if(!(Test-Path -Path $fileNamePath))
	{
	  New-Item $fileNamePath -ItemType Directory -Force
	}
	
	$fileName = Join-Path $fileNamePath "LogonScript.ps1"
	$content = Set-Content -Path $fileName `
						   -Value $scripBlock
	
	#gpInit file
	$contentgptIniFile = "[General]`r`ngPCUserExtensionNames=[{42B5FAAE-6536-11D2-AE5A-0000F87571E3}{40B66650-4972-11D1-A7CA-0000F87571E3}]`r`nVersion=524288`r`n"
	$gptIniFilePath = Join-Path $gpRoot "gpt.ini"
	Set-Content -Path $gptIniFilePath `
		   -Value $contentgptIniFile
	
	# logon/logoff scripts
	$userScriptsPath = Join-Path $gpRoot "User\Scripts\psscripts.ini"
	$contentLogonScript = "`r`n[ScriptsConfig]`r`nStartExecutePSFirst=true`r`n[Logon]`r`n0CmdLine=LogonScript.ps1`r`n0Parameters=-storageAccountName:$azStorageAccountName -storageAccountPort:445 -storageAccountSharedKey:$azStorageAccountSharedKey -fileShareName:$azFileShareName"

	Set-Content -Path $userScriptsPath `
		   -Value $contentLogonScript
	gpupdate

}

function Register-EnvisionAddIn-Dll()
{
	Write-Host "Register-EnvisionAddIn-Dll>> Trying to Registrer 'EnvisionAddIn.dll'. Wait..." -ForegroundColor DarkCyan

	$envisionPath = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Ascentn\Envision"
	if(!(Test-Path -Path $envisionPath))
	{
		Write-Host "Register-EnvisionAddIn-Dll>> Unable to find Envision Path for this Machine" -ForegroundColor yellow
		return;
	}
	try
	{
		$envisionKey = Get-ItemProperty -Path $envisionPath
		$envisionPath = Join-Path -Path $envisionKey.location "EnvisionAddIn.dll"
		$assembly = [System.Reflection.Assembly]::LoadFrom($envisionPath);
		$registrationService = New-Object -TypeName System.Runtime.InteropServices.RegistrationServices
		$registerStatus = $registrationService.RegisterAssembly($assembly, [System.Runtime.InteropServices.AssemblyRegistrationFlags]::SetCodeBase);
		Write-Host "Register-EnvisionAddIn-Dll>> Done with status: $registerStatus !" -ForegroundColor DarkGreen
	}
	catch
	{
		Write-Host "Register-EnvisionAddIn-Dll>> Error Happens" -ForegroundColor Red
		Write-Host "$($_.Exception)" -ForegroundColor Red
	}
}

function Set-RemoteDesktop-Configuration()
{
	if($deploymentType -ne "Cloud")
	{
		Write-Host "Set-RemoteDesktop-Configuration doesn't apply to NON 'Cloud' Environments" -ForegroundColor DarkCyan
		return;
	}

	$fullPath = "Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Ole\AppCompat"

	if (!(Test-Path -Path $fullPath ))
	{
		New-item -Path $fullPath -Force
		New-ItemProperty -Path $fullPath -Name 'RequireIntegrityActivationAuthenticationLevel' -Value 0 -PropertyType DWord
		
	}
	else
	{
		Set-ItemProperty -Path $fullPath -Name 'RequireIntegrityActivationAuthenticationLevel' -Value 0
	}

	Write-Host "Set-RemoteDesktop-Configuration successfully executed! 'RequireIntegrityActivationAuthenticationLevel' has been set to '0'" -ForegroundColor DarkGreen
}

#################################################END FUNCTIONS#################################################################

Remove-Old-Stencils-Folders
Set-Envision-Config-Keys
Deploy-License
Remove-WebViewDll-FromOfficeFolder
Trust-EnvisionAddIn-ForAllUsers
Write-LogonScript
Register-EnvisionAddIn-Dll
Set-RemoteDesktop-Configuration

Stop-Transcript

exit 0
