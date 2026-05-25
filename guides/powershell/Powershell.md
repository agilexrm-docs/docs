# AgileXRM Powershell API

**AgileXRM** provides a `PowerShell API` wich allow automation and management interface for interacting with the platform and its components.

This API is designed to facilitate operational and administrative tasks, as well as technical integrations, that require automated execution, repeatable deployments or bulk resource management. Using PowerShell scripts, administrators and developers can perform operations on processes, configurations, entities and system components without needing to use the graphical user interface.

The API is typically used in scenarios such as:

- Manage process temaplate definitions.
- Manage process instances.
- Cancel
- Suspend
- Change flow
- Migrate process instances
- Bulk process migrations

## Powershell API Requeriments

**AgileXRM** `powershell API` needs its own module of Powershell. 

This module is deployed with AgileXRM server components in the path `AgileXRM\AgilePoint Server Component\PowerShell\CmdLets`

In order to use its needed to copy the AgileXRMAdmin commandlet (AgileXRMAdmin.dll) in our working environtment and import them.

> Powershell version: PowerShell 7.6.1

## Powershell API overview

**AgileXRM** `powershell API` is divided in three groups:

- Connection: Allows connection
  - Get-Connect, allows connect to **AgileXRM** Server

- Discover: These are methods to facilitate get needed information
  - Get-axrmProcessTemplates
  - Get-axrmProcessTemplateVersions
  - Get-axrmProcessTemplateActvities
  - Get-axrmProcessInstances
  - Get-axrmMigrationDefinition

- Operations: Performs operation
  - Set-axrmChangeflow
  - Set-axrmSuspendProcessInstance
  - Set-axrmResumeProcessInstance
  - Set-axrmMigrateProcessInstance
  - Set_axrmBulkMigrate

All methods allow connect to AgileXRM server bypassing these parameters itself. Once its connected, it not needed to send credentials.

**However, the recommendation is to always use the Get-Connect connection method**
  
    Parameters:
    - URL: the URL of AgileXRM Server.
    - UserName: The username to connect.
    - Password: The password for selected user.

