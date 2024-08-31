---
title: "Writing ssisUnit test using API"
date: "2018-08-13"
draft: false
image: "2018/08/13/writing-ssisunit-test-using-api/images/ssisUnitAPI.png"
categories: ['Series', 'Testing', 'Learning']
tags: ['MSTest', 'SSIS', 'ssisUnit']
---

In [the post about using MSTest framework to execute ssisUnit tests](http://blog.bartekr.net/2018/06/15/executing-ssisunit-tests-in-mstest-framework/), I used parts of the ssisUnit API model. If you want, you can write all your tests using this model, and this post will guide you through the first steps. I will show you how to write one of the previously prepared XML tests using C# and (again) MSTest.

Why MSTest? Because I don't want to write some application that will contain all the tests I want to run, display if they pass or not. When I write the MSTest tests, I can run them using the Test Explorer in VS, using a command line, or in TFS.

## The preparations

I create a new project `ssisUnitLearning.API` within the `ssisUnitLearning` solution using right-click on a solution name, then _Add > New Project > Visual C# > Class library (.NET framework)_ and using .NET 4.5 as a target.

I rename the newly created `Class1.cs` file to `Test_15_Users_Dataset.cs` and will write the test from scratch. I set up the references - I need `SSISUnit2017.dll`(I will work with the latest version of ssisUnit compiled for SSIS 2017, but the standard `SSISUnit2012.dll` will work too) and `SSISUnitBase.dll`. I clear all the default references.

I will use MSTest v2. I didn't create a new project as a test project, but as a library, so I will add the testing framework using NuGet. Right-click the _References_ node, and choose _Manage NuGet packages_ and in the _Browse_ section search for _MsTest_. Choose `MsTest.Framework` and `MsTest.TestAdapter` and install them. At the time of writing, I work with version 1.3.2.

Last thing before I start writing the tests - I set up namespaces for ssisUnit and MsTest:

```csharp
using SsisUnit;
using SsisUnitBase.Enums;
using SsisUnit.Packages;
using SsisUnit.Enums;
using Microsoft.VisualStudio.TestTools.UnitTesting;
```

## The reference

I chose the [`15_Users_Dataset.ssisUnit`](https://github.com/BartekR/ssisUnitLearning/tree/master/Tests) file as a reference. I will write the same test using the API.

[![Users dataset](images/15_Users_Dataset.png#center)](images/15_Users_Dataset.png)

The referenced ssisUnit test file contains:

- the connection to the _ssisUnitLearningDB_ database
- the reference to the _15\_Users\_Dataset_ package
- two datasets: _expected_ and _actual_
- one test with setup, teardown and two asserts

The API idea is simple: create the objects (connections, tests, asserts, commands etc.), add them to the ssisUnit test suite object and execute the suite.

## Writing the test

I start with the scaffolding:

```csharp
namespace ssisUnitLearning.API
{
    [TestClass]
    public class Test_15_Users_Dataset
    {
        [TestMethod]
        public void SQL_MERGE_Users_Empty_table()
        {
        }
    }
}
```

I assume one ssisUnit test suite as one class and one ssisUnit test as one method. The class' name cannot begin with the number, so I add the _Test\__ prefix. I add the _TestClass_, and _TestMethod_ attributes to expose my code to the MsTest framework. The test method is void and without the parameters.

The central element in the ssisUnit API is the `SsisUnitSuite` class - it contains all the test suite objects. At the beginning I create an empty object:

```csharp
SsisTestSuite ts = new SsisTestSuite();
```

Then I create the package and the database connection references (the code is split into the separate lines for readability):

```csharp
// the package to test
PackageRef p = new PackageRef(
    "15_Users_Dataset",
    @"C:\Users\Administrator\source\repos\ssisUnitLearning\ssisUnitLearning\bin\Development\ssisUnitLearning.ispac",
    "15_Users_Dataset.dtsx",
    PackageStorageType.FileSystem
);

// the connection for the datasets
ConnectionRef c = new ConnectionRef(
    "ssisUnitLearningDB",
    @"Provider=SQLNCLI11.1;Data Source=.\SQL2017;Integrated Security=SSPI;Initial Catalog=ssisUnitLearningDB;Auto Translate=False",
    ConnectionRef.ConnectionTypeEnum.ConnectionString
);
```

The package reference is created with a _15\_Users\_Dataset_ name. The package is a part of the project saved in the file system, so I add the full path to the `.ispac` file (the project), the name of the package within the project (`.dtsx` file), and set the storage type. The connection reference has the name _ssisUnitLearningDB_ and is stored as a connection string.

Now I can add those two objects to the test suite. Because I can have many packages and database connections, they are stored in lists:

```csharp
ts.ConnectionList.Add(c.ReferenceName, c);
ts.PackageList.Add(p.Name, p);
```

The next objects are the datasets - expected and actual. They are created with a reference to the test suite, a name, reference to the database connection and a SQL command. The `false` in the definitions is that the datasets will not store the results in the test suite. One thing that is a bit misleading is the reference to the test suite (the _ts_ object). It's not used to add the dataset to the test suite, but to make the dataset aware of the test suite. It's because of some ssisUnit model designs, mostly used for the progress reporting and the test suite statistics. We add the datasets to the suite using the `Add()` method on the `Datasets` list.

```csharp
Dataset expected = new Dataset(
    ts,
    "Empty table test: expected dataset",
    c,
    false,
    @"SELECT *
FROM(
    VALUES
        (CAST('Name 1' AS VARCHAR(50)), CAST('Login 1' AS CHAR(12)), CAST(1 AS BIT), CAST(1 AS INT), CAST(2 AS TINYINT), CAST(0 AS BIT)),
        (CAST('Name 2' AS VARCHAR(50)), CAST('Login 2' AS CHAR(12)), CAST(1 AS BIT), CAST(2 AS INT), CAST(2 AS TINYINT), CAST(0 AS BIT)),
        (CAST('Name 3' AS VARCHAR(50)), CAST('Login 3' AS CHAR(12)), CAST(0 AS BIT), CAST(3 AS INT), CAST(2 AS TINYINT), CAST(0 AS BIT))
)x(Name, Login, IsActive, Id, SourceSystemId, IsDeleted)
ORDER BY Id; ");

Dataset actual = new Dataset(
    ts,
    "Empty table test: actual dataset",
    c,
    false,
    @"SELECT
    Name,
    Login,
    IsActive,
    SourceId,
    SourceSystemId,
    IsDeleted
FROM dbo.Users
ORDER BY SourceId;");

// add the datasets to the test suite
ts.Datasets.Add(expected.Name, expected);
ts.Datasets.Add(actual.Name, actual);
```

The same situation with the test and other objects - we make them aware of the test suite and add them to the same test suite. The test has a name (_SQL MERGE Users: Empty table_), references the _15\_Users\_Dataset_ package, has no password (_null_) and works with the SQL Merge Users task (_{FB549B65-6F0D-4794-BA8E-3FF975A6AE0B}_). As for the last part - you can set the task object either as the ID of the element in the SSIS package (as in the example) or the PackagePath. I chose the ID, as I copied it from the `.ssisUnit` file (the wizard in the ssisUnit GUI works with the IDs)

```csharp
Test t = new Test(
    ts,
    "SQL MERGE Users: Empty table",
    "15_Users_Dataset",
    null,
    "{FB549B65-6F0D-4794-BA8E-3FF975A6AE0B}"
);
ts.Tests.Add(t.Name, t);
```

The test has a setup command. The `stg.Users` table is empty, so I use the `SqlCommand` to fill it with the data. In the end, I add the command to the collection of the `TestSetup` commands of the test.

```csharp
SqlCommand s1 = new SqlCommand(
    ts,
    "ssisUnitLearningDB",
    false,
    @"WITH stgUsers AS (
SELECT *
FROM (
    VALUES
        ('Name 1', 'Login 1', 1, 1, 2, -1),
        ('Name 2', 'Login 2', 1, 2, 2, -1),
        ('Name 3', 'Login 3', 0, 3, 2, -1)
)x (Name, Login, IsActive, Id, SourceSystemId, InsertedAuditId)
)
INSERT INTO stg.Users (
    Name, Login, IsActive, Id, SourceSystemId, InsertedAuditId
)
SELECT
    Name, Login, IsActive, Id, SourceSystemId, InsertedAuditId
FROM stgUsers
;");

t.TestSetup.Commands.Add(s1);
```

The test has two asserts:

- checking if the `dbo.Users` table has 3 records,
- and if those 3 records look like the expected dataset.

The assert is a definition of the expected result, and it executes a command to get the actual. Take a look at the first assert's definition. It has the reference to the test suite (_ts_), the test (_t_), has a name (_Assert: Added 3 records_), expects _3_ as a result, and is executed after the task executes (_false_). It runs a `SqlCommand` referencing the test suite (_ts_) using _ssisUnitLearningDB_ connection reference, returns a value (_true_), and the command to run is _SELECT COUNT(\*) FROM dbo.Users_.

Similar with the second assert, the difference is the command - a `DatasetCommand` - that compares the expected and the actual datasets and has no name (_""_). After the asserts are created, I add them to the test.

```csharp
SsisAssert a1 = new SsisAssert(
    ts,
    t,
    "Assert: Added 3 records",
    3,
    false);

a1.Command = new SqlCommand(
    ts,
    "ssisUnitLearningDB",
    true,
    "SELECT COUNT(*) FROM dbo.Users;"
);

SsisAssert a2 = new SsisAssert(
    ts,
    t,
    "Assert: dbo.Users has expected records",
    true,
    false
);

a2.Command = new DataCompareCommand(
    ts,
    "",
    expected,
    actual
);

t.Asserts.Add(a1.Name, a1);
t.Asserts.Add(a2.Name, a2);
```

The last part of the test is the TestTeardown. I tidy up after the tests running `TRUNCATE TABLE` commands on the `stg.Users` and `dbo.Users` tables. The commands are added to the `TestTeardown` collection.

```csharp
SqlCommand t1 = new SqlCommand(
    ts,
    "ssisUnitLearningDb",
    false,
    "TRUNCATE TABLE stg.Users;"
);

SqlCommand t2 = new SqlCommand(
    ts,
    "ssisUnitLearningDb",
    false,
    "TRUNCATE TABLE dbo.Users;"
);

t.TestTeardown.Commands.Add(t1);
t.TestTeardown.Commands.Add(t2);
```

Finally, the test and all the test suite is ready, and I can run it using the `Execute()` command.

```csharp
ts.Execute();
```

To check if all the ssisUnit test suite asserts finished successfully I use `Assert.AreEqual()` command of the MsTest. I take the number of the ssisUnit asserts that passed and compare it to the expected value. The ssisUnit test suite holds the `Statistics` object with the numbers of tests and asserts executed, passed and failed, so I use it to get the value:

```csharp
Assert.AreEqual(2, ts.Statistics.GetStatistic(StatisticEnum.AssertPassedCount));
```

When I run this, I get the error: _Message: Assert.AreEqual failed. Expected:<2>. Actual:<3>_. Why 3?! I have only two asserts! The reason becomes clear when I run the `.ssisUnit` test in the GUI - the third assert comes from the _TaskResult_.

[![15_Users_Dataset test results](images/15_Users_Dataset_Result.png#center)](images/15_Users_Dataset_Result.png)

So, the proper command is:

```csharp
Assert.AreEqual(3, ts.Statistics.GetStatistic(StatisticEnum.AssertPassedCount));
```

And that's it. The test suite is finished.

## Summary

The API model of the ssisUnit is not complicated, but sometimes its a bit unintuitive. I would like to operate more on the prepared objects than on their names, but maybe that's just me. A bit odd (at the beginning) is fact, that I have to set the test suite object as the parameter of the objects other than `CommandRef` and `PackageRef`, and then also add the objects to the test suite.

If you want to know more about ssisUnit API model, I encourage you to read the code in the `SsisUnit.Tests` folder of the [ssisUnit source code](https://github.com/johnwelch/ssisUnit), as there's a lot of examples how to use the API.

The full code is [available on GitHub](https://github.com/BartekR/ssisUnitLearning).
