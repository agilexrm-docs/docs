__[Home](/) --> [AgileDialogs Design Guide](/guides/AgileDialogs-DesignGuide.md) --> Group Container Control__

# Group Container control

The Group Container allows us to build a certain set of controls inside a same
group container, for functional and / or decorative purposes. We can group
different kinds of controls (textboxes, combos, calendars, etc.) inside this
container, and we also can validate all these inner elements as a whole or
toggle its visibility through the container properties.

![](../media/AgileDialogsDesignGuide/GroupContainerControl_01.png)

**How to create a Group Container in a Form**

The way to add a new group container would be through the add control / Group
Container options.

![](../media/AgileDialogsDesignGuide/GroupContainerControl_02.png)

![](../media/AgileDialogsDesignGuide/GroupContainerControl_03.png)

Once we added the group container to the form, we will proceed to place our
inner controls inside it. We have to position into our control and add the
desired elements right-clicking on it

![](../media/AgileDialogsDesignGuide/GroupContainerControl_04.png)

The properties for the Group Container control are:

-   **AllowAlign**:

-   If activated, the container would position inline to the other elements next
    to it.

    ![](../media/AgileDialogsDesignGuide/GroupContainerControl_05.png)

-   If set to false, the group container will be aligned as a block and will not
    allow other elements to be positioned beside it.

    ![](../media/AgileDialogsDesignGuide/GroupContainerControl_06.png)

-   **ColumnSpan**: this property can be modified for the element to adjust its
    width inside the canvas, from a minimum of 1 column to a maximum of 12 (the
    actual canvas width).

-   **GroupType**: this property controls the appearance of the actual group
    container to be shown in the canvas.

    -   **None**: the group container will not have any special appearance or borders to
    separate it from the rest of the canvas elements.

    -   **FieldSet**: the group container will have a leading title and a line
        delimiter. There will be a margin between the container and the elements
        surrounding it.

        ![](../media/AgileDialogsDesignGuide/GroupContainerControl_07.png)

    -   **Panel**: the group container will be locked inside a thicker delimiter (title
    included). There will be a margin between the container and the elements
    surrounding it.

    ![](../media/AgileDialogsDesignGuide/GroupContainerControl_08.png)

    -   **Box**: the group container will be locked inside a thin delimiter (title
    included). There **will not be** a margin between the container and the
    elements surrounding it.

    ![](../media/AgileDialogsDesignGuide/GroupContainerControl_09.png)

**Visible**: controls if the control is visible to the user. This can be
adjusted on runtime to improve performance or include new application
functionalities.

**Height**: Optional property. Handles the height of the Group Container (in
    pixels). Useful in cases in which there are various group containers,
    aligned horizontally, with different content, and we want them to have the
    same height for layout purposes (image below).

![](../media/AgileDialogsDesignGuide/GroupContainerControl_10.png)

>   Figure 6. Two aligned group containers, the first one does not have the
>   height property set.

![](../media/AgileDialogsDesignGuide/GroupContainerControl_11.png)

> Figure 7. "Height" property set in the first group container, to match the same
> height of the second group container
