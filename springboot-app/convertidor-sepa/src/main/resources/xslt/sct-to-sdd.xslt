<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:sct="urn:iso:std:iso:20022:tech:xsd:pain.001.001.09"
    xmlns:sdd="urn:iso:std:iso:20022:tech:xsd:pain.008.001.08"
    exclude-result-prefixes="sct">

    <xsl:output method="xml" encoding="UTF-8" indent="yes" />

    <!-- Root: build an SDD Document -->
    <xsl:template match="/sct:Document">
        <sdd:Document xmlns:sdd="urn:iso:std:iso:20022:tech:xsd:pain.008.001.08">
            <sdd:CstmrDrctDbtInitn>
                <xsl:call-template name="mapGrpHdr" />
                <xsl:for-each select="sct:CstmrCdtTrfInitn/sct:PmtInf">
                    <sdd:PmtInf>
                        <!-- PmtInfId -->
                        <xsl:if test="sct:PmtInfId">
                            <sdd:PmtInfId>
                                <xsl:value-of select="sct:PmtInfId" />
                            </sdd:PmtInfId>
                        </xsl:if>

                        <!-- Payment method: direct debit -->
                        <sdd:PmtMtd>DD</sdd:PmtMtd>

                        <!-- Number of txs and control sum -->
                        <sdd:NbOfTxs>
                            <xsl:value-of select="count(sct:CdtTrfTxInf)" />
                        </sdd:NbOfTxs>
                        <xsl:if test="sct:CtrlSum">
                            <sdd:CtrlSum>
                                <xsl:value-of select="sct:CtrlSum" />
                            </sdd:CtrlSum>
                        </xsl:if>

                        <!-- Payment type info -->
                        <sdd:PmtTpInf>
                            <sdd:SvcLvl>
                                <sdd:Cd>SEPA</sdd:Cd>
                            </sdd:SvcLvl>
                            <sdd:LclInstrm>
                                <sdd:Cd>CORE</sdd:Cd>
                            </sdd:LclInstrm>
                            <sdd:SeqTp>
                                <xsl:choose>
                                    <xsl:when test="sct:SeqTp"><xsl:value-of select="sct:SeqTp" /></xsl:when>
                                    <xsl:otherwise>FRST</xsl:otherwise>
                                </xsl:choose>
                            </sdd:SeqTp>
                        </sdd:PmtTpInf>

                        <!-- Requested collection date: convert complex -> simple (YYYY-MM-DD) -->
                        <xsl:if test="sct:ReqdExctnDt/sct:Dt or sct:ReqdExctnDt/sct:DtTm">
                            <sdd:ReqdColltnDt>
                                <xsl:choose>
                                    <xsl:when test="sct:ReqdExctnDt/sct:Dt">
                                        <xsl:value-of select="sct:ReqdExctnDt/sct:Dt" />
                                    </xsl:when>
                                    <xsl:when test="sct:ReqdExctnDt/sct:DtTm">
                                        <xsl:value-of
                                            select="substring-before(sct:ReqdExctnDt/sct:DtTm, 'T')" />
                                    </xsl:when>
                                </xsl:choose>
                            </sdd:ReqdColltnDt>
                        </xsl:if>

                        <!-- Creditor (in SDD) <- Dbtr in SCT -->
                        <sdd:Cdtr>
                            <sdd:Nm>
                                <xsl:value-of
                                    select="sct:Dbtr/sct:Nm | sct:CdtTrfTxInf[1]/sct:Dbtr/sct:Nm" />
                            </sdd:Nm>

                            <!-- Map postal country to CtryOfRes if available (avoid full PstlAdr) -->
                            <xsl:if
                                test="sct:Dbtr/sct:PstlAdr/sct:Ctry or sct:CdtTrfTxInf[1]/sct:Dbtr/sct:PstlAdr/sct:Ctry">
                                <sdd:CtryOfRes>
                                    <xsl:value-of
                                        select="sct:Dbtr/sct:PstlAdr/sct:Ctry | sct:CdtTrfTxInf[1]/sct:Dbtr/sct:PstlAdr/sct:Ctry" />
                                </sdd:CtryOfRes>
                            </xsl:if>

                            <!-- Id (OrgId->Othr->Id) if present -->
                            <xsl:if test="sct:Dbtr/sct:Id or sct:CdtTrfTxInf[1]/sct:Dbtr/sct:Id">
                                <sdd:Id>
                                    <xsl:if test="sct:Dbtr/sct:Id/sct:OrgId/sct:Othr/sct:Id">
                                        <sdd:OrgId>
                                            <sdd:Othr>
                                                <sdd:Id>
                                                    <xsl:value-of
                                                        select="sct:Dbtr/sct:Id/sct:OrgId/sct:Othr/sct:Id | sct:CdtTrfTxInf[1]/sct:Dbtr/sct:Id/sct:OrgId/sct:Othr/sct:Id" />
                                                </sdd:Id>
                                            </sdd:Othr>
                                        </sdd:OrgId>
                                    </xsl:if>
                                </sdd:Id>
                            </xsl:if>
                        </sdd:Cdtr>

                        <!-- Creditor account (from DbtrAcct in SCT) -->
                        <sdd:CdtrAcct>
                            <sdd:Id>
                                <sdd:IBAN>
                                    <xsl:value-of
                                        select="sct:DbtrAcct/sct:Id/sct:IBAN | sct:CdtTrfTxInf[1]/sct:DbtrAcct/sct:Id/sct:IBAN" />
                                </sdd:IBAN>
                            </sdd:Id>
                        </sdd:CdtrAcct>

                        <!-- Creditor agent: map BICFI -> BICFI in SDD (FinInstnId child) -->
                        <xsl:if
                            test="sct:DbtrAgt/sct:FinInstnId/sct:BICFI or sct:CdtTrfTxInf[1]/sct:DbtrAgt/sct:FinInstnId/sct:BICFI">
                            <sdd:CdtrAgt>
                                <sdd:FinInstnId>
                                    <sdd:BICFI>
                                        <xsl:value-of
                                            select="sct:DbtrAgt/sct:FinInstnId/sct:BICFI | sct:CdtTrfTxInf[1]/sct:DbtrAgt/sct:FinInstnId/sct:BICFI" />
                                    </sdd:BICFI>
                                </sdd:FinInstnId>
                            </sdd:CdtrAgt>
                        </xsl:if>

                        <!-- Transactions: each credit-transfer in SCT becomes a direct-debit in SDD -->
                        <xsl:for-each select="sct:CdtTrfTxInf">
                            <sdd:DrctDbtTxInf>
                                <sdd:PmtId>
                                    <sdd:EndToEndId>
                                        <xsl:value-of select="sct:PmtId/sct:EndToEndId" />
                                    </sdd:EndToEndId>
                                </sdd:PmtId>

                                <sdd:InstdAmt Ccy="{sct:Amt/sct:InstdAmt/@Ccy}">
                                    <xsl:value-of select="sct:Amt/sct:InstdAmt" />
                                </sdd:InstdAmt>

                                <sdd:DrctDbtTx>
                                    <sdd:MndtRltdInf>
                                        <sdd:MndtId>
                                            <xsl:choose>
                                                <xsl:when test="sct:PmtId/sct:InstrId">
                                                    <xsl:value-of select="sct:PmtId/sct:InstrId" />
                                                </xsl:when>
                                                <xsl:when test="sct:PmtId/sct:EndToEndId">
                                                    <xsl:value-of
                                                        select="concat('MNDT-', sct:PmtId/sct:EndToEndId)" />
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of
                                                        select="concat('MNDT-', position())" />
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </sdd:MndtId>
                                    </sdd:MndtRltdInf>
                                </sdd:DrctDbtTx>

                                <!-- Opcional: si tu SCT incluye un acreedor último -->
                                <xsl:if test="sct:UltmtCdtr">
                                    <sdd:UltmtCdtr>
                                        <sdd:Nm>
                                            <xsl:value-of select="sct:UltmtCdtr/sct:Nm" />
                                        </sdd:Nm>
                                    </sdd:UltmtCdtr>
                                </xsl:if>

                                <!-- DbtrAgt DEBE ir antes de Dbtr -->
                                <xsl:if test="sct:CdtrAgt/sct:FinInstnId/sct:BICFI">
                                    <sdd:DbtrAgt>
                                        <sdd:FinInstnId>
                                            <sdd:BICFI>
                                                <xsl:value-of
                                                    select="sct:CdtrAgt/sct:FinInstnId/sct:BICFI" />
                                            </sdd:BICFI>
                                        </sdd:FinInstnId>
                                    </sdd:DbtrAgt>
                                </xsl:if>

                                <!-- Dbtr después de DbtrAgt -->
                                <sdd:Dbtr>
                                    <sdd:Nm>
                                        <xsl:value-of select="sct:Cdtr/sct:Nm | ../sct:Cdtr/sct:Nm" />
                                    </sdd:Nm>
                                    <xsl:if test="sct:Cdtr/sct:PstlAdr/sct:Ctry">
                                        <sdd:CtryOfRes>
                                            <xsl:value-of select="sct:Cdtr/sct:PstlAdr/sct:Ctry" />
                                        </sdd:CtryOfRes>
                                    </xsl:if>
                                </sdd:Dbtr>

                                <sdd:DbtrAcct>
                                    <sdd:Id>
                                        <sdd:IBAN>
                                            <xsl:value-of select="sct:CdtrAcct/sct:Id/sct:IBAN" />
                                        </sdd:IBAN>
                                    </sdd:Id>
                                </sdd:DbtrAcct>

                                <xsl:if test="sct:RmtInf/sct:Ustrd">
                                    <sdd:RmtInf>
                                        <sdd:Ustrd>
                                            <xsl:value-of select="sct:RmtInf/sct:Ustrd" />
                                        </sdd:Ustrd>
                                    </sdd:RmtInf>
                                </xsl:if>
                            </sdd:DrctDbtTxInf>
                        </xsl:for-each>


                    </sdd:PmtInf>
                </xsl:for-each>
            </sdd:CstmrDrctDbtInitn>
        </sdd:Document>
    </xsl:template>

    <!-- Group Header mapping -->
    <xsl:template name="mapGrpHdr">
        <xsl:variable name="gh" select="/sct:Document/sct:CstmrCdtTrfInitn/sct:GrpHdr" />
    <sdd:GrpHdr>
            <xsl:if test="$gh/sct:MsgId"><sdd:MsgId>
                    <xsl:value-of select="$gh/sct:MsgId" />
                </sdd:MsgId></xsl:if>
            <xsl:if test="$gh/sct:CreDtTm"><sdd:CreDtTm>
                    <xsl:value-of select="$gh/sct:CreDtTm" />
                </sdd:CreDtTm></xsl:if>
            <sdd:NbOfTxs>
                <xsl:value-of
                    select="count(/sct:Document/sct:CstmrCdtTrfInitn/sct:PmtInf/sct:CdtTrfTxInf)" />
            </sdd:NbOfTxs>
            <xsl:if test="$gh/sct:CtrlSum"><sdd:CtrlSum>
                    <xsl:value-of select="$gh/sct:CtrlSum" />
                </sdd:CtrlSum></xsl:if>
            <xsl:if test="$gh/sct:InitgPty">
                <sdd:InitgPty>
                    <sdd:Nm>
                        <xsl:value-of select="$gh/sct:InitgPty/sct:Nm" />
                    </sdd:Nm>
                </sdd:InitgPty>
            </xsl:if>
        </sdd:GrpHdr>
    </xsl:template>

    <!-- default: do not copy unexpected nodes -->
    <xsl:template match="node()|@*" />

</xsl:stylesheet>