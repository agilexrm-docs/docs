__[Home](/) --> AgileXRM System Requirements__


# AgileXRM System Requirements

## Introduction

This document describes the supported system requirements for installing
the components of the product suite. The following components are
included in the product suite:

-   Process Server (incl. Administration Portal)
-   Process Manager
-   Envision Process Modeler
-   Dynamics 365 CE/Dataverse/CDS Integration
-   AgileDialogs
-   SharePoint Integration (Optional)
-   External Connector (Optional)

Requirements are kept in line with Dynamics 365 CE (CRM) System Requirements as described here:

<https://docs.microsoft.com/en-us/dynamics365/customerengagement/on-premises/deploy/system-requirements-required-technologies>

AgileXRM supports **Microsoft Dataverse (formerly Common Data Service - CDS) of Power Platform** as 
well as any Apps built on top of Dyn365/Dataverse like **Microsoft Project Online**.

AgileXRM currently *does not* support Dynamics 365 for Operations or Finance and Business Central.

## Deployment Options

These are the different Deplyment Options that are supported:

|  #  | AgileXRM Installed in:                       | Dynamics 356 CE / Dataverse Online | Dynamics 365 CE/CRM installed in Azure VM | Dynamics 365 CE/CRM installed in non-Azure VM | Dynamics 365 CE/CRM installed in client On-Premise |
|-----|----------------------------------------------|-----|-----|-----|-----|
|**A**| Public Cloud (*Shared*)                      |**Y**|  N  |  N  |  N  |
|**B**| Public Cloud (*Dedicated*)                   |**Y**|**Y**| (*) | (*) |
|**C**| Client Azure VMs<br/>(*Managed by AgileXRM*) |**Y**|**Y**| (*) | (*) |
|**D**| Client Azure VMs<br/>(*Managed by client*)   |**Y**|**Y**| (*) | (*) |
|**E**| Client Cloud non-Azure VMs                   | (*) |  N  |**Y**| (*) |
|**F**| Client On-Premises                           | (*) | (*) | (*) |**Y**|

>   **(*)** : **Not-Recommended** but consult for these combinations, as it 
>   maybe supported under certain circumstances.
 
## Deployment Options A and B

### AgileXRM in Public Cloud (A-Shared)

This is a tenant in a multi-tenant shared AgileXRM Online pool.
One AgileXRM tenant can support any number of Dynamics 365 CE Online organizations and/or 
Dataverse/CDS Environments, as long as these are in the same Azure Region.
It is possible to connect to client's on-premise legacy systems via Azure AD Application Proxy.

![](media/SystemRequirements_01.png)
> **Figure 1**. Public Cloud (Shared)

### AgileXRM in Public Cloud (B-Dedicated)

This is a single tenant in a dedicated AgileXRM Online environment. Nothing is shared with any other client.
This can support any number of Dynamics 365 CE organizations (both installed or Online) and/or 
Dataverse/CDS Environments, as long as these are in the same Azure Region.
It is possible to connect to client's on-premise systems via Azure AD Application Proxy or Private VPN.

![](media/SystemRequirements_02.png)
> **Figure 2**. Public Cloud (Dedicated)

### Integration Requirements (Options A and B)

In order to integrate the AgileXRM Tenant with the client's Dynamics/Dataverse environment, the following are needed:

