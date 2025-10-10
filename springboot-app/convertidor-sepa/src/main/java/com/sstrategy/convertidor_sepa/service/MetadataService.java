package com.sstrategy.convertidor_sepa.service;

import org.springframework.stereotype.Service;
import org.w3c.dom.Document;
import org.w3c.dom.Node;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.xpath.*;

import java.io.ByteArrayInputStream;

import com.sstrategy.convertidor_sepa.dto.FileInfo;

@Service
public class MetadataService {
    public FileInfo extractMetadata(byte[] xmlContent, String fileName, String type) throws Exception {
        DocumentBuilder db = DocumentBuilderFactory.newInstance().newDocumentBuilder();
        Document doc = db.parse(new ByteArrayInputStream(xmlContent));

        XPath xpath = XPathFactory.newInstance().newXPath();

        String total = getXPathText(doc, xpath, "//GrpHdr/CtrlSum");
        String currency = getXPathAttribute(doc, xpath, "//*[local-name()='InstdAmt']", "Ccy");
        String transactions = getXPathText(doc, xpath, "//GrpHdr/NbOfTxs");
        String creationDate = getXPathText(doc, xpath, "//GrpHdr/CreDtTm");
        String initiatingParty = getXPathText(doc, xpath, "//GrpHdr/InitgPty/Nm");

        long size = xmlContent.length;

        return new FileInfo(
                fileName,
                size,
                type + " XML",
                total,
                currency,
                transactions,
                creationDate,
                initiatingParty);
    }

    private String getXPathText(Document doc, XPath xpath, String expression) {
        try {
            return xpath.compile(expression).evaluate(doc);
        } catch (Exception e) {
            return "Sin valores";
        }
    }

    private String getXPathAttribute(Document doc, XPath xpath, String expression, String attr) {
        try {
            Node node = (Node) xpath.compile(expression).evaluate(doc, XPathConstants.NODE);
            if (node != null && node.getAttributes() != null) {
                Node attrNode = node.getAttributes().getNamedItem(attr);
                if (attrNode != null)
                    return attrNode.getTextContent();
            }
            return "Sin valores";
        } catch (Exception e) {
            return "Sin valores";
        }
    }
}