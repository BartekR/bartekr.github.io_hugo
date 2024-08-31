---
title: "Testing SSIS Projects with ssisUnit"
date: "2018-03-19"
draft: false
image: "2018/03/19/testing-ssis-projects-with-ssisunit/images/ssisUnit_HeaderImage.png"
tags: ['SQL Server 2017', 'SSIS', 'ssisUnit']
categories: ['Learning', 'Series', 'Testing']
---

During the upcoming [SQLDay 2018](http://sqlday.pl/en/) conference (10th edition of SQLDay!) I'll be [speaking about testing SSIS packages and projects](https://sqlday.pl/en/session/start-testing-your-ssis-packages/). From my observations, I see that we don't like testing (I'm talking about database and ETL people), but when we start doing it - it becomes a natural part of our work. In my current project, we started slow, with some data quality testing for some parts of the process. Today you can hear "let's write a test for it", and it's just a regular part of the process.

I want to take a testing experience a bit further. We already have data quality testing (and the number of tests grows each day), but how about SSIS testing? How can we do it? This post starts the series about testing SSIS packages and projects (mostly projects) with different tools. The first step in our ETL testing will be asking ourselves some questions about testing, then we start doing technical things getting familiar with the [ssisUnit](https://github.com/johnwelch/ssisUnit) framework by John Welch.

The ssisUnit project started [a long time ago](http://agilebi.com/jwelch/2008/03/12/ssisunit-a-unit-testing-tool-for-ssis/) and was [hosted on CodePlex](https://archive.codeplex.com/?p=ssisunit), then moved to GitHub. As John works now for Pragmatic Works, the project is also incorporated in the commercial tools and is being developed mainly for their products ([BiXpress](https://pragmaticworks.com/Products/BI-xPress), [LegiTest](https://pragmaticworks.com/Products/LegiTest)). The last version of ssisUnit is compiled for SSIS 2014, but you are welcome to use the source code and make all desired changes that will suit your needs.

## But why?

Why would we even think about SSIS testing? Most of the times we already check our work during development, don't we? We carefully craft our packages, run them many times to see the outcome, sometimes we even disable some Control Flow elements and check how the moving parts work alone. We write some SQL to review the data before and after the process. And it's good!

It's nothing wrong in testing the packages this way. If it's done at the beginning of your journey to ETL with SSIS. When you work with it for some time you probably see the main three cons:

- it's a manual job
- it's a manual job
- it's a manual job

(also error-prone, makes you work harder during debugging and you have a headache when you are forced to work with the package looking like a giant spider of tasks, constraints and data flows).

And probably the most important thing: lots of the times you THINK you are testing the package. If it's a simple package for staging the data it's often hard to do something wrong, but what with the more advanced logic? Are you sure you know the data you work with? Do you have some use cases? Probably not. You have some requirements that you discuss with the team (or analyst), and you put the code using the best knowledge you have. And then it starts - data duplicates on some joins, there are nulls when you want to insert data to NOT NULL column, divide by zero, MERGE tries to update the row twice, primary key violations. Sounds familiar?

## Why do I test?

Because of all the above. And more. Because I write a lot of tests when I'm programming with PowerShell or C#. Because I've made all those mistakes and have seen other team members facing them. Because just data quality testing before and after the package run is not enough for me. I want to know if my package is ready to deal with some problems. I want to be sure, that when I change the package in a future, the test will show me the issues before they hit production testing environment. Because someone could change the table I'm using in the package (like, say - adding a NOT NULL column at the end) and my package will stop working. Because writing the tests makes me think more about the data and forces me to understand the requirements.

## Last thing before we start

Testing SSIS packages is hard. The more complex tasks the package is supposed to do, the more complicated testing is. It can take a lot of time to build the tests for the package (and sometimes we can't afford it).

But - as with the programming - thinking "how could I test this part?" impacts your package design. You make it more modular, you start improving logging, creating the tables that hold temporary data for diagnostic purposes. It gives you the comfort of well-done work. Probably you won't test everything, but you have to begin with something. Start with something simple, test one thing. Then test second, third thing. Don't think "it's a hell of a job to write the tests for the whole package". It is, but it's like eating an elephant - one piece at a time.

After you start testing, you will change your mindset, and the tests will become the standard tool in your work.

## Let's start

When I started using ssisUnit, I knew almost nothing about it. I just said to myself "I will finally start testing SSIS packages, and I will use that thing I've read about a while ago - ssisUnit".

I remembered that it's one of the few tools that help to test the SSIS packages. And that it uses XML to define those tests. Nothing more. There are two simple examples of testing individual packages in the documentation (and they are a good entry point), but I wanted to start with testing the packages in the SSIS projects, not the individual packages. Also - you have only the source code that you have to compile yourself so the entry point is not as easy as you might think. But - it's not that complicated. I will show you how to compile ssisUnit in the next posts. For now - you can [download the compiled version for SSIS 2017 here](https://github.com/BartekR/ssisUnit/releases).

When you compile it, you have the ssisUnit library, the test runner (command line) and the Test Suite Builder (that also can run the tests in a GUI). The GUI is simple and helps you get started - pick the _File > New From Package..._ option, choose the package and its tasks, and you're good to write the tests.

[![New SSISUnit test from package](images/ssisUnit_NewFromPackage.png#center)](images/ssisUnit_NewFromPackage.png)

I started with the simple staging package. I've analysed the examples, watched the recorded sessions by John during the SQLBits ([there](http://sqlbits.com/Sessions/Event12/Practical_Unit_Testing_for_SSIS_Packages) and [there](http://sqlbits.com/Sessions/Event10/Unit_Testing_SSIS_Packages)) and prepared my first test for the SQL Task element. And it passed as expected! Wow me! Then I made a second test. And it didn't pass. The program started to throw errors with connection managers (that worked with the previous test). I wrote the third test. It didn't pass, but also didn't throw the engine errors.

I got confused. And angry - why it doesn't want to work? I also checked the tests in BiXpress - and it gave me exactly the same errors. So I started the project that would help me learn ssisUnit starting with simple tests. Getting the data from a variable, from a variable with an expression, in a container, with a different scope. Each test gave me more insight into the way the ssisUnit works.

[![SSISUnit test example](images/ssisUnit_TestExample.png#center)](images/ssisUnit_TestExample.png)

The picture above is an example of the basic tests I made to learn how to use ssisUnit. I will tell more about them in the next posts. For now, let's talk a bit about

## The ssisUnit test structure

ssisUnit follows the convention known from another testing frameworks:

- you can set up individual test, run it, and clean up after it (teardown)
- the tests are organised in a test suite, that can also have setup and teardown phases
- the tests execution is automated and repeatable

If you create an empty test in the GUI and then save it you have the following content:

```xml
<?xml version="1.0" encoding="utf-8" ?>
<TestSuite xmlns="http://tempuri.org/SsisUnit.xsd">
  <ConnectionList />
  <PackageList />
  <DatasetList />
  <TestSuiteSetup />
  <Setup />
  <Tests />
  <Teardown />
  <TestSuiteTeardown />
</TestSuite>
```

`<TestSuite>` groups all the elements. You can set up and tear down the whole suite with - surprise - `<TestSuiteSetup>` / `<TestSuiteTeardown>` elements. It's the place where you run all the preparations for the tests to run and clean up after the job is done. The code is run only once. The tests are stored it the `<Tests>` element, and you can `<Setup>` and `<Teardown>` the code that will be applied **before and after each test**.

There are also helper objects:

- `<ConnectionList>` will hold all the database connections you can use during the testing,
- `<PackageList>` contains references to all the packages used within the test suite,
- `<DatasetList>` has all the datasets you need for your data compare tests

When you start adding the tests you fill the `<Tests>` element with `<Test>` elements (you also do the `<PackageList>` and the `<ConnectionList>`, but let's skip it for now). The `<Test>` element contains `<Assert>`s (how do we expect the result of the test to be), and each assert contains the `<Command>` element, where we tell the engine what operation it should it do.

Well, the `<Command>` element is my global term to the eight possible commands you can run with ssisUnit, but you get the idea.

[![Add command](images/ssisUnit_Commands.png#center)](images/ssisUnit_Commands.png)

The outcome of the command is then compared with assertions. If they match - the test passes, if not - the test fails. That simple. Below you find an example how the test with one assertion definition looks like (you can have more than one assertion per test).

```xml
<Test name="Container test" package="01\_OnlyParametersAndVariables" task="{E4C43E00-EC90-4C0D-92CB-CC3D5CD44236}" taskResult="Success">
    <Assert name="Assert: Container Variable == 42" expectedResult="42" testBefore="false" expression="false">
        <VariableCommand name="ContainerVariable" operation="Get" value="" />
    </Assert>
</Test>
```

You can run the test using the GUI or the console test runner. In both situations, you have the simple report of the test suite outcome.

[![Test results](images/ssisUnit_TestResults.png#center)](images/ssisUnit_TestResults.png)

The assertion error you see above is expected to fail as I check the variable out of the test's scope.

## Testing is useful

Working more and more with the tests I found them easy to write and my brain started to think about more and more things I could test. And it helped me to correct my testing package. I started not just testing the existing part of the package - I started test-driven development.

I wrote the test for SQL Task that didn't exist yet, then I prepared that task using Ctrl+C, Ctrl+V form another SQL Task (don't tell me that you don't do it!), edited the parts of it and run the tests. And the test failed. Because it found, that I didn't change the variable name for the outcome of the script.

This post is just an introduction to SSIS testing. In the next posts, I will show you how to start with writing the first ssisUnit tests and slowly beginning to do something more complicated.
