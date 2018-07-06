**[Home](/) --> [Reference](/ref) --> [Common Properties](/ref/common) --> Session Mode**

### Session Mode property 

Default value: Single

This property can be set to the following specific values:

-   **Single** - If it is set to single, then ONLY one session is effective,
    meaning that in a loop scenario as shown below, the engine would cancel a
    task from the previous session automatically

-   **Multiple** - If it is set to multiple, then multiple sessions can be
    effective in a loop scenario, and the process will wait for all tasks to
    complete and not cancel any previous tasks

![](/ref/media/SessionMode.png)
