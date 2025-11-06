import { Component, inject } from '@angular/core';
import { Router } from '@angular/router';
import { ConversionService } from '../../services/conversion.service';
import { XmlView } from '../../components/xml-view/xml-view.component';

interface XmlInfo {
  label: string;
  value: string;
  icon: string;
}

@Component({
  selector: 'app-executive-view.pages',
  imports: [XmlView],
  templateUrl: './executive-view.pages.html',
})
export class ExecutiveViewPages {
  private router = inject(Router);
  private conversionService = inject(ConversionService);

  xmlRaw: string | null = null;
  xmlConverted: string | null = null;
  isDownloading = false;
  xmlInfo: XmlInfo[] = [];

  constructor() {
    const state = this.router.currentNavigation()?.extras.state as any;
    this.xmlRaw = state?.xmlRaw ?? null;
    this.xmlConverted = state?.xmlConverted ?? null;

    if (this.xmlConverted) {
      this.extractXmlInfo();
    }
  }

  private extractXmlInfo() {
    if (!this.xmlConverted) return;

    const parser = new DOMParser();
    const xmlDoc = parser.parseFromString(this.xmlConverted, 'text/xml');
    const info: XmlInfo[] = [];

    // Tipo de mensaje
    const messageType = xmlDoc.documentElement?.tagName || 'Desconocido';
    info.push({
      label: 'Tipo de Mensaje',
      value: messageType,
      icon: '📄'
    });

    // ID del mensaje
    const messageId = xmlDoc.querySelector('MsgId')?.textContent ||
                      xmlDoc.querySelector('GrpHdr MsgId')?.textContent ||
                      'No disponible';
    info.push({
      label: 'ID del Mensaje',
      value: messageId,
      icon: '🆔'
    });

    // Fecha de creación
    const creationDate = xmlDoc.querySelector('CreDtTm')?.textContent ||
                        xmlDoc.querySelector('GrpHdr CreDtTm')?.textContent ||
                        'No disponible';
    if (creationDate !== 'No disponible') {
      const date = new Date(creationDate).toLocaleString('es-ES');
      info.push({
        label: 'Fecha de Creación',
        value: date,
        icon: '📅'
      });
    }

    // Número de transacciones
    const transactions = xmlDoc.querySelectorAll('CdtTrfTxInf, DrctDbtTxInf');
    if (transactions.length > 0) {
      info.push({
        label: 'Número de Transacciones',
        value: transactions.length.toString(),
        icon: '🔢'
      });
    }

    // Monto total
    let totalAmount = 0;
    const amounts = xmlDoc.querySelectorAll('Amt');
    amounts.forEach(amount => {
      const value = parseFloat(amount.textContent || '0');
      if (!isNaN(value)) {
        totalAmount += value;
      }
    });

    if (totalAmount > 0) {
      info.push({
        label: 'Monto Total',
        value: `€${totalAmount.toFixed(2)}`,
        icon: '💰'
      });
    }

    // Nombre del ordenante
    const debtorName = xmlDoc.querySelector('Dbtr Nm')?.textContent ||
                      xmlDoc.querySelector('InitgPty Nm')?.textContent ||
                      'No disponible';
    if (debtorName !== 'No disponible') {
      info.push({
        label: 'Ordenante',
        value: debtorName,
        icon: '👤'
      });
    }

    // IBAN del ordenante
    const debtorIban = xmlDoc.querySelector('DbtrAcct Id IBAN')?.textContent ||
                      xmlDoc.querySelector('DbtrAcct Id Othr Id')?.textContent ||
                      'No disponible';
    if (debtorIban !== 'No disponible') {
      info.push({
        label: 'IBAN Ordenante',
        value: debtorIban,
        icon: '🏦'
      });
    }

    this.xmlInfo = info;
  }

  goBack() {
    this.router.navigate(['/dashboard']);
  }

  downloadXml() {
    if (!this.xmlConverted) return;

    this.isDownloading = true;

    // Crear archivo temporal con xmlRaw para enviar al servicio de descarga
    const blob = new Blob([this.xmlRaw!], { type: 'application/xml' });
    const file = new File([blob], 'ArchivoConvertido.xml', { type: 'application/xml' });

    this.conversionService.downloadFile(file).subscribe({
      next: (res: Blob) => {
        const url = window.URL.createObjectURL(res);
        const a = document.createElement('a');
        a.href = url;
        a.download = 'converted.xml';
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        window.URL.revokeObjectURL(url);
        this.isDownloading = false;
      },
      error: (err) => {
        console.error('Error descargando el XML:', err);
        this.isDownloading = false;
      }
    });
  }

  viewXml() {
    if (!this.xmlConverted) return;

    // Crear un blob con el XML convertido y abrirlo en una nueva pestaña
    const blob = new Blob([this.xmlConverted], { type: 'application/xml' });
    const url = window.URL.createObjectURL(blob);
    window.open(url, '_blank');

    // Limpiar el URL del objeto después de un tiempo
    setTimeout(() => {
      window.URL.revokeObjectURL(url);
    }, 100);
  }
}