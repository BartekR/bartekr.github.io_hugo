---
title: "Advent of Code 2020" # Title of the blog post.
date: 2020-12-31 # Date of post creation.
publishdate: 2020-12-30T09:00:00.000Z
image: "2020/12/31/advent-of-code-2020/images/AoC.png"
#description: "How I migrated my previous WordPress blog." # Description used for search engine.
#featured: false # Sets if post is a featured post, making it appear on the sidebar. A featured post won't be listed on the sidebar if it's the current page
draft: false # Sets whether to render this page. Draft of true will not be rendered.

categories: ['Programming', 'Advent of Code']
tags: ['PowerShell', 'AoC2020']
---

This year I took part in "Advent of Code" - a challenge with the series of puzzles to solve using any programming language. I tried two years ago but resigned after the first day. This year was different, as we set the internal leaderboards, and I had a motivation to test my skills. My initial idea was to use only the PowerShell, but after some talks, I thought "maybe it's a good moment to start learning `go` lang"?

The answer was: no.

I started solving puzzles with PowerShell and learned `go` along. But as puzzles began to be more difficult, I focused only on PowerShell. `go` has to wait a bit.

I collected 28 stars out of 50 possible. Which I think is not that bad result. (You see 29 on the picture in the header because I started searching how others solved the problems and implemented first overdue task).

But - to the point. Before AoC I thought I know and understand PowerShell pretty well. During the AoC, I had to revisit it. Some tasks I usually do without thinking started to cause troubles when solving the puzzles. Like: hashtables didn't want to cooperate with numbers, or: read the file; the first part is X, the second is Y. I was too much used to my default set of techniques, and it was sometimes hard to think outside the box.

This post summarises what I learned (or reminded) during the AoC, sometimes with links for the broader explanation.

## 1. Reading files

Not much new stuff. As usual - use `Get-Content`, but become more familiar with `-Raw` parameter to read all data as one piece of text instead a `string[]` array. The `-Raw` parameter allows easy splitting data in the file that has to be separated via empty line. Like:

```cmd
line1;val1;val2
line2;val1;val2

part2:val1,val2
part2:val3:val4

part3|abc
part3|def
```

To separate the above code into three separate elements, use "-split "`r'n'r'n"  ". **Remember to use double quotes**.

```powershell
$customDeclarations = Get-Content "$PSScriptRoot\CustomDeclarations.txt" -Raw
$cd = $customDeclarations -split "`r`n`r`n"
```

## 2. Named regex

When using `-match` we get `$Matches` array with the numbered matches. Say we have these lines (taken from my Day02 puzzle input):

```cmd
3-7 r: mxvlzcjrsqst
1-3 c: ccpc
6-12 f: mqcccdhxfbrhfpf
```

The task was to check if the letter appears between X and Y number of times in the password. Looking at the first line:

* `3-7` min/max appearances
* `r` letter
* `mxvlzcjrsqst` password

We can read data using regex like `(\d+)-(\d+) ([a-z]): ([a-z]+)`, but we have to remember the indices of the groups, like `$Matches[3]` means the third group (the letter a-z).

```powershell
$passwords = Get-Content .\Passwords.txt -First 3
$passwords | ForEach-Object {
    $_ -match '(\d+)-(\d+) ([a-z]): ([a-z]+)' | Out-Null
    $Matches
}

<#
Name                           Value
----                           -----
4                              mxvlzcjrsqst
3                              r
2                              7
1                              3
0                              3-7 r: mxvlzcjrsqst
4                              ccpc
3                              c
2                              3
1                              1
0                              1-3 c: ccpc
4                              mqcccdhxfbrhfpf
3                              f
2                              12
1                              6
0                              6-12 f: mqcccdhxfbrhfpf
#>
```

Instead, we can use named references in regexes using `?<name>` construction before the pattern, like:

`(?<minLength>\d+)-(?<maxLength>\d+) (?<letter>[a-z]): (?<password>[a-z]+)`

```powershell
$passwords = Get-Content .\Passwords.txt -First 3
$passwords | ForEach-Object {
    $_ -match '(?<minLength>\d+)-(?<maxLength>\d+) (?<letter>[a-z]): (?<password>[a-z]+)' | Out-Null
    $Matches
}

<#
Name                           Value
----                           -----
minLength                      3
maxLength                      7
letter                         r
password                       mxvlzcjrsqst
0                              3-7 r: mxvlzcjrsqst
minLength                      1
maxLength                      3
letter                         c
password                       ccpc
0                              1-3 c: ccpc
minLength                      6
maxLength                      12
letter                         f
password                       mqcccdhxfbrhfpf
0                              6-12 f: mqcccdhxfbrhfpf
#>
```

The `Out-Null` prevents the `-match` result to appear on the screen (`True` or `False`)

## 3. Join lines

How to join a few lines in one? Use `-replace`. **Again - remember about double quotes**.

```powershell
$lines = '
hgt:176cm
iyr:2013
hcl:#fffffd ecl:amb
byr:2000
eyr:2034
cid:89 pid:934693255
'

$lines -replace "`n", ';'
# or: $lines -replace "`r`n", ';'

# hgt:176cm;iyr:2013;hcl:#fffffd ecl:amb;byr:2000;eyr:2034;cid:89 pid:934693255
```

## 4. Sort array of strings as numbers

AoC had almost all the puzzle inputs in the separate files. So I created the input files for each day and read it using `Get-Content`. Some files contained a series of numbers, and when we read data from a file, we get all as a string. So when I wanted to sort the array I read from the file, I got unexpected results.

```powershell
# simulating array read from file
$a = [string[]]@(2, 3, 1, 11, 15, 21)
$a | Sort-Object

