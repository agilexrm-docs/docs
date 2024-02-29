**[Home](/) --> [Reference](/ref) --> Process Params**

# Process Params

**AgileDialogs** allows additional parameters to be sent to process instances.

These values are stored in the process context and can be used during the process as an additional variable like any other variable.

> Note: 

In the case where a parameter is sent whose name matches a page control, this value shall be used as the control value.

## Single value

To send additional parameters to the process context we only have to specify the **ProcessParams** parameter in the URL we use to execute the dialog.

The parameters must be specified as key-value pairs - `param1=param1Value` - and URL encoded. This means that ProcessParams value look like this `ProcesParams=param1%3Dparam1Value`.

> Tip: Use encodeURIComponent javascript function to get a valid value to ProcessParams

<pre><code>
https://axrm/AgileDialogs/AgileDialogsKendoRuntime.aspx?orgname=[Org]&DefaultProcessTemplate=[Template]&<b>ProcessParams=paramName%3DParamValue</b>
</code></pre>


> This sample will create a `param1` variable in process context with `ParamValue` value.



## Multiple values 

To send multiple additional parameters to the process context, we act in the same way as for sending a single parameter, but use the "&" symbol to concatenate the multiple values. Exactly the same as any other querystring string parameter. 

The parameters must be specified as key-value pairs: param1=param1Value&param2=param2Value

<pre><code>
https://axrm/AgileDialogs/AgileDialogsKendoRuntime.aspx?orgname=[Org]&DefaultProcessTemplate=[Template]&<b>ProcessParams=param1%3Dparam1Value%26param2%3Dparam2Value</b>
</code></pre>

> This sample will create two variables in process context,  `param1` variable with `param1Value` value and `param2` variable with `param2Value`.


## Disclaimer of warranty

[Disclaimer of warranty](../guides/common/DisclaimerOfWarranty.md)
