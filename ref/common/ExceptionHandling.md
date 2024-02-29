# Exception Handling properties

**[Home](/) --> [Reference](/ref) --> [Common Properties](/ref/common) --> Exception Handling**

---

## Exception Handler Behavior

Default Value: **SuspendActivity**

This property determines the runtime behavior in case the process instance
throws an error when executing the current activity.

This property can be set to the following specific values:

- **SuspendActivity** – If the activity property is marked with this value, in
    case of an error the process instance will pause the flow on the current
    activity; but the process instance will not pause other parallel flows in
    case these exist.

- **SuspendProcess** – With this setting, the process instance will pause **all the running flows** that
    are active.

- **Continue** – In case of encountering an error, the process instance will
    ignore such error and continue to move forward through the process flow.

---

### Exception Handler Scope

Default value: **Local**

Specifies the value which determines how the process Engine (AgilePoint Server)
will handle an AgilePart exception. Two options are available:

- **Local** - This value indicates the exception handling (i.e., error message and status) information for an AgilePart within a single process instance will be saved to the process variables defined in the **SaveErrorMessageTo** and **SaveStatusTo** properties.
    > Note: if this option is set, the generated
    error (process exception) will not be logged in CRM

- **Global** - This value indicates the exception handling (i.e., error message and status) information is handled the same as the Local option, but includes the extended ability to call on a custom AgileConnector to handle the exception as desired. For information regarding building a Custom AgileConnector, please contact AgilePoint Professional Services.

---

### On Exception

---

### Save Error Message To

Default value: **ErrorMessage**

Specifies the name of a process variable that should be updated if the AgileShape causes an error at runtime. If such an error occurs, a message containing information about the error will be stored in the process variable specified by this property

---

#### Save Status To

Default value: **Success**

Specifies the name of a process variable that should be updated when the AgileShape is exited. Depending if the shape executed correctly or if an error occurred, then the values true or false will be stored (as a String) in the process variable specified by this property. It is common to use a Single Condition shape directly afterwards, bound to the process variable

## Disclaimer of warranty

[Disclaimer of warranty](../../guides/common/DisclaimerOfWarranty.md)