- Give Consent by an Azure AD Administrator at the Azure Tenant level by clicking on the following consent links:
  * Services App ([consent link](https://login.microsoftonline.com/common/oauth2/authorize?response_type=code&client_id=19e4137f-55ae-4dbf-9fbc-e386bbf36304&resource=https%3A%2F%2Fgraph.windows.net&redirect_uri=https%3A%2F%2Fpool400.agilexrmonline.com%2FAgileDialogs%2fConsentDone.aspx&prompt=admin_consent))
  * Portal App   ([consent link](https://login.microsoftonline.com/common/oauth2/authorize?response_type=code&client_id=81c01359-21c1-467f-a3a8-52f5d6721fa0&resource=https%3A%2F%2Fgraph.windows.net&redirect_uri=https%3A%2F%2Fpool400.agilexrmonline.com%2FAgileDialogs%2fConsentDone.aspx&prompt=admin_consent))
  * Envision App ([consent link](https://login.microsoftonline.com/common/oauth2/authorize?response_type=code&client_id=583a4e00-bcf2-4fbb-b346-6c90c376f160&resource=https%3A%2F%2Fgraph.windows.net&redirect_uri=https%3A%2F%2Fpool400.agilexrmonline.com%2FAgileDialogs%2fConsentDone.aspx&prompt=admin_consent))

- For each Org/Environment, add an Application User as such:
 
    |  Field        | Value                                     |
    |---------------|-------------------------------------------|
    | User Name     | s2s.*[unique orgname]*@agilexrmonline.com |
    | App ID        | 81c01359-21c1-467f-a3a8-52f5d6721fa0      |
    | Full Name     | AgileXRM S2S Application User             |
    | Email address | support@agilexrm.com                      |
    | Security Role | System Administrator                      |

  * Import AgileXRM Solution & configure
  * Enable selected Tables (Entities) and Activities to be used with AgileXRM
  * Add AgileXRM Full License to Users that are going to use AgileXRM 

## Server Requirements for Deployment Options C, D, E and F

AgileXRM is very flexible in that it can be installed on one single server for smaller
deployments or distributed in a High Availibility (HA) cluster for large deployments, including ScaleSets. The
components easily scale out. The information here applies to both physical
machines as well as virtual machines. VMs can also be in public Cloud like Azure
or other IaaS providers supported by Microsoft. For further information on
Virtual Machine support, please see Support for Virtualization Technologies further below.

### AgileXRM in Client Azure VM (Options C and D)

This is when AgileXRM is installed in client's Azure subscription. 
There is an option that AgileXRM manages the environment as a Managed Service or the client 
maintains the environment themselves. 
This can support any number of Dynamics 365 CE organizations and/or 
Dataverse/CDS Environments, as long as these are in the same Azure Region. 
It is possible to connect to client's on-premise legacy systems via Azure AD Application Proxy or Private VPN.

![](media/SystemRequirements_03.png)
> **Figure 3**. AgileXRM in Client Azure VMs

#### Azure Resource Requirements (Options C and D)

The following Azure resources will be required:
- Virtual Network
- Network Interface Card
- VMs for AgileXRM Server 
- VM for AgileXRM Modeler 
- SQL Azure for 4 DBs 
- Storage Account
- Public IP
- Visio Plan 2 License

Also need:
- DNS Entries
- WildCard Public Certificate (not self-signed) 
- 1 Email Account as sender (with SMTP capabilities) 
- 1 Email Account as platform notification receiver 
​
### AgileXRM Server Requirements

This section provides detailed information about the specific optimal system
requirements for an AgileXRM  server, where all server components are
installed in one server:

| Feature            | Requirements               |
|--------------------|----------------------------|
| **vCPUs**          | 4                          |
| **Memory (RAM)**   | 8 GB RAM                   |
| **Hard Disk**      | 20 GB (RAID 1 or 5) SSD    |
| **Network**        | 1 Gb or higher             |

In Azure VM Size terminology:
- **PRO**: D8as v4 or higher 
- **Non-PRO**: B4MS or higher

#### AgileXRM Server Installation Prerequisites 

In all AgileXRM Servers (64-bit only):
 
1.	**Create a Domain User** to be used as a service account (i.e. non-expiring password).<br>
    This user will also be used during the installation process, so it should be allowed to logon to the 
    Windows Server, including via RDP.
    *	Add this user to **Local Administrator** group on the server
    *   Create a **mailbox** for the service account 
    *   **Logon to the server** with this user and complete the rest of the tasks with this user
1.  Turn off things that interfere with the installation (all can be turned back on after the installation):
    *  **Turn off Windows Firewall**
    *  **Turn off AntiVirus**
    *  **Disable UAC and reboot** 
1.	Decide which **ports** are going to be used.<br>
    Normally these ports are used:
      * AgileDialogs & ProcessManager: 443 (https) or 8888 (http)
      * WCF Service: 444 (https) or 13487 (http)
      * REST API: 443 (https) or 13490 (http)
      * Admin Portal: 443 (https) or 13491 (http)
1.  Decide which **host headers** are going to be used.<br>
    Something like this: [can change *agilexrm* for other word)]
      * AgileDialogs / ProcessManager: *agilexrm*.contoso.com
      * REST API & WCF Service: *agilexrm*-api.contoso.com or *agilexrm*.api.contoso.com
      * Admin Portal: *agilexrm*-admin.contoso.com or *agilexrm*.admin.contoso.com
1.  If SSL is required then have a valid **SSL Certificate** available that covers the chosen host headers 
1.	Have **.NET Framework 4.7.2 or higher** enabled/installed
1.	Create the following **empty DBs** in SQL Server:
    *  **APDB**
    *  **APMasterPortalDB**
    *  **APTenantPortalDB**
    *  **APArchiveDB**
    *  Grant **db_owner** privilege to **service account** user in all DBs
1.	Provide **access to SMTP server** for the service account to send emails
1.  Install **Chrome or Edge** (Chromium version)
1.  Copy **AgileXRM Installer** ZIP file onto the server


### System Requirements for Envision Process Modeler

This section provides detailed information about the specific system
requirements for the Envision component of.

| Feature               | Requirements                                            |
|-----------------------|---------------------------------------------------------|
| **Processor (CPU)**   | Follow recommendations for your Visio version           |
| **Memory (RAM)**      | 1 GB RAM                                                |
| **Hard Disk**         | 500 MB (plus an additional 150+ MB for Microsoft Visio) |


## Supported Microsoft Products

### Operating Systems

- Windows Server 2019
- Windows Server 2016 (ADFS 4.0 not supported)
- Windows Server 2012 R2

### Database

- SQL Server 2017 (Std, Ent, DC)
- SQL Server 2016 (Std, Ent, DC)
- SQL Server 2014 (Std, Ent, DC)
- SQL Server 2012 (Std, Ent, DC)
- SQL Azure
 
>   **NOTE**: SSD disks are highly recommended for Production environments.

### Dynamics 365 Customer Engagement / Power Platform Dataverse/CDS

- Power Platform Dateverse/CDS 
- Dynamics 365 CE Online (8.2+, 9.0+)
- Dynamics 365 (CRM) 2016 (SP1 or higher)
- Dynamics CRM 2015 (Update 0.1 or higher)
- Dynamics CRM 2013 (SP1 or higher) 

> **NOTE**: CRM On-Premise Workgroup Edition is not supported.

### SharePoint

- SharePoint Online (also includes Teams Files, OneDrive for Business)
- SharePoint 2019 (Any Edition) 
- SharePoint 2016 (Any Edition) 
- SharePoint 2013 (Any Edition)

### Visio

- Microsoft Visio 2019 (Any Edition - x64 Only)
- Microsoft Visio 2016 (Any Edition - x64 Only)
- Microsoft Visio 2013 (Any Edition - x64 Only)

> **IMPORTANT**: The option *.NET Programmability Support* should be selected when installing Visio.

### .NET Framework

- .NET Framework 4.7.2

## Supported Browsers

- Latest Chrome version 
- Latest Firefox version
- Latest Edge (Chromium) version

## Support for Virtualization Technologies


AgileXRM is committed to fully supporting running on virtualization
technologies. AgileXRM supports both physical server machines as well as
virtual machines. AgileXRM recommends **Windows Server® Hyper-V™**,
however other Microsoft and non-Microsoft virtualization products are also
supported as discussed in the link below:

<http://www.windowsservercatalog.com/results.aspx?&bCatID=1521&cpID=0&avc=0>

## Disclaimer of warranty

[Disclaimer of warranty](../guides/common/DisclaimerOfWarranty.md)


