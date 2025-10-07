<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:sdd="urn:iso:std:iso:20022:tech:xsd:pain.008.001.08"
    xmlns:sct="urn:iso:std:iso:20022:tech:xsd:pain.001.001.09"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="sdd xs">

    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

    <xsl:template match="/sdd:Document">
        <sct:Document xmlns:sct="urn:iso:std:iso:20022:tech:xsd:pain.001.001.09">
            <sct:CstmrCdtTrfInitn>
                <xsl:apply-templates select="sdd:CstmrDrctDbtInitn/sdd:GrpHdr"/>
                <xsl:apply-templates select="sdd:CstmrDrctDbtInitn/sdd:PmtInf"/>
            </sct:CstmrCdtTrfInitn>
        </sct:Document>
    </xsl:template>

    <xsl:template match="sdd:GrpHdr">
        <sct:GrpHdr>
            <sct:MsgId><xsl:value-of select="sdd:MsgId"/></sct:MsgId>
            <sct:CreDtTm><xsl:value-of select="sdd:CreDtTm"/></sct:CreDtTm>

            <xsl:variable name="totalTxs" select="count(../../sdd:PmtInf/sdd:DrctDbtTxInf)"/>
            <sct:NbOfTxs><xsl:value-of select="$totalTxs"/></sct:NbOfTxs>

            <xsl:variable name="ctrlSum" select="sum(../../sdd:PmtInf/sdd:DrctDbtTxInf/sdd:InstdAmt/xs:decimal(.))"/>
            <sct:CtrlSum>
                <xsl:value-of select="format-number($ctrlSum, '0.00')"/>
            </sct:CtrlSum>

            <sct:InitgPty>
                <xsl:if test="sdd:InitgPty/sdd:Nm">
                    <sct:Nm><xsl:value-of select="sdd:InitgPty/sdd:Nm"/></sct:Nm>
                </xsl:if>
                <xsl:if test="sdd:InitgPty/sdd:Id">
                    <sct:Id>
                        <xsl:if test="sdd:InitgPty/sdd:Id/sdd:OrgId/sdd:Othr">
                            <sct:OrgId>
                                <sct:Othr>
                                    <sct:Id>
                                        <xsl:value-of select="sdd:InitgPty/sdd:Id/sdd:OrgId/sdd:Othr/sdd:Id"/>
                                    </sct:Id>
                                </sct:Othr>
                            </sct:OrgId>
                        </xsl:if>
                        <xsl:if test="sdd:InitgPty/sdd:Id/sdd:PrvtId/sdd:Othr">
                            <sct:PrvtId>
                                <sct:Othr>
                                    <sct:Id>
                                        <xsl:value-of select="sdd:InitgPty/sdd:Id/sdd:PrvtId/sdd:Othr/sdd:Id"/>
                                    </sct:Id>
                                </sct:Othr>
                            </sct:PrvtId>
                        </xsl:if>
                    </sct:Id>
                </xsl:if>
            </sct:InitgPty>
        </sct:GrpHdr>
    </xsl:template>

    <xsl:template match="sdd:PmtInf">
        <sct:PmtInf>
            <sct:PmtInfId><xsl:value-of select="sdd:PmtInfId"/></sct:PmtInfId>

            <sct:PmtMtd>TRF</sct:PmtMtd>

            <xsl:if test="sdd:BtchBookg">
                <sct:BtchBookg><xsl:value-of select="sdd:BtchBookg"/></sct:BtchBookg>
            </xsl:if>

            <xsl:variable name="localTxs" select="count(sdd:DrctDbtTxInf)"/>
            <xsl:if test="$localTxs &gt; 0">
                <sct:NbOfTxs><xsl:value-of select="$localTxs"/></sct:NbOfTxs>
            </xsl:if>

            <xsl:variable name="localSum" select="sum(sdd:DrctDbtTxInf/sdd:InstdAmt/xs:decimal(.))"/>
            <xsl:if test="$localSum &gt; 0">
                <sct:CtrlSum><xsl:value-of select="format-number($localSum, '0.00')"/></sct:CtrlSum>
            </xsl:if>

            <sct:PmtTpInf>
                <sct:SvcLvl><sct:Cd>SEPA</sct:Cd></sct:SvcLvl>
            </sct:PmtTpInf>

            <sct:ReqdExctnDt>
                <sct:Dt><xsl:value-of select="normalize-space(sdd:ReqdColltnDt)"/></sct:Dt>
            </sct:ReqdExctnDt>

            <xsl:if test="sdd:PoolgAdjstmntDt">
                <sct:PoolgAdjstmntDt>
                    <sct:Dt><xsl:value-of select="sdd:PoolgAdjstmntDt"/></sct:Dt>
                </sct:PoolgAdjstmntDt>
            </xsl:if>

            <xsl:if test="sdd:Cdtr">
                <sct:Dbtr>
                    <xsl:if test="sdd:Cdtr/sdd:Nm"><sct:Nm><xsl:value-of select="sdd:Cdtr/sdd:Nm"/></sct:Nm></xsl:if>
                    <xsl:if test="sdd:Cdtr/sdd:PstlAdr">
                        <sct:PstlAdr>
                            <xsl:for-each select="sdd:Cdtr/sdd:PstlAdr/*">
                                <xsl:element name="{local-name()}" namespace="urn:iso:std:iso:20022:tech:xsd:pain.001.001.09">
                                    <xsl:value-of select="."/>
                                </xsl:element>
                            </xsl:for-each>
                        </sct:PstlAdr>
                    </xsl:if>
                </sct:Dbtr>
            </xsl:if>

            <xsl:if test="sdd:CdtrAcct">
                <sct:DbtrAcct>
                    <sct:Id>
                        <xsl:choose>
                            <xsl:when test="sdd:CdtrAcct/sdd:Id/sdd:IBAN">
                                <sct:IBAN><xsl:value-of select="sdd:CdtrAcct/sdd:Id/sdd:IBAN"/></sct:IBAN>
                            </xsl:when>
                            <xsl:when test="sdd:CdtrAcct/sdd:Id/sdd:Othr">
                                <sct:Othr>
                                    <sct:Id><xsl:value-of select="sdd:CdtrAcct/sdd:Id/sdd:Othr/sdd:Id"/></sct:Id>
                                </sct:Othr>
                            </xsl:when>
                        </xsl:choose>
                    </sct:Id>
                </sct:DbtrAcct>
            </xsl:if>

            <xsl:if test="sdd:CdtrAgt">
                <sct:DbtrAgt>
                    <sct:FinInstnId>
                        <xsl:for-each select="sdd:CdtrAgt/sdd:FinInstnId/*">
                            <xsl:element name="{local-name()}" namespace="urn:iso:std:iso:20022:tech:xsd:pain.001.001.09">
                                <xsl:value-of select="."/>
                            </xsl:element>
                        </xsl:for-each>
                    </sct:FinInstnId>
                </sct:DbtrAgt>
            </xsl:if>
            <xsl:for-each select="sdd:DrctDbtTxInf">
                <sct:CdtTrfTxInf>
                    <sct:PmtId>
                        <xsl:if test="sdd:PmtId/sdd:EndToEndId">
                            <sct:EndToEndId><xsl:value-of select="sdd:PmtId/sdd:EndToEndId"/></sct:EndToEndId>
                        </xsl:if>
                    </sct:PmtId>

                    <sct:InstdAmt>
    <xsl:attribute name="Ccy">
        <xsl:value-of select="sdd:InstdAmt/@Ccy"/>
    </xsl:attribute>
    <xsl:value-of select="normalize-space(sdd:InstdAmt)"/>
