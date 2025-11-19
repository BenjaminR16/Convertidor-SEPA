export interface FieldNode {
    label: string;
    value: string;
}

export function valoresGenericos(xml: string): FieldNode[] {

    if (!xml) return [];

    const parser = new DOMParser();
    const xmlDoc = parser.parseFromString(xml, "text/xml");
    const root = xmlDoc.documentElement;

    const tagNames: Record<string, string> = {
        "CstmrDrctDbtInitn": "Cliente domiciliación SEPA",
        "GrpHdr": "Cabecera del mensaje",
        "MsgId": "ID del mensaje",
        "CreDtTm": "Fecha de creación",
        "NbOfTxs": "Número de transacciones",
        "CtrlSum": "Importe total",
        "InitgPty": "Parte que inicia el pago",
        "Nm": "Nombre",
        "Id": "Identificación",
        "OrgId": "Identificación de organización",
        "PrvtId": "Identificación privada",
        "Othr": "Otra identificación",
        "BICOrBEI": "Código BIC o BEI",
        "PmtInf": "Información del pago",
        "PmtInfId": "ID del pago",
        "PmtMtd": "Método de pago",
        "BtchBookg": "Agrupación por lotes",
        "ReqdColltnDt": "Fecha de cobro requerida",
        "ChrgBr": "Responsable de los cargos",
        "PmtTpInf": "Tipo de pago",
        "SvcLvl": "Nivel de servicio",
        "LclInstrm": "Instrumento local",
        "SeqTp": "Tipo de secuencia",
        "CtgyPurp": "Propósito / Categoría",
        "Cd": "Código",
        "UltmtCdtr": "Acreedor final",
        "Cdtr": "Acreedor / Beneficiario",
        "CdtrAcct": "Cuenta del acreedor",
        "Ccy": "Moneda",
        "CdtrAgt": "Agente del acreedor",
        "FinInstnId": "Entidad financiera",
        "BIC": "Código BIC",
        "CdtrSchmeId": "Identificación del esquema de acreedor",
        "SchmeNm": "Nombre del esquema",
        "Prtry": "Propietario",
        "DrctDbtTxInf": "Transacción domiciliación",
        "PmtId": "Identificación del pago",
        "InstrId": "ID de instrucción",
        "EndToEndId": "ID EndToEnd",
        "InstdAmt": "Importe a instruir",
        "DrctDbtTx": "Detalle de domiciliación",
        "MndtRltdInf": "Información del mandato",
        "MndtId": "ID del mandato",
        "DtOfSgntr": "Fecha de firma",
        "AmdmntInd": "Indicador de enmienda",
        "AmdmntInfDtls": "Detalles de enmienda",
        "OrgnlDbtrAcct": "Cuenta original del deudor",
        "Dbtr": "Deudor / Ordenante",
        "DbtrAcct": "Cuenta del deudor",
        "DbtrAgt": "Agente del deudor",
        "UltmtDbtr": "Ordenante final",
        "Purp": "Propósito de la transacción",
        "RmtInf": "Información de remesa",
        "Ustrd": "Concepto no estructurado",
        "Strd": "Concepto estructurado",
        "CdOrPrtry": "Código o propietario",
        "Issr": "Emisor",
        "Ref": "Referencia",
        "PstlAdr": "Dirección postal",
        "Ctry": "País",
        "AdrLine": "Línea de dirección",
        "Dt": "Fecha",
        "BICFI": "Código BIC del banco",
        "CtryOfRes": "País de residencia",
    };

    function traverse(node: Element): FieldNode[] {
        const tag = node.tagName.includes(":") ? node.tagName.split(":")[1] : node.tagName;
        const children = Array.from(node.children);

        // Solo los nodos hoja tienen valor
        if (children.length === 0) {
            const value = node.textContent?.trim();
            if (value && !value.startsWith("urn:")) {
                return [{ label: tagNames[tag] || tag, value }];
            }
            return [];
        }
        //recorrer hijos
        let results: FieldNode[] = [];
        children.forEach(child => {
            results.push(...traverse(child));
        });
        return results;
    }

    return traverse(root);
}
