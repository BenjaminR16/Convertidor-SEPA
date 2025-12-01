package com.sstrategy.convertidor_sepa.util;

import org.xml.sax.SAXException;

import java.io.ByteArrayInputStream;
import java.nio.charset.StandardCharsets;

import javax.xml.parsers.DocumentBuilderFactory;

public class XmlUtils {

    public static void ensureNoDtd(byte[] xmlBytes) throws SAXException {
        String xml = new String(xmlBytes, StandardCharsets.UTF_8);

        int dtdIndex = xml.indexOf("<!DOCTYPE");
        if (dtdIndex == -1) {
            return;
        }

        // Busca el cierre de la declaración DTD
        int endIndex = xml.indexOf(">", dtdIndex);
        if (endIndex == -1) {
            throw new SAXException("DTD mal formado en el archivo XML.");
        }

        String dtdDeclaration = xml.substring(dtdIndex, endIndex + 1).trim();

        // Solo se permite exactamente <!DOCTYPE xml>
        if (!"<!DOCTYPE xml>".equals(dtdDeclaration)) {
            throw new SAXException("DTD no permitido: " + dtdDeclaration);
        }
    }

    public static String detectNamespace(String xml) {
        try {
            var dbf = DocumentBuilderFactory.newInstance();
            dbf.setNamespaceAware(true);
            var db = dbf.newDocumentBuilder();
            var doc = db.parse(new ByteArrayInputStream(xml.getBytes(StandardCharsets.UTF_8)));

            return doc.getDocumentElement().getNamespaceURI();
        } catch (Exception e) {
            throw new RuntimeException("No se pudo detectar el namespace del XML", e);
        }
    }

}
