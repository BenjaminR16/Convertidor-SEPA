package com.sstrategy.convertidor_sepa.service;

import org.springframework.stereotype.Service;
// import org.w3c.dom.Document;

// import javax.xml.parsers.DocumentBuilder;
// import javax.xml.parsers.DocumentBuilderFactory;

// import java.io.ByteArrayInputStream;

import com.sstrategy.convertidor_sepa.dto.FileInfo;

@Service
public class MetadataService {
    public FileInfo extractMetadata(byte[] xmlContent, String fileName, String type) throws Exception {
        // DocumentBuilder db =
        // DocumentBuilderFactory.newInstance().newDocumentBuilder();
        // Document doc = db.parse(new ByteArrayInputStream(xmlContent));

        long size = xmlContent.length;
        return new FileInfo(fileName, size, type);
    }
}
