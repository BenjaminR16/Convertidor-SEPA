package com.sstrategy.convertidor_sepa.service;

import org.springframework.stereotype.Service;
import org.w3c.dom.Document;

import java.io.ByteArrayInputStream;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathFactory;

import com.sstrategy.convertidor_sepa.dto.FileInfo;
import com.sstrategy.convertidor_sepa.exception.MetadataExtractionException;

@Service
public class MetadataService {

    public FileInfo extractMetaInfo(byte[] xmlContent) throws MetadataExtractionException {
        try {
            DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
            dbf.setNamespaceAware(true);
            DocumentBuilder db = dbf.newDocumentBuilder();
            Document doc = db.parse(new ByteArrayInputStream(xmlContent));

            XPath xpath = XPathFactory.newInstance().newXPath();

            String msgId = getXPathText(doc, xpath, "//*[local-name()='GrpHdr']/*[local-name()='MsgId']");
            String fecha = getXPathText(doc, xpath, "//*[local-name()='GrpHdr']/*[local-name()='CreDtTm']");
            String nbOfTxs = getXPathText(doc, xpath, "//*[local-name()='GrpHdr']/*[local-name()='NbOfTxs']");
            String ctrlSum = getXPathText(doc, xpath, "//*[local-name()='GrpHdr']/*[local-name()='CtrlSum']");
            String nomEmpresa = getXPathText(doc, xpath,
                    "//*[local-name()='GrpHdr']/*[local-name()='InitgPty']/*[local-name()='Nm']");

            return new FileInfo(msgId, fecha, nbOfTxs, ctrlSum, nomEmpresa);
        } catch (Exception e) {
            throw new MetadataExtractionException("Error al extraer metadatos del XML: " + e.getMessage(), e);
        }
    }

    private String getXPathText(Object context, XPath xpath, String expression) {
        try {
            String value = xpath.compile(expression).evaluate(context);
            return (value == null || value.isEmpty()) ? "Sin valores" : value;
        } catch (Exception e) {
            return "Sin valores";
        }
    }
}
