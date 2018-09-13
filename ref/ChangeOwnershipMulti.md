__[Home](/) --> [Reference](/ref) --> Change ownership (Multi)__

# Change ownership (Multi)

![Change ownership (Multi)](media/ChangeOwnerShipMulti.png)

This shape is used to change the Owner of multiple entity records to another User or Team.

The set of records that are affected are selected by either:

* The ones returned by the query configured in the *QueryExpression* property
* From a semicolon-separated list of IDs passed via the *EntityIds* property

> __NOTE__: Owner field is a special field and cannot be changed using the *Update Entity (Multi)* shape.

## Shape-Specific Properties

| Property | Description |
|-----------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **EntityIds**   | This could be a list of entity record IDs seperated with a semicolon (;). It can take dynamic variable(s)                                                                                                                                   |
| **EntityName**| [Entity Name](common/EntityName.md)|
| **NewOwner**| This can be any of these: If *OwnerType* property is set to *User* then it can be either *CRM Domain Logon Name* (*domainname*) or *User* (*systemuserid*). If *OwnerType* property is set to *Team* then it must be the *Team ID.(teamid)* |
| **OwnerType**| This can be either **User** or **Team**|
| **QueryExpression** | [Query Expression](common/QueryExpression.md)|

## Other Common Properties
All shapes have many other common properties. Look them up here: [Common Poperties](common/README.md)

## Actions
See [Actions](common/Actions.md)
