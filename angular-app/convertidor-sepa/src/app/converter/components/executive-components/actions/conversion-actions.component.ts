import { ChangeDetectionStrategy, Component, OnDestroy, computed, effect, inject, input, signal } from '@angular/core';
import { Router } from '@angular/router';
import { jsPDF } from 'jspdf';
import { ConversionService } from '../../../services/conversion.service';
import { buildXmlInfo } from '../info-grid/conversion-info-grid.component';

@Component({
  selector: 'app-conversion-actions',
  standalone: true,
  templateUrl: './conversion-actions.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ConversionActionsComponent implements OnDestroy {
  private router = inject(Router);
  private conversionService = inject(ConversionService);

  xmlRaw = input<string | null>(null);
  xmlConverted = input<string | null>(null);

  readonly hasResult = computed(() => !!this.xmlConverted());
  readonly canDownloadXml = computed(() => !!this.xmlConverted() && !!this.xmlRaw());
  readonly isDownloading = signal(false);
  readonly showSpinner = signal(false);

  private spinnerTimeout: ReturnType<typeof setTimeout> | null = null;

  constructor() {
    effect(() => {
      const downloading = this.isDownloading();
      if (!downloading) {
        this.clearSpinnerDelay();
        this.showSpinner.set(false);
        return;
      }

      if (this.showSpinner() || this.spinnerTimeout !== null) {
        return;
      }

      this.spinnerTimeout = setTimeout(() => {
        this.spinnerTimeout = null;
        if (this.isDownloading()) {
          this.showSpinner.set(true);
        }
      }, 500);
    });
  }

  ngOnDestroy(): void {
    this.clearSpinnerDelay();
  }

  goBack() {
    this.router.navigate(['/dashboard']);
  }

  viewXml() {
    const converted = this.xmlConverted();
    if (!converted) return;

    const blob = new Blob([converted], { type: 'application/xml' });
    const url = window.URL.createObjectURL(blob);
    window.open(url, '_blank');

    setTimeout(() => {
      window.URL.revokeObjectURL(url);
    }, 100);
  }

  downloadXml() {
    const raw = this.xmlRaw();
    const converted = this.xmlConverted();
    if (!converted || !raw) return;

    this.isDownloading.set(true);

    const blob = new Blob([raw], { type: 'application/xml' });
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
        this.isDownloading.set(false);
      },
      error: (err) => {
        console.error('Error descargando el XML:', err);
        this.isDownloading.set(false);
      }
    });
  }

  downloadPdf() {
    const converted = this.xmlConverted();
    if (!converted) return;

    const info = buildXmlInfo(converted);

    const doc = new jsPDF();
    const margin = 20;
    let yPosition = 30;
    const lineHeight = 8;

    doc.setFont('helvetica', 'bold');
    doc.setFontSize(18);
    doc.text('Resumen de conversión SEPA', margin, yPosition);

    doc.setFontSize(11);
    doc.setFont('helvetica', 'normal');
    yPosition += lineHeight * 1.5;

    if (!info.length) {
      doc.text('No se encontraron datos relevantes para este archivo.', margin, yPosition);
      doc.save('resumen-conversion.pdf');
      return;
    }

    info.forEach((item) => {
      const availableHeight = doc.internal.pageSize.getHeight() - margin;
      if (yPosition + lineHeight * 2 > availableHeight) {
        doc.addPage();
        yPosition = margin;
      }

      doc.setFont('helvetica', 'bold');
      doc.text(item.label, margin, yPosition);
      yPosition += lineHeight;

      doc.setFont('helvetica', 'normal');
      const wrappedValue = doc.splitTextToSize(item.value, doc.internal.pageSize.getWidth() - margin * 2);
      wrappedValue.forEach((line: string) => {
        if (yPosition + lineHeight > availableHeight) {
          doc.addPage();
          yPosition = margin;
        }
        doc.text(line, margin, yPosition);
        yPosition += lineHeight;
      });

      yPosition += lineHeight * 0.5;
    });

    doc.save('resumen-conversion.pdf');
  }

  private clearSpinnerDelay() {
    if (this.spinnerTimeout !== null) {
      clearTimeout(this.spinnerTimeout);
      this.spinnerTimeout = null;
    }
  }
}
