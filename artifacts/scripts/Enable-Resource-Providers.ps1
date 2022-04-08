<#
    .DESCRIPTION
        This script will enable all Azure Resource Providers required for any AgileXRM Infraestructure Installation

    .NOTES
        AUTHOR: AgileXRM Team
        LASTEDIT: April 1st,2022
#>

Write-Host "Retrieving info from Environment. Please wait...." -ForegroundColor DarkCyan
$policyValue = Get-ExecutionPolicy -Scope "CurrentUser"
Write-Host "ExecutionPolicy for 'CurrentUser' is $policyValue" -ForegroundColor DarkGreen

if ($policyValue -ne "RemoteSigned")
{
	Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
}

$azModule = Get-InstalledModule -Name Az -ErrorAction Ignore
if($azModule -eq $null)
{
	Write-Host "Installing Az Module for current user. Please wait..." -ForegroundColor DarkCyan
	Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
	Write-Host "Az Module installed!" -ForegroundColor DarkGreen
}
else
{
	Write-Host "Az Module is already installed. Details: $azModule" -ForegroundColor DarkGreen
}

Write-Host "Connecting to Azure Subscription. Please provide Subscription Owner user to register required providers..." -ForegroundColor DarkCyan
Clear-AzContext -Scope CurrentUser -Force
Connect-AzAccount
$modules = @("Microsoft.Resources","Microsoft.Storage","Microsoft.Compute","Microsoft.Network", "Microsoft.Sql", "Microsoft.KeyVault", "Microsoft.DevTestLab", "Microsoft.Authorization")
foreach($module in $modules)
{
		$provider = Register-AzResourceProvider -ProviderNamespace $module -ErrorAction Ignore
		if($provider -ne $null)
		{
			Write-Host "Provider $module registered!" -ForegroundColor DarkGreen
		}
		else
		{
			Write-Host "Unable to register Provider $module" -ForegroundColor Yellow
		}
}
