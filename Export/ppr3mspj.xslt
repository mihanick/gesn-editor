<xsl:stylesheet version = "2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
>

<!-- 
 	(с)Магма-Компьютер, Омск, 2010.
	Данный xslt-файл преобразования xml проекта из Стройплощадка 3.0 в xml-файл, читаемый Microsoft Project.
	Преобразует вложенную структуру работ проекта в перечень позиций для локальной сметы.
	Из стройплощадки транслируются перечень разделов, работ и заголовков с единицами измерения и количеством,
	а также назначенная на работу техника и ее количество на единицу измерения работы, персонал и материалы
	в соответствии с текущей расценкой на работу
	
	
	Что делает преобразование:
	Пробегает по оси project\prjType\JobsTable
	Выбирает все узлы в которых prop@name='Job'
	Преобразует узлы в те имена, которые читает гранд-смета
	По ID текущей расценки (prjActiveRateID) находит Технику (по типу \\node\prop[@name=node-type]='Technics'
	Персонал ,
	Материалы ,
	и включает их в список ресурсов на текущую работу.
-->




<xsl:output method="xml" encoding="utf-8" indent="yes"/>

<xsl:template match = "root">
	<!-- Ищем в корне project-->
        <xsl:apply-templates select="project"/>
</xsl:template>


<xsl:template match = "project">
	<xsl:apply-templates select="node[@Name='PPR']" mode="prjType"/>
</xsl:template>

<xsl:template match="node" mode ="prjType">
	<xsl:variable name="job-node-type" select="prop[@name='node-type']"/>       <!-- Тип узла-->	

	<!-- Первый уровень вложенности: тип узла == prjType-->
	<xsl:if test="$job-node-type='prjType'">
		<!--
			Спецификация формата msProject xml 2007
			http://msdn.microsoft.com/en-us/library/bb968652.aspx
		-->
	
		<Project>
			<Name>Проекта Стройплощадка 3.0</Name>
			<NewTasksAreManual>1</NewTasksAreManual>
			<ProjectExternallyEdited>1</ProjectExternallyEdited>
			<NewTaskStartDate>0</NewTaskStartDate>
			<StartDate>2011-02-01T09:00:00</StartDate>

			<xsl:apply-templates select="node" mode="prjType"/>

			<Assignments>
				<xsl:apply-templates select="//node[./prop[@name='node-type']='DBTechLink']" mode="assignment"/>
			</Assignments>
		</Project>
		
	</xsl:if>
	<!-- Второй уровень вложенности: тип узла == JobsTable-->
	<xsl:if test="$job-node-type='JobsTable'">
		<Tasks>
		<xsl:apply-templates select="node[./prop[@name='node-type']='Job']" mode="Task">
			<!--Здесь и далее применение шаблонов сортируется по оси Position, т.к. в исходной xml-ке они
			    могут идти как попало-->
		        <xsl:sort select="current()/prop[@name='Position']" data-type="number" order="ascending"/>
		</xsl:apply-templates>
		</Tasks>
	</xsl:if>
	<!-- Второй уровень вложенности: тип узла == DBTechnicsTable-->
	<xsl:if test="$job-node-type='DBTechnicsTable'">
		<Resources>
		<xsl:apply-templates select="node[./prop[@name='node-type']='DBTechnics']" mode="technics"/>
		</Resources>
	</xsl:if>

</xsl:template>


<xsl:template match = "node" mode="Task">

	<!-- Преобразуем дочерние узлы выбранного узла в текущие переменные:-->
	<xsl:variable name="job-node-type" select="prop[@name='node-type']"/>       <!-- Тип узла-->	
	<xsl:variable name="job-style"     select="prop[@name='Style']"/>	    <!-- Стиль работы-->	
	<xsl:variable name="job-number"    select="prop[@name='Path']"/>	    <!-- Путь (номер) работы-->	
	<xsl:variable name="job-unit"      select="prop[@name='Unit']"/>	    <!-- Ед.изм. работы-->	
	<xsl:variable name="job-volume"    select="prop[@name='Volume']"/>	    <!-- Объем работы-->	
	<xsl:variable name="job-contents"  select="prop[@name='Contents']"/>        <!-- Состав работы-->	
	<xsl:variable name="job-rate-id"   select="prop[@name='prjActiveRateID']"/> <!-- ID Текущей расценки на работе-->
	

	<!-- Последующие уровни вложенности: тип узла == Job-->
	<xsl:if test="$job-node-type='Job'">

		<Task>
			<Name><xsl:value-of select="@Name"/></Name> <!--Наименование работы-->
			<UID><xsl:value-of select="prop[@name='prjID']"/></UID> <!--Уникальный идентификатор-->
			<ID><xsl:value-of select="prop[@name='Position']"/></ID> <!--Номер позиции в разделе-->
			<Active>1</Active>
			<IsNull>0</IsNull>
			<OutlineLevel><xsl:value-of select="count(ancestor::*)-3"/></OutlineLevel> <!-- Уровень вложенности-->

			<!--Пример преобразованя дат из C++ time64_t в нормальный формат http://www.dpawson.co.uk/xsl/rev2/dates.html-->
			<xsl:variable name="start-date" select="prop[@name='Period1S']"/>
			<xsl:variable name="normalized-start-date" select="xs:dateTime('1970-01-01T00:00:00') + $start-date * xs:dayTimeDuration('PT1S')"/> 

			<xsl:variable name="finish-date" select="prop[@name='Period1E']"/>
			<xsl:variable name="normalized-finish-date" select="xs:dateTime('1970-01-01T00:00:00') + $finish-date * xs:dayTimeDuration('PT1S')"/> 

			<xsl:variable name="calculated-duration" select="($finish-date - $start-date) * xs:dayTimeDuration('P0DT0H0M01S')"/> 
			<xsl:variable name="msproject-style-calculated-duration" select="concat('P','T',24*days-from-duration($calculated-duration)+hours-from-duration($calculated-duration),'H',minutes-from-duration($calculated-duration),'M',seconds-from-duration($calculated-duration),'S')"/>

                        <ConstraintType>4</ConstraintType>
			<ConstraintDate><xsl:value-of select="$normalized-start-date"/></ConstraintDate>
			<Duration><xsl:value-of select="$msproject-style-calculated-duration"/></Duration>
			<DurationFormat>37<!--Estimated hours--></DurationFormat>

			<Start><xsl:value-of select="$normalized-start-date"/></Start>
			<Finish><xsl:value-of select="$normalized-finish-date"/></Finish>

		</Task>	
		<xsl:apply-templates select="node[./prop[@name='node-type']='Job']" mode="Task">
			<xsl:sort select="current()/prop[@name='Position']" data-type="number" order="ascending"/>
		</xsl:apply-templates>
	</xsl:if>
</xsl:template>

<xsl:template match = "node" mode="technics">
	<Resource>
		<UID><xsl:value-of select="prop[@name='prjID']"/></UID> 
		<Name><xsl:value-of select="@Name"/></Name>
		<Type>1</Type> <!-- 0 -Material (consumable supplies like steel, concrete, or soil), 1 - Work (people and equipment), 2 - Cost resource -->
		<Initials><xsl:value-of select="prop[@name='Type']"/></Initials>
		<Code><xsl:value-of select="prop[@name='SideNumber']"/></Code>
		<MaterialLabel><xsl:value-of select="prop[@name='Unit']"/></MaterialLabel>
		<Group>Техника</Group>
	</Resource>
</xsl:template>

<xsl:template match="node" mode="assignment">
	<Assignment>
		<UID><xsl:value-of select="prop[@name='prjID']"/></UID>
		<TaskUID><xsl:value-of select="../prop[@name='prjID']"/></TaskUID>

		<Units><xsl:value-of select="./prop[@name='Value']"/></Units>
		<xsl:call-template name="find-resource-id">
			<xsl:with-param name="link" select="@link">
			</xsl:with-param>
		</xsl:call-template>

		<xsl:variable name="start-date" select="prop[@name='Period1S']"/>
		<xsl:variable name="normalized-start-date" select="xs:dateTime('1970-01-01T00:00:00') + $start-date * xs:dayTimeDuration('PT1S')"/> 

		<xsl:variable name="finish-date" select="prop[@name='Period1E']"/>
		<xsl:variable name="normalized-finish-date" select="xs:dateTime('1970-01-01T00:00:00') + $finish-date * xs:dayTimeDuration('PT1S')"/> 
		<Start><xsl:value-of select="$normalized-start-date"/></Start>
		<Finish><xsl:value-of select="$normalized-finish-date"/></Finish>

	</Assignment>
</xsl:template>

<xsl:template name="find-resource-id">
	<xsl:param name="link" select="."/>
	<xsl:apply-templates select="//node[@Id=$link]" mode="resource-id"/>	
</xsl:template>

<xsl:template match="node" mode="resource-id">
	<ResourceUID>
		<xsl:value-of select="prop[@name='prjID']"/>
	</ResourceUID>
</xsl:template>

</xsl:stylesheet>

        			
