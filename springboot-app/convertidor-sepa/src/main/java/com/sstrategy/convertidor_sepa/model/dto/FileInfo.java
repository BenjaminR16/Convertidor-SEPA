package com.sstrategy.convertidor_sepa.model.dto;

import java.time.LocalDateTime;

public class FileInfo {
    private String fileName;
    private long size;
    private String contentType;
    private LocalDateTime uploadTime;

    public FileInfo() {
    }

    public FileInfo(String fileName, long size, String contentType, LocalDateTime uploadTime) {
        this.fileName = fileName;
        this.size = size;
        this.contentType = contentType;
        this.uploadTime = uploadTime;
    }

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public long getSize() {
        return size;
    }

    public void setSize(long size) {
        this.size = size;
    }

    public String getContentType() {
        return contentType;
    }

    public void setContentType(String contentType) {
        this.contentType = contentType;
    }

    public LocalDateTime getUploadTime() {
        return uploadTime;
    }

    public void setUploadTime(LocalDateTime uploadTime) {
        this.uploadTime = uploadTime;
    }

}
