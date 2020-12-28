---
title: "Draw the SSIS package using SVG - part I"
date: "2019-07-08"
draft: false
images:
  - src: "2019/07/08/draw-the-ssis-package-using-svg-part-i/images/DTS_DesignTimeProperties.png"
    alt: ""
    stretch: ""
tags: ['SSIS', 'SVG', 'XML', 'XSLT']
categories: ['Learning', 'Series']
---

For one of my projects, I need to draw the content of an SSIS package. It should not be a big problem, as the file contains all the required information. If you need to do something similar - I write a series of posts on how to achieve it using SVG, XSLT transformations and a bit of PowerShell (and maybe something more along the way). All the code [is available on GitHub](https://github.com/BartekR/blog/tree/master/201907%20Draw%20SSIS%20package%20using%20SVG%20part%20I).

## The setup

I start with the sample package as on the picture. It has three elements aligned vertically, with `AND` precedence constraints, evaluated as _Success_. It also has a small annotation on the side.

[![Sample SSIS package](images/SSISPackage.png#center)](images/SSISPackage.png)

The part responsible for the layout is the tag`<DTS:DesignTimeProperties>` at the end of the XML, that stores the data as a `CDATA` section.

[![DTS:DesignTimeProperties](images/DTS_DesignTimeProperties.png#center)](images/DTS_DesignTimeProperties.png)

For a start, it's enough to save its content to a separate XML file named [PackageLayout.xml](https://github.com/BartekR/blog/blob/master/201907%20Draw%20SSIS%20package%20using%20SVG%20part%20I/PackageLayout.xml) and take only one part of it containing the `<Package>` element and save as [Beginning.xml](https://github.com/BartekR/blog/blob/master/201907%20Draw%20SSIS%20package%20using%20SVG%20part%20I/Beginning.xml).

The last thing is to have some XSLT processor. I use [Saxon](http://www.saxonica.com/welcome/welcome.xml) for years, and for the demos, I use the Saxon HE 9.9 .NET version. I will use some of the features of XSLT 2.0, so I skip the XSLT processing used in the browsers as they don't support it.

To run the XSLT transformation, I use `Transform.exe` with three parameters:

- `-s:<source.xml.file>`
- `-xsl:<xsl.transformations.file>`
- `-o:<generated.svg.file>`

To ease the process, I create the [diagram2svg.bat](https://github.com/BartekR/blog/blob/master/201907%20Draw%20SSIS%20package%20using%20SVG%20part%20I/diagram2svg.bat) file, where I provide the path to the Saxon executables (`set SAXONPATH=D:\tools\SaxonHE9.9N\bin`) and all the commands to produce SVG files, like:

```cmd
%SAXONPATH%\Transform -s:Sample2.xml -xsl:package2svg.xsl -o:Sample2.svg
```

## The beginnings

When I started to prepare the XSLT transformations, I used the Beginning.xml file and prepared the package2svg.xsl file. But not everything wanted to work, so I took a few steps back and started slowly. First - I created a blank SVG file - [00.svg](https://github.com/BartekR/blog/blob/master/201907%20Draw%20SSIS%20package%20using%20SVG%20part%20I/00.svg) - just to be sure that I remember how to draw a simple image. Then I took the `<NodeLayout>` element and put it directly inside the `<Objects>` to test a simple XSLT transformation. I tested it with the [01.xml](https://github.com/BartekR/blog/blob/master/201907%20Draw%20SSIS%20package%20using%20SVG%20part%20I/01.xml) and [01.xsl](https://github.com/BartekR/blog/blob/master/201907%20Draw%20SSIS%20package%20using%20SVG%20part%20I/01.xsl) files.

```xml
<?xml version="1.0"?>
<!-- First try: pretend, that NodeLayout is the first element under the root -->
<Objects Version="sql11">
    <NodeLayout Size="179,42" Id="Package\\SQL Create table test" TopLeft="5.50000000000003,5.5" />
</Objects>
```

XSLT processing is as follows:

- `xsl:stylesheet` is 1.0 version (for a start it's enough)
- `xsl:output` is indented XML
- `xsl:template match="/Objects"` finds the root element (`Objects`) of the XML file and prepares the root element of the SVG file; I make the SVG 2.0 version, so I use just the minimum declaration
- inside the root element I `xsl:apply-templates` for the `NodeLayout` (it's just below the `Objects)`
- to draw the node I use the `<rect>` tag and pass all its attributes as `xsl:attribute`, because I want to evaluate the expressions
- the `x` and `y` coordinates are stored inside the `TopLeft` attribute, and the `width` and `height`are inside the `Size`; they are separated by a comma, so I use `substring-before()` and `substring-after()` XSLT functions to get them; the SSIS package starts its coordinate system just like the SVG in the upper left corner of the screen, so I don't have to do sophisticated calculations
- I draw the node using light grey colour (`fill`) with a black border (`stroke`) of 1px width (`stroke-width`) and round the corners using 10px measure (`rx` and `ry`); a side note - if you don't specify the measure units in SVG [it's assumed to be pixels](http://tutorials.jenkov.com/svg/svg-coordinate-system.html#coordinate-system-units)
- I have a habit that all the SVG elements created with XSLT are grouped using the `<g>` tag, even if the group contains just one object; it also helps me to deal with the namespaces
- the essential part of the template is to use the proper namespace, that's why the full element is `<g **xmlns="http://www.w3.org/2000/svg"**>` - if I don't use the namespace, the SVG file will have `<g xmlns="">` as the outcome and will not draw the node
- the `<g>` tag as a wrapper also has an advantage - I specify the namespace only for the one element (in another case I would have to write it for all of them within the `xsl:template`)

```xslt
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>

  <xsl:output
      method="xml"
      encoding="UTF-8"
      indent="yes" />

  <xsl:template match="/Objects">

    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox = "0 0 1000 600"
    >

      <xsl:apply-templates select="NodeLayout" />

    </svg>

  </xsl:template>

  <xsl:template match="NodeLayout">

    <g xmlns="http://www.w3.org/2000/svg">

        <rect>
            <xsl:attribute name="x"><xsl:value-of select="substring-before(@TopLeft, ',')"/></xsl:attribute>
            <xsl:attribute name="y"><xsl:value-of select="substring-after(@TopLeft, ',')"/></xsl:attribute>
            <xsl:attribute name="rx">10</xsl:attribute>
            <xsl:attribute name="ry">10</xsl:attribute>
            <xsl:attribute name="width"><xsl:value-of select="substring-before(@Size, ',')"/></xsl:attribute>
            <xsl:attribute name="height"><xsl:value-of select="substring-after(@Size, ',')"/></xsl:attribute>
            <xsl:attribute name="fill">lightgray</xsl:attribute>
            <xsl:attribute name="stroke">black</xsl:attribute>
            <xsl:attribute name="stroke-width">1</xsl:attribute>
        </rect>

    </g>

  </xsl:template>

</xsl:stylesheet>
```

## The next step

I can draw the node from the XML document with one level of nesting. But in reality, it has four levels: `/Objects/Package/GraphInfo/LayoutInfo/NodeLayout` with a `<GraphLayout>` tag having different namespace(s). Working with namespaces is hard in the beginning, so the next step is to draw the same node, but with four levels of nesting. The example is in the [02.xml](https://github.com/BartekR/blog/blob/master/201907%20Draw%20SSIS%20package%20using%20SVG%20part%20I/02.xml) and [02.xsl](https://github.com/BartekR/blog/blob/master/201907%20Draw%20SSIS%20package%20using%20SVG%20part%20I/02.xsl) files.

```xml
<?xml version="1.0"?>
<Objects Version="sql11">
    <Package>
        <LayoutInfo>
            <GraphLayout>
                <NodeLayout Size="179,42" Id="Package\\SQL Create table test" TopLeft="5.50000000000003,5.5" />
            </GraphLayout>
        </LayoutInfo>
    </Package>
</Objects>
```

The 02.xsl transformation file has two differences when compared to 01.xsl:

- the root node now uses `xsl:apply-templates` to call the `Package`template
- all the descendant nodes call the templates of the child nodes - `Package` calls `LayoutInfo`, `LayoutInfo` calls `GraphLayout`, and `GraphLayout` calls `NodeLayout`
- the same result I can achieve using `xsl:apply-templates="Package/LayoutInfo/GraphLayout/NodeLayout` and `xsl:template-match="Package/LayoutInfo/GraphLayout/NodeLayout"` (as in [02a.xsl](https://github.com/BartekR/blog/blob/master/201907%20Draw%20SSIS%20package%20using%20SVG%20part%20I/02a.xsl) file), but I may want to decorate the intermediate elements, so I use this construction

```xslt
(...)
<xsl:apply-templates select="Package" />
(...)
<xsl:template match="Package">
    <xsl:apply-templates select="LayoutInfo" />
</xsl:template>

<xsl:template match="LayoutInfo">
    <xsl:apply-templates select="GraphLayout" />
</xsl:template>

<xsl:template match="GraphLayout">
    <xsl:apply-templates select="NodeLayout" />
</xsl:template>
```

Now to the namespace part. The `<GraphLayout>`item looks like this (skipping the `Capacity` attribute):

```xml
<GraphLayout
    xmlns="clr-namespace:Microsoft.SqlServer.IntegrationServices.Designer.Model.Serialization;assembly=Microsoft.SqlServer.IntegrationServices.Graph"
    xmlns:mssgle="clr-namespace:Microsoft.SqlServer.Graph.LayoutEngine;assembly=Microsoft.SqlServer.Graph"
    xmlns:assembly="http://schemas.microsoft.com/winfx/2006/xaml"
>
```

To generate the correct SVG, I have to do two things:

- add the namespace(s) used in `<GraphLayout>` to the xsl file
- use the namespace in the templates

Take a look at the [03.xsl](https://github.com/BartekR/blog/blob/master/201907%20Draw%20SSIS%20package%20using%20SVG%20part%20I/03.xsl) file:

- the default namespace of the `<GraphLayout>` tag has to be added to the `xsl:stylesheet` declaration and prefixed to use it later; I chose the `gl` prefix; I can skip the remaining namespaces `mssgle` and `assembly` as I don't use them in the [03.xml](https://github.com/BartekR/blog/blob/master/201907%20Draw%20SSIS%20package%20using%20SVG%20part%20I/03.xml) example
- the `gl` name has to be used in the `GraphLayout` template and all its descendants

```xslt
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  **xmlns:gl="clr-namespace:Microsoft.SqlServer.IntegrationServices.Designer.Model.Serialization;assembly=Microsoft.SqlServer.IntegrationServices.Graph"**
>
(...)

    <xsl:template match="LayoutInfo">
        <xsl:apply-templates select="**gl:GraphLayout**" />
    </xsl:template>

    <xsl:template match="**gl:GraphLayout**">
        <xsl:apply-templates select="**gl:NodeLayout**" />
    </xsl:template>

  <xsl:template match="**gl:NodeLayout**">
(...)
```

## The drawing

Having all the preparation steps completed, I can now draw the Beginning.xml part of the package. I use the [package2svg.xsl](https://github.com/BartekR/blog/blob/master/201907%20Draw%20SSIS%20package%20using%20SVG%20part%20I/package2svg.xsl) that contains the previously learnt things and expand it with the new elements:

- the ``gl:GraphLayout contains `gl:NodeLayout`, `gl:EdgeLayout` and `gl:AnnotationLayout` ``
- I want to display the names of the nodes (they are stored as the last part of the path in the `Id` attribute of the `NodeLayout`), so I use the `<text>` element
- I position the text inside the node, that's why I add 5 pixels to the `x` position and calculate about the half of the height of the node for the `y` position and add about half the height of the font (all based on trial-and-error, I will make it more dynamic later)
- To use the calculations, I have to cast the values to `number()`s
- to get the last element of the path, I use the `tokenize()` function on the `Id` attribute providing the backslash (escaped) as the separator and save the result to the `xsl:variable` `nodeNameTokens`
- the `nodeNameTokens` holds the collection, and I'm interested only in the last element of it, so I use `$nodeNameTokens[last()]` for the description of the node
- the `tokenize()` function is available since XSLT 2.0, so I have to change the declaration of the xsl file to `xsl:stylesheet version="2.0"`
- I want to have a light grey background of the image, so I use the trick with `<rect width="100%" height="100%">` on the whole surface
- to draw the edges, I use the `<line>` tag in the `gl:EdgeLayout` template; it's a simple package with the straight lines, so I don't care about the drawing the curves
- the `(x1, y1)` and `(x2, y2)` coordinates are calculated using the `TopLeft` attribute of the `EdgeLayout` and the `End` attribute of the `mssgle:Curve` (I also added this namespace to the `xsl:stylesheet` declaration)
- the lines of the edges don't connect the elements, so I add the little triangle at the end using the `<polygon>`
- the triangle's sides are calculated using the ends of the edges (`mssgle:Curve/@End`) and the connectors (`mssgle:Curve/@EndConnector`)
- the `<polygon>` element has the points attribute, where I have to provide the coordinates of the points `x,y` separated by a space (like: `<polygon points="10,10 10,15 15,15" />`), so I use `<xsl:text> </xsl:text>` to put a space between the calculated positions
- the `AnnotationElement` is drawn similarly to the `NodeElement` with an additional border around it (to see that the rectangle exists); compared to the original package there is a room for improvement in the text positioning

```xslt
<xsl:stylesheet **version="2.0"**
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:gl="clr-namespace:Microsoft.SqlServer.IntegrationServices.Designer.Model.Serialization;assembly=Microsoft.SqlServer.IntegrationServices.Graph"
  xmlns:mssgle="clr-namespace:Microsoft.SqlServer.Graph.LayoutEngine;assembly=Microsoft.SqlServer.Graph"
>

  <xsl:output
      method="xml"
      encoding="UTF-8"
      indent="yes" />

  <xsl:template match="/Objects">

    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox = "0 0 600 600"
    >
      <rect width="100%" height="100%" fill="lightgray"/>

      <xsl:apply-templates select="Package" />

    </svg>

  </xsl:template>

    <xsl:template match="Package">
        <xsl:apply-templates select="LayoutInfo" />
    </xsl:template>

    <xsl:template match="LayoutInfo">
        <xsl:apply-templates select="gl:GraphLayout" />
    </xsl:template>

    <xsl:template match="gl:GraphLayout">
        <xsl:apply-templates select="gl:NodeLayout" />
        <xsl:apply-templates select="gl:EdgeLayout" />
        <xsl:apply-templates select="gl:AnnotationLayout" />
    </xsl:template>

  <xsl:template match="gl:NodeLayout">

    <xsl:variable name="**nodeNameTokens**" select="tokenize(@Id, '\\')" />

    <g xmlns="http://www.w3.org/2000/svg">

        <rect>
            <xsl:attribute name="x"><xsl:value-of select="substring-before(@TopLeft, ',')"/></xsl:attribute>
            <xsl:attribute name="y"><xsl:value-of select="substring-after(@TopLeft, ',')"/></xsl:attribute>
            <xsl:attribute name="rx">10</xsl:attribute>
            <xsl:attribute name="ry">10</xsl:attribute>
            <xsl:attribute name="width"><xsl:value-of select="substring-before(@Size, ',')"/></xsl:attribute>
            <xsl:attribute name="height"><xsl:value-of select="substring-after(@Size, ',')"/></xsl:attribute>
            <xsl:attribute name="fill">white</xsl:attribute>
            <xsl:attribute name="stroke">black</xsl:attribute>
            <xsl:attribute name="stroke-width">1</xsl:attribute>
        </rect>

        <text>
            <xsl:attribute name="x"><xsl:value-of select="number(substring-before(@TopLeft, ',')) + 5"/></xsl:attribute>
            <xsl:attribute name="y"><xsl:value-of select="number(substring-after(@TopLeft, ',')) + (number(substring-after(@Size, ',')) div 2) + 7"/></xsl:attribute>
            <xsl:attribute name="fill">black</xsl:attribute>
            <xsl:attribute name="font-family">Verdana</xsl:attribute>
            <xsl:attribute name="font-size">12</xsl:attribute>
            <xsl:value-of select="$nodeNameTokens\[last()\]"/>
        </text>

    </g>

  </xsl:template>

  <xsl:template match="gl:EdgeLayout">

    <g xmlns="http://www.w3.org/2000/svg">

        <line>
            <xsl:attribute name="x1"><xsl:value-of select="substring-before(@TopLeft, ',')"/></xsl:attribute>
            <xsl:attribute name="y1"><xsl:value-of select="substring-after(@TopLeft, ',')"/></xsl:attribute>
            <xsl:attribute name="style">stroke:#006600</xsl:attribute>
            <xsl:attribute name="x2"><xsl:value-of select="number(substring-before(@TopLeft, ',')) + number(substring-before(gl:EdgeLayout.Curve/mssgle:Curve/@End, ','))"/></xsl:attribute>
            <xsl:attribute name="y2"><xsl:value-of select="number(substring-after(@TopLeft, ',')) + number(substring-after(gl:EdgeLayout.Curve/mssgle:Curve/@End, ','))"/></xsl:attribute>
        </line>

        <polygon>
            <xsl:attribute name="points">
                <xsl:value-of select="number(substring-before(@TopLeft, ',')) + number(substring-before(gl:EdgeLayout.Curve/mssgle:Curve/@End, ',')) - 3"/>,<xsl:value-of select="number(substring-after(@TopLeft, ',')) + number(substring-after(gl:EdgeLayout.Curve/mssgle:Curve/@End, ','))"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="number(substring-before(@TopLeft, ',')) + number(substring-before(gl:EdgeLayout.Curve/mssgle:Curve/@End, ',')) + 3"/>,<xsl:value-of select="number(substring-after(@TopLeft, ',')) + number(substring-after(gl:EdgeLayout.Curve/mssgle:Curve/@End, ','))"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="number(substring-before(@TopLeft, ',')) + number(substring-before(gl:EdgeLayout.Curve/mssgle:Curve/@EndConnector, ','))"/>,<xsl:value-of select="number(substring-after(@TopLeft, ',')) + number(substring-after(gl:EdgeLayout.Curve/mssgle:Curve/@EndConnector, ','))"/>
            </xsl:attribute>
            <xsl:attribute name="style">stroke:#006600; fill:#006600</xsl:attribute>
        </polygon>

    </g>

  </xsl:template>

  <xsl:template match="gl:AnnotationLayout">

    <g xmlns="http://www.w3.org/2000/svg">
      <text>
        <xsl:attribute name="x"><xsl:value-of select="number(substring-before(@TopLeft, ','))"/></xsl:attribute>
        <xsl:attribute name="y"><xsl:value-of select="number(substring-after(@TopLeft, ',')) + (number(substring-after(@Size, ',')) div 2)"/></xsl:attribute>
        <xsl:attribute name="fill">black</xsl:attribute>
        <xsl:attribute name="font-family">Verdana</xsl:attribute>
        <xsl:attribute name="font-size">12</xsl:attribute>
        <xsl:value-of select="@Text"/>
      </text>

      <rect>
        <xsl:attribute name="x"><xsl:value-of select="substring-before(@TopLeft, ',')"/></xsl:attribute>
        <xsl:attribute name="y"><xsl:value-of select="substring-after(@TopLeft, ',')"/></xsl:attribute>
        <xsl:attribute name="width"><xsl:value-of select="substring-before(@Size, ',')"/></xsl:attribute>
        <xsl:attribute name="height"><xsl:value-of select="substring-after(@Size, ',')"/></xsl:attribute>
        <xsl:attribute name="fill">none</xsl:attribute>
        <xsl:attribute name="stroke">black</xsl:attribute>
        <xsl:attribute name="stroke-width">1</xsl:attribute>
      </rect>
    </g>
  </xsl:template>

</xsl:stylesheet>
```

## The result

[![Generated SVG](images/GeneratedSVG.png#center)](images/GeneratedSVG.png)

[![SSIS Package](images/SSISPackage.png#center)](images/SSISPackage.png)

The current drawing does not look as nice as the original SSIS, but hey - it's the same layout! So, let's draw something more complicated - the sequences with the elements aligned horizontally, vertically, with split paths:

[![SSIS sequence example](images/SequencesExample.png#center)](images/SequencesExample.png)

The plan of the image is stored in the [Sample2.xml](https://github.com/BartekR/blog/blob/master/201907%20Draw%20SSIS%20package%20using%20SVG%20part%20I/Sample2.xml) file. When I run the transformation using diagram2svg.xsl file I get the following:

[![Unexpected sample](images/UnexpectedSample2.png#center)](images/UnexpectedSample2.png)

No sequences, some elements are hidden, no path annotations. A mess. I knew I did not implement all the features, but I wanted to see the aligned nodes. Well, not this time. Adding the sequence objects, curved arrows and cleaning the XSLT, to get a picture below is a subject for the next part of the series.

[![Expected sample](images/ExpectedSample.png#center)](images/ExpectedSample.png)
