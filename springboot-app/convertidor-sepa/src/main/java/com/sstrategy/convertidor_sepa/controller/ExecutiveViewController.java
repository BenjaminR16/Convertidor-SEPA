package com.sstrategy.convertidor_sepa.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import com.sstrategy.convertidor_sepa.dto.FileInfo;
import com.sstrategy.convertidor_sepa.service.MetadataService;

@RestController
@RequestMapping("/api/v1/executive-view")
public class ExecutiveViewController {

    private final MetadataService metadataService;

    public ExecutiveViewController(MetadataService metadataService) {
        this.metadataService = metadataService;
    }

    @PostMapping("/metadata")
    public ResponseEntity<?> metadata(
            @RequestParam MultipartFile file,
            @RequestParam String type) {
        try {
            FileInfo info = metadataService.extractMetadata(
                    file.getBytes(),
                    file.getOriginalFilename(),
                    type);
            return ResponseEntity.ok(info);
        } catch (Exception e) {
            return ResponseEntity
                    .badRequest()
                    .body("Error al extraer metadata: " + e.getMessage());
        }
    }

    @PostMapping("/xml")
    public ResponseEntity<?> xml(@RequestParam MultipartFile file) {
        try {
            String xmlText = new String(file.getBytes(), "UTF-8");
            return ResponseEntity.ok(xmlText);
        } catch (Exception e) {
            return ResponseEntity
                    .badRequest()
                    .body("Error al leer XML: " + e.getMessage());
        }
    }
}
