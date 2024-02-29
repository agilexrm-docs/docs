# Audit Level property

**[Home](/) --> [Reference](/ref) --> [Common Properties](/ref/common) --> Audit Level**

---

Default value: **High**

This property determines the amount of process related data that is recorded to
the workflow database. This property can be set at either the *Process Template
Properties* layer or at the individual AgileShape layer. This property allows you
to control the level of granularity in terms of the amount of process related
data that is recorded to the workflow database. This property can be set to the
following specific values:

- **High** - This value indicates that process engine will record all data about
    the activity or process to the database.

- **Low** - The record of auto work item will be deleted from database after
    leaving the activity. No record will be kept for this particular activity. For high volume environments, it is recommended to set this property to Low, to reduce DB size.

---

## Disclaimer of warranty

[Disclaimer of warranty](../../guides/common/DisclaimerOfWarranty.md)
