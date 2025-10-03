package com.sstrategy.convertidor_sepa.service;

import org.springframework.web.multipart.MultipartFile;

import com.sstrategy.convertidor_sepa.dto.ConversionResult;

public interface ConversionService {
    ConversionResult convertSctToSdd(MultipartFile file);

    ConversionResult convertSddToSct(MultipartFile file);
}
