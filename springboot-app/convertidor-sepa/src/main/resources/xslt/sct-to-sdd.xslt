<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:sct="urn:iso:std:iso:20022:tech:xsd:pain.001.001.03"
    xmlns:sdd="urn:iso:std:iso:20022:tech:xsd:pain.008.001.02"
    exclude-result-prefixes="sct">

    <xsl:output method="xml" encoding="UTF-8" indent="yes" />

    <xsl:template match="/">
        <sdd:Document>
            <sdd:DrctDbtInitn>
                <!-- Copiar GrpHdr -->
                <xsl:for-each select="//sct:GrpHdr">
                    <sdd:GrpHdr>
                        <sdd:MsgId><xsl:value-of select="sct:MsgId"/></sdd:MsgId>
                        <sdd:CreDtTm><xsl:value-of select="sct:CreDtTm"/></sdd:CreDtTm>
                        <sdd:NbOfTxs><xsl:value-of select="sct:NbOfTxs"/></sdd:NbOfTxs>
                        <sdd:CtrlSum><xsl:value-of select="sct:CtrlSum"/></sdd:CtrlSum>
                        <sdd:InitgPty>
                            <sdd:Nm><xsl:value-of select="sct:InitgPty/sct:Nm"/></sdd:Nm>
                        </sdd:InitgPty>
                    </sdd:GrpHdr>
                </xsl:for-each>

                <xsl:for-each select="//sct:PmtInf">
                    <sdd:PmtInf>
                        <sdd:PmtInfId><xsl:value-of select="sct:PmtInfId"/></sdd:PmtInfId>
                        <sdd:PmtMtd>DD</sdd:PmtMtd>
                        <sdd:NbOfTxs><xsl:value-of select="sct:NbOfTxs"/></sdd:NbOfTxs>
                        <sdd:CtrlSum><xsl:value-of select="sct:CtrlSum"/></sdd:CtrlSum>
                        <sdd:Dbtr>
                            <sdd:Nm><xsl:value-of select="sct:Dbtr/sct:Nm"/></sdd:Nm>
                        </sdd:Dbtr>
                        <sdd:DbtrAcct>
                            <sdd:Id>
                                <sdd:IBAN><xsl:value-of select="sct:DbtrAcct/sct:Id/sct:IBAN"/></sdd:IBAN>
                            </sdd:Id>
                        </sdd:DbtrAcct>

                        <xsl:for-each select="sct:CdtTrfTxInf">
                            <sdd:DrctDbtTxInf>
                                <sdd:PmtId>
                                    <sdd:EndToEndId><xsl:value-of select="sct:PmtId/sct:EndToEndId"/></sdd:EndToEndId>
                                </sdd:PmtId>
                                <sdd:InstdAmt Ccy="EUR"><xsl:value-of select="sct:Amt/sct:InstdAmt"/></sdd:InstdAmt>
                                <sdd:Cdtr>
                                    <sdd:Nm><xsl:value-of select="sct:Cdtr/sct:Nm"/></sdd:Nm>
                                </sdd:Cdtr>
                                <sdd:CdtrAcct>
                                    <sdd:Id>
                                        <sdd:IBAN><xsl:value-of select="sct:CdtrAcct/sct:Id/sct:IBAN"/></sdd:IBAN>
                                    </sdd:Id>
                                </sdd:CdtrAcct>
                            </sdd:DrctDbtTxInf>
                        </xsl:for-each>

                    </sdd:PmtInf>
                </xsl:for-each>
            </sdd:DrctDbtInitn>
        </sdd:Document>
    </xsl:template>

</xsl:stylesheet>