</sct:InstdAmt>


                    <!-- CdtrAgt proviene del DbtrAgt de la DrctDbt (si existe) -->
                    <xsl:if test="sdd:DbtrAgt">
                        <sct:CdtrAgt>
                            <sct:FinInstnId>
                                <xsl:for-each select="sdd:DbtrAgt/sdd:FinInstnId/*">
    <xsl:element name="{local-name()}" namespace="urn:iso:std:iso:20022:tech:xsd:pain.001.001.09">
        <xsl:value-of select="."/>
    </xsl:element>
</xsl:for-each>

                            </sct:FinInstnId>
                        </sct:CdtrAgt>
                    </xsl:if>

                    <sct:Cdtr>
                        <xsl:if test="sdd:Dbtr/sdd:Nm"><sct:Nm><xsl:value-of select="sdd:Dbtr/sdd:Nm"/></sct:Nm></xsl:if>
                    </sct:Cdtr>

                    <sct:CdtrAcct>
                        <sct:Id>
                            <xsl:choose>
                                <xsl:when test="sdd:DbtrAcct/sdd:Id/sdd:IBAN">
                                    <sct:IBAN><xsl:value-of select="sdd:DbtrAcct/sdd:Id/sdd:IBAN"/></sct:IBAN>
                                </xsl:when>
                                <xsl:when test="sdd:DbtrAcct/sdd:Id/sdd:Othr">
                                    <sct:Othr>
                                        <sct:Id><xsl:value-of select="sdd:DbtrAcct/sdd:Id/sdd:Othr/sdd:Id"/></sct:Id>
                                    </sct:Othr>
                                </xsl:when>
                            </xsl:choose>
                        </sct:Id>
                    </sct:CdtrAcct>

                    <xsl:if test="sdd:RmtInf/sdd:Ustrd">
                        <sct:RmtInf><sct:Ustrd><xsl:value-of select="sdd:RmtInf/sdd:Ustrd"/></sct:Ustrd></sct:RmtInf>
                    </xsl:if>
                </sct:CdtTrfTxInf>
            </xsl:for-each>
        </sct:PmtInf>
    </xsl:template>

</xsl:stylesheet>
