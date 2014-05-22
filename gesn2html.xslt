<xsl:stylesheet version = '1.0'	
    xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
    xmlns:my="http://schemas.microsoft.com/office/infopath/2003/myXSD/2010-07-08T07:14:19"
 >

<xsl:output 
	method="html" 
        encoding="UTF-8"
	doctype-system="http://www.w3.org/TR/html4/strict.dtd" 
	doctype-public="-//W3C//DTD HTML 4.01//EN" 
	indent="yes" />

<!-- 
XSL преобразование для преобразования в html 
файла Infopath в котором вводились даные по ГЭСН
-->

<xsl:template match="/">
        <div id="hd">
            <xsl:apply-templates select="PPR"/>
        </div>
</xsl:template>
<xsl:template match="PPR">
        <div id="PPR">
            <xsl:apply-templates select="my:job"/>
        </div>
</xsl:template>


<xsl:template match = "my:job" >
    <div id="job">
        <xsl:value-of select="@my:strName"/>
        <xsl:value-of select="./my:Technics/my:Item_Technics"/>
    </div>
</xsl:template>


</xsl:stylesheet>