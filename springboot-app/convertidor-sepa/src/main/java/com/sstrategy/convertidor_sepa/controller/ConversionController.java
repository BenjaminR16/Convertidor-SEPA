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

    @PostMapping("/sct-to-sdd")
    public ResponseEntity<?> sctToSdd(@RequestParam MultipartFile file) {
        try {
            ConversionResult result = conversionService.convertSctToSdd(file);
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            return ResponseEntity
                    .badRequest()
                    .body("Error en conversión SCT->SDD: " + e.getMessage());
        }
    }

    @PostMapping("/sdd-to-sct")
    public ResponseEntity<?> sddToSct(@RequestParam MultipartFile file) {
        try {
            ConversionResult result = conversionService.convertSddToSct(file);
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            return ResponseEntity
                    .badRequest()
                    .body("Error en conversión SDD->SCT: " + e.getMessage());
        }
    }

    @PostMapping("/download")
    public ResponseEntity<?> download(@RequestParam MultipartFile file,
            @RequestParam String direction) {
        try {
            if (file == null || file.isEmpty()) {
                return ResponseEntity.badRequest().body("No se ha subido ningún archivo");
            }

            ConversionResult result;
            if ("sct-to-sdd".equalsIgnoreCase(direction)) {
                result = conversionService.convertSctToSdd(file);
            } else if ("sdd-to-sct".equalsIgnoreCase(direction)) {
                result = conversionService.convertSddToSct(file);
            } else {
                return ResponseEntity.badRequest().body("Dirección de conversión inválida");
            }

            String xmlContent = result.getConvertedXml() != null ? result.getConvertedXml() : "";
            byte[] xmlBytes = xmlContent.getBytes(StandardCharsets.UTF_8);
            ByteArrayResource resource = new ByteArrayResource(xmlBytes);

            String originalName = file.getOriginalFilename() != null ? file.getOriginalFilename() : "file.xml";
            String filename = "converted_" + originalName;

            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + filename + "\"")
                    .contentType(MediaType.APPLICATION_XML)
                    .contentLength(xmlBytes.length)
                    .body(resource);

        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error interno: " + e.getMessage());
        }
    }

    @PostMapping("/executive-view")
    public ResponseEntity<?> viewConverted(@RequestParam MultipartFile file,
            @RequestParam String direction) {
        try {
            ConversionResult result;
            if ("sct-to-sdd".equalsIgnoreCase(direction)) {
                result = conversionService.convertSctToSdd(file);
            } else if ("sdd-to-sct".equalsIgnoreCase(direction)) {
                result = conversionService.convertSddToSct(file);
            } else {
                return ResponseEntity.badRequest().body("Conversión inválida");
            }

            FileInfo metaInfo = metadataService.extractMetaInfo(
                    result.getConvertedXml().getBytes(StandardCharsets.UTF_8));

            return ResponseEntity.ok(metaInfo);

        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error interno: " + e.getMessage());
        }
    }

}
