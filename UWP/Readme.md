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

UWP crashes without usable callstack (possibly with ESRI runtime) / fix by renaming projects
=============================

What happens: When a component that uses ESRI is loaded from a separate project it sometimes cannot be loaded. Renaming the project might fix this issue.

`
Exe --> A.DLL // fail
Exe --> F.DLL // works
`

Whether this is an UWP or ESRI bug is unclear.

The issue is located in UWP apps' `XamlTypeInfo.g.cs` file. When an UWP library uses anything from ESRI, whether it will work or not, currently depends on the name of the library. If the name of the library starts with a letter that comes before E it will fail, everything post E will work. UWP generates the `XamlTypeInfo.g.cs` by name.

Failing example, because Assembly namespace starts with `Abar`

```cs
private global::System.Collections.Generic.List<global::Windows.UI.Xaml.Markup.IXamlMetadataProvider> OtherProviders
{
	get
	{
		if(_otherProviders == null)
		{
			var otherProviders = new global::System.Collections.Generic.List<global::Windows.UI.Xaml.Markup.IXamlMetadataProvider>();
			global::Windows.UI.Xaml.Markup.IXamlMetadataProvider provider;
			provider = new global::Abar.SituationEditor_Ui_XamlTypeInfo.XamlMetaDataProvider() as global::Windows.UI.Xaml.Markup.IXamlMetadataProvider;
			otherProviders.Add(provider); 
			provider = new global::Esri.ArcGISRuntime.Esri_ArcGISRuntime_Universal_XamlTypeInfo.XamlMetaDataProvider() as global::Windows.UI.Xaml.Markup.IXamlMetadataProvider;
			otherProviders.Add(provider); 
			provider = new global::Esri.ArcGISRuntime.Toolkit.Esri_ArcGISRuntime_Toolkit_XamlTypeInfo.XamlMetaDataProvider() as global::Windows.UI.Xaml.Markup.IXamlMetadataProvider;
			otherProviders.Add(provider); 
			_otherProviders = otherProviders;
		}
		return _otherProviders;
	}
}
```

If the library is called `Fbar`, the order is different and the code then works

```cs
private global::System.Collections.Generic.List<global::Windows.UI.Xaml.Markup.IXamlMetadataProvider> OtherProviders
{
	get
	{
		if(_otherProviders == null)
		{
			var otherProviders = new global::System.Collections.Generic.List<global::Windows.UI.Xaml.Markup.IXamlMetadataProvider>();
			global::Windows.UI.Xaml.Markup.IXamlMetadataProvider provider;
			provider = new global::Esri.ArcGISRuntime.Esri_ArcGISRuntime_Universal_XamlTypeInfo.XamlMetaDataProvider() as global::Windows.UI.Xaml.Markup.IXamlMetadataProvider;
			otherProviders.Add(provider); 
			provider = new global::Esri.ArcGISRuntime.Toolkit.Esri_ArcGISRuntime_Toolkit_XamlTypeInfo.XamlMetaDataProvider() as global::Windows.UI.Xaml.Markup.IXamlMetadataProvider;
			otherProviders.Add(provider); 
			provider = new global::Fbar.SituationEditor_Ui_XamlTypeInfo.XamlMetaDataProvider() as global::Windows.UI.Xaml.Markup.IXamlMetadataProvider;
			otherProviders.Add(provider); 
			_otherProviders = otherProviders;
		}
		return _otherProviders;
	}
}
```
