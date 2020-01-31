__[Home](/) --> [Reference](/ref) -->  [Parent Shape](javascript:history.back()) --> Execute Async__

### RunProcessIndependently property 

Default value: **False**
- **False** : Any process instance started will be a child process of the current process instance.
- **True** : Any process instance started will not be a child process of this current process instance, but an independent process instance with no connection to this process. 
This is useful for Router Processes, where a process kicks off other processes and the parent-child relationship is not desired.