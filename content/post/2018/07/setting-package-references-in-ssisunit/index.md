---
title: "Setting package references in ssisUnit"
date: "2018-07-05"
draft: false
images:
  - src: "2018/07/05/setting-package-references-in-ssisunit/images/StorageType_MSDB.png"
    alt: ""
    stretch: ""
categories: ['Series', 'Testing', 'Learning']
tags: ['SSIS', 'ssisUnit']
coverImage: "StorageType_MSDB.png"
---

When you set the packages' references in the ssisUnit tests you have four options for the source (_StoragePath_) of the package:

- _Filesystem_ - references the package in the filesystem - either within a project or standalone
- _MSDB_ - package stored in the `msdb` database
- _Package store_ - packages managed by Integration Services Service
- _SsisCatalog_ - references the package in the Integration Services Catalog

In this post, I will show you how to set the package reference (_PackageRef_) for each option.

## Filesystem

In the previous posts about ssisUnit, I used the packages from the project located in the file system. So just to have a complete reference:

- if you use the standalone package - use the path to the package
- if you use the package in the project - use the path to the `.ispac` file, and then the name of the package (without the path)

[![StorageType Filesystem](images/StorageType_Filesystem.png#center)](images/StorageType_Filesystem.png)

## MSDB

[![StorageType MSDB](images/StorageType_MSDB.png#center)](images/StorageType_MSDB.png)

If you use the legacy Package Deployment Model, you can store your packages in the `msdb` database. You have to provide the same details as in the SQL Agent's job step for SSIS subsystem when you choose _SQL Server_ as the package source:

- The SQL Server instance name
- The full package path, starting with a backslash

Note, that the package does not end with the `.dtsx` extension.

## Package store

[![SSIS PackageStore](images/PackageStore.png#center)](images/PackageStore.png)

It's also related to the legacy Package Deployment Model. This time you pick either the packages in the default folder for the Integration Services Service or the `msdb` database. In the documentation, you can find that the package store is related to the filesystem, but the package store really means the locations that the SQL Server Integration Services Service is aware of. Those locations are defined in the file `MsDtsSrvr.ini.xml` located in the `C:\Program Files\Microsoft SQL Server\140\DTS\Binn` folder.

Because it's managed by the service you set up:

- the server name (not the instance name)
- the path to the package (also without the `.dtsx` extension)

[![StorageType PacjageStore](images/StorageType_PackageStore.png#center)](images/StorageType_PackageStore.png)

## SSIS Catalog

When you use the SsisCatalog option:

- provide the name of the SQL Server, where the Integration Services Catalog is stored
- set the path to the project
- set the full name of the package

[![SSIS Catalog path](images/SSISCatalogPath.png#center)](images/SSISCatalogPath.png)

Currently, only the Windows Authentication is supported, so run ssisUnit with the account that has the proper privileges. Also note, that when you set up the path to the package in the SQL Agent SSIS step, you use the full path to the package, like `\SSISDB\ssisUnit\ssisUnitLearning\60_Loops.dtsx`. In ssisUnit, you don't use the `\SSISDB\` part.

[![StorageType SsisCatalog](images/StorageType_SsisCatalog.png#center)](images/StorageType_SsisCatalog.png)
