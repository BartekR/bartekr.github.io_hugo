---
title: "Upgrading SSIS projects, part II"
date: "2018-02-04"
draft: false
images:
  - src: "2018/02/04/upgrading-ssis-projects-part-ii/images/Debugging.png"
    alt: ""
    stretch: ""
coverImage: "Debugging.png"
tags: ['migration', 'SSIS', 'SSIS internals']
categories: ['internals']
---

The problem I want to solve is automation of the SSIS project upgrade. [Previously](http://blog.bartekr.net/2017/12/24/upgrading-ssis-projects-part-i/) I wrote about the options to use [Application.Upgrade()](https://docs.microsoft.com/en-us/dotnet/api/microsoft.sqlserver.dts.runtime.application.upgrade?view=sqlserver-2017) or [Application.SaveAndUpdateVersionToXml()](https://docs.microsoft.com/en-us/dotnet/api/microsoft.sqlserver.dts.runtime.application.saveandupdateversiontoxml?view=sqlserver-2017) methods. This post is about the first of those options.

If you take a look at the documentation link provided above you will see just the information about the function and its parameters, nothing more. Luckily, at the time of writing there is another version of the documentation on MSDN: [https://msdn.microsoft.com/en-us/library/microsoft.sqlserver.dts.runtime.application.upgrade.aspx](https://msdn.microsoft.com/en-us/library/microsoft.sqlserver.dts.runtime.application.upgrade.aspx) with the example of upgrading the packages stored in the filesystem. If the page disappears, I have a [backup copy on my](https://gist.github.com/BartekR/c32ccac38321811b7277cce87c2ee976) GitHub:

{{< gist BartekR c32ccac38321811b7277cce87c2ee976 >}}

Great! So, we just copy the example, change the filenames and folders to reflect our project location, and that's it!

No, it isn’t. It doesn't work.

_Failed to backup the old package: The given path's format is not supported._

The method works, but we need to tweak it a bit. Let's dig a bit more into the API and the example.

I will use a sample migration project with one package, that creates a table, generates some numbers and inserts them into the created table and at the end, it drops the table. It uses one project connection manager to the `tempdb` database. The link to the download is at the end of the post.

[![Package](images/Package.png#center)](images/Package.png)

Side note: when I test the following code I set up the breakpoint on the `app.Upgrade()` line and analyse the output object, mostly looking at the Failures collection.

[![Debugging app.Upgrade](images/Debugging.png#center)](images/Debugging.png)

Also – when you set up the reference to the `Microsoft.SqlServerManagedDTS.dll` (located in `C:\Windows\Microsoft.NET\assembly\GAC_MSIL\Microsoft.SqlServer.ManagedDTS`) be sure to check the version you are planning to use. For example – if you check the version 14.0 (`v4.0_14.0.0.0__89845dcd8080cc91` subfolder) you will be able to migrate ONLY to SQL Server 2017. If you want to migrate to SQL Server 2016 use version 13.0 (`v4.0_13.0.0.0__89845dcd8080cc91` subfolder). The library version is important as it sets up the [Application.ComponentStorePath](https://msdn.microsoft.com/en-us/library/microsoft.sqlserver.dts.runtime.application.componentstorepath.aspx) property – the folder to tasks and components of SSIS (e.g. `C:\Program Files (x86)\Microsoft SQL Server\140\DTS` for SQL Server 2017)

## Application.Upgrade()

First things first: take a look at the `Application.Upgrade()` at the end of the script. What are the parameters of the `Upgrade()` method:

```csharp
public Microsoft.SqlServer.Dts.Runtime.UpgradeResult Upgrade (
    System.Collections.Generic.IEnumerable<Microsoft.SqlServer.Dts.Runtime.UpgradePackageInfo> packages,
    Microsoft.SqlServer.Dts.Runtime.StorageInfo source,
    Microsoft.SqlServer.Dts.Runtime.StorageInfo destination,
    Microsoft.SqlServer.Dts.Runtime.BatchUpgradeOptions options,
    Microsoft.SqlServer.Dts.Runtime.IDTSEvents events
);
```

- the packages we want to upgrade (packages)
- location of these packages (source)
- where we want to save the upgraded packages (destination)
- some options for the upgrading process (options)
- an object for the events that happened during the process (events)

The method returns the [UpgradeResult](https://docs.microsoft.com/en-us/dotnet/api/microsoft.sqlserver.dts.runtime.upgraderesult?view=sqlserver-2017) object with the results of the upgrade for each package. The earlier parts of the script are preparing the Application object and all parameters for the `Upgrade()` method.

Why the example doesn't want to work? The [UpgradePackageInfo()](https://docs.microsoft.com/en-us/dotnet/api/microsoft.sqlserver.dts.runtime.upgradepackageinfo.-ctor?view=sqlserver-2017#Microsoft_SqlServer_Dts_Runtime_UpgradePackageInfo__ctor) method documentation - states that we provide the names and the full paths of the packages. The [StorageInfo](https://docs.microsoft.com/en-us/dotnet/api/microsoft.sqlserver.dts.runtime.storageinfo?view=sqlserver-2017) class documentation - the property [RootFolder](https://docs.microsoft.com/en-us/dotnet/api/microsoft.sqlserver.dts.runtime.storageinfo.rootfolder?view=sqlserver-2017#Microsoft_SqlServer_Dts_Runtime_StorageInfo_RootFolder) gets or sets the path to the folder where we back up the packages. When we set the `RootFolder` property it is prepended to the package path provided in the `UpgradePackageInfo()` – so we have an invalid path. So either we have to remove either RootFolder property or leave just the names of the packages in `UpgradePackageInfo()`. When you test both options you know, you have to use RootFolder property, otherwise you get an error:

_Failed to backup the old package: A source root folder is not specified._

I change then the `UpgradePackageInfo()` and put just the file name. To make things consistent, I will also use the `RootFolder` for the target location:

```csharp
UpgradePackageInfo packinfo1 = new UpgradePackageInfo("Package.dtsx", "Package.dtsx", null);

StorageInfo storeinfoDest = StorageInfo.NewFileStorage();
storeinfoDest.RootFolder = "C:\\tmp\\MigrationSample";
```

If you run the code, you still get an error, but this time it’s different. This time the Failures collection contains 5 error messages:

1. "The package format was migrated from version 6 to version 8. It must be saved to retain migration changes.\\r\\n"
2. "The connection \\"{CE71E990-4590-4AB1-998B-E7AA9C87DE35}\\" is not found. This error is thrown by Connections collection when the specific connection element is not found.\\r\\n"
3. "The connection \\"{CE71E990-4590-4AB1-998B-E7AA9C87DE35}\\" is not found. This error is thrown by Connections collection when the specific connection element is not found.\\r\\n"
4. "Succeeded in upgrading the package.\\r\\n"
5. "The loading of the package Package.dtsx has failed."

It looks like the package was migrated from version 6 to 8 \[1\], the package was upgraded with success \[4\], but I had the problem with the connection \[2\], \[3\] and had some problems with loading the Package.dtsx (it’s about the source package name, not the target).

So – did the package upgrade or not? Not. The source package is still the same – when you check the source of the package you see `<DTS:Property DTS:Name="PackageFormatVersion">6</DTS:Property>`.

The problem with the connection is because it uses connection manager at the project level, not the package level. How can we use the information stored in the project file? The `BatchUpgradeOptions` class has the [`ProjectPath`](https://msdn.microsoft.com/en-us/library/microsoft.sqlserver.dts.runtime.batchupgradeoptions.projectpath.aspx) property where we can set (and get) the full path to the `.dtproj` file.

```csharp
upgradeOpts.ProjectPath = "C:\\tmp\\MigrationSample\\MigrationSample.dtproj";
```

Now the example works but gives a warning instead of success. The warning contains four messages:

- "Failed to decrypt an encrypted XML node. Verify that the project was created by the same user. Project load will attempt to continue without the encrypted information."
- "Failed to decrypt sensitive data in project with a user key. You may not be the user who encrypted this project, or you are not using the same machine that was used to save the project. If the sensitive data is a parameter value, the value may be required to run the package on the Integration Services server."
- "The package format was migrated from version 6 to version 8. It must be saved to retain migration changes.\\r\\n"
- "Succeeded in upgrading the package.\\r\\n"

The source SSIS project was created with default protection level `EncryptSensitiveWithUserKey`. The user key is created for the user and the machine that package was created (or edited), so when we try to open the package on another machine, it has the problem with decryption of the sensitive data. This project has no sensitive data, so it’s just a standard behaviour of SSIS and we can ignore the warnings.

## UpgradeOptions

To set some options for the upgrade process we used the `BatchUpgradeOptions` class. That’s why we have an additional SSISBackupFolder in our project’s location (we used `BackupOldPackages = true` so it creates backup copy of each package in the default subfolder). But we can also set the options for the packages using the `PackageUpgradeOptions` class.

The `Application` class has the property `PackageUpgradeOptions` of type – you guessed right: `PackageUpgradeOptions`. We create new object of that class, set the properties and assign it to the `Application.PackageUpgradeOptions`:

```csharp
PackageUpgradeOptions pkgUpgradeOpts = new PackageUpgradeOptions
{
    RegeneratePackageID = true,
    UpgradeConnectionProviders = true
};

app.PackageUpgradeOptions = pkgUpgradeOpts;
```

All of the above can be set in the `SSISUpgrade.exe` in the configuration window:

[![SSIS Upgrade options](images/SSISUpgradeOptions.png#center)](images/SSISUpgradeOptions.png)

## Summary

The `Application.Upgrade()` method works great. It's the same way that we do the upgrade using `SSISUpgrade.exe`, but we have set it up a bit different than stated in the documentation.

One thing to watch - the package may be migrated with success, but the info about it can be stated in the Warnings section of the output.

## Additional materials

All source files are available on [GitHub](https://github.com/BartekR/blog/tree/master/201802%20Upgrading%20SSIS%20Projects%20part%20II).
