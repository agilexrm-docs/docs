__[Home](/) --> [AgileDialogs Design Guide](/guides/AgileDialogs-DesignGuide.md) --> Combo__

# Combo control

This control presents a set of options in a combo box (Currently the edit part
of the combo is disabled and the combo control behaves as a standard drop-down
list box).

![](../media/AgileDialogsDesignGuide/Combo_01.png)

Combo can show:

-   Static values
-   Dynamic values

The **AutoNext** property, if set to **true**, enables the control to move
forward, once the user has filled in the control with the desired value.

![](../media/AgileDialogsDesignGuide/Combo_02.png)

For instance, if we have a Page Form composed of one Combo control, with its
*Required* property set to **true** we would need to select an item inside our
control, and press the predefined **next** button afterwards to move forward
in the dialog (image below); however, if we set **AutoNext** to *true*, the
process will continue as soon as we select a value for our Combo control,
without pressing the *next* button.

> **Important**: if there is any other control
> in the current form with its *required* property set to true, the process will not
> move forward automatically.

![](../media/AgileDialogsDesignGuide/Combo_03.png)

