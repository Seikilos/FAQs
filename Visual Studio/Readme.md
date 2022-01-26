Installing Visual Studio offline on a machine without internet
==============================
See https://docs.microsoft.com/en-US/visualstudio/install/create-a-network-installation-of-visual-studio?view=vs-2019

**Important**: If you install by this way, the layout location is fixed. You will always have to install it from this location for all future updates.
If you already installed from an incomplete location and need update this layout there, you either have to uninstall or update the location. You can't simply run the installer
from another (e.g. more complete) layout

* First: Create a network installation from the bootstrapper of your choice
  `.\vs_professional.exe --layout 'F:\\Visual Studio 2019\\layout' --useLatestInstaller --includeRecommended --lang en-US`
* (Install Certificates on this machine, because installation might fail otherwise)

* Installation can be done by simply running the `vs_professional.exe` from the layout folder

Troubleshooting offline installation
=================================
On some machines even having a complete layout of the installer, it decides that it does not have the necessary packages.
To debug this, go to `%TMP%` (*not %TEMP%*) and look for `dd_` files.
Sometimes there is an error that an vsix package could not be found. This happens even if it can be located in the layout physically.
The installer does not check the *offline layout* folder for it but starts looking in `%PROGRAMDATA%/Microsoft/VisualStudio/Packages`. 
It does not exist there, obviously and instead turning to the offline layout, it pulls the catalog file and tries to download it.

Possible workarounds:
* Copy all packages from the offline layout manually to `%PROGRAMDATA%/Microsoft/VisualStudio/Packages`. Then try again. Note: This might require a lot of disk space
* Download a new vanilla offline layout and try again (tried and failed) => Appears that currently visual studio clean install without internet documentation is not complete

