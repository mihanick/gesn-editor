<xsl:stylesheet version = '2.0'
	xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
>

<!-- 
 	(с)Магма-Компьютер, Омск, 2010.
	Данный xslt-файл преобразования xml проекта из Стройплощадка 3.0 в xml-файл, читаемый Гранд-Смета.
	Преобразует вложенную структуру работ проекта в перечень позиций для локальной сметы.
	Из стройплощадки транслируются перечень разделов, работ и заголовков с единицами измерения и количеством,
	а также назначенная на работу техника и ее количество на единицу измерения работы, персонал и материалы
	в соответствии с текущей расценкой на работу
	
	Работы проекта со стилем Раздел - становятся разделами сметы.
	Работы проекта со стилем Заголовок становятся заголовками. (заголовки в гранд-смете не включают работы 
	(как в стройплощадке), поэтому при преобразовании этим файлом они будут попадать в том же уровне, что и перечень работ, которые в них входит.
	
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
	<xsl:apply-templates select="node[@Name='PPR']"/>
</xsl:template>



<xsl:template match = "node">

	<!-- Преобразуем дочерние узлы выбранного узла в текущие переменные:-->
	<xsl:variable name="job-node-type" select="prop[@name='node-type']"/>       <!-- Тип узла-->	
	<xsl:variable name="job-style"     select="prop[@name='Style']"/>	    <!-- Стиль работы-->	
	<xsl:variable name="job-number"    select="prop[@name='Path']"/>	    <!-- Путь (номер) работы-->	
	<xsl:variable name="job-unit"      select="prop[@name='Unit']"/>	    <!-- Ед.изм. работы-->	
	<xsl:variable name="job-volume"    select="prop[@name='Volume']"/>	    <!-- Объем работы-->	
	<xsl:variable name="job-contents"  select="prop[@name='Contents']"/>        <!-- Состав работы-->	
	<xsl:variable name="job-rate-id"   select="prop[@name='prjActiveRateID']"/> <!-- ID Текущей расценки на работе-->
	
	<!-- Первый уровень вложенности: тип узла == prjType-->
	<xsl:if test="$job-node-type='prjType'">
		<!-- Эти заголовки нужны чтобы xml мог быть прочитан GrandSmeta -->
		<Document Generator="GrandSmeta">
			<xsl:attribute name="DocumentType">{2B0470FD-477C-4359-9F34-EEBE36B7D340}</xsl:attribute>
		<Chapters>
			<xsl:apply-templates select="node">
				<xsl:sort select="current()/prop[@name='Position']" data-type="number" order="ascending"/>
			</xsl:apply-templates>
		</Chapters>
		</Document>

	</xsl:if>

	<!-- Второй уровень вложенности: тип узла == JobsTable-->
	<xsl:if test="$job-node-type='JobsTable'">
		<!-- В первом уровне GrandSmeta разрешены только Chapter-->
		<xsl:apply-templates select="node[./prop[@name='Style']=0]">
			<!--Здесь и далее применение шаблонов сортируется по оси Position, т.к. в исходной xml-ке они
			    могут идти как попало-->
			<xsl:sort select="current()/prop[@name='Position']" data-type="number" order="ascending"/>
		</xsl:apply-templates>
	</xsl:if>

	<!-- Последующие уровни вложенности: тип узла == Job-->
	<xsl:if test="$job-node-type='Job'">
		<!-- Стиль работы == "Раздел" -->	
		<xsl:if test="$job-style=0">
			<Chapter>
				<!-- В GrandSmeta выводим наименование вместе с номером-->
				<xsl:attribute name="Caption"><xsl:value-of select="$job-number"/>. <xsl:value-of select="@Name"/></xsl:attribute>
				<xsl:apply-templates select="node">
					<xsl:sort select="current()/prop[@name='Position']" data-type="number" order="ascending"/>
				</xsl:apply-templates>
			</Chapter>
		</xsl:if>
                <!-- Стиль работы == "Заголовок" -->	
		<xsl:if test="$job-style=1">
			<Header>
				<!-- В GrandSmeta выводим наименование вместе с номером-->
				<xsl:attribute name="Caption"><xsl:value-of select="$job-number"/>. <xsl:value-of select="@Name"/></xsl:attribute>
			</Header>
			<!-- GrandSmeta не позволяет теги Position внутри Header-->	
			<xsl:apply-templates select="node">
				<xsl:sort select="current()/prop[@name='Position']" data-type="number" order="ascending"/>
			</xsl:apply-templates>
		</xsl:if>
		<!-- Стиль работы == "Позиция" -->
      	 	<xsl:if test="$job-style=2">
			<Position>
				<xsl:attribute name="Caption" ><xsl:value-of select="@Name"/></xsl:attribute>       <!--Наименование-->
				<xsl:attribute name="Number"  ><xsl:value-of select="$job-number"/></xsl:attribute> <!--Номер-->
				<xsl:attribute name="Quantity"><xsl:value-of select="$job-volume"/></xsl:attribute> <!--Объем-->
				<xsl:attribute name="Units"   ><xsl:value-of select="$job-unit"/></xsl:attribute>   <!--Ед.изм.-->
				
                                <!--Перечень работ-->
				<WorksList>
					<!--Если заполнен состав работ, то он будет выведен-->
					<xsl:if test="not($job-contents='')">			        	  
						<xsl:value-of select="$job-contents"/>
					</xsl:if>
					<!--Если есть еще работы со стилем Состав работы - то они также будут выведены -->
					<xsl:apply-templates select="node">
						<xsl:sort select="current()/prop[@name='Position']" data-type="number" order="ascending"/>
					</xsl:apply-templates>
				</WorksList>
				<!--Ресурсы, назначенные на работу-->
				<Resources>
					<!--    Находим все узлы (//node) с типом Technics для 
						которых prjRateID==prjActiveRateID(текущей работы)

						Запись означает:
						//node[       - вообще все узлы node в xml
							(./prop[  - у которых есть потомок prop
								(@name='prjRateID') - c атрибутом @name=="prjRateID" 
								and(.=$job-rate-id) - и значением потомка равным $job-rate-id (ID текущей расценки текущей работы)
							])
							and
							(./prop[ - а также есть потомок prop 
								(@name='node-type') - c атрибутом @name=="node-type"
								and(.='Technics')]  - и значением этого потомка =="Technics"
							)
						       ]
					-->
					<xsl:for-each select="//node[(./prop[(@name='prjRateID')and(.=$job-rate-id)])and(./prop[(@name='node-type')and(.='Technics')])]">
						<Mch>
						   <!--Заполняем атрибуты техники: Наимерование, ед.изм., кол-во, код-->
					           <xsl:attribute name="Caption"><xsl:value-of select="@Name"/></xsl:attribute>
						   <xsl:attribute name="Units"><xsl:value-of select="prop[@name='Unit']"/></xsl:attribute>
						   <xsl:attribute name="Quantity"><xsl:value-of select="prop[@name='Value']"/></xsl:attribute>
						   <xsl:attribute name="Code"><xsl:value-of select="prop[@name='Code']"/></xsl:attribute>
						</Mch>
					</xsl:for-each>

					<!--    Находим все узлы (//node) с типом Personal для 
						которых prjRateID==prjActiveRateID(текущей работы)
					-->

					<xsl:for-each select="//node[(./prop[(@name='prjRateID')and(.=$job-rate-id)])and(./prop[(@name='node-type')and(.='Personal')])]">
						<!--Весь персонал будет попадать в трудозатраты рабочих-->
						<Tzr>
						   <!--Заполняем атрибуты персонала: Наимерование, ед.изм., кол-во, код-->

					           <xsl:attribute name="Caption"><xsl:value-of select="@Name"/></xsl:attribute>
						   <xsl:attribute name="Units"><xsl:value-of select="prop[@name='Unit']"/></xsl:attribute>
						   <xsl:attribute name="Quantity"><xsl:value-of select="prop[@name='Value']"/></xsl:attribute>
						   <xsl:attribute name="Code"><xsl:value-of select="prop[@name='Code']"/></xsl:attribute>
						</Tzr>
					</xsl:for-each>

					<!-- NB: Трудозатраты машинистов, пока не выводятся-->
					<Tzm/>

					<!--    Находим все узлы (//node) с типом Material для 
						которых prjRateID==prjActiveRateID(текущей работы)
					-->
					<xsl:for-each select="//node[(./prop[(@name='prjRateID')and(.=$job-rate-id)])and(./prop[(@name='node-type')and(.='Material')])]">
						<Mat>
						   <!--Заполняем атрибуты материала: Наимерование, ед.изм., кол-во, код-->	
					           <xsl:attribute name="Caption"><xsl:value-of select="@Name"/></xsl:attribute>
						   <xsl:attribute name="Units"><xsl:value-of select="prop[@name='Unit']"/></xsl:attribute>
						   <xsl:attribute name="Quantity"><xsl:value-of select="prop[@name='Value']"/></xsl:attribute>
						   <xsl:attribute name="Code"><xsl:value-of select="prop[@name='Code']"/></xsl:attribute>
						</Mat>
					</xsl:for-each>
				</Resources>
			</Position>
		</xsl:if>
		<!-- Стиль работы == "Состав работы" (для ЕНИР) -->
		<xsl:if test="$job-style=3">
			<Work>
				<xsl:attribute name="Caption"><xsl:value-of select="@Name"/></xsl:attribute>
			</Work>
		</xsl:if >
	</xsl:if>
</xsl:template>
</xsl:stylesheet>

