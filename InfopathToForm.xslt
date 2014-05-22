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
XSL преобразование для преобразования в xml 
файла Infopath в котором вводились даные по ГЭСН
-->

<!--
The structure we want to obtain
ppr 
    job @id @class='job'
        att[strName etc.]
        ...
        job
            Rates
                Rate @id @class='Rate'
                    att[RateName etc.]
                    RatesTechnics
                        RateTechnics
                            att [RateTechnicsName etc.]
                    RatesPersonal
                        RatePersonal
                            att [RatePersonalName etc.]
                    RatesMaterial
                        RateMaterial
                            att [RateMaterialName etc.]
                ...
                Rate
                ...
-->

<xsl:template match="/">
            <xsl:apply-templates select="PPR"/>
</xsl:template>
<xsl:template match="PPR">
        <div class="ppr">
            <xsl:apply-templates select="my:job"/>
        </div>
</xsl:template>


<xsl:template match = "my:job" >
    <div class="job">
            <xsl:attribute name="id"><xsl:value-of select="generate-id()"/></xsl:attribute>
            <att name="strName">     <xsl:value-of select="@my:strName"/>     </att> 
            <att name="strUnit">     <xsl:value-of select="@my:strUnit"/>     </att>
            <att name="strComment">  <xsl:value-of select="@my:strComment"/>  </att>
            <att name="nStyle" >     <xsl:value-of select="@my:nStyle"/>      </att>
            <att name="strURL" >     <xsl:value-of select="@my:strURL"/>      </att>            
            <att name="strENIR" >    <xsl:value-of select="@my:strENIR"/>     </att>            
            <att name="JobContents"> <xsl:value-of select="@my:JobContents"/> </att>   
            
        <xsl:apply-templates select="my:Rates"/>
        <xsl:apply-templates select="my:job"/>
      </div>
      
</xsl:template>


<xsl:template match="my:Rates">
    <div class="Rates">
        <xsl:apply-templates select="my:Rate"/>
    </div>
</xsl:template>

<xsl:template match="my:Rate">
    <div class="Rate">
        <!--Generating unique id for divs-->
        <xsl:attribute name="id"><xsl:value-of select="generate-id()"/></xsl:attribute>
        
        <att name="RateName">     <xsl:value-of select="@my:RateName"/>     </att>
        <att name="RateCode">     <xsl:value-of select="@my:RateCode"/>     </att>
        <att name="RateComment">  <xsl:value-of select="@my:RateComment"/>  </att>
        <att name="RateMeasure">  <xsl:value-of select="@my:RateMeasure"/>  </att>

        <xsl:apply-templates select="my:RateTechnics"/>
        <xsl:apply-templates select="my:RatePersonal"/>
        <xsl:apply-templates select="my:RateMaterial"/>
        
    </div>
</xsl:template>

<xsl:template match="my:RateTechnics">
    <div class="RateTechnics">
        <xsl:attribute name="id"><xsl:value-of select="generate-id()"/></xsl:attribute>
       <att name="RateTechnicsName" ><xsl:value-of select="@my:RateTechnicsName"/></att>
       <att name="RateTechnisCode" ><xsl:value-of select="@my:RateTechnisCode"/></att>
       <att name="RateTechnicsUnit" ><xsl:value-of select="@my:RateTechnicsUnit"/></att>
       <att name="RateTechnicsValue" ><xsl:value-of select="@my:RateTechnicsValue"/></att>
       <att name="RateTechnicsComment" ><xsl:value-of select="@my:RateTechnicsComment"/></att>
       <att name="RateTechnicsTime" ><xsl:value-of select="@my:RateTechnicsTime"/></att>
    </div>
</xsl:template>

<xsl:template match="my:RatePersonal">
    <div class="RatePersonal">
       <xsl:attribute name="id"><xsl:value-of select="generate-id()"/></xsl:attribute>
       <att name="RatePersonalName" ><xsl:value-of select="@my:RatePersonalName"/></att>
       <att name="RatePersonalCode" ><xsl:value-of select="@my:RatePersonalCode"/></att>
       <att name="RatePersonalUnit" ><xsl:value-of select="@my:RatePersonalUnit"/></att>
       <att name="RatePersonalValue" ><xsl:value-of select="@my:RatePersonalValue"/></att>
       <att name="RatePersonalRank" ><xsl:value-of select="@my:RatePersonalRank"/></att>
       <att name="RatePersonalComment" ><xsl:value-of select="@my:RatePersonalComment"/></att>
       <att name="RatePersonalTime" ><xsl:value-of select="@my:RatePersonalTime"/></att>
    </div>
</xsl:template>

<xsl:template match="my:RateMaterial">
    <div class="RateMaterial">
       <xsl:attribute name="id"><xsl:value-of select="generate-id()"/></xsl:attribute>
       <att name="RateMaterialName" ><xsl:value-of select="@my:RateMaterialName"/></att>
       <att name="RateMaterialCode" ><xsl:value-of select="@my:RateMaterialCode"/></att>
       <att name="RateMaterialUnit" ><xsl:value-of select="@my:RateMaterialUnit"/></att>
       <att name="RateMaterialValue" ><xsl:value-of select="@my:RateMaterialValue"/></att>
       <att name="RateMaterialComment" ><xsl:value-of select="@my:RateMaterialComment"/></att>
    </div>
    
</xsl:template>


</xsl:stylesheet>
