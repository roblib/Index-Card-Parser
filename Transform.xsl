<?xml version="1.0"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output omit-xml-declaration="no" indent="yes"/>

	<xsl:template match="/references">
		<xsl:choose>
			<xsl:when test="reference[2]">
				<modsCollection xmlns="http://www.loc.gov/mods/v3"
					xmlns:mods="http://www.loc.gov/mods/v3"
					xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
					xmlns:xlink="http://www.w3.org/1999/xlink">
					<xsl:apply-templates/>
				</modsCollection>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="reference">
		<mods xmlns="http://www.loc.gov/mods/v3" xmlns:mods="http://www.loc.gov/mods/v3"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xmlns:xlink="http://www.w3.org/1999/xlink">
			<xsl:apply-templates select="title"/>
			<xsl:apply-templates select="author"/>
			<xsl:apply-templates select="header"/>
			<xsl:apply-templates select="footer"/>

			<!-- Origin Info (Not part of Book) -->
			<xsl:if test="not(booktitle)">
				<xsl:choose>
					<xsl:when test="date[following-sibling::journal]">
						<originInfo>
							<dateIssued>
								<xsl:apply-templates select="location"/>
								<xsl:apply-templates select="publisher"/>
								<xsl:value-of select="date[following-sibling::journal]"/>
							</dateIssued>
						</originInfo>
					</xsl:when>
					<xsl:when test="date and not(journal)">
						<originInfo>
							<dateIssued>
								<xsl:apply-templates select="location"/>
								<xsl:apply-templates select="publisher"/>
								<xsl:value-of select="date"/>
							</dateIssued>
						</originInfo>
					</xsl:when>
					<xsl:when test="location | publisher">
						<xsl:apply-templates select="location"/>
						<xsl:apply-templates select="publisher"/>
					</xsl:when>
				</xsl:choose>
			</xsl:if>
			<!-- Related Item -->
			<xsl:if test="journal | booktitle">
				<relatedItem type="host">
					<titleInfo>
						<title>
							<xsl:value-of select="journal | booktitle"/>
						</title>
					</titleInfo>
					<!-- Origin Info (For Book) -->
					<xsl:if test="booktitle">
						<xsl:if test="location | publisher | date">
							<originInfo>
								<xsl:apply-templates select="location"/>
								<xsl:apply-templates select="publisher"/>
								<xsl:if test="date">
									<dateIssued>
										<xsl:value-of select="date"/>
									</dateIssued>
								</xsl:if>
							</originInfo>
						</xsl:if>
					</xsl:if>
					<!-- Part -->
					<xsl:if test="volume | pages | date">
						<part>
							<xsl:apply-templates select="volume"/>
							<xsl:apply-templates select="pages"/>
							<xsl:if test="date[preceding-sibling::journal]">
								<date>
									<xsl:value-of select="date[preceding-sibling::journal]"/>
								</date>
							</xsl:if>
						</part>
					</xsl:if>
				</relatedItem>
			</xsl:if>
		</mods>

	</xsl:template>

	<xsl:template match="author">
		<xsl:choose>
			<xsl:when test="contains(.,',')">
				<xsl:for-each select="tokenize(.,'and ')">
					<name xmlns="http://www.loc.gov/mods/v3" type="personal">
						<xsl:if test="contains(.,',')">
							<namePart type="family">
								<xsl:value-of select="substring-before(., ',')"/>
							</namePart>
							<namePart type="given">
								<xsl:value-of select="normalize-space(substring-after(., ','))"/>
							</namePart>
						</xsl:if>
						<role>
							<roleTerm authority="marcrelator" type="text">author</roleTerm>
						</role>
					</name>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<name xmlns="http://www.loc.gov/mods/v3" type="organization">
					<namePart>
						<xsl:value-of select="."/>
					</namePart>
					<role>
						<roleTerm authority="marcrelator" type="text">author</roleTerm>
					</role>
				</name>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="title">
		<titleInfo xmlns="http://www.loc.gov/mods/v3">
			<title>
				<xsl:value-of select="."/>
			</title>
		</titleInfo>
	</xsl:template>
	<xsl:template match="header">
		<xsl:if test="not(starts-with(.,'-'))">
			<subject xmlns="http://www.loc.gov/mods/v3">
				<topic>
					<xsl:value-of select="."/>
				</topic>
			</subject>
		</xsl:if>
	</xsl:template>
	<xsl:template match="footer">
		<location xmlns="http://www.loc.gov/mods/v3">
			<physicalLocation>Robertson Library</physicalLocation>
			<holdingSimple>
				<copyInformation>
					<shelfLocator>
						<xsl:value-of select="."/>
					</shelfLocator>
				</copyInformation>
			</holdingSimple>
		</location>
	</xsl:template>
	<xsl:template match="pages">
		<extent xmlns="http://www.loc.gov/mods/v3" unit="pages">
			<xsl:choose>
				<xsl:when test="contains(.,'-')">
					<start>
						<xsl:value-of select="normalize-space(substring-before(., '-'))"/>
					</start>
					<end>
						<xsl:value-of select="normalize-space(substring-after(., '-'))"/>
					</end>
				</xsl:when>
				<xsl:otherwise>
					<start>
						<xsl:value-of select="normalize-space(.)"/>
					</start>
					<end>
						<xsl:value-of select="normalize-space(.)"/>
					</end>
				</xsl:otherwise>
			</xsl:choose>
		</extent>
	</xsl:template>
	<xsl:template match="volume">
		<xsl:choose>
			<xsl:when test="contains(.,'(')">
				<detail xmlns="http://www.loc.gov/mods/v3" type="volume">
					<number>
						<xsl:value-of select="substring-before(., '(')"/>
					</number>
				</detail>
				<detail xmlns="http://www.loc.gov/mods/v3" type="issue">
					<number>
						<xsl:analyze-string select="." regex="\(([^)]+)\)">
							<xsl:matching-substring>
								<xsl:value-of select="regex-group(1)"/>
							</xsl:matching-substring>
						</xsl:analyze-string>
					</number>
				</detail>
			</xsl:when>
			<xsl:otherwise>
				<detail xmlns="http://www.loc.gov/mods/v3" type="volume">
					<number>
						<xsl:value-of select="normalize-space(.)"/>
					</number>
				</detail>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="location">
		<place xmlns="http://www.loc.gov/mods/v3">
			<placeTerm>
				<xsl:value-of select="."/>
			</placeTerm>
		</place>
	</xsl:template>
	<xsl:template match="publisher">
		<publisher xmlns="http://www.loc.gov/mods/v3">
			<xsl:value-of select="."/>
		</publisher>
	</xsl:template>
</xsl:stylesheet>
