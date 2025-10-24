<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:sct="urn:iso:std:iso:20022:tech:xsd:pain.001.001.09"
    xmlns:sdd="urn:iso:std:iso:20022:tech:xsd:pain.008.001.08"
    exclude-result-prefixes="sct">

    <xsl:output method="xml" encoding="UTF-8" indent="yes" /> <!-- Salida como XML indentado -->
    <xsl:template match="/sct:Document">
        <!-- Coincide con el elemento raíz Document de SCT -->
        <sdd:Document
            xmlns:sdd="urn:iso:std:iso:20022:tech:xsd:pain.008.001.08"> <!-- Crear elemento raíz
            Document de SDD -->
            <sdd:CstmrDrctDbtInitn> <!-- Iniciar Customer Direct Debit Initiation -->
                <xsl:call-template name="mapGrpHdr" /> <!-- Mapear cabecera de grupo usando plantilla
                nombrada -->
                <xsl:for-each select="sct:CstmrCdtTrfInitn/sct:PmtInf"> <!-- Para cada Payment
                    Information en SCT -->
                    <sdd:PmtInf> <!-- Crear
                        Payment Information en SDD -->
                        <xsl:if test="sct:PmtInfId"> <!-- Si existe Payment Info ID -->
                            <sdd:PmtInfId>
                                <xsl:value-of select="sct:PmtInfId" /> <!-- Copiar Payment Info ID -->
                            </sdd:PmtInfId>
                        </xsl:if>
                        <sdd:PmtMtd>DD</sdd:PmtMtd> <!-- Establecer método de pago a Débito Directo -->
                        <sdd:NbOfTxs>
                            <xsl:value-of select="count(sct:CdtTrfTxInf)" /> <!-- Contar número de
                            transacciones -->
                        </sdd:NbOfTxs>
                        <xsl:if test="sct:CtrlSum"> <!-- Si existe Control Sum -->
                            <sdd:CtrlSum>
                                <xsl:value-of select="sct:CtrlSum" /> <!-- Copiar Control Sum -->
                            </sdd:CtrlSum>
                        </xsl:if>
                        <sdd:PmtTpInf> <!-- Información del tipo de pago -->
                            <sdd:SvcLvl>
                                <sdd:Cd>SEPA</sdd:Cd> <!-- Establecer nivel de servicio a SEPA -->
                            </sdd:SvcLvl>
                            <sdd:LclInstrm>
                                <sdd:Cd>CORE</sdd:Cd> <!-- Establecer instrumento local a CORE -->
                            </sdd:LclInstrm>
                            <sdd:SeqTp>
                                <xsl:choose>
                                    <xsl:when test="sct:SeqTp"><xsl:value-of select="sct:SeqTp" /></xsl:when> <!--
                                    Usar tipo de secuencia si está presente -->
                                    <xsl:otherwise>FRST</xsl:otherwise> <!-- Si no, por defecto FRST -->
                                </xsl:choose>
                            </sdd:SeqTp>
                        </sdd:PmtTpInf>
                        <xsl:if test="sct:ReqdExctnDt/sct:Dt or sct:ReqdExctnDt/sct:DtTm"> <!-- Si
                            existe fecha de ejecución solicitada -->
                            <sdd:ReqdColltnDt>
                                <xsl:choose>
                                    <xsl:when test="sct:ReqdExctnDt/sct:Dt">
                                        <xsl:value-of select="sct:ReqdExctnDt/sct:Dt" /> <!-- Copiar
                                        fecha (Dt) -->
                                    </xsl:when>
                                    <xsl:when test="sct:ReqdExctnDt/sct:DtTm">
                                        <xsl:value-of
                                            select="substring-before(sct:ReqdExctnDt/sct:DtTm, 'T')" /> <!--
                                        Copiar fecha de DtTm -->
                                    </xsl:when>
                                </xsl:choose>
                            </sdd:ReqdColltnDt>
                        </xsl:if>
                        <sdd:Cdtr> <!-- Información del acreedor (desde deudor en SCT) -->
                            <sdd:Nm>
                                <xsl:value-of
                                    select="sct:Dbtr/sct:Nm | sct:CdtTrfTxInf[1]/sct:Dbtr/sct:Nm" /> <!--
                                Copiar nombre del deudor -->
                            </sdd:Nm>
                            <xsl:if
                                test="sct:Dbtr/sct:PstlAdr/sct:Ctry or sct:CdtTrfTxInf[1]/sct:Dbtr/sct:PstlAdr/sct:Ctry"> <!--
                                Si existe país del deudor -->
                                <sdd:CtryOfRes>
                                    <xsl:value-of
                                        select="sct:Dbtr/sct:PstlAdr/sct:Ctry | sct:CdtTrfTxInf[1]/sct:Dbtr/sct:PstlAdr/sct:Ctry" /> <!--
                                    Copiar país del deudor -->
                                </sdd:CtryOfRes>
                            </xsl:if>
                            <xsl:if test="sct:Dbtr/sct:Id or sct:CdtTrfTxInf[1]/sct:Dbtr/sct:Id"> <!--
                                Si existe ID del deudor -->
                                <sdd:Id>
                                    <xsl:if test="sct:Dbtr/sct:Id/sct:OrgId/sct:Othr/sct:Id"> <!-- Si
                                        existe ID de organización del deudor -->
                                        <sdd:OrgId>
                                            <sdd:Othr>
                                                <sdd:Id>
                                                    <xsl:value-of
                                                        select="sct:Dbtr/sct:Id/sct:OrgId/sct:Othr/sct:Id | sct:CdtTrfTxInf[1]/sct:Dbtr/sct:Id/sct:OrgId/sct:Othr/sct:Id" /> <!--
                                                    Copiar ID de organización del deudor -->
                                                </sdd:Id>
                                            </sdd:Othr>
                                        </sdd:OrgId>
                                    </xsl:if>
                                </sdd:Id>
                            </xsl:if>
                        </sdd:Cdtr>
                        <sdd:CdtrAcct> <!-- Cuenta del acreedor (desde cuenta del deudor en SCT) -->
                            <sdd:Id>
                                <sdd:IBAN>
                                    <xsl:value-of
                                        select="sct:DbtrAcct/sct:Id/sct:IBAN | sct:CdtTrfTxInf[1]/sct:DbtrAcct/sct:Id/sct:IBAN" /> <!--
                                    Copiar IBAN del deudor -->
                                </sdd:IBAN>
                            </sdd:Id>
                        </sdd:CdtrAcct>
                        <!-- CdtrAgt requerido en pain.008.001.08, siempre generar con valor por
                        defecto si falta -->
                        <sdd:CdtrAgt>
                            <sdd:FinInstnId>
                                <xsl:choose>
                                    <xsl:when
                                        test="sct:DbtrAgt/sct:FinInstnId/sct:BICFI or sct:CdtTrfTxInf[1]/sct:DbtrAgt/sct:FinInstnId/sct:BICFI">
                                        <sdd:BICFI>
                                            <xsl:value-of
                                                select="sct:DbtrAgt/sct:FinInstnId/sct:BICFI | sct:CdtTrfTxInf[1]/sct:DbtrAgt/sct:FinInstnId/sct:BICFI" /> <!--
                                            Copiar BICFI del agente del deudor -->
                                        </sdd:BICFI>
                                    </xsl:when>
                                    <xsl:when
                                        test="sct:DbtrAgt/sct:FinInstnId/sct:Othr/sct:Id or sct:CdtTrfTxInf[1]/sct:DbtrAgt/sct:FinInstnId/sct:Othr/sct:Id">
                                        <sdd:Othr>
                                            <sdd:Id>
                                                <xsl:value-of
                                                    select="sct:DbtrAgt/sct:FinInstnId/sct:Othr/sct:Id | sct:CdtTrfTxInf[1]/sct:DbtrAgt/sct:FinInstnId/sct:Othr/sct:Id" /> <!--
                                                Copiar otro ID del agente del deudor -->
                                            </sdd:Id>
                                        </sdd:Othr>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <sdd:Othr>
                                            <sdd:Id>NOTPROVIDED</sdd:Id> <!-- Valor por defecto si no
                                            hay ID -->
                                        </sdd:Othr>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </sdd:FinInstnId>
                        </sdd:CdtrAgt>
                        <xsl:for-each select="sct:CdtTrfTxInf"> <!-- Para cada transacción de
                            transferencia de crédito -->
                            <sdd:DrctDbtTxInf> <!-- Crear
                                transacción de débito directo -->
                                <sdd:PmtId>
                                    <sdd:EndToEndId>
                                        <xsl:value-of select="sct:PmtId/sct:EndToEndId" /> <!--
                                        Copiar EndToEnd ID -->
                                    </sdd:EndToEndId>
                                </sdd:PmtId>

                                <sdd:InstdAmt Ccy="{sct:Amt/sct:InstdAmt/@Ccy}"> <!-- Establecer
                                    importe e importe en moneda -->
                                    <xsl:value-of select="sct:Amt/sct:InstdAmt" /> <!-- Copiar
                                    importe -->
                                </sdd:InstdAmt>
                                <sdd:DrctDbtTx>
                                    <sdd:MndtRltdInf>
                                        <sdd:MndtId>
                                            <xsl:choose>
                                                <xsl:when test="sct:PmtId/sct:InstrId">
                                                    <xsl:value-of select="sct:PmtId/sct:InstrId" /> <!--
                                                    Usar Instruction ID si está presente -->
                                                </xsl:when>
                                                <xsl:when test="sct:PmtId/sct:EndToEndId">
                                                    <xsl:value-of
                                                        select="concat('MNDT-', sct:PmtId/sct:EndToEndId)" /> <!--
                                                    Si no, usar EndToEnd ID -->
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of
                                                        select="concat('MNDT-', position())" /> <!--
                                                    Si no, usar posición como valor por defecto -->
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </sdd:MndtId>
                                    </sdd:MndtRltdInf>
                                </sdd:DrctDbtTx>
                                <xsl:if test="sct:UltmtCdtr"> <!-- Si existe Ultimate Creditor -->
                                    <sdd:UltmtCdtr>
                                        <sdd:Nm>
                                            <xsl:value-of select="sct:UltmtCdtr/sct:Nm" /> <!--
                                            Copiar nombre de Ultimate Creditor -->
                                        </sdd:Nm>
                                    </sdd:UltmtCdtr>
                                </xsl:if>
                                <!-- DbtrAgt debe ir antes de Dbtr, siempre generar con valor por
                                defecto si falta -->
                                <sdd:DbtrAgt>
                                    <sdd:FinInstnId>
                                        <xsl:choose>
                                            <xsl:when test="sct:CdtrAgt/sct:FinInstnId/sct:BICFI">
                                                <sdd:BICFI>
                                                    <xsl:value-of
                                                        select="sct:CdtrAgt/sct:FinInstnId/sct:BICFI" /> <!--
                                                    Copiar BICFI del agente del acreedor -->
                                                </sdd:BICFI>
                                            </xsl:when>
                                            <xsl:when
                                                test="sct:CdtrAgt/sct:FinInstnId/sct:Othr/sct:Id">
                                                <sdd:Othr>
                                                    <sdd:Id>
                                                        <xsl:value-of
                                                            select="sct:CdtrAgt/sct:FinInstnId/sct:Othr/sct:Id" /> <!--
                                                        Copiar otro ID del agente del acreedor -->
                                                    </sdd:Id>
                                                </sdd:Othr>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <sdd:Othr>
                                                    <sdd:Id>NOTPROVIDED</sdd:Id> <!-- Valor por
                                                    defecto si no hay ID -->
                                                </sdd:Othr>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </sdd:FinInstnId>
                                </sdd:DbtrAgt>
                                <sdd:Dbtr> <!-- Información del deudor (desde acreedor en SCT) -->
                                    <sdd:Nm>
                                        <xsl:value-of select="sct:Cdtr/sct:Nm | ../sct:Cdtr/sct:Nm" /> <!--
                                        Copiar nombre del acreedor -->
                                    </sdd:Nm>
                                    <xsl:if test="sct:Cdtr/sct:PstlAdr/sct:Ctry"> <!-- Si existe país
                                        del acreedor -->
                                        <sdd:CtryOfRes>
                                            <xsl:value-of select="sct:Cdtr/sct:PstlAdr/sct:Ctry" /> <!--
                                            Copiar país del acreedor -->
                                        </sdd:CtryOfRes>
                                    </xsl:if>
                                </sdd:Dbtr>

                                <sdd:DbtrAcct> <!-- Cuenta del deudor (desde cuenta del acreedor en
                                    SCT) -->
                                    <sdd:Id>
                                        <sdd:IBAN>
                                            <xsl:value-of select="sct:CdtrAcct/sct:Id/sct:IBAN" /> <!--
                                            Copiar IBAN del acreedor -->
                                        </sdd:IBAN>
                                    </sdd:Id>
                                </sdd:DbtrAcct>

                                <xsl:if test="sct:RmtInf/sct:Ustrd"> <!-- Si existe información de
                                    remesa -->
                                    <sdd:RmtInf>
                                        <sdd:Ustrd>
                                            <xsl:value-of select="sct:RmtInf/sct:Ustrd" /> <!--
                                            Copiar información de remesa -->
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
    <xsl:template name="mapGrpHdr"> <!-- Plantilla para mapear la cabecera de grupo -->
        <xsl:variable name="gh"
            select="/sct:Document/sct:CstmrCdtTrfInitn/sct:GrpHdr" /> <!-- Obtener nodo de cabecera
        de grupo -->
        <sdd:GrpHdr>
            <xsl:if test="$gh/sct:MsgId"><sdd:MsgId>
                    <xsl:value-of select="$gh/sct:MsgId" /> <!-- Copiar Message ID -->
                </sdd:MsgId></xsl:if>
            <xsl:if test="$gh/sct:CreDtTm"><sdd:CreDtTm>
                    <xsl:value-of select="$gh/sct:CreDtTm" /> <!-- Copiar fecha y hora de creación -->
                </sdd:CreDtTm></xsl:if>
            <sdd:NbOfTxs>
                <xsl:value-of
                    select="count(/sct:Document/sct:CstmrCdtTrfInitn/sct:PmtInf/sct:CdtTrfTxInf)" /> <!--
                Contar todas las transacciones -->
            </sdd:NbOfTxs>
            <xsl:if test="$gh/sct:CtrlSum"><sdd:CtrlSum>
                    <xsl:value-of select="$gh/sct:CtrlSum" /> <!-- Copiar Control Sum -->
                </sdd:CtrlSum></xsl:if>
            <xsl:if test="$gh/sct:InitgPty">
                <sdd:InitgPty>
                    <sdd:Nm>
                        <xsl:value-of select="$gh/sct:InitgPty/sct:Nm" /> <!-- Copiar nombre de la
                        parte iniciadora -->
                    </sdd:Nm>
                </sdd:InitgPty>
            </xsl:if>
        </sdd:GrpHdr>
    </xsl:template>
    <xsl:template match="node()|@*" /> <!-- Plantilla identidad para ignorar nodos no coincidentes -->

</xsl:stylesheet>