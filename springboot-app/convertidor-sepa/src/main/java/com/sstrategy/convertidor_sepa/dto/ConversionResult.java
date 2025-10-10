package com.sstrategy.convertidor_sepa.dto;

public class ConversionResult {
    private String convertedXml;

    public ConversionResult(String convertedXml) {
        this.convertedXml = convertedXml;
    }

    public String getConvertedXml() {
        return convertedXml;
    }

}
