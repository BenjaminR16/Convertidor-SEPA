package com.sstrategy.convertidor_sepa.service;

import java.nio.charset.StandardCharsets;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import com.sstrategy.convertidor_sepa.dto.ConversionResult;
import com.sstrategy.convertidor_sepa.exception.ConversionException;
import com.sstrategy.convertidor_sepa.exception.FileProcessingException;
import com.sstrategy.convertidor_sepa.exception.ValidationException;
import com.sstrategy.convertidor_sepa.util.XsltTransformer;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import com.sstrategy.convertidor_sepa.util.XmlUtils;

import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class ConversionServiceImpl implements ConversionService {
    private final ValidationService validationService;

    @Override
    public ConversionResult convertSctToSdd(MultipartFile file) {
        return convert(
                file,
                "SCT",
                Map.of(
                        "urn:iso:std:iso:20022:tech:xsd:pain.001.001.03",
                        new ConversionSpec("/xsd/pain.001.001.03.xsd", "/xslt/sct103-to-sdd108.xslt"),
                        "urn:iso:std:iso:20022:tech:xsd:pain.001.003.03",
                        new ConversionSpec("/xsd/pain.001.003.03.xsd", "/xslt/sct303-to-sdd108.xslt"),
                        "urn:iso:std:iso:20022:tech:xsd:pain.001.001.09",
                        new ConversionSpec("/xsd/pain.001.001.09.xsd", "/xslt/sct109-to-sdd108.xslt")),
                "/xsd/pain.008.001.08.xsd",
                "Versión SCT no soportada. Se espera pain.001.001.03, pain.001.001.09 o pain.001.003.03",
                "Error en conversión SCT→SDD");
    }

    @Override
    public ConversionResult convertSddToSct(MultipartFile file) {
        return convert(
                file,
                "SDD",
                Map.of(
                        "urn:iso:std:iso:20022:tech:xsd:pain.008.001.02",
                        new ConversionSpec("/xsd/pain.008.001.02.xsd", "/xslt/sdd102-to-sct109.xslt"),
                        "urn:iso:std:iso:20022:tech:xsd:pain.008.003.02",
                        new ConversionSpec("/xsd/pain.008.003.02.xsd", "/xslt/sdd302-to-sct109.xslt"),
                        "urn:iso:std:iso:20022:tech:xsd:pain.008.001.08",
                        new ConversionSpec("/xsd/pain.008.001.08.xsd", "/xslt/sdd108-to-sct109.xslt")),
                "/xsd/pain.001.001.09.xsd",
                "Versión SDD no soportada. Se espera pain.008.001.02, pain.008.001.08 o pain.008.003.02",
                "Error en conversión SDD→SCT");
    }

    private ConversionResult convert(MultipartFile file,
            String typeLabel,
            Map<String, ConversionSpec> conversionMap,
            String outputXsd,
            String unsupportedMessage,
            String errorPrefix) {
        try {
            if (file.isEmpty()) {
                throw new FileProcessingException("Archivo " + typeLabel + " vacío");
            }

            byte[] xmlBytes = file.getBytes();
            XmlUtils.ensureNoDtd(xmlBytes);
            String xmlString = new String(xmlBytes, StandardCharsets.UTF_8);

            // Detectar versión por el namespace
            ConversionSpec spec = conversionMap.entrySet().stream()
                    .filter(entry -> xmlString.contains(entry.getKey()))
                    .map(Map.Entry::getValue)
                    .findFirst()
                    .orElseThrow(() -> new IllegalArgumentException(unsupportedMessage));

            // Validar entrada
            try {
                validationService.validate(xmlBytes, spec.inputXsd());
            } catch (Exception ignored) {
                log.warn("Validación inicial falló para {}, continuando transformación...", spec.inputXsd());
            }

            // Transformar
            String convertedXml = XsltTransformer.transform(file, spec.xsltPath());
            log.info("Transformación {} completada con XSLT: {}", typeLabel, spec.xsltPath());

            // Validar salida
            validationService.validate(convertedXml.getBytes(StandardCharsets.UTF_8), outputXsd);
            log.info("Validación final exitosa contra {}", outputXsd);

            return new ConversionResult(convertedXml);

        } catch (FileProcessingException | ValidationException e) {
            throw e;
        } catch (Exception e) {
            log.error("{}: {}", errorPrefix, e.getMessage(), e);
            throw new ConversionException(errorPrefix + ": " + e.getMessage(), e);
        }
    }

    // guarda la especificación de conversión inputXsd + xsltPath
    private record ConversionSpec(String inputXsd, String xsltPath) {
    }
}
