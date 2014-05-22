<xsl:stylesheet version = '2.0'	
    xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
    xmlns:my="http://schemas.microsoft.com/office/infopath/2003/myXSD/2010-07-08T07:14:19"
 >

<xsl:output 
	method="xml" 
        encoding="UTF-8"
	indent="yes" />

<!-- 
xsl преобразование для причесывания xml
-->
<xsl:template match="/">

  <xsl:apply-templates/>


</xsl:template>

<xsl:template match="*">
	<xsl:copy-of select=".">
	</xsl:copy-of>
</xsl:template>

</xsl:stylesheet>
