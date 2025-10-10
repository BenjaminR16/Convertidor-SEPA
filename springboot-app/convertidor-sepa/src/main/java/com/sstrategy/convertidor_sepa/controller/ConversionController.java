package com.sstrategy.convertidor_sepa.controller;

import java.nio.charset.StandardCharsets;

import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.http.MediaType;

import com.sstrategy.convertidor_sepa.dto.ConversionResult;
import com.sstrategy.convertidor_sepa.service.ConversionService;

@RestController
@RequestMapping("/api/v1/convert")
public class ConversionController {

    private final ConversionService conversionService;

    public ConversionController(ConversionService conversionService) {
        this.conversionService = conversionService;
    }

    @PostMapping("/sct-to-sdd")
    public ResponseEntity<?> sctToSdd(@RequestParam("file") MultipartFile file) {
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
    public ResponseEntity<?> sddToSct(@RequestParam("file") MultipartFile file) {
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
    public ResponseEntity<?> download(@RequestParam("file") MultipartFile file,
            @RequestParam("direction") String direction) {
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

}
