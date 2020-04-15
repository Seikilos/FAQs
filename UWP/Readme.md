UWP apps cannot be uninstalled from other user
=======================
See http://techgenix.com/sysprep-problems-app-x-packages/ and use the provided script.

There is sometimes an issue that prevents devs to uninstall apps installed by other users. 
Restoring the app registry is therefore a possible solution to messing with `Get-AppxPackage -AllUsers | Remove-AppPackage -AllUsers` combinations which fail in certain scenarios

Download Fix-Sysprep.ps1 to C:\Powershell\Fix-Sysprep.ps1
and execute this line *as admin*

```bat
schtasks /create /RU "SYSTEM" /NP /SC ONSTART /TN Reset-AppX /TR "powershell C:\Powershell\Fix-Sysprep.ps1" /F
```

NetNative compiling ILC issues
===============================

32 bit nutc compiler sometimes fails, without looking at diagnostic output of msbuild there is no really helpful error. Force it to 64 bit

```xml
<Use64BitCompiler>true</Use64BitCompiler>

<!-- Unverified -->
<ShortcutGenericAnalysis>true</ShortcutGenericAnalysis>
<SingleThreadNUTC>true</SingleThreadNUTC> <!-- This might slow things down a lot -->

```

DependencyProperty for Nullable types and IReference<T> error
============================

Binding to nullable will often result in such an error

`Converter failed to convert value of type 'Windows.Foundation.UInt32' to type 'IReference`1<UInt32>' ...`

This article explains a lot: https://www.danrigby.com/2012/07/24/windows-8-dev-tip-nullable-dependency-properties-and-binding/

The gist is, the property can be _nullable type_ but the DependencyProperty **must** be object

```cs
public static readonly DependencyProperty SomeNumberProperty = DependencyProperty.Register(
    "SomeNumber", typeof(object), typeof(MyClass), new PropertyMetadata(default(uint?)));  // <-- typeof(object) but default is uint?

public uint? SomeNumber  // <-- uint?
{
	get
	{
		return (uint?)this.GetValue(SomeNumberProperty); // <-- uint?
	}
	set
	{
		this.SetValue(SomeNumberProperty, value);
	}
}
```
