---
title: "Writing first tests with ssisUnit"
date: "2018-03-26"
draft: false
image: "2018/03/19/testing-ssis-projects-with-ssisunit/images/ssisUnit_HeaderImage.png"
categories: ['Learning', 'Series', 'Testing']
tags: ['SSIS', 'ssisUnit']
---

[Previously](http://blog.bartekr.net/2018/03/19/testing-ssis-projects-with-ssisunit/) I wrote about the importance of testing the SSIS packages and introduced you to ssisUnit. In this post, I will show you how to write simple tests for the variables and parameters using Test Suite Builder. As I wrote before: just start slow and small, don't write your first tests for the most complicated part of the package.

Create a new SSIS project and use the automatically generated `Package.dtsx`. Open it and add two parameters:

- first, a regular parameter, an `Int32` type with value `10`
- second, an encrypted `String` parameter, with value `123qwe!@#` marked as sensitive

[![Package parameters](images/PackageParameters.png#center)](images/PackageParameters.png)

Then create two variables with the package scope (by default all variables get the package scope):

- first - the `String` with `G10` value
- second - also the `String`, but this time we use an expression to get value "E" and the value of the `Int32` package parameter: `"E" + (DT_WSTR, 2)@[$Package::pPackageParameter]`

[![Variables](images/Variables01.png#center)](images/Variables01.png)

Now let's write the tests for parameters and variables.

## But first

If you have read the [Getting Started](https://github.com/johnwelch/ssisUnit/blob/master/docs/Getting%20Started.md) and the [Product Sample Package](https://github.com/johnwelch/ssisUnit/blob/master/docs/Product%20Sample%20Package%20and%20Test.md) from the ssisUnit docs you probably saw, that they use the _Package Deployment Model_, not the _Project Deployment Model_ we use and love since SQL Server 2012. But it's no problem for us, as ssisUnit also supports the projects. It's not the `.dtproj` files though, but the `.ispac` files. So - before we prepare our tests we have to compile the project.

## The package reference

We will start from scratch and won't use the _New From Package..._ option. After the compilation, open the Test Suite Builder, choose _File > New..._ (or Ctrl + N, or pick the first icon on the toolbar from the left) and go to the _Package List_ node. To test the packages we have to reference them in the test file, and we do that by _PackageRef_s. Right-click on the node and select _Add PackageRef_. On the right side, click the _ProjectPath_ line and then click the ellipsis to set the `.ispac` file.

[![Add package reference - before](images/AddPackageRef_Before.png#center)](images/AddPackageRef_Before.png)

For my ssisUnitLearning project, I have it in the `ssisUnitLearning\bin\Development` subfolder. Now pick the package you created - go to the _PackagePath_ line, click the ellipsis and select the package. Leave the rest of the fields with the default values. The last part, for now, is to give the PackageRef a name. I choose the name of the package. In the end, you should have something similar to the picture below. Save the test.

[![Add package reference - after](images/AddPackageRef_After.png#center)](images/AddPackageRef_After.png)

## The first test

Now we can start testing the package. Go to the _Tests_ node, right-click and select _Add Test_. On the _PackageLocation_ line pick the package to test (the list is populated from the _PackageRef_s). Now go to the _Task_ line, and click the ellipsis. If you did everything with the instructions above you should see an error like this:

[![Task selection error](images/Test_TaskSelectionError.png#center)](images/Test_TaskSelectionError.png)

The error states that it can't find our package within the compiled project. And it's correct. When we want to test the package contained in the project we have to give just a name of the package, not the path to the package on disk. Go to the package reference and delete the path to the package file leaving just the name of the package file. Like this:

[![Package reference - corrected](images/PackageRef_Corrected.png#center)](images/PackageRef_Corrected.png)

Now go back to the test node, click the ellipsis you should see the window with the package name. Pick it and click OK. Give your test a name (I use the package or task name), and save the test file. On the left side, the node still has a name _Test1_ and is in red. The test name will refresh after you pick a different node on the tree. And the colour is red because you didn't finish the test.

[![Test definition](images/Test_Definition.png#center)](images/Test_Definition.png)

The test node is just the container for the assertions. Let's build first - we will check if the _pProjectParameter_ has the value of 10. Right-click the test name node on the tree, select _Add Assert_ and define the _ExpectedResult_ as 10. To remember that I'm writing an assert I add 'Assert:' before each assertion. So I end up with something like below (or in the post's header):

[![Assert definition](images/Assert_Definition.png#center)](images/Assert_Definition.png)

The name of the assert refreshes in the tree after you select a different node and it will also be red. We have an assertion (what we expect the test to return) and now we have to run a command to return some kind of the result. We are testing the package parameter, so pick the _ParameterCommand_ right-clicking the assert's name.

[![Add ParameterCommand](images/SelectingParameterCommand.png#center)](images/SelectingParameterCommand.png)

We will test the _pPackageParameter_ in the package, so select Package from the drop-down list as the ParameterType and write the parameter's name in the _ParameterName_ line. Leave the rest with the default values.

[![ParameterCommand](images/ParameterCommand.png#center)](images/ParameterCommand.png)

The test is now ready. Hit the play button on the bar (or use _Ctrl + R_ or use _Test Suite > Run Suite_ from the menu). Tada! Your first test passes!

[![Test results](images/TestResults.png#center)](images/TestResults.png)

The result shows 1 test run, 1 test passed, 2 asserts run, 2 asserts passed.

Wait, what? We have prepared only one assert, why does it show two?

The second assert is: "_Task Completed: Actual result (Success) was equal to the expected result (Success)._". Great. Where does it come from? Let's find out.

We have two places (up to now) that use "Task completed" setting: the test and the command. I will set _TaskResult = Failure_ for the _ParameterCommand_, save and run again. The test still passes, so it must be the setting on the test node.

But before setting up the test node a quick verification: save the test file and open it again. Go to the _ParameterCommand_ node and check the value of _TestResult_ line. It should be _Success_ again, even when you set it to a different value. If you take a look at the source of the `.ssisUnit` file, you will see, that TestResult setting isn't stored in the configuration.

```xml
<Test name="01\_OnlyParametersAndVariables" package="01\_OnlyParametersAndVariables.dtsx" task="{5A229C3E-AE1F-48D1-AEF4-0EEB5C9E081E}" taskResult="Success">
    <Assertname="Assert: pPackageParameter should be 10" expectedResult="10" testBefore="false" expression="false">
        <ParameterCommandname="" operation="Get" parameterName="pPackageParameter" parameterType="Package" value=""/>
    </Assert>
</Test>
```

Now change the setting for the test and run the suite. The package test didn't finish with a Failure (it ended with the Success), so the other assert didn't even run.

[![Failed Assert - Package](images/FailedAssert_Package.png#center)](images/FailedAssert_Package.png)

As a homework - check how will the test suite run, when you change _TestResult_ to _Cancelled_ or _Completed_.

## Next tests

You successfully completed the first test. Now write the test for the second parameter that is sensible. Take a moment, think about it and try to write on your own. Then compare to the assert and the command below.

[![Sensitive parameter assert](images/SensitiveParameterAssert.png#center)](images/SensitiveParameterAssert.png)
[![Sensitive parameter command](images/SensitiveParameterCommand.png#center)](images/SensitiveParameterCommand.png)

A note here. By default, I have _the EncryptSensitiveWithUserKey_ security setting for my packages, and I run the tests on the same machine I have prepared the packages. So the UserKey security is not an issue. But what if we would run the tests on another computer? Or with _the EncryptAllWithPassword_ setting for example? I will show you in the following posts.

Now let's switch to the variables. You know how to test the package parameters, the variables are similar so there should be no problem for you to prepare the tests by yourself. It's also easier because when you use VariableCommand, you don't set the Project/Package scope.

One question that may come to your mind when testing the variable calculated with an expression is "should I use the Expression line setting when testing the expressions?". The answer is NO. The expression is to evaluate some .NET code expression, and it's something to check in the next blog posts, but for now just leave it always as _false_.

If you want to compare your tests for the variables open the source code of your `.ssisUnit` test file (or switch to the XML tab on the Assert node) and take a look below.

```xml
<Assert name="Assert: Global variable == G10" expectedResult="G10" testBefore="false" expression="false">
  <VariableCommand name="GlobalVariable" operation="Get" value="" />
</Assert>
<Assert name="Assert: Global variable with expression" expectedResult="E10" testBefore="false" expression="false">
  <VariableCommand name="GlobalVariableWithExpression" operation="Get" value="" />
</Assert>
```

Congratulations. You now know how o write simple tests for parameters and variables.

## The scope

The last thing to check today is the variable's scope. You have checked the variables with the default scope of the package. Now test the variable with the scope of a container.

Create an empty Sequence Container _SEQC Some container_ and add a new variable _ContainerVariable_. Then change the scope of the variable to the container. To do it click the _Move Variable_ button in the Variables window and pick the _SEQC Some container_ node in the _Select New Scope_ window. Then click OK.

[![Move variable](images/MoveVariable.png#center)](images/MoveVariable.png)
[![Select New Scope](images/SelectNewScope.png#center)](images/SelectNewScope.png)

Now write the test for the _ContainerVariable_ just as you wrote the test for the previous variables. Be sure to add the assert and the command at the SEQC Some container level. You should get a test similar to this one:

[![Assert variable with scope](images/Assert_VariableWithScope.png#center)](images/Assert_VariableWithScope.png)

What would happen if we tried to test the variable on the package level? After you define the same test but in the previous test tree that is made on the package level (_01\_OnlyParametersAndVariables_ from the picture above), you will get an error. The assert command failed with the following exception: _Failed to lock variable "ContainerVariable" for read access with error 0xC0010001 "The variable cannot be found. This occurs when an attempt is made to retrieve a variable from the Variables collection on a container during execution of the package, and the variable is not there. The variable name may have changed or the variable is not being created_.

[![Assert - variable scope error](images/Assert_VarableScopeError.png#center)](images/Assert_VarableScopeError.png)

That's all for now. We started from the very beginning with parameters and variables. We checked the variables scope, saw that we can test the sensitive parameters (in some circumstances) and we are ready to test the project parameters. The last one is your homework: create the project parameter and test it with ssisUnit.

You can find the sample package `01_OnlyParametersAndVariables.dtsx` and ssisUnit test for it [on my GitHub](https://github.com/BartekR/ssisUnitLearning).
