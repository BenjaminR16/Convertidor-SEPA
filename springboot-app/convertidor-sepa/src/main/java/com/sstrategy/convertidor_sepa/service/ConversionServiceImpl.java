package com.sstrategy.convertidor_sepa.service;

import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.sstrategy.convertidor_sepa.dto.ConversionResult;
import com.sstrategy.convertidor_sepa.dto.FileInfo;
import com.sstrategy.convertidor_sepa.util.XsltTransformer;

@Service
public class ConversionServiceImpl implements ConversionService {
    @Override
    public ConversionResult convertSctToSdd(MultipartFile file) {
        try {
            String convertedXml = XsltTransformer.transform(new String(file.getBytes()), "/xslt/sct-to-sdd.xslt");
            FileInfo metadata = new FileInfo(file.getOriginalFilename(), file.getSize(), convertedXml);
            return new ConversionResult(convertedXml, metadata);
        } catch (Exception e) {
            throw new RuntimeException("Error en conversión SCT->SDD: " + e.getMessage());
        }
    }

    @Override
    public ConversionResult convertSddToSct(MultipartFile file) {
        try {
            String convertedXml = XsltTransformer.transform(new String(file.getBytes()), "/xslt/sdd-to-sct.xslt");
            FileInfo metadata = new FileInfo(file.getOriginalFilename(), file.getSize(), convertedXml);
            return new ConversionResult(convertedXml, metadata);
        } catch (Exception e) {
            throw new RuntimeException("Error en conversión SDD->SCT: " + e.getMessage());
        }
    }
}
