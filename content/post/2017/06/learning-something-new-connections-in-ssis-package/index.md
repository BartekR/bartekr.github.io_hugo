---
title: "Learning something new: connections in SSIS package"
date: "2017-06-25"
draft: false
images:
  - src: "2017/06/25/learning-something-new-connections-in-ssis-package/images/DTS_ExecutablesLight.png"
    alt: ""
    stretch: ""
coverImage: "DTS_ExecutablesLight.png"
tags: ['internals', 'SSIS']
categories: ['Learning', 'SSIS internals']
---

[Starting to learn something new](http://blog.bartekr.net/2017/06/14/learn-something-new-power-bi-ssis-sql-server-2017-graphs/) - first step. Let's analyse the code of SSIS package. How does it store the information about the element connections? How can I get that data as graph's edges and nodes? Step by step - building the packages from empty one to more complex I will find how they are stored.

To achieve this I will prepare the new SSIS Project and call it _SSIS\_Graph_. It will get new packages each time I will want to check something new. For start I create an empty package, then package with one Control Flow element - I will use empty Data Flow Task and the Sequence Container, then I will create two empty Data Flow Tasks and connect them with one precedence constraint (success). And so on - more precedence constraints, constraints with expressions. I won't paste the code for all the sample packages. It's just to help me get more familiar with DTSX XML and find the patterns. At the beginning, I will concentrate on Control Flow elements. The main goal is to visualise packages dependencies within a project and then other - dependencies between projects or dependencies between package's elements.

When you take a look at the code of two empty Data Flow Tasks connected with precedence constraint you find those elements of interest:

- `DTS:Executables` - they contain - well - `Executable`s
- `DTS:Executable` - the task on the Control Flow area
- `DTS:PrecedenceConstraints` - guess?
- `DTS:PrecedenceConstraint` - you guessed right!

Each element has plenty of attributes, but we mostly care about:

- `DTS:ObjectName` - exactly what it says on the tin
- `DTS:refId` - the path to the element (task)
- `DTS:From` (for precedence constraints - starting point)
- `DTS:To` (for precedence constraints - finishing point)
- `DTS:LogicalAnd` (for precedence constraints - appears when it's AND constraint; does not appear for OR constraints)
- `DTS:value` (for precedence constraints - appears for constraints other than Success)
- `DTS:Expresion` (when precedence constraint uses expression)
- `DTS:EvalOp` (Evaluation Operation? - used when precedence constraint uses an expression)

For the graph data, I will take more of the attributes. For now, I just write down the most important of them. It's enough to get me started. The next step: create graph tables.
