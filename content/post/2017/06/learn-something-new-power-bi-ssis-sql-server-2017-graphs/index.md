---
title: "Learn something new - Power BI + SSIS + SQL Server 2017 Graphs"
date: "2017-06-14"
draft: false
tags: ['Graph', 'Power BI', 'SQL Server 2017', 'SSIS']
categories: ['Learning']
---

Recently I attended the AppDev PASS Virtual Group [webinar about graphs in SQL Server 2017](http://appdev.pass.org/?EventID=8085). When the demo about car manufacturing structure appeared in Power BI (49th minute of the recording - using [Force-directed graph plugin](https://powerbi.microsoft.com/en-us/blog/visual-awesomeness-unlocked-the-force-directed-graph/)) the idea struck: how about visualising SSIS packages' relations using graphs and Power BI?

Maybe it won't work, maybe there are limitations I'm not aware right now, but I have to try. This post will serve as the gateway to the series of post where I will write about my findings on graphs in SQL Server, their visualisations, querying, structure defining, Power BI embracement and - of course - SSIS.

For a time of writing I know there are some limitations about graph querying for hierarchical data - [but only until next CTP](https://twitter.com/arvisam/status/873312748142080000), so I will start slow - with defining the sample project and a graph itself. The rough roadmap below:

- creating sample SSIS project with Sequence Containers, Execute Package Tasks, different precedence constraints
- internal SSIS package structure analysis - how to turn that data into graphs
- graph structure modelling and transforming the SSIS package data into graph data
- visualising it all in Power BI

Looks surprisingly easy. Waiting for the first hurdle.

Series parts:

- [Learn something new – Power BI + SSIS + SQL Server 2017 Graphs](http://blog.bartekr.net/2017/06/14/learn-something-new-power-bi-ssis-sql-server-2017-graphs/)
- [Learning something new: connections in SSIS package](http://blog.bartekr.net/2017/06/25/learning-something-new-connections-in-ssis-package/)
- [Learning something new: getting information from SSIS packages with PowerShell](http://blog.bartekr.net/2017/07/26/learning-something-new-getting-information-from-ssis-packages-with-powershell/)
- (on hold)
