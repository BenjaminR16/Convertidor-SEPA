import { ChangeDetectionStrategy, Component, OnDestroy, computed, effect, inject, input, signal } from '@angular/core';
import { Router } from '@angular/router';
import { jsPDF } from 'jspdf';
import { ConversionService } from '../../../services/conversion.service';
import { FieldNode, valoresGenericos } from '../../../util/extract-values';

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

    const fields: FieldNode[] = valoresGenericos(converted); // ya es plano

    const doc = new jsPDF();
    const margin = 15;
    const pageWidth = doc.internal.pageSize.getWidth();
    const usableWidth = pageWidth - margin * 2;

    let y = 25;

    // Header
    doc.setFont('helvetica', 'bold');
    doc.setFontSize(20);
    doc.text('Resumen de Conversión SEPA', margin, y);
    doc.setDrawColor(52, 152, 219);
    doc.setLineWidth(1.2);
    doc.line(margin, y + 3, pageWidth - margin, y + 3);
    y += 18;

    // Ancho dinámico de label
    doc.setFont('helvetica', 'bold');
    doc.setFontSize(11);
    const labelWidths = fields.map(f => doc.getTextWidth(`${f.label}:`));
    const maxLabelWidth = Math.min(Math.max(...labelWidths), 80); // ancho máximo dinámico

    // Tabla con estilo cards
    const rowPadding = 6;
    const rowSpacing = 4;

    fields.forEach((f, index) => {
      // Envolver el texto
      const wrapped = doc.splitTextToSize(f.value, usableWidth - maxLabelWidth - rowPadding * 2);
      const rowHeight = Math.max(18, wrapped.length * 7 + rowPadding * 2);

      // Saltar de página si no cabe
      if (y + rowHeight + margin > doc.internal.pageSize.getHeight()) {
        doc.addPage();
        y = margin;
      }

      // Color alterno
      if (index % 2 === 0) {
        doc.setFillColor(245, 247, 250); // claro
      } else {
        doc.setFillColor(255, 255, 255); // blanco
      }

      // Dibujar fondo
      doc.setDrawColor(200, 200, 200);
      doc.roundedRect(margin, y, usableWidth, rowHeight, 2, 2, 'FD');

      // Label
      doc.setFont('helvetica', 'bold');
      doc.setFontSize(11);
      doc.setTextColor(52, 73, 94);
      doc.text(`${f.label}:`, margin + rowPadding, y + 10);

      // Valor alineado automáticamente
      const labelWidthReal = doc.getTextWidth(`${f.label}:`);
      doc.setFont('helvetica', 'normal');
      doc.setTextColor(44, 62, 80);
      doc.text(wrapped, margin + rowPadding + labelWidthReal + 3, y + 10);

      y += rowHeight + rowSpacing;
    });

    doc.save('resumen-sepa.pdf');
  }


  private clearSpinnerDelay() {
    if (this.spinnerTimeout !== null) {
      clearTimeout(this.spinnerTimeout);
      this.spinnerTimeout = null;
    }
  }
}
