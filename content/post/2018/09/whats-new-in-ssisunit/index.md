---
title: "What's new in ssisUnit?"
date: "2018-09-12"
draft: false
images:
  - src: "2018/09/12/whats-new-in-ssisunit/images/ProjectConnectionStringSetup.png"
    alt: ""
    stretch: ""
categories: ['Testing']
tags: ['ssisUnit']
coverImage: "ProjectConnectionStringSetup.png"
---

ssisUnit has a stable version for SSIS 2005 - 2014. [It didn't change much since August 2014](https://github.com/johnwelch/ssisUnit/commits?author=johnwelch), until August 2017. Then [my Pull Request](https://github.com/johnwelch/ssisUnit/pull/1) was merged, and it added some new functionality for ssisUnit.

First - it works with SSIS 2017. You can probably use it with SSIS 2016 packages, but I didn't test it yet. Although - you can't check everything - there are problems when you want to use Control Flow Templates in your packages. When I tried to read the variable from the container included from the template - it hangs for a few seconds and returns an incorrect result. It's something to investigate later.

[![Project connection string setup](images/ProjectConnectionStringSetup.png#center)](images/ProjectConnectionStringSetup.png)

Second - you can get and set the properties of the project and its elements. Like - overwriting project connection managers (I designed it with this particular need on my mind). You can now set the connection string the different server (or database) - in the PropertyPath of the PropertyCommand use `\Project\ConnectionManagers`, write the name of the connection manager **with the extension**, and use one of the _Properties_. You can do it during the Test setup (or all tests setup), but not during the test suite setup, as ssisUnit is not aware of the project until it loads it into the memory.

Third - I added simple Dataset viewer/editor. It's still a work in progress, but you can already use it to either visualise the data or to keep it within the test file (set `IsResultsStored` to _true_, open the DataSet and save the test suite file). You don't have to [prepare the XML representation of the dataset manually](http://blog.bartekr.net/2018/05/31/using-cached-datasets-in-ssisunit/).

There are also some minor changes:

- Fixed _"No rows can be added to a DataGridView control that does not have columns. Columns must be added first"_ error in test results window
- `Dataset`, `PackageRef`, `ConnectionRef` extend `SsisUnitBaseObject` - now you can see XML code in the GUI for these elements
- Query Editor resizes with the window and returns unmodified code on cancel
- added several library tests (a great way to get to know the ssisUnit model better!)

If you want to get the latest version - [go to the GitHub repository](https://github.com/johnwelch/ssisUnit), download or clone the source code, compile it, and run. That easy! In case you have some problems with compilation (or ssisUnit not working correctly) - [open an issue](https://github.com/johnwelch/ssisUnit/issues) or write a comment to this post.
