<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:sdd="urn:iso:std:iso:20022:tech:xsd:pain.008.003.02"
    xmlns:sct="urn:iso:std:iso:20022:tech:xsd:pain.001.001.09"
    exclude-result-prefixes="sdd"
    version="1.0">

    <xsl:output method="xml" indent="yes" encoding="UTF-8" />

    <xsl:template match="/">
        <sct:Document xmlns:sct="urn:iso:std:iso:20022:tech:xsd:pain.001.001.09">
            <sct:CstmrCdtTrfInitn>
                <xsl:apply-templates select="sdd:Document/sdd:CstmrDrctDbtInitn/sdd:GrpHdr" />
                <xsl:apply-templates select="sdd:Document/sdd:CstmrDrctDbtInitn/sdd:PmtInf" />
            </sct:CstmrCdtTrfInitn>
        </sct:Document>
    </xsl:template>

    <xsl:template match="sdd:GrpHdr">
        <sct:GrpHdr>
            <xsl:if test="sdd:MsgId">
                <sct:MsgId>
                    <xsl:value-of select="sdd:MsgId" />
                </sct:MsgId>
            </xsl:if>
            <xsl:if test="sdd:CreDtTm">
                <sct:CreDtTm>
                    <xsl:value-of select="sdd:CreDtTm" />
                </sct:CreDtTm>
            </xsl:if>
            <xsl:if test="sdd:NbOfTxs">
                <sct:NbOfTxs>
                    <xsl:value-of select="sdd:NbOfTxs" />
                </sct:NbOfTxs>
            </xsl:if>
            <xsl:if test="sdd:CtrlSum">
                <sct:CtrlSum>
                    <xsl:value-of select="sdd:CtrlSum" />
                </sct:CtrlSum>
            </xsl:if>
            <xsl:if test="sdd:InitgPty/sdd:Nm">
                <sct:InitgPty>
                    <sct:Nm>
                        <xsl:value-of select="sdd:InitgPty/sdd:Nm" />
                    </sct:Nm>
                </sct:InitgPty>
            </xsl:if>
        </sct:GrpHdr>
    </xsl:template>

    <xsl:template match="sdd:PmtInf">
        <sct:PmtInf>
            <xsl:if test="sdd:PmtInfId">
                <sct:PmtInfId>
                    <xsl:value-of select="sdd:PmtInfId" />
                </sct:PmtInfId>
            </xsl:if>
            <sct:PmtMtd>TRF</sct:PmtMtd>
            <xsl:if test="sdd:NbOfTxs">
                <sct:NbOfTxs>
                    <xsl:value-of select="sdd:NbOfTxs" />
                </sct:NbOfTxs>
            </xsl:if>
            <xsl:if test="sdd:CtrlSum">
                <sct:CtrlSum>
                    <xsl:value-of select="sdd:CtrlSum" />
                </sct:CtrlSum>
            </xsl:if>

            <sct:PmtTpInf>
                <sct:SvcLvl>
                    <sct:Cd>SEPA</sct:Cd>
                </sct:SvcLvl>
            </sct:PmtTpInf>
            <xsl:if test="sdd:ReqdColltnDt">
                <sct:ReqdExctnDt>
                    <xsl:choose>
                        <xsl:when test="contains(sdd:ReqdColltnDt, 'T')">
                            <sct:DtTm>
                                <xsl:value-of select="sdd:ReqdColltnDt" />
                            </sct:DtTm>
                        </xsl:when>
                        <xsl:otherwise>
                            <sct:Dt>
                                <xsl:value-of select="sdd:ReqdColltnDt" />
                            </sct:Dt>
                        </xsl:otherwise>
                    </xsl:choose>
                </sct:ReqdExctnDt>
            </xsl:if>
            <sct:Dbtr>
                <sct:Nm>
                    <xsl:value-of select="sdd:Cdtr/sdd:Nm" />
                </sct:Nm>
            </sct:Dbtr>

            <sct:DbtrAcct>
                <sct:Id>
                    <sct:IBAN>
                        <xsl:value-of select="sdd:CdtrAcct/sdd:Id/sdd:IBAN" />
                    </sct:IBAN>
                </sct:Id>
            </sct:DbtrAcct>

            <sct:DbtrAgt>
                <sct:FinInstnId>
                    <xsl:choose>
                        <xsl:when test="sdd:CdtrAgt/sdd:FinInstnId/sdd:BIC">
                            <sct:BICFI>
                                <xsl:value-of select="sdd:CdtrAgt/sdd:FinInstnId/sdd:BIC" />
                            </sct:BICFI>
                        </xsl:when>
                        <xsl:when test="sdd:CdtrAgt/sdd:FinInstnId/sdd:Othr/sdd:Id">
                            <sct:Othr>
                                <sct:Id>
                                    <xsl:value-of select="sdd:CdtrAgt/sdd:FinInstnId/sdd:Othr/sdd:Id" />
                                </sct:Id>
                            </sct:Othr>
                        </xsl:when>
                        <xsl:otherwise>
                            <sct:Othr>
                                <sct:Id>NOTPROVIDED</sct:Id>
                            </sct:Othr>
                        </xsl:otherwise>
                    </xsl:choose>
                </sct:FinInstnId>
            </sct:DbtrAgt>

            <xsl:for-each select="sdd:DrctDbtTxInf">
                <sct:CdtTrfTxInf>
                    <sct:PmtId>
                        <xsl:if test="sdd:PmtId/sdd:InstrId">
                            <sct:InstrId>
                                <xsl:value-of select="sdd:PmtId/sdd:InstrId" />
                            </sct:InstrId>
                        </xsl:if>
                        <xsl:if test="sdd:PmtId/sdd:EndToEndId">
                            <sct:EndToEndId>
                                <xsl:value-of select="sdd:PmtId/sdd:EndToEndId" />
                            </sct:EndToEndId>
                        </xsl:if>
                    </sct:PmtId>
                    <sct:Amt>
                        <sct:InstdAmt Ccy="{sdd:InstdAmt/@Ccy}">
                            <xsl:value-of select="sdd:InstdAmt" />
                        </sct:InstdAmt>
                    </sct:Amt>
                    <sct:CdtrAgt>
                        <sct:FinInstnId>
                            <xsl:choose>
                                <xsl:when test="sdd:DbtrAgt/sdd:FinInstnId/sdd:BIC">
                                    <sct:BICFI>
                                        <xsl:value-of select="sdd:DbtrAgt/sdd:FinInstnId/sdd:BIC" />
                                    </sct:BICFI>
                                </xsl:when>
                                <xsl:when test="sdd:DbtrAgt/sdd:FinInstnId/sdd:Othr/sdd:Id">
                                    <sct:Othr>
                                        <sct:Id>
                                            <xsl:value-of select="sdd:DbtrAgt/sdd:FinInstnId/sdd:Othr/sdd:Id" />
                                        </sct:Id>
                                    </sct:Othr>
                                </xsl:when>
                                <xsl:otherwise>
                                    <sct:Othr>
                                        <sct:Id>NOTPROVIDED</sct:Id>
                                    </sct:Othr>
                                </xsl:otherwise>
                            </xsl:choose>
                        </sct:FinInstnId>
                    </sct:CdtrAgt>
                    <sct:Cdtr>
                        <sct:Nm>
                            <xsl:value-of select="sdd:Dbtr/sdd:Nm" />
                        </sct:Nm>
                    </sct:Cdtr>
                    <sct:CdtrAcct>
                        <sct:Id>
                            <sct:IBAN>
                                <xsl:value-of select="sdd:DbtrAcct/sdd:Id/sdd:IBAN" />
                            </sct:IBAN>
                        </sct:Id>
                    </sct:CdtrAcct>
                    <xsl:if test="sdd:RmtInf/sdd:Ustrd">
                        <sct:RmtInf>
                            <sct:Ustrd>
                                <xsl:value-of select="sdd:RmtInf/sdd:Ustrd" />
                            </sct:Ustrd>
                        </sct:RmtInf>
                    </xsl:if>
                </sct:CdtTrfTxInf>
            </xsl:for-each>
        </sct:PmtInf>
    </xsl:template>

</xsl:stylesheet>
