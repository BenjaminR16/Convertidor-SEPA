package com.sstrategy.convertidor_sepa.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.sstrategy.convertidor_sepa.dto.ConversionResult;
import com.sstrategy.convertidor_sepa.service.ConversionService;

@RestController
@RequestMapping("/sepa")
public class ConversionController {
    private final ConversionService conversionService;

    public ConversionController(ConversionService conversionService) {
        this.conversionService = conversionService;
    }

    @PostMapping("/sct-to-sdd")
    public ResponseEntity<ConversionResult> sctToSdd(@RequestParam("file") MultipartFile file) {
        return ResponseEntity.ok(conversionService.convertSctToSdd(file));
    }

    @PostMapping("/sdd-to-sct")
    public ResponseEntity<ConversionResult> sddToSct(@RequestParam("file") MultipartFile file) {
        return ResponseEntity.ok(conversionService.convertSddToSct(file));
    }
}
