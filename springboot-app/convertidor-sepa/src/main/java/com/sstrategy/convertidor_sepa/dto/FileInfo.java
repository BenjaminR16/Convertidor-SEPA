package com.sstrategy.convertidor_sepa.dto;

public class FileInfo {
    private String msgId;
    private String fechaCreacion;
    private String numeroTransacciones;
    private String sumaTotal;
    private String nomEmpresa;

    public FileInfo() {
    }

    public FileInfo(String msgId, String fechaCreacion, String numeroTransacciones, String sumaTotal,
            String nomEmpresa) {
        this.msgId = msgId;
        this.fechaCreacion = fechaCreacion;
        this.numeroTransacciones = numeroTransacciones;
        this.sumaTotal = sumaTotal;
        this.nomEmpresa = nomEmpresa;
    }

    public String getMsgId() {
        return msgId;
    }

    public void setMsgId(String msgId) {
        this.msgId = msgId;
    }

    public String getFechaCreacion() {
        return fechaCreacion;
    }

    public void setFechaCreacion(String fechaCreacion) {
        this.fechaCreacion = fechaCreacion;
    }

    public String getNumeroTransacciones() {
        return numeroTransacciones;
    }

    public void setNumeroTransacciones(String numeroTransacciones) {
        this.numeroTransacciones = numeroTransacciones;
    }

    public String getSumaTotal() {
        return sumaTotal;
    }

    public void setSumaTotal(String sumaTotal) {
        this.sumaTotal = sumaTotal;
    }

    public String getNomEmpresa() {
        return nomEmpresa;
    }

    public void setNomEmpresa(String iniciador) {
        this.nomEmpresa = iniciador;
    }

}
