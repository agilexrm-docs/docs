# Schema Generic variables

**[Home](/) --> [AgileDialogs design guide](/guides/AgileDialogs-DesignGuide.md) --> Schema Generic variables**

---

|Name|Description|
|-|-|
|**ActivityName**| Gets the name of current activity.|
|**ActivityParticipantFullNames**| Gets the full name of current activity.|
|**ActivityParticipantUserNames**| Gets the name of all participants.|
|**CurrentDate**| Gets the server current date. Its an UTC date in ISO-8601 format.<br />Sample value: *2019-09-18T12:55:45Z*|
|**HomeDirectory**| Gets the home directory of Process server instance.|
|**ProcessID**| Gets the process instance ID of current process.<br />Sample value: *edb3529f13dae911826d0050562195fa*|
|**ParentProcessID**| When process instance is a subprocess, return the parent process ID.|
|**ProcessInitiator**| Gets the user name thats has initiate the current process instance. <br />Sample value: *DOMAIN\UserName*|
|**ProcessInitiatorLocation**| Gets the machine name since process instance have been launched.<br />Sample value: *machinename*|
|**ProcessInitiatorCDSId**| Gets the **CRM/CDS** user ID of user that has initiate the current process instance.  <br />Sample value:*edb4425f13dae911826d0050562195fa*|
|**ProcessInstanceID**| Returs the instance ID of current proccess instance.<br />Sample value: *edb3529f13dae911826d0050562195fa*|
|**ProcessInstanceName**| Gets the instance name of current process instance.|
|**ProcessName**| The process instance name of current process instance.|
|**ProcessStartedDate**| The process started date of current process instance.Its an UTC date in ISO-8601 format.<br />Sample value: *2019-09-18T12:55:44Z*|
|**ProcessTemplateID**| Gets the process template ID of current process instance..<br />Sample value: *edb3529f13dae911826d0050562195fa*|
|**ProcessTemplateName**| Gets the name of process template of current process instance.|
|**ProcessTemplateVersion**| Gets the version number of process template of current process instance.|
|**TaskAssignedDate**| Gets the data when current task was assigned|
|**TaskDueDate**| Return the due date of current date. Its an UTC date in ISO-8601 format.<br />Sample value:**|
|**TaskID**| Return the ID of the current Task.|
|**TaskName**| Resturns the name of current Task.|
|**TaskParticipantFullName**| Gets the full name of current task participant|
|**TaskParticipantUserName**| Gets the user name of current task participant|
|**Session**| Gets the session value for current activity. Each time activity is executed this number is ingeased. |
|**SystemUserEmailAddress**| Gets the email address of system user.<br />Sample value: *username@domain.com*|
|**SystemUserName**| Gets the name of system user.<br />Sample value:*DOMAIN\UserName*|
|**WorkItemID**| Gets the current workitem ID. <br />Sample value:*826D0050562195FA1199DA139CD1AFBF* |
|**CrmBeId**| This is the record id of the main entity. <br />Sample value:**|
|**CrmBeType**| This is the type of the process main entity, for example *account* or *incident*.|
|**organizationname**| This is the name of the CRM organization that the process record belongs to.|
|**userlcid**| This is used lcid for AgileDialogs process template.|
|**DialogTaskCRMActivityId**| If part of Dialog Activity, this property holds the CRM Activity ID that launched the current dialog instance.|

---

## Disclaimer of warranty

[Disclaimer of warranty](DisclaimerOfWarranty.md)
