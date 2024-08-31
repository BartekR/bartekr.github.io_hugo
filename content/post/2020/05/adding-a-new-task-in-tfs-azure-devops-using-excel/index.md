---
title: "Adding a new task in TFS (Azure DevOps) using Excel"
date: "2020-05-19"
draft: false
image: "2020/05/19/adding-a-new-task-in-tfs-azure-devops-using-excel/images/AzureDevOps_TeamPlugin.png"
tags: ['Azure DevOps', 'Excel']
categories: ['TFS']
---

[In the previous post](http://blog.bartekr.net/2020/05/04/adding-a-new-task-in-tfs-using-c/), I added the tasks to on-premises TFS using C#. This time I will add similar data using an Excel add-in. I will also learn how to accidentally remove the link from the task to the parent element.

First things first - if you do not have Azure DevOps Office® Integration 2019 installed (you need it to work with TFS / Azure DevOps from Excel), then go to [https://visualstudio.microsoft.com/downloads/](https://visualstudio.microsoft.com/downloads/) and pick it from the _Other Tools and Frameworks_ section at the bottom of the page. Install, and you should then see the Team plugin in the Excel menu.

[![Team plugin](images/AzureDevOps_TeamPlugin.png#center)](images/AzureDevOps_TeamPlugin.png)

This time I will use my Azure DevOps collection [bartekr](https://bartekr.visualstudio.com) and the _AzureDevOps\_APITests_ project. It uses a _Basic_ process, but I also tested the process on an _Agile_ workflow. To add the elements click _New List_ and connect to the project. If it's the first time you connect to Azure DevOps or TFS you will be prompted to set up the connection to the collection. After you connect pick the _Input list_ from the options

[![Input list](images/ExcelNewList_InputList.png#center)](images/ExcelNewList_InputList.png)

Now you should see an empty list with information about the connection. The list is ready and you could start filling the columns Title, Work Item Type, State, Reason, Assigned To (ID is read-only).

[![Empty list](images/ExcelEmptyList.png#center)](images/ExcelEmptyList.png)

But - we want to add not only the tasks but also the connection to a parent element. In this case, tasks should be connected to the Issue (in a _Basic_ process) or the User Story (an _Agile_ process). To do it we have to work with the tree, not a flat list (notice: List type: Flat on the right side of the yellow header). Click on the list and you should see an enabled _Add Tree Level_ button. Click it.

[![Add tree level](images/ExcelAddTreeLevel.png#center)](images/ExcelAddTreeLevel.png)

In the _Convert to Tree List_ select Parent-Child (the default option)

[![Convert to tree](images/ExcelConvertToTreeList.png#center](images/ExcelConvertToTreeList.png)

Now you should see the columns - _Title 1_ and _Title 2_ and the _List type: tree_. The first title is for the parent item, the second for the child.

[![Empty work items list](images/ExcelEmptyWorkitemsTree-1.png#center)](images/ExcelEmptyWorkitemsTree-1.png)

Now - I want to add the new tasks for the Issue 2

[![Backlog before](images/AzureDevOps_BacklogBefore.png#center)](images/AzureDevOps_BacklogBefore.png)

In the _Team_ toolbar click _Get Work Items_, find the _Issue 2_ in the opened window, select it and click _OK_.

[![Find work item](images/ExcelFindWorkItem.png#center)](images/ExcelFindWorkItem.png)

The spreadsheet looks like below:

[![Issue 2 as tree](images/ExcelIssue2Tree.png#center)](images/ExcelIssue2Tree.png)

Nothing unusual. Now - in the _Title 2_ column add new tasks with Work Item Type == _Task_ and push the button _Publish_. And that's it!

[![Issue 2 - new work items](images/ExcelIssue2Tree_NewWorkItems.png#center)](images/ExcelIssue2Tree_NewWorkItems.png)

In Azure DevOps:

[![Backlog after](images/AzureDevOps_BacklogAfter.png#center)](images/AzureDevOps_BacklogAfter.png)

If I wanted to fill more columns (like Assigned To, Sprint, Estimated time and so on) - I click _Choose columns_ button and add them to the list.

One more small thing for the end. Let's say you have a lot of Tasks with one parent Issue / User Story. **Do not delete them from the list** _"because you want to have a clean sheet with just the Issue / User Story"_. Deleting the tasks from the list does not delete the tasks (of course), but it removes the Parent-Child hierarchy for the deleted elements.

If you repeat the steps to get the tasks for Issue 2 and delete them, you will see they lost the connection:

[![Work item delete](images/AzureDevOps_WorkitemDeletedLink.png#center)](images/AzureDevOps_WorkitemDeletedLink.png)

In short: adding work items to TFS / Azure DevOps using Excel is easy. The trick is ~~[to keep breathing](https://www.youtube.com/watch?v=GwKtszQ8Ejo)~~ to use the _Add Tree Level_ button.
