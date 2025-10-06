package com.sstrategy.convertidor_sepa.dto;

public class ErrorInfo {
    private String message;
    private int code;

    public ErrorInfo(String message, int code) {
        this.message = message;
        this.code = code;
    }

    public String getMessage() {
        return message;
    }

    public int getCode() {
        return code;
    }
}
