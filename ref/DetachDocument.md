__[Home](/) --> [Reference](/ref) --> Detach Document__

# Detach Document

![Detach Document](media/DetachDocument.png)

This shape is used to copy/move attachments (*annotations*) from an CRM entity
to others systems.

The destination system can be any AgilePoint NX Global Access Token. Global
Access Token must be created previously in AgilePoint NX administration portal.

## Shape-Specific Properties

| *Document Source (CRM Entity)* |  
| -------- | ----------- |
| Property | Description |
| <span style="padding-left:16px" />**EntityId**    |[EntityId](common/EntityId.md)|
| <span style="padding-left:16px" />**EntityName**  |[Entity Name](common/EntityName.md)|
| <span style="padding-left:16px" />**AnnotationId**| The annotationID for the document source. Multiple values are allowed using ";". |
| <span style="padding-left:16px" />**Filter**      | The filename or filter for the document source. Wildcards are allowed. For example, it can be "\*.pdf" to get all PDF files. When both the annotationID property and the filter property have value, the filter property is applied to the result set obtained from the query by annotationID |
| <span style="padding-left:16px" />**RemoveNotes** | Indicates if the source annotation should be deleted after transfer document. |
| *__Document Destination__* |  
| Property | Description |
| <span style="padding-left:16px" />**Destination** |[Destination](common/DestinationProperty.md)|
| <span style="padding-left:16px" />**SaveResponseIdTo** |The variable name where created document response will be store|


## Other Common Properties
All shapes have many other common properties. Look them up here: [Common Poperties](common/README.md)

## Actions
See [Actions](common/Actions.md)

## Disclaimer of warranty

[Disclaimer of warranty](../guides/common/DisclaimerOfWarranty.md)