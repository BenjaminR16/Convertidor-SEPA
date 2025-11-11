package com.sstrategy.convertidor_sepa.controller;

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
        String normalized = direction != null ? direction.trim().toLowerCase() : null;

        if (normalized == null || normalized.isEmpty() || "auto".equals(normalized)) {
            // Detectar dirección basándose en el namespace del XML
            String xml = new String(file.getBytes(), StandardCharsets.UTF_8).toLowerCase();
            if (xml.contains("urn:iso:std:iso:20022:tech:xsd:pain.001")) {
                normalized = "sct-to-sdd";
            } else if (xml.contains("urn:iso:std:iso:20022:tech:xsd:pain.008")) {
                normalized = "sdd-to-sct";
            } else {
                throw new IllegalArgumentException(
                        "No se pudo detectar el tipo del archivo (SCT/SDD). Especifique 'direction'.");
            }
        }

        if ("sct-to-sdd".equalsIgnoreCase(normalized)) {
            return conversionService.convertSctToSdd(file);
        } else if ("sdd-to-sct".equalsIgnoreCase(normalized)) {
            return conversionService.convertSddToSct(file);
        } else {
            throw new InvalidConversionDirectionException(
                    "Dirección de conversión inválida: " + direction + ". Valores permitidos: sct-to-sdd, sdd-to-sct");
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
    public ResponseEntity<?> download(@RequestParam MultipartFile file,
            @RequestParam(required = false) String direction) {
        try {
            ConversionResult result = convertFile(file, direction);

            byte[] xmlBytes = result.getConvertedXml().getBytes(StandardCharsets.UTF_8);
            ByteArrayResource resource = new ByteArrayResource(xmlBytes);

            String originalName = file.getOriginalFilename() != null ? file.getOriginalFilename() : "file.xml";
            String filename = "converted_" + originalName;

            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + filename + "\"")
                    .contentType(MediaType.APPLICATION_XML)
                    .contentLength(xmlBytes.length)
                    .body(resource);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error interno: " + e.getMessage());
        }
    }

    @PostMapping("/executive-view")
    public ResponseEntity<?> viewConverted(@RequestParam MultipartFile file,
            @RequestParam(required = false) String direction) {
        try {
            ConversionResult result = convertFile(file, direction);

            FileInfo metaInfo = metadataService.extractMetaInfo(
                    result.getConvertedXml().getBytes(StandardCharsets.UTF_8));

            return ResponseEntity.ok(metaInfo);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error interno: " + e.getMessage());
        }
    }

}
