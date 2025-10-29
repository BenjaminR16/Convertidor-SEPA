import { Component, inject } from '@angular/core';
import { Router } from '@angular/router';
import { ConversionService } from '../../services/conversion.service';
import { XmlView } from '../../components/xml-view/xml-view.component';

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

  constructor() {
    const state = this.router.currentNavigation()?.extras.state as any;
    this.xmlRaw = state?.xmlRaw ?? null;
    this.xmlConverted = state?.xmlConverted ?? null;
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
}