__[Home](/) --> [AgileDialogs Design Guide](/guides/AgileDialogs-DesignGuide.md) --> Calendar__

# Calendar control

This control shows a date picker and an optional time picker to the user:

![](../media/AgileDialogsDesignGuide/Calendar_01.png)

In order to only show the date picker, in the *Advanced* tab set *DateOnly*
property to *true*.

![](../media/AgileDialogsDesignGuide/Calendar_02.png)

In order to set the current datetime in the calendar control, use the special
value **Now** in the *Default Value* property (note: the values range go from
1900 to 2099).

![](../media/AgileDialogsDesignGuide/Calendar_03.png)

By default, AgileDialogs calendar control shows its content using CRM timezone settings so we can change this behavior by *TimeZoneIndependent* property.

Either type the date/time or select them using the mouse:

![](../media/AgileDialogsDesignGuide/Calendar_04.png)

![](../media/AgileDialogsDesignGuide/Calendar_05.png)

> **Note**: Calendar control uses the *ISO-8601* format to store its value variable.

> **Note**: The control does not have the ControlWidth property.

