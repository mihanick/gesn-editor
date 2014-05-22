
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
XSL преобразование для преобразования в файл, читаемый Infopath
данных php формы
-->
<!--
The structure to obtain
PPR 
my:job
    ...
    my:job @my:strName etc.
        my:Rates
            my:Rate @RateName etc.
            ...
            my:Rate
                my:RatesTechnics
                    my:RateTechnics @RateTechnicsName etc.
                    ...
                my:RatesPersonal
                    my:RatePersonal @RatePersonalName etc.
                    ...
                my:RatesMaterial
                    my:RateMaterial @RateMaterialName etc.
                    ...
             ..

-->


    <xsl:template match="/">
        <xsl:apply-templates select="ppr"/>
    </xsl:template>

    <xsl:template match="ppr">
        <PPR>
            <xsl:apply-templates select="div[@class='job']"/>
        </PPR>
    </xsl:template>

    <xsl:template match="div">
        
        <xsl:element name="{concat('my:',@class)}">
        
            <xsl:apply-templates select="att"/>
        
            <xsl:apply-templates select="div"/>
            
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="att">
            <xsl:variable name="attName" select="concat('my:',@name)"/>
            <xsl:attribute name="{$attName}">
                <xsl:value-of select="."/>
            </xsl:attribute>
        
    </xsl:template>
</xsl:stylesheet>
