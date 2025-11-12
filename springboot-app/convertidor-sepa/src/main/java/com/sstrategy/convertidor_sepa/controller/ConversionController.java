package com.sstrategy.convertidor_sepa.controller;

import java.io.IOException;
import java.nio.charset.StandardCharsets;

import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.http.MediaType;

import com.sstrategy.convertidor_sepa.dto.ConversionResult;
import com.sstrategy.convertidor_sepa.dto.FileInfo;
import com.sstrategy.convertidor_sepa.exception.FileProcessingException;
import com.sstrategy.convertidor_sepa.exception.InvalidConversionDirectionException;
import com.sstrategy.convertidor_sepa.service.ConversionService;
import com.sstrategy.convertidor_sepa.service.MetadataService;

@RestController
@RequestMapping("/api/v1/convert")
public class ConversionController {

    private final ConversionService conversionService;
    private final MetadataService metadataService;

    public ConversionController(ConversionService conversionService, MetadataService metadataService) {
        this.conversionService = conversionService;
        this.metadataService = metadataService;
    }

    private ConversionResult convertFile(MultipartFile file, String direction) throws Exception {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("El archivo proporcionado está vacío o es nulo.");
        }

        String dir = normalizeDirection(direction);

        if (dir == null) {
            dir = detectDirection(file);
        }

        return switch (dir) {
            case "sct-to-sdd" -> conversionService.convertSctToSdd(file);
            case "sdd-to-sct" -> conversionService.convertSddToSct(file);
            default -> throw new InvalidConversionDirectionException(
                    "Dirección de conversión inválida: " + direction + ". Valores permitidos: sct-to-sdd, sdd-to-sct");
        };
    }

    private String normalizeDirection(String direction) {
        if (direction == null)
            return null;
        String normalized = direction.trim().toLowerCase();
        return normalized.isEmpty() || "auto".equals(normalized) ? null : normalized;
    }

    private String detectDirection(MultipartFile file) throws FileProcessingException {
        try {
            String xml = new String(file.getBytes(), StandardCharsets.UTF_8).toLowerCase();

            if (xml.contains("urn:iso:std:iso:20022:tech:xsd:pain.001")) {
                return "sct-to-sdd";
            } else if (xml.contains("urn:iso:std:iso:20022:tech:xsd:pain.008")) {
                return "sdd-to-sct";
            } else {
                throw new InvalidConversionDirectionException(
                        "No se pudo detectar el tipo del archivo (SCT/SDD). Especifique 'direction'.");
            }
        } catch (IOException e) {
            throw new FileProcessingException("Error al leer el archivo: " + e.getMessage(), e);
        }
    }

    @PostMapping
    public ResponseEntity<?> convert(@RequestParam MultipartFile file,
            @RequestParam(required = false) String direction) {
        try {
            ConversionResult result = convertFile(file, direction);
            return ResponseEntity.ok(result);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error en conversión: " + e.getMessage());
        }
    }

    @PostMapping("/download")
    public ResponseEntity<ByteArrayResource> download(@RequestParam MultipartFile file,
            @RequestParam(required = false) String direction) throws Exception {
        ConversionResult result = convertFile(file, direction);

        byte[] xmlBytes = getUtf8Bytes(result.getConvertedXml());
        ByteArrayResource resource = new ByteArrayResource(xmlBytes);

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment")
                .contentType(MediaType.APPLICATION_XML)
                .contentLength(xmlBytes.length)
                .body(resource);
    }

    @PostMapping("/executive-view")
    public FileInfo viewConverted(@RequestParam MultipartFile file,
            @RequestParam(required = false) String direction) throws Exception {
        ConversionResult result = convertFile(file, direction);
        return metadataService.extractMetaInfo(getUtf8Bytes(result.getConvertedXml()));
    }

    private byte[] getUtf8Bytes(String xml) {
        return xml.getBytes(StandardCharsets.UTF_8);
    }

}
