**[Home](/) --> [Reference](/ref) --> Upsert Entity**

# Upsert Entity

![Upsert Entity](media/UpsertEntity.png)

This activity is used to look for a particular entity record (or set of records) to be updated if there are found, otherwise a new record is created, including custom entities
as well as entities not related to the Main Entity.

The set of records that are affected are selected by the ones returned by the query configured in the *QueryExpression* property


## Shape-Specific Properties

| Property | Description |
| -------- | ----------- |
| **EntitySpecification** 				| [Entity Specification](common/EntitySpecification.md)  |
| **EntityType**   						|[Entity Type](common/EntityType.md)    |
| **OnBehalfOf**   						|[On Behalf Of](common/OnBehalfOf.md)    |
| **QueryExpression** 					| [QueryExpression](common/QueryExpression.md) |
| **RecordCreatedValueTo** 				| [Record Created Value To](common/RecordCreatedValueTo.md) |
| **SaveEntityIdTo**       				| [Save Entity Id To](common/SaveEntityIdTo.md) |
| **ThrowExceptionIfMultipleFound** 	| [Throw Exception If Multiple Found](common/ThrowExceptionIfMultipleFound.md) |


## Other Common Properties
All shapes have many other common properties. Look them up here: [Common Poperties](common/README.md)

## Actions
See [Actions](common/Actions.md)

## Disclaimer of warranty

[Disclaimer of warranty](../guides/common/DisclaimerOfWarranty.md)