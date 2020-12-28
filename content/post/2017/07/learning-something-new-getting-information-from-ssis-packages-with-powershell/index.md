---
title: "Learning something new: getting information from SSIS packages with PowerShell"
date: "2017-07-26"
draft: false
images:
  - src: "2017/07/26/learning-something-new-getting-information-from-ssis-packages-with-powershell/images/SSISParsingScript.png"
    alt: ""
    stretch: ""
coverImage: "SSISParsingScript.png"
tags: ['PowerShell', 'SSIS', 'XML']
categories: ['Learning']
---

In the series of learning something new, I started with analysing of the SSIS package XML. I know what I want to extract, so let the fun begin. I will use Powershell to get the data from the `.dtsx` files and save it to the database. The whole script is presented below with comments. For more information scroll down.

```powershell
# I will use Out-DbaDataTable and Write-DbaDataTable from dbatools, so import it
Import-Module dbatools

# find recursively all Executable nodes in .dtsx file
function Find-Executables($fileName, $executable)
{
    foreach($item in $executable)
    {
        # are we there, yet? (if no - recursion)
        if($item.Executables)
        {
            Find-Executables $fileName $item.Executables.Executable
        }

        # if yes - the result
        $prop = @{
            'refId' = $item.refId
            'creationName' = $item.CreationName
            'description' = $item.Description
            'objectName' = $item.ObjectName
            'executableType' = $item.ExecutableType
            'objectData' = $item.ObjectData.ExpressionTask.Expression
        }

        $prop

    }
}

# get all Precedence Constraints; simpler than Executables, because all of them are in single node
function Find-PrecedenceConstraints($fileName, $precedenceConstraints)
{
    foreach($item in $precedenceConstraints)
    {
        $prop = @{
            'refId' = $item.refId
            'from' = $item.From
            'to' = $item.To
            'logicalAnd' = [boolean]$item.LogicalAnd
            'evalOp' = [int]$item.EvalOp
            'objectName' = $item.ObjectName
            'expression' = $item.Expression
            'value' = [int]$item.Value
        }

        $prop
    }
}

# the data collectors
$allPackagesInfo = @()
$allExecutables = @()
$allPrecedenceConstraints = @()

# loop through every .dtsx file in folder; all my packages' names start with 0, so there is an example how to filter it
foreach($file in (Get-ChildItem C:\Users\brata_000\Source\Repos\SSIS_Graph\SSIS_Graph\SSIS_Graph\* -Include 0*.dtsx))
{

    # read .dtsx into XML variable
    [xml] $pkg = Get-Content $file

    # create hash table with package information
    $pkgInfo = @{
        'Name' = $file.Name
        'Executables' = Find-Executables $file.Name $pkg.Executable
        'PrecedenceConstraints' = Find-PrecedenceConstraints $file.Name $pkg.Executable.PrecedenceConstraints.PrecedenceConstraint
    }

    # add the table as PSobject to variable with all the package information
    $allPackagesInfo += New-Object psobject -Property $pkgInfo

}

# I don't want to confirm TRUNCATE TABLE for Write-DbaDataTable (when I'm running it few times)
$ConfirmPreference = 'none'

# Having all the information in one place - save it in the database; loop through all the packages (see the filter, again?)
$allPackagesInfo | Where-Object -Property Name -Like '0*' | ForEach-Object {

    $pkgName = $_.Name

    # all the Executables in the package
    $_.Executables | ForEach-Object {
        $d = @{
            'pkgName' = $pkgName
            'refId' = $_.refId
            'creationName' = $_.creationName
            'description' = $_.description
            'objectName' = $_.objectName
            'executableType' = $_.executableType
            'objectData' = $_.objectData
        }

        $allExecutables += New-Object psobject -Property $d
    }

    # all the Precedence Constraints in the package; casting to proper types will automaticaly create
    # columns of types other than nvarchar(max) when using -AutoCreateTable on Write-DbaDataTable
    $_.PrecedenceConstraints | ForEach-Object {
        $d = @{
            'pkgName' = $pkgName
            'refId' = $_.refId
            'from' = $_.from
            'to' = $_.to
            'logicalAnd' = [boolean]$_.logicalAnd
            'evalOp' = [int\]$_.evalOp
            'objectName' = $_.objectName
            'expression' = $_.expression
            'value' = [int]$_.value
        }
        $allPrecedenceConstraints += New-Object psobject -Property $d
    }
}

# I'm using SQL Server for Linux, connecting to the VM, so I use SQL authentication (for now) - why not use 'sa' then?
$cred = Get-Credential sa

#save all Executables to the database
$allExecutables | Out-DbaDataTable | Write-DbaDataTable -SqlInstance 127.0.0.1:14333 `
                    -SqlCredential $cred -Database SSISGraph -Schema dbo -Table Executables -AutoCreateTable -Truncate

