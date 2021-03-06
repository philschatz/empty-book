<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:c="http://cnx.rice.edu/cnxml"
  xmlns:m="http://www.w3.org/1998/Math/MathML"
  xmlns:qml="http://cnx.rice.edu/qml/1.0"
  xmlns:mod="http://cnx.rice.edu/#moduleIds"
  xmlns:bib="http://bibtexml.sf.net/"
  xmlns:x="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="c"
  >

<xsl:output omit-xml-declaration="yes"/>

<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="x:head">
  <xsl:apply-templates select="node()"/>
</xsl:template>

<!-- Generate the Liquid Template header for modules -->
<xsl:template match="x:body/x:div[@data-type='title']">
  <title>
    <xsl:apply-templates select="node()"/>
  </title>
</xsl:template>


<!-- Clean up the collxml HTML -->

<xsl:template match="x:body[x:nav]/x:h1">
  <title>
    <xsl:apply-templates select="node()"/>
  </title>
</xsl:template>

<xsl:template match="x:nav">
  <xsl:apply-templates select="node()"/>
</xsl:template>

<xsl:template match="
    x:nav//x:li/@data-document
  | x:nav//x:li/@data-version
  | x:nav//x:li/@data-repository
  | x:nav//x:li/@data-version-at-this-collection-version
  "/>

<!-- scrap the .xinclude and .overridden-content classes on ToC links -->
<xsl:template match="x:nav//x:li[@data-document]/x:a/@class"/>

<!-- Convert Introduction modules into the chapter link -->
<xsl:template match="x:nav//x:li[x:ol/x:li/x:a[starts-with(text(), 'Introduction')]]/x:span">
  <xsl:apply-templates mode="intro" select="../x:ol/x:li/x:a[starts-with(text(), 'Introduction')]">
    <xsl:with-param name="link-text" select="text()"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template               match="x:li[@class]/x:ol/x:li[x:a[starts-with(text(), 'Introduction')]]"/>
<xsl:template mode="intro"  match="x:nav//x:li[@class]/x:ol/x:li/x:a[starts-with(text(), 'Introduction')]">
  <xsl:param name="link-text"/>
  <xsl:copy>
    <xsl:apply-templates select="@*"/>
    <xsl:apply-templates select="$link-text"/>
  </xsl:copy>
</xsl:template>

<!-- Rename links that end in .xhtml to .md -->
<xsl:template match="x:nav//x:a[contains(@href, '.xhtml')]/@href">
  <xsl:attribute name="href">
    <xsl:text>contents/</xsl:text>
    <xsl:value-of select="substring-before(., '.xhtml')"/>
    <xsl:text>.md</xsl:text>
  </xsl:attribute>
</xsl:template>


<!-- Unwrap the span in the ToC -->
<xsl:template match="x:nav//x:li[@class='part']/x:span">
  <xsl:apply-templates select="node()"/>
</xsl:template>







<!-- Clean up sections with titles -->

<!-- <xsl:template match="x:section">
  <xsl:apply-templates select="node()"/>
</xsl:template>
 -->
<xsl:template match="
    h1/@data-type
  | h2/@data-type
  | h3/@data-type
  | h4/@data-type
  | h5/@data-type
  | h6/@data-type"/>

<xsl:template match="x:a[@class='autogenerated-content']/@class"/>


<xsl:template match="x:img/@src">
  <xsl:attribute name="src">
    <xsl:text>../resources/</xsl:text>
    <xsl:value-of select="."/>
  </xsl:attribute>
</xsl:template>





<!-- convert span.term to strong.term to reduce the amount of HTML markup -->
<xsl:template match="x:span[@data-type='term']">
  <strong>
    <xsl:apply-templates select="@*|node()"/>
  </strong>
</xsl:template>



<!-- Omit because this is already in the <title> -->
<xsl:template match="x:body/*[@data-type='title']"/>

<xsl:template match="x:section[*[@data-type='title']]">
  <xsl:apply-templates select="node()"/>
</xsl:template>

