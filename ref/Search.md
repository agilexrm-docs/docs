__[Home](/) --> [Reference](/ref) --> Search__

# Search

![Search](media/search.png)

This shape can:

-   Check if a certain Search criteria in CRM is met or not and return a count
-   Optionally, return all the records that meet a certain search criteria in CRM


## Shape-Specific Properties

| Property | Description |
| -------- | ----------- |
| **Exists**              | The holds the name of the Boolean process variable that is set depending if the query expression returns zero (False) or one-or-more records (True). By default the name of the variable is *Exists*, but this can set to any valid variable name. It is common to use this variable to take decisions later in the process. |
| **QueryExpression**     | [Query Expression](common/QueryExpression.md)|
| **ResultCount**         | The holds the name of the variable that is set to the number of records that the query expression has returnes. By default the name of the process variable is *ResultCount*, but this can set to any valid variable name. |
| **ReturnAllRecords**    | Default value: **False**<br />- **False** : The query will variables defined in the *Save Output* tab of the QueryExpression dialog are set to the first record that meets the search criteria<br />- **True** : The variables defined in the *Save Output* tab of the QueryExpression dialog are set to a semicolon-seperated list of of all records returned by the search criteria|
| **ReturnDisplayValues** | Default value: **False**<br />- **False** : The variables defined in the *Save Output* tab of the QueryExpression will return internal values (applies for OptionSet, Two Values,... fields) <br />- **True** : The variables defined in the *Save Output* tab of the QueryExpression will return display values (applies for OptionSet, Two Values,... fields)|


## Other Common Properties
All shapes have many other common properties. Look them up here: [Common Poperties](common/README.md)

## Actions
See [Actions](common/Actions.md)

## Disclaimer of warranty

[Disclaimer of warranty](../guides/common/DisclaimerOfWarranty.md)