If not familiar with ProcessManager app, check this link before use powershell API.
[Process Manager actions](https://docs.agilexrm.com/guides/ProcessManager-UserGuide.html#actions)


## Powershell API Methods


### Get-Connect

This method gets a new connection to server. By calling this method, we avoid having to provide our login credentials with every API call.

    Parameters:
    - URL: the URL of AgileXRM Server.
    - UserName: The username to connect.
    - Password: The password for selected user.

```powershell 
Import-Module "AgileXRMAdmin.dll" # path where we copied AgileXRMAdmin.dll

Get-Command -module AgileXRMAdminCmdLet

$url = "https://axrm-api.aidev.loc/AgilePointServer/"; # url of AgilePointServer
$usr = "valid_username";
$pwd = "******************";

$securestr = ConvertTo-SecureString $pwd -AsPlainText

Get-Connect -url: $url -username: $usr -password: $securestr
```
> All methods allow connect to AgileXRM server bypassing these parameters itself. 
> 
> Once its connected, it not needed to send credentials for current powershell session.


### Get-axrmProcessTemplates

This method allow get process templates definitions. 
We can retrieve all available process templates or all versions of a specific template, using `TemplateName` parameter to filter results.


    Parameters:
    - TemplateName. Optional. This is the process definition name. If empty then method will return all available process definitions.

```powershell
Import-Module "AgileXRMAdmin.dll" # path where we copied AgileXRMAdmin.dll

Get-Command -module AgileXRMAdminCmdLet

$url = "https://axrm-api.aidev.loc/AgilePointServer/"; # url of AgilePointServer
$usr = "valid_username";
$pwd = "******************";

$securestr = ConvertTo-SecureString $pwd -AsPlainText

Get-axrmProcessTemplates -url: $url -username: $usr -password: $securestr 
    | Format-Table

# This execution returns all process template in the server.

```

And filtering using TemplateName parameter    

```powershell
Import-Module "AgileXRMAdmin.dll" # path where we copied AgileXRMAdmin.dll

Get-Command -module AgileXRMAdminCmdLet

$url = "https://axrm-api.aidev.loc/AgilePointServer/"; # url of AgilePointServer
$usr = "valid_username";
$pwd = "******************";

$securestr = ConvertTo-SecureString $pwd -AsPlainText

Get-axrmProcessTemplates -url: $url -username: $usr -password: $securestr -TemplateName: "AgileXRM Documentation demo" 
    | Format-Table

# This execution return selected process template in the server.

```

### Get-axrmProcessTemplateVersions

This method allows get all versions of a process template definition.

    Parameters:
    - TemplateName: the name of process definition  
    - Version: Optional, the requested version. If not provides returns the records of last version.


```powershell 
Import-Module "AgileXRMAdmin.dll" # path where we copied AgileXRMAdmin.dll

Get-Command -module AgileXRMAdminCmdLet

$url = "https://axrm-api.aidev.loc/AgilePointServer/"; # url of AgilePointServer
$usr = "valid_username";
$pwd = "******************";

$securestr = ConvertTo-SecureString $pwd -AsPlainText

Get-axrmProcessTemplateVersions -TemplateName: "AgileXRM Documentation demo" 
```

```powershell 
Import-Module "AgileXRMAdmin.dll" # path where we copied AgileXRMAdmin.dll

Get-Command -module AgileXRMAdminCmdLet

$url = "https://axrm-api.aidev.loc/AgilePointServer/"; # url of AgilePointServer
$usr = "valid_username";
$pwd = "******************";

$securestr = ConvertTo-SecureString $pwd -AsPlainText

Get-axrmProcessTemplateVersions -TemplateName: "AgileXRM Documentation demo" -Version "1.05"

```

### Get-axrmProcessTemplateActvities

This method allow us to get the activities of a process template. If we dont provide `Version` this methods returns all activities for lastest version.

    Parameters CHECK:
    - TemplateName: the name of process definition
    - Version
    - Status
    - ActivityName
    - InstancesIDs

```powershell
Import-Module "AgileXRMAdmin.dll" # path where we copied AgileXRMAdmin.dll

Get-Command -module AgileXRMAdminCmdLet

$url = "https://axrm-api.aidev.loc/AgilePointServer/"; # url of AgilePointServer
$usr = "valid_username";
$pwd = "******************";

$securestr = ConvertTo-SecureString $pwd -AsPlainText

Get-Connect -url: $url -username: $usr -password: $securestr

$activities = Get-axrmProcessTemplateActivities -templatename: "AgileXRM Documentation demo" 
$activities | Format-Table

# returns activities from lastest process definition

```
```powershell
Import-Module "AgileXRMAdmin.dll" # path where we copied AgileXRMAdmin.dll

Get-Command -module AgileXRMAdminCmdLet

$url = "https://axrm-api.aidev.loc/AgilePointServer/"; # url of AgilePointServer
$usr = "valid_username";
$pwd = "******************";

$securestr = ConvertTo-SecureString $pwd -AsPlainText

Get-Connect -url: $url -username: $usr -password: $securestr

$activities = Get-axrmProcessTemplateActivities -TemplateName: "AgileXRM Documentation demo" -Version: "0.01"
$activities | Format-Table

# returns activities from specific process definition (0.01)

```

### Get-axrmProcessInstances

This methods allow to get process instances. We can get process instances of specific process definition, version and status. Obsvioly we algo can we process instace by process instance ID.

ActivityName

    Parameters:
    - TemplateName: the name of process definition
    - Version
    - Status
    - ActivityName
    - InstancesIDs

```powershell
Import-Module "AgileXRMAdmin.dll" # path where we copied AgileXRMAdmin.dll

Get-Command -module AgileXRMAdminCmdLet

$url = "https://axrm-api.aidev.loc/AgilePointServer/"; # url of AgilePointServer
$usr = "valid_username";
$pwd = "******************";

$securestr = ConvertTo-SecureString $pwd -AsPlainText

Get-Connect -url: $url -username: $usr -password: $securestr

$instances = Get-axrmProcessInstances -TemplateName: "AgileXRM Documentation demo"
$instances | Format-Table
    
```

```powershell
Import-Module "AgileXRMAdmin.dll" # path where we copied AgileXRMAdmin.dll

Get-Command -module AgileXRMAdminCmdLet

$url = "https://axrm-api.aidev.loc/AgilePointServer/"; # url of AgilePointServer
$usr = "valid_username";
$pwd = "******************";

$securestr = ConvertTo-SecureString $pwd -AsPlainText

Get-Connect -url: $url -username: $usr -password: $securestr

$instances = Get-axrmProcessInstances -TemplateName: "AgileXRM Documentation demo" -Version: "0.02"
$instances | Format-Table
    
```

```powershell
Import-Module "AgileXRMAdmin.dll" # path where we copied AgileXRMAdmin.dll

Get-Command -module AgileXRMAdminCmdLet

$url = "https://axrm-api.aidev.loc/AgilePointServer/"; # url of AgilePointServer
$usr = "valid_username";
$pwd = "******************";

$securestr = ConvertTo-SecureString $pwd -AsPlainText

Get-Connect -url: $url -username: $usr -password: $securestr

Get-axrmProcessInstances -InstancesIDs: "f8343198a153f111b99c0050562195fa"

    
```

### Set-axrmChangeflow

This methods allow to perform a change flow operation. 

    Parameters:
    - Inputs: Instances wich i would migrate. Use Get-axrmProcessInstances to get instances before Get-axrmChangeflow call 
    - SourceActivitiesNames: Source activity names. This means currently active activities.
    - TargetActivitiesNames: Target activity names. This means the activity name to activate.

> Change flow operations has these limitations:
> Cannot perform change flow operation for `AgileDialogs` process.

```powershell
Import-Module "AgileXRMAdmin.dll" # path where we copied AgileXRMAdmin.dll

Get-Command -module AgileXRMAdminCmdLet

$url = "https://axrm-api.aidev.loc/AgilePointServer/"; # url of AgilePointServer
$usr = "valid_username";
$pwd = "******************";

$securestr = ConvertTo-SecureString $pwd -AsPlainText

Get-Connect -url: $url -username: $usr -password: $securestr

Get-axrmProcessInstances -InstancesIDs: "f8343198a153f111b99c0050562195fa" 
    | Set-axrmChangeflow -SourceActivitiesNames: "Manual Task.53" -TargetActivitiesNames: "Manual Task.61"

```

### Set-axrmSuspendProcessInstance

This method allow supend one or more process instances.

```powershell
Import-Module "AgileXRMAdmin.dll" # path where we copied AgileXRMAdmin.dll

Get-Command -module AgileXRMAdminCmdLet

$url = "https://axrm-api.aidev.loc/AgilePointServer/"; # url of AgilePointServer
$usr = "valid_username";
$pwd = "******************";

$securestr = ConvertTo-SecureString $pwd -AsPlainText

Get-Connect -url: $url -username: $usr -password: $securestr

$processInstances = Get-axrmProcessInstances -TemplateName "Migration Test" -Status "Running"

Set-axrmSuspendProcessInstance -ProcessInstances $processInstances 

```

### Set-axrmResumeProcessInstance

This method allow resume a suspended process instance.

```powershell
Import-Module "AgileXRMAdmin.dll" # path where we copied AgileXRMAdmin.dll

Get-Command -module AgileXRMAdminCmdLet

$url = "https://axrm-api.aidev.loc/AgilePointServer/"; # url of AgilePointServer
$usr = "valid_username";
$pwd = "******************";

$securestr = ConvertTo-SecureString $pwd -AsPlainText

Get-Connect -url: $url -username: $usr -password: $securestr

$processInstances = Get-axrmProcessInstances -TemplateName "Migration Test" -Status "Running"

Set-axrmResumeProcessInstance -ProcessInstances $processInstances 

```

### Get-axrmMigrationDefinition.

This method allows get a migration instruccion file. Also, this file can be get from process manager.

    Parameters:
    - ProcessInstance         
    - ProcessInstanceID 
    - ProcDef 
    - TemplateName        
    - TemplateVersion 

```powershell
Import-Module "AgileXRMAdmin.dll" # path where we copied AgileXRMAdmin.dll

Get-Command -module AgileXRMAdminCmdLet

$url = "https://axrm-api.aidev.loc/AgilePointServer/"; # url of AgilePointServer
$usr = "valid_username";
$pwd = "******************";

$securestr = ConvertTo-SecureString $pwd -AsPlainText

Get-Connect -url: $url -username: $usr -password: $securestr

# Get-axrmProcessInstances -InstancesIDs: "f8343198a153f111b99c0050562195fa" 
# | Get-axrmMigrationDefinition

$instance = Get-axrmProcessInstances -InstancesIDs: "f8343198a153f111b99c0050562195fa" 

# in this case we look for Relased version
$targetProcDef  = (Get-axrmProcessTemplateVersions -TemplateName: $instance.TemplateName).where({ $_.Status -eq "Released" })

$templateName = $targetProcDef[0].TemplateName
$templateVersion = $targetProcDef[0].Version

Get-axrmMigrationInstruccion -ProcessInstanceID: $instance.ProcInstID -TemplateName: $templateName  -TemplateVersion: $templateVersion

```

> Also can get an instruccion file from `ProcessManager`

### Set-axrmMigrateProcessInstance (Migrate_axrmProcessInstance).

This method allow performs a process migration against process instance.

    Parameters
    [-ProcessInstance] 
    [-ProcessInstanceID] 
    [-ProcDef] 
    [-TemplateName ] 
    [-TemplateVersion ] 
    <!--[-URL <string>] 
    [-UserName <string>] 
    [-Password <securestring>] -->
    [-WaitForEvent ] 
    [-DelayTime ] 
    [-MaxTries ] 


```powershell
Import-Module "AgileXRMAdmin.dll" # path where we copied AgileXRMAdmin.dll

Get-Command -module AgileXRMAdminCmdLet

$url = "https://axrm-api.aidev.loc/AgilePointServer/"; # url of AgilePointServer
$usr = "valid_username";
$pwd = "******************";

$securestr = ConvertTo-SecureString $pwd -AsPlainText

Get-Connect -url: $url -username: $usr -password: $securestr

$instance = Get-axrmProcessInstances -InstancesIDs: "f8343198a153f111b99c0050562195fa" 

$targetProcDef  = (Get-axrmProcessTemplateVersions -TemplateName: $instance.TemplateName).where({ $_.Status -eq "Released" })

$templateName = $targetProcDef[0].TemplateName
$templateVersion = $targetProcDef[0].Version

$instruccions = Get-axrmMigrationInstruccion -ProcessInstanceID: $instance.ProcInstID -TemplateName: $templateName  -TemplateVersion: $templateVersion

Set-axrmMigrateProcessInstance  -ProcessInstanceIDs: $instance.ProcInstID -Instruccion: $instruccions

```

#### Migrate_axrmProcessInstance using an instruccion file.

Get migration file instruccion from `ProcessManager` and save it locally.
```xml
<?xml version="1.0" encoding="utf-8"?>
<WFProcessMigrationInstruction xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
							   xmlns:xsd="http://www.w3.org/2001/XMLSchema">
	<Action>KeepState</Action>
	<IncludeXmlData>true</IncludeXmlData>
	<MatchingActivityDefinitions>
		
			<MatchingActivityDefinition>
				<CurrentActivated>false</CurrentActivated>
				<SourceName>Manual Task.53</SourceName>
				<TargetName>Manual Task.53</TargetName>
			</MatchingActivityDefinition>
		
			<MatchingActivityDefinition>
				<CurrentActivated>false</CurrentActivated>
				<SourceName>Manual Task.57</SourceName>
				<TargetName>Manual Task.57</TargetName>
			</MatchingActivityDefinition>
		
			<MatchingActivityDefinition>
				<CurrentActivated>true</CurrentActivated>
				<SourceName>Manual Task.61</SourceName>
				<TargetName>Manual Task.61</TargetName>
			</MatchingActivityDefinition>
		
			<MatchingActivityDefinition>
				<CurrentActivated>false</CurrentActivated>
				<SourceName></SourceName>
				<TargetName>Manual Task.68</TargetName>
			</MatchingActivityDefinition>
		
	</MatchingActivityDefinitions>
	<SourceProcessDefinitionID>B99C0050562195FA111153A16B9D9D43</SourceProcessDefinitionID>
	<TargetProcessDefinitionID>B99C0050562195FA11115430E32E27E6</TargetProcessDefinitionID>
</WFProcessMigrationInstruction>
```

Now we can migrate instance using instruccion file.

 [-Inputs <ProcInstData[]>] 
 [-ProcessInstanceIDs <string>] 
 [-FilePath <string>] 
 [-Instruccion <ProcessMigrationInstruction>] 
 [-URL <string>] 
 [-UserName <string>] 
 [-Password <securestring>] 
 [-WaitForEvent <bool>] 
 [-DelayTime <int>] 
 [-MaxTries <int>] 

```powershell
Import-Module "AgileXRMAdmin.dll" # path where we copied AgileXRMAdmin.dll

Get-Command -module AgileXRMAdminCmdLet


$url = "https://axrm-api.aidev.loc/AgilePointServer/"; # url of AgilePointServer
$usr = "valid_username";
$pwd = "******************";

$securestr = ConvertTo-SecureString $pwd -AsPlainText

Get-Connect -url: $url -username: $usr -password: $securestr

Set-axrmMigrateProcessInstance "f8343198a153f111b99c0050562195fa" -FilePath "C:\Migrations\migrationinstructions.xml"

```

### Set_axrmBulkMigrate

This method allows to perform multiple process migration at once. 

**Bulk migration is a risky operation, so before carrying it out, you should make a full backup of the AgileXRM database**

Bulk migration needs a instruccion file.


Parameters:
- Version. Required. The number version of target
- Filename. Fullpath of the file with migrations instruccions.

```powershell
Import-Module "AgileXRMAdmin.dll" # path where we copied AgileXRMAdmin.dll

Get-Command -module AgileXRMAdminCmdLet


$url = "https://axrm-api.aidev.loc/AgilePointServer/"; # url of AgilePointServer
$usr = "valid_username";
$pwd = "******************";

$securestr = ConvertTo-SecureString $pwd -AsPlainText

Get-Connect -url: $url -username: $usr -password: $securestr

$instances = Get-axrmProcessInstances -InstancesIDs: "98ae51903155f111b99c0050562195fa", "1531d6993155f111b99c0050562195fa" 

Set-axrmBulkMigrate -ProcessInstances: $instances -Version: "0.01" -FilePath: "C:\Pruebas\migrationinstructions_2026-04-21_16-35-15.xml"

```

```powershell
Import-Module "AgileXRMAdmin.dll" # path where we copied AgileXRMAdmin.dll

Get-Command -module AgileXRMAdminCmdLet


$url = "https://axrm-api.aidev.loc/AgilePointServer/"; # url of AgilePointServer
$usr = "valid_username";
$pwd = "******************";

$securestr = ConvertTo-SecureString $pwd -AsPlainText

Get-Connect -url: $url -username: $usr -password: $securestr

Set-axrmBulkMigrate -ProcessInstancesIDs: "98ae51903155f111b99c0050562195fa", "1531d6993155f111b99c0050562195fa" -Version: "0.01" -FilePath: "C:\Pruebas\migrationinstructions_2026-04-21_16-35-15.xml"

```


