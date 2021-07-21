__[Home](/) --> [AgileDialogs Design Guide](/guides/AgileDialogs-DesignGuide.md) --> XRM Connection Window__

# AgileDialogs Security

Configuring permissions for AgileDialogs works like configuring permissions for
AgileXRM processes. When a Dialog is deployed to server the modeler can
configure permissions using the same mechanism.

![](../media/AgileDialogsDesignGuide/AgileDialogsSecurity_01.png)

Process permission can be managed using Process Security button in AgileXRM Ribbon.

Runtime Permissions have the same configuration options as for AgileXRM processes

![](../media/AgileDialogsDesignGuide/AgileDialogsSecurity_02.png)

And permission can be assigned based on XRM roles:

![](../media/AgileDialogsDesignGuide/AgileDialogsSecurity_03.png)

In order to launch a Dialog the user must belong to a role that has *Initiate Process* permission.
