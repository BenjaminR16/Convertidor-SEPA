package com.sstrategy.convertidor_sepa.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.sstrategy.convertidor_sepa.dto.FileInfo;
import com.sstrategy.convertidor_sepa.service.MetadataService;

@RestController
@RequestMapping("/executive-view")
public class ExecutiveViewController {
    private final MetadataService metadataService;

    public ExecutiveViewController(MetadataService metadataService) {
        this.metadataService = metadataService;
    }

    @PostMapping("/metadata")
    public ResponseEntity<FileInfo> metadata(
            @RequestParam("file") MultipartFile file,
            @RequestParam("type") String type) throws Exception {
        return ResponseEntity.ok(
                metadataService.extractMetadata(file.getBytes(), file.getOriginalFilename(), type));
    }

    @PostMapping("/xml")
    public ResponseEntity<String> xml(@RequestParam("file") MultipartFile file) throws Exception {
        return ResponseEntity.ok(new String(file.getBytes()));
    }
}