<xsl:template match="x:section[@id]/*[@data-type='title']">
  <xsl:copy>
    <xsl:apply-templates select="../@id|@*|node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="x:section/*[@data-type='title']/@data-type"/>


<!-- Ignore various @id attributes because they only clutter up the kramdown markup -->

<xsl:template match="x:p/@id|x:ol/@id|x:ul/@id"/>

<!-- Ignore `fs-id123456` ids since they were generated by EIP -->
<xsl:template match="@id">
  <xsl:if test="not(starts-with(., 'fs-id'))">
    <xsl:copy/>
  </xsl:if>
</xsl:template>

<xsl:template match="x:figure[*[@data-type='media']/x:img]">
  <xsl:apply-templates select="*[@data-type='media']/x:img"/>
</xsl:template>

<xsl:template match="x:img/@width"/>

<xsl:template match="x:figure/*[@data-type='media']/x:img">
  <!-- <xsl:value-of disable-output-escaping="yes" select="'&lt;p&gt;'"/> -->

  <xsl:copy>
    <xsl:apply-templates select="../../@id"/><!-- preserve the figure id because xrefs -->
    <xsl:apply-templates select="@*"/>
    <xsl:if test="../../*[@data-type='title']">
      <xsl:attribute name="data-title">
        <xsl:value-of select="../../*[@data-type='title']"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="../../x:figcaption">
      <xsl:attribute name="title">
        <xsl:value-of select="../../x:figcaption"/>
      </xsl:attribute>
    </xsl:if>

<!--     <xsl:if test="../../*[data-type='title'] or ../../x:figcaption">
      <xsl:attribute name="title">
        <xsl:if test="../../*[data-type='title']">
          <xsl:text>[</xsl:text>
          <xsl:value-of select="../../*[data-type='title']"/>
          <xsl:text>] </xsl:text>
        </xsl:if>
        <xsl:value-of select="../../x:figcaption"/>
      </xsl:attribute>
    </xsl:if>
 -->

    <xsl:attribute name="data-z-for-sed"/>
  </xsl:copy>

  <!-- <xsl:value-of disable-output-escaping="yes" select="'&lt;/p&gt;'"/> -->

</xsl:template>


<xsl:template match="x:img/@data-media-type"/>


<xsl:template match="x:em/@data-effect|x:strong/@data-effect"/>
<xsl:template match="*[@data-type='solution']/@data-label"/>

<xsl:template match="*[@data-type='newline' and not(@effect)]">
  <br>
    <xsl:apply-templates select="@*"/>
  </br>
</xsl:template>

<xsl:template match="*[@data-type='newline' and not(@effect)]">
  <hr>
    <xsl:apply-templates select="@*"/>
  </hr>
</xsl:template>



<!-- Escape pipes and underscores because they have special meaning in kramdown -->
<xsl:template name="string-replace">
   <xsl:param name="text" />
   <xsl:param name="pattern" />
   <xsl:param name="replace-with" />
   <xsl:choose>
      <xsl:when test="contains($text, $pattern)">
         <xsl:value-of select="substring-before($text, $pattern)" />
         <xsl:value-of select="$replace-with" />
         <xsl:call-template name="string-replace">
            <xsl:with-param name="text" select="substring-after($text, $pattern)" />
            <xsl:with-param name="pattern" select="$pattern" />
            <xsl:with-param name="replace-with" select="$replace-with" />
         </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
         <xsl:value-of select="$text" />
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template match="text()">
  <xsl:variable name="original" select="."/>
  <xsl:variable name="pipes">
    <xsl:call-template name="string-replace">
      <xsl:with-param name="text" select="$original"/>
      <xsl:with-param name="pattern">|</xsl:with-param>
      <xsl:with-param name="replace-with">\|</xsl:with-param>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="underscores">
    <xsl:call-template name="string-replace">
      <xsl:with-param name="text" select="$pipes"/>
      <xsl:with-param name="pattern">_</xsl:with-param>
      <xsl:with-param name="replace-with">\_</xsl:with-param>
    </xsl:call-template>
  </xsl:variable>
  <!-- For liquid templates -->
  <xsl:variable name="double-curly">
    <xsl:call-template name="string-replace">
      <xsl:with-param name="text" select="$underscores"/>
      <xsl:with-param name="pattern">{{</xsl:with-param>
      <xsl:with-param name="replace-with">{ {</xsl:with-param>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="curly-percent">
    <xsl:call-template name="string-replace">
      <xsl:with-param name="text" select="$double-curly"/>
      <xsl:with-param name="pattern">{%</xsl:with-param>
      <xsl:with-param name="replace-with">{ %</xsl:with-param>
    </xsl:call-template>
  </xsl:variable>

  <xsl:value-of select="$curly-percent"/>
</xsl:template>

<xsl:template match="*[@data-type='footnote']">
  <span>
    <xsl:apply-templates select="@*|node()"/>
  </span>
</xsl:template>

</xsl:stylesheet>
