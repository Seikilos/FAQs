Change the dotnet executable version to known version
====================

Default `dotnet` cli command will call latest installed. If you wish to use another known, working version, you have to create a global.json in a working directory
where the command is executed (any working directory will do. It is not required to have this file somewhere in the repo.

```
dotnet --list-sdks
3.1.401 [C:\Program Files\dotnet\sdk]
5.0.400 [C:\Program Files\dotnet\sdk]
6.0.300 [C:\Program Files\dotnet\sdk]

```

In your working directory call

```
dotnet new globaljson --sdk-version 5.0.400
 
dotnet --version
5.0.400

```

Now only in this directory the version is pinned. If you `cd ..` and execute `dotnet --version` you will get another version
