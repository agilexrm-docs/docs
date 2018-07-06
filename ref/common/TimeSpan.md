**[Home](/) --> [Reference](/ref) --> [Common Properties](/ref/common) --> Time Span**

### Time Span property 

Specifies the maximum amount of time that should be allowed for the completion of the activity associated with this AgileShape before it is considered overdue.

#### Business Time
Default value: False

Determines whether the time span represents normal time, or business hours only.

This property can be set to the following specific values:

-   **True** - When set to this value, the time span represents a span of
    business hours only. E.g. 5 Days of business time would normally be
    equivalent to 7 Days of normal time, and 8 hours of business time would
    normally be equivalent to 24 hours of normal time

-   **False** - When set to this value, the time span represents a normal
    (absolute) time span, and is unaffected by any business time configuration
    settings

#### Length
The number of Time Units represented by the Time Span

#### Time Unit
The type of time unit represented by the time span. This property can be set to
the following specific values:

-   Second
-   Minute
-   Hour
-   Day
-   Week
-   Month

