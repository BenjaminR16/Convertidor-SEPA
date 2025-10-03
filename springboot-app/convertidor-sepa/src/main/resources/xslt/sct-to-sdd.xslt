<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:pain="urn:iso:std:iso:20022:tech:xsd:pain.001.001.03">

    <xsl:output method="xml" indent="yes"/>

    <!-- Transformación trivial SCT → SDD -->
    <xsl:template match="/">
        <Document xmlns="urn:iso:std:iso:20022:tech:xsd:pain.008.001.02">
            <xsl:copy-of select="pain:CstmrCdtTrfInitn"/>
        </Document>
    </xsl:template>

</xsl:stylesheet>
