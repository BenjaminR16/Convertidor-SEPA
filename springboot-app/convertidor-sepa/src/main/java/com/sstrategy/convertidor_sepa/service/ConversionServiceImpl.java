package com.sstrategy.convertidor_sepa.service;

import java.nio.charset.StandardCharsets;

import com.sstrategy.convertidor_sepa.dto.ConversionResult;
import com.sstrategy.convertidor_sepa.exception.ConversionException;
import com.sstrategy.convertidor_sepa.exception.FileProcessingException;
import com.sstrategy.convertidor_sepa.exception.ValidationException;
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
                throw new FileProcessingException("Archivo SCT vacío");
            byte[] xmlBytes = file.getBytes();

            String xmlString = new String(xmlBytes, StandardCharsets.UTF_8);

            final String xslt;
            if (xmlString.contains("urn:iso:std:iso:20022:tech:xsd:pain.001.001.03")) {
                // pain.001.001.03 -> pain.008.001.08
                try {
                    validationService.validate(xmlBytes, "/xsd/pain.001.001.03.xsd");
                } catch (Exception v03e) {
                    // Permitir continuar con transformacion aunque el orden de elementos no vaya en orden
                }
                xslt = "/xslt/sct03-to-sdd08.xslt";
            } else if (xmlString.contains("urn:iso:std:iso:20022:tech:xsd:pain.001.001.09")) {
                // pain.001.001.09 -> pain.008.001.08
                validationService.validate(xmlBytes, "/xsd/pain.001.001.09.xsd");
                xslt = "/xslt/sct-to-sdd.xslt";
            } else {
                throw new IllegalArgumentException("Versión SCT no soportada. Se espera pain.001.001.03 o pain.001.001.09");
            }

            String convertedXml = XsltTransformer.transform(file, xslt);
            validationService.validate(convertedXml.getBytes(StandardCharsets.UTF_8),
                    "/xsd/pain.008.001.08.xsd");
            return new ConversionResult(convertedXml);

        } catch (FileProcessingException | ValidationException e) {
            throw e;
        } catch (Exception e) {
            throw new ConversionException("Error en conversión SCT→SDD: " + e.getMessage(), e);
        }
    }

    // entrada sdd salida sct
    @Override
    public ConversionResult convertSddToSct(MultipartFile file) {
        try {
            if (file.isEmpty())
                throw new FileProcessingException("Archivo SDD vacío");
            byte[] xmlBytes = file.getBytes();

            String xmlString = new String(xmlBytes, StandardCharsets.UTF_8);

            final String xslt;
            if (xmlString.contains("urn:iso:std:iso:20022:tech:xsd:pain.008.001.02")) {
                // pain.008.001.02 -> pain.001.001.09
                try {
                    validationService.validate(xmlBytes, "/xsd/pain.008.001.02.xsd");
                } catch (Exception v02e) {
                    // Permitir continuar con transformacion aunque el orden de elementos no vaya en orden
                }
                xslt = "/xslt/sdd02-to-sct09.xslt";
            } else if (xmlString.contains("urn:iso:std:iso:20022:tech:xsd:pain.008.001.08")) {
                // pain.008.001.08 -> pain.001.001.09 
                validationService.validate(xmlBytes, "/xsd/pain.008.001.08.xsd");
                xslt = "/xslt/sdd-to-sct.xslt";
            } else {
                throw new IllegalArgumentException("Versión SDD no soportada. Se espera pain.008.001.02 o pain.008.001.08");
            }

            String convertedXml = XsltTransformer.transform(file, xslt);
            validationService.validate(convertedXml.getBytes(StandardCharsets.UTF_8), "/xsd/pain.001.001.09.xsd");
            return new ConversionResult(convertedXml);

        } catch (FileProcessingException | ValidationException e) {
            throw e;
        } catch (Exception e) {
            throw new ConversionException("Error en conversión SDD→SCT: " + e.getMessage(), e);
        }
    }
}
