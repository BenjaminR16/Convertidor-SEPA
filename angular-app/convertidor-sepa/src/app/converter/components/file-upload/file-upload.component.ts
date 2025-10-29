import { HttpErrorResponse } from '@angular/common/http';
import { ChangeDetectionStrategy, Component, HostListener, inject, signal } from '@angular/core';
import { Router } from '@angular/router';
import { ConversionService } from '../../services/conversion.service';
import { ConversionResult } from '../../interface/conversion-result';

@Component({
  selector: 'app-file-upload',
  templateUrl: './file-upload.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class FileUploadComponent {
  private router = inject(Router);
  private conversionService = inject(ConversionService);

  isDragOver = signal(false);
  selectedFile = signal<File | null>(null);
  errorMessage = signal<string | null>(null);
  xmlRaw = signal<string | null>(null);
  isLoading = signal(false);

  onFileInputChange(event: Event): void {
    const input = event.target as HTMLInputElement;
    if (input?.files?.length) {
      this.handleFiles(input.files);
      input.value = '';
    }
  }

  onDragOver(event: DragEvent) { this.preventDefaults(event); this.isDragOver.set(true); }
  onDragLeave(event: DragEvent) { this.preventDefaults(event); this.isDragOver.set(false); }
  onDrop(event: DragEvent) {
    this.preventDefaults(event);
    this.isDragOver.set(false);
    const files = event.dataTransfer?.files;
    if (files?.length) this.handleFiles(files);
  }

  @HostListener('document:dragover', ['$event'])
  @HostListener('document:drop', ['$event'])
  preventDefaults(event: Event) { event.preventDefault(); event.stopPropagation(); }

  private handleFiles(files: FileList) {
    this.errorMessage.set(null);
    const file = files[0];
    if (!file) return;

    const maxBytes = 10 * 1024 * 1024;
    const isXml = file.name.toLowerCase().endsWith('.xml') ||
      ['application/xml', 'text/xml'].includes(file.type) ||
      file.type.endsWith('+xml');

    if (!isXml) { this.selectedFile.set(null); this.errorMessage.set('Solo archivos XML'); return; }
    if (file.size > maxBytes) { this.selectedFile.set(null); this.errorMessage.set('Archivo >10MB'); return; }

    this.selectedFile.set(file);
    const reader = new FileReader();
    reader.onload = () => this.xmlRaw.set(String(reader.result ?? ''));
    reader.onerror = () => this.errorMessage.set('Error leyendo archivo');
    reader.readAsText(file);
  }

  convertFile() {
    const file = this.selectedFile();
    if (!file) { this.errorMessage.set('No hay archivo seleccionado'); return; }

    this.isLoading.set(true);
    this.conversionService.convertFile(file, 'auto').subscribe({
      next: (res: ConversionResult) => {
        this.router.navigate(['/dashboard/executive-view'], {
          state: { xmlRaw: this.xmlRaw(), xmlConverted: res.convertedXml }
        });
        this.isLoading.set(false);
      },
      //manejo de errores
      error: (err: any) => {
        let msg = err.message || 'Error desconocido.';
        if (msg.includes('Error de validación XSD')) {
          msg = 'El archivo XML no cumple con el formato SEPA esperado (error de validación XSD).';
        }

        this.errorMessage.set(msg);
        this.isLoading.set(false);
      }


    });
  }

  goBack() {
    this.router.navigate(['/dashboard']);
  }
}
