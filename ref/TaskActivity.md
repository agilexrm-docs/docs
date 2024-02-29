**[Home](/) --> [Reference](/ref) --> Task Activity**

# Task Activity

![Task Activity](media/TaskActivity.png)

This shape is used for creating a CRM Task activity. The Task *Owner* will be
the User/Team that the task is assigned to (i.e. Participant), and the
*Regarding* field will be the Main Entity of the process.

This shape can optionally have a [Page Form](PageForm.md). This permits
creating activity-based forms, which have all the fields necessary for carrying
out this task by the user.

When the task is *Marked as Completed* in CRM, the process continues to next
steps.

The mapping of the fields is as shown below:

| CRM Field    | AgilePoint setting                                                       |
|--------------|--------------------------------------------------------------------------|
| **Subject**      | Subject property                                                         |
| **Description**  | TaskDescription property                                                 |
| **Regarding**    | RegardingEntityId & RegardingEntityType properties                       |
| **Priority**     | Priority property                                                        |
| **Due**          | TimeSpan property                                                        |
| **Owner**        | the Participant property . When Participant is a Queue, OwnerID property |
| **Other fields** | Set using the ActivityProperties property                                |

## Participants
The property *ConfigureParticipants* allows to set the Activity owner and (optionally) assign the activity to a queue, just clicking on the ellipsis button.

To see full configuration navigate to the [Participants](./common/Participants.md) detailed section.

## Shape-Specific Properties

| Property | Description |
| -------- | ----------- |
| **ActivityProperties**           | [Activity Properties](common/ActivityProperties.md)  |
| **AfterSubmitAction**            | [After Submit Action](common/AfterSubmitAction.md)   |
| **EmbededHeight**                | [Embeded Height](common/EmbededHeight.md)       |
| **ExistingActivityId**           | [Existing Activity Id](common/ExistingActivityId.md)       |
| **OwnerID**                      | [DEPRECATED][Owner ID](common/OwnerID.md)             |
| **PageForm**                     | [Page Form](common/PageForm.md)            |
| **RegardingEntityID**            | [Regarding Entity ID](common/RegardingEntityID.md)   |
| **RegardingEntityType**          | [Regarding Entity Type](common/RegardingEntityType.md) |
| **SaveCrmActivityFieldsTo**      | [Save CRM Activity Fields To](common/SaveCrmActivityFieldsTo.md) |
| **SaveCrmActivityIdTo**          | [DEPRECATED] [Save CRM Activity Id To](common/SaveCrmActivityIdTo.md) |
| **Subject**                      | [Subject](common/Subject.md)             |
| **TaskDescription**              | [Task Description](common/Subject.md)     |


## Other Common Properties
All shapes have many other common properties. Look them up here: [Common Poperties](common/README.md)

## Actions
See [Actions](common/Actions.md)

## Disclaimer of warranty

[Disclaimer of warranty](../guides/common/DisclaimerOfWarranty.md)