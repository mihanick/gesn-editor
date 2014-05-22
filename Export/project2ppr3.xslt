<xsl:stylesheet version = '2.0'
	xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
        xmlns:project="http://schemas.microsoft.com/project"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
>
<xsl:output 
	method="xml" 
        encoding="utf-8"
	indent="yes" />


<xsl:template match = "/">
	<root>
		<xsl:attribute name="prj_version">2</xsl:attribute>
	<Project>
		<xsl:call-template name="generate-id"/>
		<xsl:apply-templates select="project:Project"/>
	</Project>
	</root>
</xsl:template>

<xsl:template match="project:Project">
	<node>
		<xsl:call-template name="generate-id"/>
		<xsl:attribute name="Name">PPR</xsl:attribute>
		<xsl:attribute name="obj_adapter">{CE850616-743C-42C6-A94D-CD0DAA4D6B39}</xsl:attribute>
		<xsl:apply-templates select="project:Tasks"/>


	</node>
</xsl:template>

<xsl:template match="project:Tasks">
	<node>
		<xsl:call-template name="generate-id"/>
		<prop name="node-type">JobsTable</prop>
		<xsl:call-template name="recursive-task-search">
			<xsl:with-param name="level" select="0"/>
			<xsl:with-param name="till-id" select="100000"/>
		</xsl:call-template>
	</node>
</xsl:template>

<xsl:template name="recursive-task-search">
	<xsl:param name="level" select="."/>
	<xsl:param name="till-id" select="."/>

	

	<xsl:for-each select="//project:Task[./project:OutlineLevel=$level]">
	        <xsl:variable name="next-same-level-id">
			<!--xsl:apply-templates select="following-sibling::project:Task[./project:OutlineLevel=$level]" mode="find-id-of-first"/-->
			<xsl:variable name="pos" select="position()"/>
                	<xsl:value-of select="following-sibling::project:Task[$pos]/project:ID"/>
		</xsl:variable>
                
		
		<node>
			<xsl:call-template name="task-attributes-1"/>
       		<debug>current position: <xsl:value-of select="./project:ID"/> next id:<xsl:value-of select="$till-id"/></debug>
                <xsl:if test="number(./project:ID) &lt;= number($till-id)">			
			<xsl:call-template name="recursive-task-search">
				<xsl:with-param name="level" select="$level+1"/>
				<xsl:with-param name="till-id" select="$next-same-level-id"/>
			</xsl:call-template>

		</xsl:if>

		</node>
		
	</xsl:for-each>

</xsl:template>

<xsl:template match="project:Task" mode="find-id-of-first">
	<xsl:if test="position()=1">
		<xsl:variable name="result"><xsl:value-of select="./project:ID"/></xsl:variable>
		<xsl:value-of select="$result"/>
	</xsl:if>
</xsl:template>

<xsl:template name = "task-attributes-1">
		<Name><xsl:value-of select="project:Name"/></Name>
</xsl:template>


<xsl:template name = "task-attributes">
	
		<xsl:call-template name="generate-id"/>
		<xsl:attribute name="Name"><xsl:value-of select="project:Name"/></xsl:attribute>
		<prop name="node-type">Job</prop>
		<prop name="Position"><xsl:value-of select="project:ID"/></prop>
                <prop name="prjID" type="int"><xsl:value-of select="project:UID"/></prop>

		<prop name="Period1S" type="i64">
			<xsl:call-template name="convertDate"><xsl:with-param name="xsDate" select="project:Start"/></xsl:call-template>
		</prop>
        	<prop name="Period1E" type="i64">
			<xsl:call-template name="convertDate"><xsl:with-param name="xsDate" select="project:Finish"/></xsl:call-template>
		</prop>
		
                <prop name="Style" type="int">0</prop>
</xsl:template>

<xsl:template name="generate-id">
        <!-- Шаблон функции назначения Id узлу-->	
	<xsl:attribute name="Id"><xsl:value-of select="concat('{',generate-id(.),'}')"/></xsl:attribute>
</xsl:template>

<xsl:template name="convertDate">
	<!-- Шаблон функции преобразования длительности из xsDate в С++-->
	<xsl:param name="xsDate" select="."/>
	
	<xsl:variable name="seconds" select="fn:seconds-from-duration((xs:dateTime($xsDate) -xs:dateTime('1970-01-01T00:00:00')))"/> 
	<xsl:variable name="minutes" select="fn:minutes-from-duration((xs:dateTime($xsDate) -xs:dateTime('1970-01-01T00:00:00')))"/> 
	<xsl:variable name="hours"   select="fn:hours-from-duration((xs:dateTime($xsDate) -xs:dateTime('1970-01-01T00:00:00')))"/> 
	<xsl:variable name="days"    select="fn:days-from-duration((xs:dateTime($xsDate) -xs:dateTime('1970-01-01T00:00:00')))"/> 
	<xsl:variable name="months"  select="fn:months-from-duration((xs:dateTime($xsDate) -xs:dateTime('1970-01-01T00:00:00')))"/> 
	<xsl:variable name="years"   select="fn:years-from-duration((xs:dateTime($xsDate) -xs:dateTime('1970-01-01T00:00:00')))"/> 

	<xsl:value-of select="60*(60*(24*(30*(12*$years+$months)+$days)+$hours)+$minutes)+$seconds"/>
</xsl:template>

</xsl:stylesheet>
                  