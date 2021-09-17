__[Home](/) --> [AgileDialogs design guide](/guides/AgileDialogs-DesignGuide.md) --> Numeric Control__

# Numeric Control

This control shows a numeric input to the user to store numeric data. This control stores an invariant numeric data in ValueVariable property and the displayed text in the DisplayVariable property.

![](../media/AgileDialogsDesignGuide/Numeric_01.png)


Numeric control uses the dot as decimal position indicator for value variable,
and the localized screen display for display variable.

Example:

>   **Value variable** saves: 6.23
>   
>   **Display variable** saves: 6,23 for es-ES culture

**Decimals**: This is the number of decilmals for the control data. Only numberic values are allowed.

**MaxValue**: This is the maximum value allowed in the control data. Property accepts a valid numeric input or a custom attribute. 

**MinValue**: This is the minimum value allowed in the control data.

## Disclaimer of warranty

[Disclaimer of warranty](DisclaimerOfWarranty.md)
