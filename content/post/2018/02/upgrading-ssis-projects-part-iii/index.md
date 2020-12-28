---
title: "Upgrading SSIS projects - part III"
date: "2018-02-28"
draft: false
images:
  - src: "2017/12/24/upgrading-ssis-projects-part-i/images/TargetServerVersion2017.png"
    alt: ""
    stretch: ""
coverImage: "TargetServerVersion2017.png"
tags: ['migration', 'SSIS', 'internals']
categories: ['SSIS internals']
---

In [the first part](http://blog.bartekr.net/2017/12/24/upgrading-ssis-projects-part-i/) of the series I mentioned two methods of upgrading SSIS projects (well - packages, for now) - [Application.Upgrade()](https://docs.microsoft.com/en-us/dotnet/api/microsoft.sqlserver.dts.runtime.application.upgrade?view=sqlserver-2017) and  [Application.SaveAndUpdateVersionToXml()](https://docs.microsoft.com/en-us/dotnet/api/microsoft.sqlserver.dts.runtime.application.saveandupdateversiontoxml?view=sqlserver-2017). This post is about the latter.

The documentation of the method is also a bit sparse at the moment, but is self-explanatory:

```csharp
public void SaveAndUpdateVersionToXml (
    string fileName,
    Microsoft.SqlServer.Dts.Runtime.Package package,
    Microsoft.SqlServer.Dts.Runtime.DTSTargetServerVersion newVersion,
    Microsoft.SqlServer.Dts.Runtime.IDTSEvents events
);
```

- the name of **the target** file - that's where we save the outcome of the update operation (fileName)
- the package we want to convert (package)
- which SSIS version we have in mind (newVersion)
- an object for the events that happened during the process (events)

To load the package I use the [`Application.LoadPackage()`](https://msdn.microsoft.com/en-us/library/ms188550.aspx) method. It reads package from the file and converts it to the object. Then set target version with the [`Application.TargetServerVersion`](https://msdn.microsoft.com/en-us/library/microsoft.sqlserver.dts.runtime.application.targetserverversion.aspx) and run `Application.SaveAndUpdateVersionToXml()`. The last thing is to create an empty class for the events, and that's it.

```csharp
using System.IO;
using Microsoft.SqlServer.Dts.Runtime; 

namespace SaveAndUpdateVersionToXML
{
    class Program
    {
        static void Main(string\[\] args)
        {
            // packages to upgrade
            System.Collections.ArrayList packages = new System.Collections.ArrayList();

            // SSIS project directory (to load packages from)
            string sourceDirectory = @"C:\\Users\\Administrator\\source\\repos\\MigrationSample\\";

            // target directory (to save migrated packages)
            string targetDirectory = @"C:\\Users\\Administrator\\source\\repos\\MigrationSample.Migrated\\";

            // add the packages; it's an example, so I'm adding manualy
            packages.Add("Package.dtsx");
            packages.Add("ScriptMigrationTesting.dtsx");

            // the events container
            MyEvents e = new MyEvents();

            // we use the appliction object for migration
            Application a = new Application();

            // load and upgrade packages
            foreach (string package in packages)
            {
                // load the package
                Package p = a.LoadPackage(Path.Combine(sourceDirectory, package), e);

                // and save to the target location
                a.SaveAndUpdateVersionToXml(Path.Combine(targetDirectory, package), p, DTSTargetServerVersion.SQLServer2017, e);
            }
        }
    }

    class MyEvents : DefaultEvents
    {

    }
}
```

There is less code than in the [`Application.Upgrade()` example](http://blog.bartekr.net/2018/02/04/upgrading-ssis-projects-part-ii/), but let's take a closer look at both. There I used two variables for source and target locations of packages. They could be the counterparts of the StorageInfo objects storeinfoSource and storeinfoDest in the `ApplicationUpgrade()` example. My `packages` collection is a less specialised version of the `UpgradePackageInfo` objects collection.

It looks like the main difference is that I don't set up the upgrade options, just tell the target version of the package. Previously, the target version was based on the version of the assembly I used in the project (thing to remember: `Application.ComponentStorePath`).

So it is just another approach to convert the packages to the version we want. But - as in the previous part - it's just the packages. The project file is still the same, and when you open it in the Visual Studio it automatically downgrades the packages. Next part of the series will be about the project file itself.

The code is also available on [GitHub](https://github.com/BartekR/blog/tree/master/201802%20Upgrading%20SSIS%20Projects%20part%20III/SaveAndUpdateVersionToXML).
