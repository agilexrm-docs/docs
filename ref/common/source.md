__[Home](/) --> [Reference](/ref)  -->  [Parent Shape](javascript:history.back()) --> Source__

### Source property 

The source for the attachment file or files.

![](../media/Source.png)

**Global Access Token:** The AgilePoint global access token to access the source
system.

**Site:** (SharePoint repository) The SharePoint site where source documents are stored. Can be a static
value or AgilePoint variable. This field is disabled from non SharePoint
document repositories.

**Document library:** (SharePoint repository) The SharePoint document library where source documents are
stored. Can be a static value or AgilePoint variable. This field is disabled
from non SharePoint document repositpries.

**Dynamic folder path:** The folder path where source documents are stored. Can
be a static value or an AgilePoint variable. This value depends on the repository type. 
For example, when document source is a SharePoint server, this
field must contains the folder name, but when document source is Google Drive
this field must contain the folderID of GoogleDrive.

> __NOTE__: For source systems that need a folderID, as GoogleDrive, the best practice
is store the value in an AgilePoint Shared Variable.

**File name:** The filename or file filter for source files. Wildcards are
allowed. For example, it can be “\*.pdf” to get all PDF files.

**Delete source files:** Indicates if the source files should be deleted after
attaching the document.

> __NOTE__: The Process Server (AgilePoint Server) Application Pool Identity
should have Read permission on the file(s)
