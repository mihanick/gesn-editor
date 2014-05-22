<xsl:stylesheet version = '1.0'
     xmlns:xsl='http://www.w3.org/1999/XSL/Transform'>

<xsl:output method="xml" encoding="utf-8" />

<xsl:template match = "jobs">
<jobs>
	<xsl:apply-templates />
</jobs>
</xsl:template>

<xsl:template match = "job">
	<job>

		<!-- По дефолту присваем всем работам стиль Заголовок -->
		<xsl:attribute name="nStyle">1</xsl:attribute>

		<!-- Работы, которые начинаются с Е, получают стиль Работа -->
		<xsl:if test="not(@sNumber='')">
			<xsl:attribute name="nStyle">2</xsl:attribute>
		</xsl:if>

		<!-- Если у работы нет потомков, то она получает стиль Состав работы -->
		<xsl:if test="count(./job)=0">
			<xsl:attribute name="nStyle">3</xsl:attribute>
		</xsl:if>

		<!-- Заполняем остальные атрибуты -->
		<xsl:attribute name="sName"> <xsl:value-of select="@sName" />	</xsl:attribute>
		<xsl:attribute name="sNormaCS"> <xsl:value-of select="@sNormaCS" />	</xsl:attribute>
		<xsl:attribute name="sNormaCSLnk"> <xsl:value-of select="@sNormaCSLnk" />	</xsl:attribute>
		<xsl:attribute name="sENIR"> <xsl:value-of select="@sNumber" />	</xsl:attribute>
		<xsl:attribute name="sUnit"> <xsl:value-of select="@sUnit" />	</xsl:attribute>
	
		
		<xsl:apply-templates />
	</job>
</xsl:template>



</xsl:stylesheet>

