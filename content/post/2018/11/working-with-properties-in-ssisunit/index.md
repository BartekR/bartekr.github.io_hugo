---
title: "Working with properties in ssisUnit"
date: "2018-11-05"
draft: false
images:
  - src: "2018/11/05/working-with-properties-in-ssisunit/images/DFTPropertyCommand.png"
    alt: ""
    stretch: ""
categories: ['Series', 'Testing', 'Learning']
tags: ['ssisUnit']
coverImage: "DFTPropertyCommand.png"
---

One of the ssisUnit commands is a `PropertyCommand`. It allows you to read or set a property of the task, the package or the project. As of the time of writing - you can't test the properties of the precedence constraints or data flow elements (but you can't currently test data flow at all).

How do you use it?

[![Empty property command](images/EmptyPropertyCommand.png#center)](images/EmptyPropertyCommand.png)

The command is simple. You can **get** or **set** the property using the **value** for given **property path**. As usual - when you get the value, you leave the value blank. The path - well - is the path to the element in the package or the project. You use backslashes to separate elements in the package tree, and at the end, you use `.Properties[PropertyName]` to read the property. If you use the elements collection - like connection managers - you can pick a single element using square brackets and the name of this element.

When you take a look into the source code (`\ssisUnit\SSISUnit\PropertyCommand.cs`), you will see the examples like:

```cmd
\Project\ConnectionManagers[localhost.AdventureWorks2012.conmgr].Properties[ConnectionString]
\Package.Properties[CreationDate]
\Package.Connections[localhost.AdventureWorksDW2008].Properties[Description]
\Package.EventHandlers[OnError].Properties[Description]
\Package\Sequence Container\Script Task.Properties[Description]
\Package.EventHandlers[OnError].Variables[System::Cancel].Properties[Value]
```

They all have one thing in common - they start with a backslash. It's not required though, it's a convention. I wrote that the _PropertyPath_ uses the backslashes as the element separator. In the examples you see, that backslash is used interchangeably with a dot. In fact, it does not matter - during the parsing phase, all the backslashes are converted to dots.

How do you write the path? You can take a look at the package and name each part that you need to walk through, to get to your element. Or simply - when you take a look at any SSIS package source code, you will see, that each `DTS:Executable` has the `DTS:refId` attribute, that contains the path to the element in the package. You can safely use it as a path for the _PropertyPath_, or you can add a leading backslash.

In what scenarios you can use the _PropertyCommand_?

- checking your programming standard (like verifying if _DelayValidation_ always turned off or if the elements have a description other than the default)
- overwriting your project connection manager connection string (if you want to run the tests on the different server)
- automated testing of DFT buffer (you could run few tests with different values of _DefaultBufferMaxRows_ and/or _DefaultBufferSize_ and check the loading times)

Personally, up to now, I used only the project connection manager overwriting. It wasn't available [until the recent ssisUnit update](http://blog.bartekr.net/2018/09/12/whats-new-in-ssisunit/), but now you can use it in your projects.