# save all Precedence Constraints to the database
$allPrecedenceConstraints | Out-DbaDataTable | Write-DbaDataTable -SqlInstance 127.0.0.1:14333 `
                    -SqlCredential $cred -Database SSISGraph -Schema dbo -Table PrecedenceConstraints -AutoCreateTable -Truncate
```

To get all the information I loop through all the files. In Control Flow the interesting data are `Executable` elements and `Precedence Constraints`. Because one `Executable` can contain another `Executable`s (think: `Sequence/For/ForEach Containers`) I use recursion. It's easier with `Precedence Constraints` because all of them are located under one XML node. Both functions get `$fileName` as the first parameter that is not used later. It's because it's one of the versions of the script and I didn't want to remove it as I'm doing more tests for later.

Each information is collected into an array `$allPackagesInfo`. It looks a bit overcomplicated, but it works. When data is collected I prepare two arrays with objects containing `Executables` and `Precedence Constraints`. I cast some of the values to the proper data types - they will be used when preparing data for the database.

That gets me to the database layer. To ease the whole process I use [dbatools](https://dbatools.io/). It contains a lot of great functions, but for now I will only use these two: [Out-DbaDataTable](https://dbatools.io/functions/out-dbadatatable/) and [Write-DbaDataTable](https://dbatools.io/functions/write-dbadatatable/). The first one prepares data in format that is understood by the second that writes data to the database.

To ease the data inserting process I use `-AutoCreateTable` switch for `Write-DbaDataTable`. It creates table in database using object created with `Out-DbaDataTable`. It uses first data row to guess data types and when not found (or it's a string) it creates `NVARCHAR(MAX)` columns - hence I provide extra info for fields other than string. The `(MAX)` doesn't bother me too much for now as I build the prototype to be expanded later. Also - I may repeat the loading process few times, so I clear the tables each time with a `-Truncate` parameter. It will ask me to confirm the data removal, so I set the `$ConfirmPreference` to `none` as I don't want to do it.

There is one thing I don't like. When using `-AutoCreateTable` one of the parameters you have to provide is schema of the table to be created. There is [a bug that sometimes prevents `Write-DbaDataTable`](https://github.com/sqlcollaborative/dbatools/issues/1845) from finding the schema in target database. So for now I use `dbo` schema.

OK. When I run the script I get populated tables dbo.Executables and dbo.PrecedenceConstraints with fresh data.

[![Inserted SSIS data](images/InsertedSSISData.png#center)](images/InsertedSSISData.png)

If you want to go deeper into the `.dtsx` internals watch André Kamman's ([b](http://andrekamman.com) | [t](https://twitter.com/AndreKamman)) PASS Summit 2015 session "Analyzing your ETL Solution with PowerShell" (available to you for free on the [PASS](http://www.pass.org/Learning/Recordings/Listing.aspx?oRecording=1092&category=conferences) site).

The next step is to transform the gathered SSIS data to the graph format.
