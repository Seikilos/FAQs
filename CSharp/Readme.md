Misc
=============

Release without debugger fails, with debugger works
---------------
Noticed behaviour: Code (unit tests) compile and run well in debug with and without attached debugger. 
In release however only when a debugger is attached, the code runs fine.
When running code without debugger or attaching it after startup code shows strange behaviour.

Known issues:
* Use of ```Assembly.GetCallingAssembly``` with **Tail-Call** optimization 
  * see https://msdn.microsoft.com/en-US/library/system.reflection.assembly.getcallingassembly%28v=vs.110%29.aspx
  * GetCallingAssembly may point to wrong assembly if optimization of code is enabled and the callee method is the last instruction in the caller method
  => Solution: Pass executing assembly to methods in different assembliesinstead of relying on GetCallingAssembly

Add subdirectories for assembly searching
--------------
There might be a situation where you must build an assembly into a subdirectory, which is then loaded by some plugin loading concept. To avoid to copy all dependencies to the subdirectory too you set those dependencies to `CopyLocal=false`. You will end up with only the assembly you need in a subdirectory. 
Since it is loaded at runtime, the host must provide all the required dependencies.

For the unit testing assembly however there might be a problem. Running the test assembly requires the assembly in the subdirectory as well all of its dependencies in the root directory.
When the unit test assembly is in the subdirectory, it won't be able to resolve all those other dependencies and vice versa.

To avoid to copy the assembly in the sub directory also into the root directory (for the tests to run) you need add the sub directory to the search path of the unit test assembly, when it resolves its dependencies.
A solution to this is to add the sub directory to the `.config` file for the test assembly:
```xml
<configuration>
   <runtime>
      <assemblyBinding xmlns="urn:schemas-microsoft-com:asm.v1">
         <probing privatePath="bin;bin2\subbin;bin3"/>
      </assemblyBinding>
   </runtime>
</configuration>
```
See: https://msdn.microsoft.com/en-us/library/823z9h8w(v=vs.110).aspx

Set Error Message to Englisch
-------------------------

```c#
public static void SetToEnglish()
{
    System.Threading.Thread.CurrentThread.CurrentCulture = System.Globalization.CultureInfo.InvariantCulture;
    System.Threading.Thread.CurrentThread.CurrentUICulture = System.Globalization.CultureInfo.InvariantCulture;
}
```

Bootstrap .net Core in Native C++ Application
=====
See https://docs.microsoft.com/en-us/dotnet/core/tutorials/netcore-hosting
