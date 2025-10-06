package com.sstrategy.convertidor_sepa.util;

import javax.xml.transform.*;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import org.springframework.web.multipart.MultipartFile;
import java.io.InputStream;
import java.io.StringReader;
import java.io.StringWriter;

public class XsltTransformer {

    public static String transform(MultipartFile xmlFile, String xsltPath) throws Exception {
        try (InputStream xsltStream = XsltTransformer.class.getResourceAsStream(xsltPath)) {

            if (xsltStream == null) {
                throw new IllegalArgumentException("No se encuentra el XSLT: " + xsltPath);
            }

            TransformerFactory factory = TransformerFactory.newInstance();
            Source xslt = new StreamSource(xsltStream);
            Transformer transformer = factory.newTransformer(xslt);

            String xmlInput = new String(xmlFile.getBytes(), "UTF-8");
            StringWriter writer = new StringWriter();
            transformer.transform(new StreamSource(new StringReader(xmlInput)), new StreamResult(writer));

            return writer.toString();

        } catch (TransformerException te) {
            throw new Exception("Error aplicando XSLT: " + te.getMessage(), te);
        }
    }
}
