package com.sstrategy.convertidor_sepa.util;

import javax.xml.transform.*;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import java.io.StringReader;
import java.io.StringWriter;

public class XsltTransformer {
    public static String transform(String xmlInput, String xsltPath) throws TransformerException {
        TransformerFactory factory = TransformerFactory.newInstance();
        Source xslt = new StreamSource(XsltTransformer.class.getResourceAsStream(xsltPath));
        Transformer transformer = factory.newTransformer(xslt);

        StringWriter writer = new StringWriter();
        transformer.transform(new StreamSource(new StringReader(xmlInput)), new StreamResult(writer));

        return writer.toString();
    }
}
