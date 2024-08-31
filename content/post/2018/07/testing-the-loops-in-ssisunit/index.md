---
title: "Testing the loops in ssisUnit"
date: "2018-07-10"
draft: false
image: "2018/07/10/testing-the-loops-in-ssisunit/images/TheForLoopTest.png"
categories: ['Series', 'Testing', 'Learning']
tags: ['SSIS', 'ssisUnit']
---

In the [Q & A post](http://agilebi.com/jwelch/2013/04/08/qa-from-unit-tests-for-ssis-packages/) after the webinar on ssisUnit (in 2013) John Welch answered the question about the loops:

> "If possible, can you demo if a container can be executed? Especially a For loop or For Each loop?"
>
> I didn’t have time to demo this during the presentation. Good thing too, because there was an error around handling of containers. This has now been fixed in the source code version of the project.

There is no example though, so let's add one.

## The setup

[![For loop example](images/TheForLoop.png#center)](images/TheForLoop.png)

The example is simple: it will add the number six within the _For Loop_, and I will check for the final results. The sample script `60_Loops.dtsx` [in the ssisUnitLearning project](https://github.com/BartekR/ssisUnitLearning/tree/master/ssisUnitLearning) contains the loop, the expression and two variables: `i` and `v`. The first is used for the iterations, the second for keeping the final value. The formula of the expression is: `@[User::v] = @[User::v] + 6`.

The loop iterates 7 times. So the final value I'm expecting is 42 - [the answer to life, the universe, everything](https://www.google.com/search?q=the+answer+to+life+the+universe+and+everything). Instead of setting the OnPostExecute breakpoint at the container level and checking for the value I will build two quick tests - for the _FLC Evaluate expression_ and _EXPR Add 6_ objects.

[![ForLoop properties](images/TheForLoopProperties.png#center)](images/TheForLoopProperties.png)

## The tests

I will add the tests using the `File > New From Package ...` option and select the container and the expression. There is no tests' setup/teardown needed, so I leave it blank. The asserts will use the _VariableCommand_ to read the values of the `v` variable. For the container, I'm setting 42 as the _ExpectedResult_, and for the expression, I'm setting ... Wait for a moment and think: what value should be written? What are we testing?

You can congratulate yourself if you think the expected value is six. It's the unit test, you are testing the individual component, so you just check the correctness of the expression. It's the container that calculates the aggregated value.

After setting up the tests and running you should have a working test, that verifies that the package works as expected.

[![ForLoop tests results](images/TheForLoopTestsResults.png#center)](images/TheForLoopTestsResults.png)

## The summary

Testing the container is no different than the other SSIS tasks. The only catch is when you want to check the value of something inside the container. Remember, always think about it as the standalone component.
