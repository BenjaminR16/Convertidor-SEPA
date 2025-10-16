package com.sstrategy.convertidor_sepa.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class FileInfo {
    private String msgId;
    private String fechaCreacion;
    private String numeroTransacciones;
    private String sumaTotal;
    private String nomEmpresa;
}
