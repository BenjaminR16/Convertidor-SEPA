package com.sstrategy.convertidor_sepa.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

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
}
