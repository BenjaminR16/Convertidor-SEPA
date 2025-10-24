package com.sstrategy.convertidor_sepa.controller;

import com.sstrategy.convertidor_sepa.exception.*;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.multipart.MaxUploadSizeExceededException;

@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(InvalidConversionDirectionException.class)
    public ResponseEntity<String> handleInvalidConversionDirection(InvalidConversionDirectionException e) {
        return ResponseEntity.badRequest().body("Dirección de conversión inválida: " + e.getMessage());
    }

    @ExceptionHandler(FileProcessingException.class)
    public ResponseEntity<String> handleFileProcessing(FileProcessingException e) {
        return ResponseEntity.badRequest().body("Error en el procesamiento del archivo: " + e.getMessage());
    }

    @ExceptionHandler(ValidationException.class)
    public ResponseEntity<String> handleValidation(ValidationException e) {
        return ResponseEntity.badRequest().body("Error de validación: " + e.getMessage());
    }

    @ExceptionHandler(ConversionException.class)
    public ResponseEntity<String> handleConversion(ConversionException e) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error en la conversión: " + e.getMessage());
    }

    @ExceptionHandler(MetadataExtractionException.class)
    public ResponseEntity<String> handleMetadataExtraction(MetadataExtractionException e) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error al extraer metadatos: " + e.getMessage());
    }

    @ExceptionHandler(MaxUploadSizeExceededException.class)
    public ResponseEntity<String> handleMaxUploadSizeExceeded(MaxUploadSizeExceededException e) {
        return ResponseEntity.status(HttpStatus.PAYLOAD_TOO_LARGE).body("El archivo es demasiado grande. Tamaño máximo permitido: " + e.getMaxUploadSize() + " bytes");
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<String> handleGeneral(Exception e) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error interno del servidor: " + e.getMessage());
    }
}