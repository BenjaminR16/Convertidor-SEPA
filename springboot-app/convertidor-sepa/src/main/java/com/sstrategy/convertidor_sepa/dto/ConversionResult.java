package com.sstrategy.convertidor_sepa.dto;

public class ConversionResult {
    private String convertedXml;
    private FileInfo metadata;

    public ConversionResult(String convertedXml, FileInfo metadata) {
        this.convertedXml = convertedXml;
        this.metadata = metadata;
    }

    public String getConvertedXml() {
        return convertedXml;
    }

    public FileInfo getMetadata() {
        return metadata;
    }
}
