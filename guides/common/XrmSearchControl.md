__[Home](/) --> [AgileDialogs design guide](/guides/AgileDialogs-DesignGuide.md) --> XRM  Search Control__

# XRM Search control

XRM Search control allows to perform a XRM FetchXML search in AgileDialogs page
and set the data retrieved to page controls.

> **Important**: FetchXML query must to retrieve a single record.

We can run the FetchXML query in these scenarios:

-   When AgileDialogs page loads.
-   When a control changes its value.

XRM Search control does not create variables in process context.

![](../media/AgileDialogsDesignGuide/XRMSearchControl_01.png)

To configure XRM Search control:

-   Click on configure button to build a FetchXML query, as any other data
    control.

    ![](../media/AgileDialogsDesignGuide/XRMSearchControl_02.png)

-   Under Advanced properties tab set these properties:

    -   **TriggerOnLoad**: This property defines if XrmSearch control will
        perform the query when AgileDialogs page is loaded.

        -   **None**: Control will not perform the search when AgileDialogs page is
            loaded.

        -   **OnlyNextNavigation**: Control will perform the query only when user
            does a *Next* navigation (using the *Next* button in AgileDialogs
            page). First page of an AgileDialogs process is considered as *Next*
            navigation.

        -   **OnlyBackNavigation**: Control will perform the query only when user
            does a *Back* navigation(using the *Back* button in AgileDialogs
            page). Navigation using page breadcrumbs is considered as *Back*
            navigation.

        -   **Always**: Control will perform the search in both navigation sources,
            *Next* and *Back* operations.

            ![](../media/AgileDialogsDesignGuide/XRMSearchControl_03.png)

    -   **TriggerControls**. This property defines which controls in the same
        AgileDialogs page will perform the Xrm search control when its value
        changes. Multiple controls will perform multiple query operations.  
        
        ![](../media/AgileDialogsDesignGuide/XRMSearchControl_04.png)

    -   **Mappings**. This property defines how the result data will populate
        the form data. Each column retrieved from FetchXML query needs an
        associated target control to display the retrieved data.

        ![](../media/AgileDialogsDesignGuide/XRMSearchControl_05.png)

        Use the left side column list to define a mapping for all FetchXML
        columns.

        ![](../media/AgileDialogsDesignGuide/XRMSearchControl_06.png)

        ![](../media/AgileDialogsDesignGuide/XRMSearchControl_07.png)
