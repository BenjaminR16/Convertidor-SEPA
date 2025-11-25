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
        "Document": "Documento raíz",
        "CstmrCdtTrfInitn": "Cliente – Transferencia SEPA (pain.001)",
        "CstmrDrctDbtInitn": "Cliente – Domiciliación SEPA (pain.008)",
        "GrpHdr": "Cabecera del mensaje",
        "MsgId": "ID del mensaje",
        "CreDtTm": "Fecha y hora de creación",
        "NbOfTxs": "Número de transacciones",
        "CtrlSum": "Importe total",
        "InitgPty": "Parte iniciadora",
        "Nm": "Nombre",
        "Id": "Identificación",
        "OrgId": "Identificación de organización",
        "PrvtId": "Identificación privada",
        "Othr": "Otra identificación",
        "BICOrBEI": "Código BIC o BEI",
        "PmtInf": "Información del pago",
        "PmtInfId": "ID de la información del pago",
        "PmtMtd": "Método de pago",
        "BtchBookg": "Contabilización por lotes",
        "ReqdExctnDt": "Fecha de ejecución requerida",
        "ReqdColltnDt": "Fecha de cobro requerida (SEPA core)",
        "ChrgBr": "Soporte de gastos",
        "PmtTpInf": "Tipo de pago",
        "SvcLvl": "Nivel de servicio",
        "LclInstrm": "Instrumento local",
        "SeqTp": "Tipo de secuencia",
        "CtgyPurp": "Propósito / categoría",
        "Cd": "Código",
        "PstlAdr": "Dirección postal",
        "Ctry": "País",
        "AdrLine": "Línea de dirección",
        "Dbtr": "Deudor / Ordenante",
        "DbtrAcct": "Cuenta del deudor",
        "DbtrAgt": "Agente del deudor",
        "UltmtDbtr": "Deudor final",
        "Purp": "Propósito del pago",
        "Cdtr": "Acreedor / Beneficiario",
        "CdtrAcct": "Cuenta del acreedor",
        "Ccy": "Moneda",
        "CdtrAgt": "Agente del acreedor",
        "FinInstnId": "Identificación de la entidad financiera",
        "BIC": "Código BIC",
        "CdtrSchmeId": "Identificador de acreedor SEPA",
        "SchmeNm": "Nombre del esquema",
        "Prtry": "Propietario / valor propio",
        "PmtId": "Identificación del pago",
        "InstrId": "ID de instrucción",
        "EndToEndId": "ID End-to-End",
        "Amt": "Importe",
        "InstdAmt": "Importe instruido",
        "DrctDbtTxInf": "Información de domiciliación",
        "DrctDbtTx": "Transacción de domiciliación",
        "MndtRltdInf": "Información del mandato",
        "MndtId": "ID del mandato",
        "DtOfSgntr": "Fecha de firma del mandato",
        "AmdmntInd": "Indicador de enmienda",
        "AmdmntInfDtls": "Detalles de la enmienda",
        "OrgnlDbtrAcct": "Cuenta original del deudor",
        "RmtInf": "Información de remesa",
        "Ustrd": "Concepto no estructurado",
        "Strd": "Concepto estructurado",
        "CdOrPrtry": "Código o propietario",
        "Issr": "Emisor",
        "Ref": "Referencia",
        "Tp": "Tipo de referencia",
        "CdtrRefInf": "Información de referencia del acreedor",
        "IBAN": "IBAN",
        "Dt": "Fecha",
        "BICFI": "Código BIC de la entidad financiera",
        "CtryOfRes": "País de residencia",
    };


    function read(node: Element): FieldNode[] {
        const tag = node.tagName.includes(":") ? node.tagName.split(":")[1] : node.tagName;
        const children = Array.from(node.children);
        //obtener valor si no tiene hijos
        if (children.length === 0) {
            let value = node.textContent?.trim() || "";
            value = value.replace(/\s+/g, " ");
            if (value && !value.startsWith("urn:")) {
                return [{ label: tagNames[tag] || tag, value }];
            }
            return [];
        }

        //recorrer hijos
        let results: FieldNode[] = [];
        children.forEach(child => {
            results.push(...read(child));
        });
        return results;
    }
    return read(root);
}
