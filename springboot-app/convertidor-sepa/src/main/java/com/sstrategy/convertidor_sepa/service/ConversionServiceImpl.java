package com.sstrategy.convertidor_sepa.service;

import com.sstrategy.convertidor_sepa.dto.ConversionResult;
import com.sstrategy.convertidor_sepa.dto.FileInfo;
import com.sstrategy.convertidor_sepa.util.XsltTransformer;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
public class ConversionServiceImpl implements ConversionService {

    private final ValidationService validationService;

    public ConversionServiceImpl(ValidationService validationService) {
        this.validationService = validationService;
    }

    // entrada sct salida sdd
    @Override
    public ConversionResult convertSctToSdd(MultipartFile file) {
        try {
            if (file.isEmpty())
                throw new IllegalArgumentException("Archivo SCT vacío");
            byte[] xmlBytes = file.getBytes();
            validationService.validate(xmlBytes, "/xsd/pain.001.001.09.xsd");
            String convertedXml = XsltTransformer.transform(file, "/xslt/sct-to-sdd.xslt");
            validationService.validate(convertedXml.getBytes(), "/xsd/pain.008.001.08.xsd");
            FileInfo metadata = new FileInfo(file.getOriginalFilename(), file.getSize(), "SCT → SDD");
            return new ConversionResult(convertedXml, metadata);

        } catch (Exception e) {
            throw new RuntimeException("Error en conversión SCT→SDD: " + e.getMessage(), e);
        }
    }

    // entrada sdd salida sct
    @Override
    public ConversionResult convertSddToSct(MultipartFile file) {
        try {
            if (file.isEmpty())
                throw new IllegalArgumentException("Archivo SDD vacío");
            byte[] xmlBytes = file.getBytes();
            validationService.validate(xmlBytes, "/xsd/pain.008.001.08.xsd");
            String convertedXml = XsltTransformer.transform(file, "/xslt/sdd-to-sct.xslt");
            validationService.validate(convertedXml.getBytes(), "/xsd/pain.001.001.09.xsd");
            FileInfo metadata = new FileInfo(file.getOriginalFilename(), file.getSize(), "SDD → SCT");
            return new ConversionResult(convertedXml, metadata);

        } catch (Exception e) {
            throw new RuntimeException("Error en conversión SDD→SCT: " + e.getMessage(), e);
        }
    }
}
