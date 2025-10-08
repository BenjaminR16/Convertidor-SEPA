<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:sdd="urn:iso:std:iso:20022:tech:xsd:pain.008.001.08"
    xmlns:sct="urn:iso:std:iso:20022:tech:xsd:pain.001.001.09"
    exclude-result-prefixes="sdd"
    version="1.0">

    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

    <!-- Plantilla raíz -->
    <xsl:template match="/">
        <sct:Document xmlns:sct="urn:iso:std:iso:20022:tech:xsd:pain.001.001.09">
            <sct:CstmrCdtTrfInitn>
                <xsl:apply-templates select="sdd:Document/sdd:CstmrDrctDbtInitn/sdd:GrpHdr"/>
                <xsl:apply-templates select="sdd:Document/sdd:CstmrDrctDbtInitn/sdd:PmtInf"/>
            </sct:CstmrCdtTrfInitn>
        </sct:Document>
    </xsl:template>

    <!-- Grupo cabecera -->
    <xsl:template match="sdd:GrpHdr">
        <sct:GrpHdr>
            <sct:MsgId><xsl:value-of select="sdd:MsgId"/></sct:MsgId>
            <sct:CreDtTm><xsl:value-of select="sdd:CreDtTm"/></sct:CreDtTm>
            <sct:NbOfTxs><xsl:value-of select="sdd:NbOfTxs"/></sct:NbOfTxs>
            <sct:CtrlSum><xsl:value-of select="sdd:CtrlSum"/></sct:CtrlSum>
            <sct:InitgPty>
                <sct:Nm><xsl:value-of select="sdd:InitgPty/sdd:Nm"/></sct:Nm>
            </sct:InitgPty>
        </sct:GrpHdr>
    </xsl:template>

    <!-- Información de pago -->
    <xsl:template match="sdd:PmtInf">
        <sct:PmtInf>
            <sct:PmtInfId><xsl:value-of select="sdd:PmtInfId"/></sct:PmtInfId>
            <sct:PmtMtd>TRF</sct:PmtMtd>
            <sct:NbOfTxs><xsl:value-of select="sdd:NbOfTxs"/></sct:NbOfTxs>
            <sct:CtrlSum><xsl:value-of select="sdd:CtrlSum"/></sct:CtrlSum>
            
            <sct:PmtTpInf>
                <sct:SvcLvl>
                    <sct:Cd>SEPA</sct:Cd>
                </sct:SvcLvl>
            </sct:PmtTpInf>

            <!-- CORRECCIÓN: elemento complejo ReqdExctnDt -->
            <sct:ReqdExctnDt>
    <xsl:choose>
        <!-- Si la fecha tiene hora -->
        <xsl:when test="contains(sdd:ReqdColltnDt, 'T')">
            <sct:DtTm><xsl:value-of select="sdd:ReqdColltnDt"/></sct:DtTm>
        </xsl:when>
        <!-- Si solo es fecha -->
        <xsl:otherwise>
            <sct:Dt><xsl:value-of select="sdd:ReqdColltnDt"/></sct:Dt>
        </xsl:otherwise>
    </xsl:choose>
</sct:ReqdExctnDt>


            <sct:Dbtr>
                <sct:Nm><xsl:value-of select="sdd:Cdtr/sdd:Nm"/></sct:Nm>
            </sct:Dbtr>

            <sct:DbtrAcct>
                <sct:Id>
                    <sct:IBAN><xsl:value-of select="sdd:CdtrAcct/sdd:Id/sdd:IBAN"/></sct:IBAN>
                </sct:Id>
            </sct:DbtrAcct>

            <sct:DbtrAgt>
                <sct:FinInstnId>
                    <sct:BICFI><xsl:value-of select="sdd:CdtrAgt/sdd:FinInstnId/sdd:BICFI"/></sct:BICFI>
                </sct:FinInstnId>
            </sct:DbtrAgt>

            <!-- Transacciones individuales -->
            <xsl:for-each select="sdd:DrctDbtTxInf">
                <sct:CdtTrfTxInf>
                    <sct:PmtId>
                        <sct:EndToEndId><xsl:value-of select="sdd:PmtId/sdd:EndToEndId"/></sct:EndToEndId>
                    </sct:PmtId>
                    <sct:Amt>
                        <sct:InstdAmt Ccy="{sdd:InstdAmt/@Ccy}">
                            <xsl:value-of select="sdd:InstdAmt"/>
                        </sct:InstdAmt>
                    </sct:Amt>
                    <sct:CdtrAgt>
                        <sct:FinInstnId>
                            <sct:BICFI><xsl:value-of select="sdd:DbtrAgt/sdd:FinInstnId/sdd:BICFI"/></sct:BICFI>
                        </sct:FinInstnId>
                    </sct:CdtrAgt>
                    <sct:Cdtr>
                        <sct:Nm><xsl:value-of select="sdd:Dbtr/sdd:Nm"/></sct:Nm>
                    </sct:Cdtr>
                    <sct:CdtrAcct>
                        <sct:Id>
                            <sct:IBAN><xsl:value-of select="sdd:DbtrAcct/sdd:Id/sdd:IBAN"/></sct:IBAN>
                        </sct:Id>
                    </sct:CdtrAcct>
                    <sct:RmtInf>
                        <sct:Ustrd><xsl:value-of select="sdd:RmtInf/sdd:Ustrd"/></sct:Ustrd>
                    </sct:RmtInf>
                </sct:CdtTrfTxInf>
            </xsl:for-each>
        </sct:PmtInf>
    </xsl:template>

</xsl:stylesheet>
