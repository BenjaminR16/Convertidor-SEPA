<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:sct="urn:iso:std:iso:20022:tech:xsd:pain.001.001.09"
    exclude-result-prefixes="sct">

    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

    <!-- Raíz -->
    <xsl:template match="/sct:Document">
        <Document xmlns="urn:iso:std:iso:20022:tech:xsd:pain.008.001.08">
            <CstmrDrctDbtInitn>
                <xsl:apply-templates select="sct:CstmrCdtTrfInitn/sct:GrpHdr"/>
                <xsl:apply-templates select="sct:CstmrCdtTrfInitn/sct:PmtInf"/>
            </CstmrDrctDbtInitn>
        </Document>
    </xsl:template>

    <!-- GrpHdr -->
    <xsl:template match="sct:GrpHdr">
        <GrpHdr>
            <MsgId><xsl:value-of select="sct:MsgId"/></MsgId>
            <CreDtTm><xsl:value-of select="sct:CreDtTm"/></CreDtTm>
            <NbOfTxs><xsl:value-of select="sct:NbOfTxs"/></NbOfTxs>
            <CtrlSum><xsl:value-of select="sct:CtrlSum"/></CtrlSum>
            <xsl:apply-templates select="sct:InitgPty"/>
        </GrpHdr>
    </xsl:template>

    <!-- PartyIdentification135 -->
    <xsl:template match="sct:InitgPty | sct:Dbtr | sct:Cdtr | sct:UltmtDbtr | sct:UltmtCdtr">
        <xsl:element name="{local-name()}" namespace="urn:iso:std:iso:20022:tech:xsd:pain.008.001.08">
            <xsl:if test="sct:Nm"><Nm><xsl:value-of select="sct:Nm"/></Nm></xsl:if>
            <xsl:if test="sct:PstlAdr">
                <PstlAdr>
                    <xsl:for-each select="sct:PstlAdr/*">
                        <xsl:element name="{local-name()}" namespace="urn:iso:std:iso:20022:tech:xsd:pain.008.001.08">
                            <xsl:value-of select="."/>
                        </xsl:element>
                    </xsl:for-each>
                </PstlAdr>
            </xsl:if>
            <xsl:if test="sct:Id"><Id><xsl:copy-of select="sct:Id/*"/></Id></xsl:if>
            <xsl:if test="sct:CtryOfRes"><CtryOfRes><xsl:value-of select="sct:CtryOfRes"/></CtryOfRes></xsl:if>
            <xsl:if test="sct:CtctDtls"><CtctDtls><xsl:copy-of select="sct:CtctDtls/*"/></CtctDtls></xsl:if>
        </xsl:element>
    </xsl:template>

    <!-- PmtInf -->
    <xsl:template match="sct:PmtInf">
        <PmtInf>
            <PmtInfId><xsl:value-of select="sct:PmtInfId"/></PmtInfId>
            <PmtMtd>DD</PmtMtd>
            <BtchBookg><xsl:value-of select="sct:BtchBookg"/></BtchBookg>
            <NbOfTxs><xsl:value-of select="sct:NbOfTxs"/></NbOfTxs>
            <CtrlSum><xsl:value-of select="sct:CtrlSum"/></CtrlSum>

            <xsl:if test="sct:PmtTpInf">
                <PmtTpInf>
                    <xsl:if test="sct:PmtTpInf/InstrPrty"><InstrPrty><xsl:value-of select="sct:PmtTpInf/InstrPrty"/></InstrPrty></xsl:if>
                    <xsl:if test="sct:PmtTpInf/SvcLvl"><SvcLvl><xsl:value-of select="sct:PmtTpInf/SvcLvl/Cd"/></SvcLvl></xsl:if>
                    <xsl:if test="sct:PmtTpInf/LclInstrm"><LclInstrm><xsl:value-of select="sct:PmtTpInf/LclInstrm/Cd"/></LclInstrm></xsl:if>
                    <xsl:if test="sct:PmtTpInf/CtgyPurp"><CtgyPurp><xsl:value-of select="sct:PmtTpInf/CtgyPurp/Cd"/></CtgyPurp></xsl:if>
                </PmtTpInf>
            </xsl:if>

            <ReqdColltnDt><xsl:value-of select="sct:ReqdExctnDt/Dt"/></ReqdColltnDt>

            <xsl:apply-templates select="sct:Dbtr"/>
            <xsl:apply-templates select="sct:DbtrAcct"/>
            <xsl:apply-templates select="sct:DbtrAgt"/>
            <xsl:apply-templates select="sct:UltmtDbtr"/>
            <xsl:apply-templates select="sct:Cdtr"/>
            <xsl:apply-templates select="sct:CdtrAcct"/>
            <xsl:apply-templates select="sct:CdtrAgt"/>
            <xsl:apply-templates select="sct:CdtTrfTxInf"/>

            <ChrgBr><xsl:value-of select="sct:ChrgBr"/></ChrgBr>
        </PmtInf>
    </xsl:template>

    <!-- CdtTrfTxInf -> DrctDbtTxInf -->
    <xsl:template match="sct:CdtTrfTxInf">
        <DrctDbtTxInf>
            <PmtId><xsl:copy-of select="sct:PmtId/*"/></PmtId>
            <InstdAmt Ccy="{sct:Amt/InstdAmt/@Ccy}"><xsl:value-of select="sct:Amt/InstdAmt"/></InstdAmt>
            <xsl:apply-templates select="sct:Dbtr"/>
            <xsl:apply-templates select="sct:DbtrAcct"/>
            <xsl:apply-templates select="sct:DbtrAgt"/>
            <xsl:apply-templates select="sct:UltmtDbtr"/>
            <xsl:if test="sct:RmtInf/Ustrd">
                <RmtInf><Ustrd><xsl:value-of select="sct:RmtInf/Ustrd"/></Ustrd></RmtInf>
            </xsl:if>
        </DrctDbtTxInf>
    </xsl:template>

    <!-- Cuentas y agentes -->
    <xsl:template match="sct:DbtrAcct | sct:CdtrAcct | sct:DbtrAgt | sct:CdtrAgt">
        <xsl:element name="{local-name()}" namespace="urn:iso:std:iso:20022:tech:xsd:pain.008.001.08">
            <xsl:copy-of select="*"/>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>
