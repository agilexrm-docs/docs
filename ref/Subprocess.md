__[Home](/) --> [Reference](/ref) --> SubProcess__

# SubProcess

![ShapeNameDisplay](media/SubProcess.png)

When entered, this AgileShape will initiate another process instance as a
sub-process.

This functionality is useful for breaking complex processes to more manageable
chunks and also allows creating more modular processes, and enhances
reusability.

It allows selecting any type of AgilePoint Process: **AgileXRM**, **AgileDialogs**,
**Generic**, **SharePoint List**, **SharePoint Doc**.

There are other AgileShapes that are better suited when calling an AgileXRM
sub-process (namely the **[SubProcess](XRMSubProcess.md)** shape in *AgileXRM Automatic Activities*
stencil) or an AgileDialog sub-process (namely **[SubDialog](SubDialog.md)** and
**[Dialog Activity](DialogActivity.md)**).

When selecting a sub-process, it is possible to initiate the latest version or a
particular version. Please see below for details of choosing which version of
the sub-process template to initiate.

## Configuration Dialogs

### Process Selector dialog

See the *SubProcess* property in the table below.

### SubProcess Parameters dialog

See the *SubProcessParams* property in the table below.

## Shape-Specific Properties

| Property | Description |
| -------- | ----------- |
| **NamePrefix**              | [Name Prefix](common/NamePrefix.md) |
| **SaveProcessInstanceIdTo** | [Save Process Instance Id To](common/SaveProcessInstanceIdTo.md) |
| **ShareAttributes**         | [Share Attributes](common/ShareAttributes.md) |
| **SubProcess**              | [SubProcess](common/SubProcess.md)             |
| **SubProcessInitiator**     | [SubProcess Initiator](common/SubProcessInitiator.md) |
| **SubProcessParams**        | [SubProcess Params](common/SubProcessParams.md)        |
| **Wait**                    | [Wait](common/Wait.md)                    |


## Other Common Properties
All shapes have many other common properties. Look them up here: [Common Poperties](common/README.md)

## Actions
See [Actions](common/Actions.md)