<#
1
11
15
2
21
3
#>
```

PowerShell is not aware that those strings are numbers, so it orders them as strings. To sort as the number [take a look in the documentation](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/sort-object?view=powershell-7.1#example-8--sort-a-string-as-an-integer) and use ScriptBlock as the `-Parameter`:

```powershell
# simulating array read from file
$a = [string[]]@(2, 3, 1, 11, 15, 21)

$a | Sort-Object  { [int]$_ }

<#
1
2
3
11
15
21
#>
```

The [Stack Overflow answer](https://stackoverflow.com/questions/15040460/sort-object-and-integers) has a bit more about it and led me to the documentation.

## 5. Expanding arrays

It's not a PowerShell trick or feature. [Day 11](https://adventofcode.com/2020/day/11) had a calculation of seats, and one of the tricks was getting info around the corners and edges. Like on a chequerboard - you have 64 squares. Each of them - excluding the edges - have 8 adjacent fields. The corner has three, and the edge has five. To check all the fields, you have to consider edges and corners as a different case. And it adds an overhead to the code.

It's easier to add a "border" to the lattice (again: think chequerboard), and analyse the original data. Like this:

```cmd
# original, 10 x 10
L.LL.LL.LL
LLLLLLL.LL
L.L.L..L..
LLLL.LL.LL
L.LL.LL.LL
L.LLLLL.LL
..L.L.....
LLLLLLLLLL
L.LLLLLL.L
L.LLLLL.LL

# with border (using dots), 12 x 12
............
.L.LL.LL.LL.
.LLLLLLL.LL.
.L.L.L..L...
.LLLL.LL.LL.
.L.LL.LL.LL.
.L.LLLLL.LL.
...L.L......
.LLLLLLLLLL.
.L.LLLLLL.L.
.L.LLLLL.LL.
............
```

Now my code will look clearer as I don't use additional `if`s or `switch`es.

To add the border, I used this code:

```powershell
# $seats0 is the original lattice

# add top and bottom border, the same length as the original row
$seats = @('.' * $columns) + $seats0 + @('.' * $columns)

# add left and right border to each row (including boundaries)
for($i = 0; $i -le $rows + 1; $i ++)
{
    $seats[$i] = '.' + $seats[$i] + '.'
}
```

## 6. Hashtables and keys

Always be aware of the datatypes. A standard case with numbers:

```powershell
$n = @(65, 66, 67, 68, 69)
$h = @{}
$n | ForEach-Object {$h[$_] = [char]$_}
$h

<#
Name                           Value
----                           -----
69                             E
68                             D
67                             C
66                             B
65                             A
#>

$h[69]
# E
$h.69
# E
$h.'69'
#(nothing)
```

But with the array of numbers as strings:

```powershell
$n1 = @('65', '66', '67', '68', '69')
$h1 = @{}
$n1 | ForEach-Object {$h1[$_] = [char][int]$_}

<#
Name                           Value
----                           -----
67                             C
66                             B
65                             A
68                             D
69                             E
#>

$h1[67]
# (nothing)
$h1.67
# (nothing)
$h1.'67'
# C
$h1['67']
# C
```

Looks the same, but I had to use a string key, not a numeric, because of a different type.

## 7. Pre-fill an array with values

Sometimes I wanted to have an array with prefilled values. Like 10 values of 0:

```powershell
$a = @(0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
```

What if I know only the number of elements in an array (as a variable)? [The fastest version](https://stackoverflow.com/questions/17875852/how-to-fill-an-array-efficiently-in-powershell/17877292#17877292):

```powershell
$n = 57
$a = ,0 * $n
```

Also worth reading - [an article on SimpleTalk](https://www.red-gate.com/simple-talk/sysadmin/powershell/powershell-one-liners--collections,-hashtables,-arrays-and-strings/).

## 8. Convert a number to a binary string

Use `[Convert]::ToString($number, 2)`. Works with other bases too.

```powershell
[Convert]::ToString(15, 2)
# 1111

[Convert]::ToString(15, 8)
# 17

[Convert]::ToString(15, 16)
# f
```

## 9. Pad numbers with zeroes

I want to prefix my number(s) with leading zeroes (like: `000000015`), and keep the lengths consistent - all prefixed numbers should have a length of 10. I used it to visualise a bitmask but works for every number.

1. Use formatting: `'{0:d10}' -f $number`; important: it has to be **a number**:

    ```powershell
    $a = '15'
    '{0:d10}' -f $a
    # 15

    '{0:d10}' -f [int]$a
    # 0000000015
    ```

2. Use `$number.PadLeft(10, '0')`; this time `$number` has to be **a string**:

    ```powershell
    '15'.PadLeft(10, '0')
    # 0000000015

    $b = 15
    $b.PadLeft(10, '0')
    # InvalidOperation: Method invocation failed because [System.Int32] does not contain a method named 'PadLeft'.

    15.PadLeft(10, '0')
    # 15.PadLeft: The term '15.PadLeft' is not recognized as a name of a cmdlet, function, script file, or executable program.
    # Check the spelling of the name, or if a path was included, verify that the path is correct and try again.

    (15).PadLeft(10, '0')
    #InvalidOperation: Method invocation failed because [System.Int32] does not contain a method named 'PadLeft'.
    ```

3. Use `ToString('0000000000')`; works only with **numbers**:

    ```powershell
    15.ToString('0000000000')
    # 15.ToString: The term '15.ToString' is not recognized as a name of a cmdlet, function, script file, or executable program.
    # Check the spelling of the name, or if a path was included, verify that the path is correct and try again.

    (15).ToString('0000000000')
    # 0000000015

    '15'.ToString('0000000000')
    # MethodException: Cannot find an overload for "ToString" and the argument count: "1".
    ```

The list may expand in the future, as I plan to finish Advent of Code 2020, hopefully before AoC 2021.
