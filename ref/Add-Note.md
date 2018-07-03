## Add Note

<embed src="media/image1.emf" style="width:1.54167in;height:1.16793in" />

Use this shape to add a Note to an entity.

### Properties

<table>
<thead>
<tr class="header">
<th>Property Name</th>
<th>Definition</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>(Name)</td>
<td>Read Only The display name of the AgileShape. To change, double-click the Shape to change its text.</td>
</tr>
<tr class="even">
<td>(UID)</td>
<td>Read Only Default value: [ShapeName.nnn]The ID that uniquely identifies this AgileShape from all others within the same process template.</td>
</tr>
<tr class="odd">
<td>Description</td>
<td><p>Optional</p>
<p><strong>NOTE</strong>: This property is ignored at runtime.</p>
<p>A description of the AgileShape. This property is primarily used as a means of recording additional notes, comments, and details about this AgileShape in order to make the process template more understandable to process modelers.</p></td>
</tr>
<tr class="even">
<td>Time Span, Business Time, Length, Time Unit</td>
<td><p>Default value: 10 Minutes</p>
<p>Specifies the maximum amount of time that should be allowed for the completion of the activity associated with this AgileShape before it is considered overdue.</p>
<p><strong>Business Time:</strong></p>
<ul>
<li></li>
<li></li>
</ul>
<p>Default value: FalseDetermines whether the time span represents normal time, or business hours only. This property can be set to the following specific values:<strong>True</strong> - When set to this value, the time span represents a span of business hours only. e.g. 5 Days of business time would normally be equivalent to 7 Days of normal time, and 8 hours of business time would normally be equivalent to 24 hours of normal time. <strong>False</strong> - When set to this value, the time span represents a normal (absolute) time span, and is unaffected by any business time configuration settings.</p>
<p><strong>Length:</strong></p>
<p>Default value: 10</p>
<p>The number of time units represented by the time span.</p>
<p><strong>Time Unit:</strong></p>
<ul>
<li></li>
<li></li>
<li></li>
<li></li>
<li></li>
<li></li>
</ul>
<p>The type of time unit represented by the time span. This property can be set to the following specific values:Second Minute Hour Day WeekMonth</p></td>
</tr>
<tr class="odd">
<td>Activity Entry Email</td>
<td><p>Optional</p>
<p>The name of an Email Template that should be used to generate an automatic email notification when this AgileShape is entered at runtime. If this property is left blank, then an email notification will not be sent automatically when the AgileShape is entered at runtime. If this property is not blank, then an email notification will be dynamically constructed and sent at runtime (when the AgileShape is entered) using the specified Email Template. To add a new Email Template select <em>Add Mail Template</em>:</p>
<p><img src="media/image2.png" style="width:1.73958in;height:0.60417in" /></p>
<p>See Defining an Email Template</p></td>
</tr>
<tr class="even">
<td>Activity Exit Email</td>
<td><p>Optional</p>
<p>The name of an Email Template that should be used to generate an automatic email notification when this AgileShape is exited at runtime. If this property is left blank, then an email notification will not be sent automatically when the AgileShape is exited at runtime. If this property is not blank, then an email notification will be dynamically constructed and sent at runtime (when the AgileShape is exited) using the specified Email Template. To add a new Email Template select <em>Add Mail Template</em>:</p>
<p><img src="media/image2.png" style="width:1.73958in;height:0.60417in" /></p>
<p>See Defining an Email Template</p></td>
</tr>
<tr class="odd">
<td>Audit Level</td>
<td><p>Default value: High</p>
<p>This property determines the amount of process related data that is recorded to the workflow database. This property can be set at either the Process Template Properties layer or at the individual AgileShape layer. This property allows you to control the level of granularity in terms of the amount of process related data that is recorded to the workflow database. This property can be set to the following specific values:</p>
<ul>
<li><p><strong>High</strong> - This value indicates that AgilePoint will record all data about the activity or process to the database.</p></li>
<li><p><strong>Low</strong> - The record of auto work item will be deleted from database after leaving the activity. No record will be kept for this particular activity</p></li>
</ul></td>
</tr>
<tr class="even">
<td>Session Mode</td>
<td><p>Default value: Single</p>
<p>This property can be set to the following specific values:</p>
<ul>
<li><p><strong>Single</strong> - If it is set to single, then ONLY one session is effective, meaning that in a loop scenario as shown below, the engine would cancel a task from the previous session automatically</p></li>
<li><p><strong>Multiple</strong> - If it is set to multiple, then multiple sessions can be effective in a loop scenario, and the process will wait for all tasks to complete and not cancel any previous tasks</p></li>
</ul>
<p><img src="media/image3.png" style="width:2.768in;height:1.53778in" /></p></td>
</tr>
<tr class="odd">
<td>Wait All Incoming</td>
<td><p>Default Value: True (Dynamic)</p>
<p><embed src="media/image4.emf" style="width:4.43765in;height:2.17391in" /></p>
<ul>
<li></li>
<li></li>
<li></li>
</ul>
<p><strong>NOTE</strong>: This property is ignored at runtime unless the AgileShape has multiple Incoming-Connectors.When an AgileShape has multiple direct predecessors (e.g. below <strong>E</strong> has multiple Incoming-Connectors leading directly from <strong>B</strong>, <strong>C</strong> and <strong>D</strong>), this property determines how the predecessor AgileShapes must be exited (at runtime) before this AgileShape can be entered (at runtime).This property can be set to the following specific values: <strong>False</strong> - This value indicates that the AgileShape (e.g. <strong>E</strong> in example above) will be entered as soon as any one of the AgileShape’s direct predecessors is exited (<strong>B</strong> or <strong>C</strong> or <strong>D</strong>, in example above). <strong>NOTE</strong>: This value is functionally equivalent to using the <strong>Or</strong> AgileShape (with <strong>Exclusive</strong> property set to <strong>False</strong>) between this AgileShape and its direct predecessors. <strong>True (Dynamic)</strong> - This value indicates that the AgileShape (<strong>E</strong> in example above) will be entered only after all of the AgileShape’s <em>enter-able</em> direct predecessors (<strong>B</strong> and either <strong>C</strong> or <strong>D</strong> based on Condition) are exited. If any of the direct predecessors are <em>un-enter-able</em> because conditional logic in the process bypassed them (e.g. <strong>D</strong> if Condition was Yes) and therefore <em>un-exit-able</em>, then those predecessors are not required to be exited before this AgileShape (<strong>E</strong>) is entered.<strong>NOTE</strong>: This value is functionally equivalent to using the <strong>And</strong> AgileShape (with the <strong>Dynamic</strong> property set to <strong>True</strong>) between this AgileShape and its direct predecessors. <strong>True (Static)</strong> - This value indicates that the AgileShape (<strong>E</strong> in example above) will be entered only after all of the AgileShape’s direct predecessors (<strong>B</strong>, <strong>C</strong> <span class="underline">and</span> <strong>D</strong>) are exited (at runtime). Use this only when all predecessors are <em>enter-able</em>.<strong>NOTE</strong>: If any of the direct predecessors are <em>un-enterable</em> (e.g. either <strong>C</strong> or <strong>D</strong>), then this AgileShape (<strong>E</strong>) will never be entered, and the process instance will be permanently delayed at this AgileShape.<strong>NOTE</strong>: This value is functionally equivalent to using the <strong>And</strong> AgileShape (with the <strong>Dynamic</strong> property set to <strong>False</strong>) between this AgileShape and its direct predecessors.</p></td>
</tr>
<tr class="even">
<td>AssemblyName</td>
<td>Read Only Default value: Automatically determined when the AgileShape is first added to the process template. The name of the .NET assembly containing the specific AgilePart or AgileWork this AgileShape instance is associated with</td>
</tr>
<tr class="odd">
<td>ClassName</td>
<td>Read Only Default value: Automatically determined when the AgileShape is first added to the process template. The fully qualified Type name (including the namespace) of the .NET class (in the .NET assembly specified by the AssemblyName property) that represents the specific AgilePart or AgileWork that this AgileShape instance is associated with</td>
</tr>
<tr class="even">
<td>Method</td>
<td>Read Only – Name of the Method being called in the Class shown in ClassName</td>
</tr>
<tr class="odd">
<td>Configure Attachments</td>
<td><p><img src="media/image5.png" style="width:4.59147in;height:3.2087in" /></p>
<table>
<tbody>
<tr class="odd">
<td></td>
<td></td>
</tr>
<tr class="even">
<td></td>
<td></td>
</tr>
<tr class="odd">
<td></td>
<td></td>
</tr>
<tr class="even">
<td></td>
<td></td>
</tr>
<tr class="odd">
<td></td>
<td></td>
</tr>
<tr class="even">
<td></td>
<td></td>
</tr>
</tbody>
</table>
<p><img src="media/image6.png" style="width:4.68696in;height:4.01157in" /></p>
<table>
<tbody>
<tr class="odd">
<td></td>
<td></td>
</tr>
<tr class="even">
<td></td>
<td></td>
</tr>
<tr class="odd">
<td></td>
<td></td>
</tr>
<tr class="even">
<td></td>
<td></td>
</tr>
<tr class="odd">
<td></td>
<td></td>
</tr>
<tr class="even">
<td></td>
<td></td>
</tr>
</tbody>
</table>
<p>OptionalThis is for associating process documentation that is stored in SharePoint to this step.Click the ellipsis button to open the Configure Attachments window:<strong>Field Name / ButtonDefinitionTitle</strong>The value of the Title column of the document that is stored in the SharePoint Document Library<strong>Attachment</strong>URL of the document in SharePoint<strong>ViewNOTE:</strong> Currently this functionality is not supported. In future versions, if checked, it means the document would become accessible and viewable in the Process Manager window<strong>Add</strong>Click to open the <strong>Get SharePoint Document Library</strong> window<strong>Remove</strong>Deletes the association to the document (it does not affect the document in SharePoint)<strong>Open</strong>Opens the document so the contents can be checked<strong>Field Name / ButtonDefinitionSharePoint Server URL</strong>URL to SharePoint Server. Enter this value or select one from the drop-down list, set the credentials and then click the <strong>Get Doc Library</strong> button<strong>Get Doc Library</strong>It connects to the SharePoint Site to get the structure and fill the Library list<strong>Domain / User Name / Password</strong>Specific credentials to connect to SharePoint Site. This user should have Read Permissions in the SharePoint site<strong>Windows Authentication</strong>If checked, the current user’s credentials are used to connect to the SharePoint site<strong>Document Library List</strong>This list is populated once the Get Doc Library button is clicked, with all the library names of the selected SharePoint site<strong>Document Name List</strong>This is a list of the documents available in the Library selected in the list on the left. Once the right document is selected, click the OK button to associate it to this step</p></td>
</tr>
<tr class="even">
<td>Reference URL</td>
<td><strong>NOTE:</strong> Currently this functionality is not supportedOptionalIn future versions , it allows adding a hyperlink to any online artifact by right-clicking and pasting the URL into this propertyThen in Process Manager, the hyperlink would be shown to allow the user to get additional information</td>
</tr>
<tr class="odd">
<td>ExceptionHandlerScope</td>
<td><ul>
<li></li>
<li></li>
</ul>
<p>Default value: LocalSpecifies the value which determines how the rocess Engine (AgilePoint Server) will handle an AgilePart exception. Two options are available: Local or Global:<strong>Local</strong> - This value indicates the exception handling (i.e., error message and status) information for an AgilePart within a single process instance will be saved to the process variables defined in the <strong>SaveErrorMessageTo</strong> and <strong>SaveStatusTo</strong> properties<strong>Global</strong> - This value indicates the exception handling (i.e., error message and status) information is handled the same as the Local option, but includes the extended ability to call on a custom AgileConnector to handle the exception as desired</p></td>
</tr>
<tr class="even">
<td>SaveErrorMessageTo</td>
<td>Default value: ErrorMessageSpecifies the name of a process variable that should be updated if the AgileShape causes an error at runtime. If such an error occurs, a message containing information about the error will be stored in the process variable specified by this property</td>
</tr>
<tr class="odd">
<td>SaveStatusTo</td>
<td>Default value: Success Specifies the name of a process variable that should be updated when the AgileShape is exited. Depending if the shape executed correctly or if an error occurred, then the values true or false will be stored (as a String) in the process variable specified by this property. It is common to use a Single Condition shape directly afterwards, bound to the process variable</td>
</tr>
<tr class="even">
<td>EntityId</td>
<td>This should be the ID of the desired entity record. This value is usually a dynamic value.</td>
</tr>
<tr class="odd">
<td>EntityType</td>
<td>Select the entity type. This can only be a static value selected from the drop-down list</td>
</tr>
<tr class="even">
<td>Subject</td>
<td>Sets the title of the Note. It can be a static or a dynamic value.</td>
</tr>
<tr class="odd">
<td>Text</td>
<td>Set the text of the body of the Note. It can be a static or a dynamic value.</td>
</tr>
</tbody>
</table>

### Actions

#### Collapse/Expand Shape

Right-clicking the shape brings up the **Collapse** menu action. Clicking it collapses the shape to a small circle. Right-clicking a collapsed shape shows the **Expand** menu item, restoring the shape to its original form.

Use Collapse shape to minimize the visual effect of steps in the process which are not of any interest to the Business User.

#### Add/Remove Timer

Right-clicking the shape brings up the **Add Timer** menu action. Clicking it adds a timer to the shape, allowing the process modeler to add an alternative route out of the shape when the configured Time Span times out.

Right-clicking a shape with a Timer shows a **Remove Timer** menu action, which would remove the timer from the shape.
