<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:sct="urn:iso:std:iso:20022:tech:xsd:pain.001.001.03"
    xmlns:sdd="urn:iso:std:iso:20022:tech:xsd:pain.008.001.02"
    exclude-result-prefixes="sdd">

    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="/">
        <sct:Document>
            <sct:CstmrCdtTrfInitn>
                <xsl:for-each select="//sdd:GrpHdr">
                    <sct:GrpHdr>
                        <sct:MsgId><xsl:value-of select="sdd:MsgId"/></sct:MsgId>
                        <sct:CreDtTm><xsl:value-of select="sdd:CreDtTm"/></sct:CreDtTm>
                        <sct:NbOfTxs><xsl:value-of select="sdd:NbOfTxs"/></sct:NbOfTxs>
                        <sct:CtrlSum><xsl:value-of select="sdd:CtrlSum"/></sct:CtrlSum>
                        <sct:InitgPty>
                            <sct:Nm><xsl:value-of select="sdd:InitgPty/sdd:Nm"/></sct:Nm>
                        </sct:InitgPty>
                    </sct:GrpHdr>
                </xsl:for-each>

                <xsl:for-each select="//sdd:PmtInf">
                    <sct:PmtInf>
                        <sct:PmtInfId><xsl:value-of select="sdd:PmtInfId"/></sct:PmtInfId>
                        <sct:PmtMtd>TRF</sct:PmtMtd>
                        <sct:NbOfTxs><xsl:value-of select="sdd:NbOfTxs"/></sct:NbOfTxs>
                        <sct:CtrlSum><xsl:value-of select="sdd:CtrlSum"/></sct:CtrlSum>
                        <sct:Dbtr>
                            <sct:Nm><xsl:value-of select="sdd:Dbtr/sdd:Nm"/></sct:Nm>
                        </sct:Dbtr>
                        <sct:DbtrAcct>
                            <sct:Id>
                                <sct:IBAN><xsl:value-of select="sdd:DbtrAcct/sdd:Id/sdd:IBAN"/></sct:IBAN>
                            </sct:Id>
                        </sct:DbtrAcct>
                        <xsl:for-each select="sdd:DrctDbtTxInf">
                            <sct:CdtTrfTxInf>
                                <sct:PmtId>
                                    <sct:EndToEndId><xsl:value-of select="sdd:PmtId/sdd:EndToEndId"/></sct:EndToEndId>
                                </sct:PmtId>
                                <sct:Amt>
                                    <sct:InstdAmt Ccy="EUR"><xsl:value-of select="sdd:InstdAmt"/></sct:InstdAmt>
                                </sct:Amt>
                                <sct:Cdtr>
                                    <sct:Nm><xsl:value-of select="sdd:Cdtr/sdd:Nm"/></sct:Nm>
                                </sct:Cdtr>
                                <sct:CdtrAcct>
                                    <sct:Id>
                                        <sct:IBAN><xsl:value-of select="sdd:CdtrAcct/sdd:Id/sdd:IBAN"/></sct:IBAN>
                                    </sct:Id>
                                </sct:CdtrAcct>
                            </sct:CdtTrfTxInf>
                        </xsl:for-each>

                    </sct:PmtInf>
                </xsl:for-each>
            </sct:CstmrCdtTrfInitn>
        </sct:Document>
    </xsl:template>

</xsl:stylesheet>
