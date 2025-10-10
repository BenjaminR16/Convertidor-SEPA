package com.sstrategy.convertidor_sepa.dto;

public class FileInfo {
    private String fileName;
    private long size;
    private String contentType;
    private String totalAmount;
    private String totalTransactions;
    private String creationDate;
    private String initiatingParty;
    private String currency;

    public FileInfo() {
    }

    public FileInfo(String fileName, long size, String contentType, String totalAmount, String totalTransactions,
            String creationDate, String initiatingParty, String currency) {
        this.fileName = fileName;
        this.size = size;
        this.contentType = contentType;
        this.totalAmount = totalAmount;
        this.totalTransactions = totalTransactions;
        this.creationDate = creationDate;
        this.initiatingParty = initiatingParty;
        this.currency = currency;
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

    public String getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(String totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getTotalTransactions() {
        return totalTransactions;
    }

    public void setTotalTransactions(String totalTransactions) {
        this.totalTransactions = totalTransactions;
    }

    public String getCreationDate() {
        return creationDate;
    }

    public void setCreationDate(String creationDate) {
        this.creationDate = creationDate;
    }

    public String getInitiatingParty() {
        return initiatingParty;
    }

    public void setInitiatingParty(String initiatingParty) {
        this.initiatingParty = initiatingParty;
    }

    public String getCurrency() {
        return currency;
    }

    public void setCurrency(String currency) {
        this.currency = currency;
    }

}
