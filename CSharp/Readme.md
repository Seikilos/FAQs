Misc
=============

Release without debugger fails, with debugger works
---------------
Noticed behaviour: Code (unit tests) compile and run well in debug with and without attached debugger. 
In release however only when a debugger is attached, the code runs fine.
When running code without debugger or attaching it after startup code shows strange behaviour.

Known issues:
* Use of ```Assembly.GetCallingAssembly``` (see https://msdn.microsoft.com/en-US/library/system.reflection.assembly.getcallingassembly%28v=vs.110%29.aspx)
  * GetCallingAssembly may point to wrong assembly if optimization of code is enabled and the callee method is the last instruction in the caller method
  => Solution: Pass executing assembly to methods in different assembliesinstead of relying on GetCallingAssembly
