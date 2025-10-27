import { ChangeDetectionStrategy, Component, HostListener, signal } from '@angular/core';
import { FileViewComponent } from "../file-view/file-view.component";
import { ConversionService } from '../service/conversion.service';
import { HttpErrorResponse } from '@angular/common/http';
import { FileInfo } from '../interfaces/file-info.model';

@Component({
  selector: 'app-file-upload',
  imports: [FileViewComponent],
  templateUrl: './file-upload.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class FileUploadComponent {

  protected readonly isDragOver = signal(false);
  protected readonly selectedFile = signal<File | null>(null);
  protected readonly errorMessage = signal<string | null>(null);
  protected readonly isConverted = signal(false);
  protected readonly isLoading = signal(false);
  protected readonly originalInfo = signal<FileInfo | null>(null);
  protected readonly convertedInfo = signal<FileInfo | null>(null);

  constructor(private conversionService: ConversionService) { }

  onFileInputChange(event: Event): void {
    const input = event.target as HTMLInputElement;
    if (input?.files && input.files.length > 0) {
      this.handleFiles(input.files);
      input.value = '';
    }
  }

  onDragOver(event: DragEvent): void { this.preventDefaults(event); this.isDragOver.set(true); }
  onDragLeave(event: DragEvent): void { this.preventDefaults(event); this.isDragOver.set(false); }
  onDrop(event: DragEvent): void {
    this.preventDefaults(event);
    this.isDragOver.set(false);
    const files = event.dataTransfer?.files;
    if (files && files.length > 0) this.handleFiles(files);
  }

  @HostListener('document:dragover', ['$event'])
  @HostListener('document:drop', ['$event'])
  preventDefaults(event: Event): void {
    event.preventDefault();
    event.stopPropagation();
  }

  private handleFiles(files: FileList): void {
    this.errorMessage.set(null);
    const file = files[0];
    if (!file) return;

    const maxBytes = 10 * 1024 * 1024;
    const isXmlByExt = file.name.toLowerCase().endsWith('.xml');
    const type = (file.type || '').toLowerCase();
    const isXmlByType = type === 'application/xml' || type === 'text/xml' || type.endsWith('+xml');

    if (!isXmlByExt && !isXmlByType) {
      this.selectedFile.set(null);
      this.errorMessage.set('Solo se permiten archivos XML (.xml)');
      return;
    }
    if (file.size > maxBytes) {
      this.selectedFile.set(null);
      this.errorMessage.set('El archivo excede el tamaño máximo de 10MB');
      return;
    }
    this.selectedFile.set(file);

    // Obtener metadata original
    this.conversionService.viewConverted(file, 'auto').subscribe({
      next: info => this.originalInfo.set(info),
      error: err => console.error('Error al obtener resumen original:', err)
    });
  }

  convertFile(): void {
    const file = this.selectedFile();
    if (!file) {
      this.errorMessage.set('No hay archivo seleccionado');
      return;
    }

    this.isLoading.set(true);
    this.errorMessage.set(null);

    this.conversionService.convertFile(file, 'auto').subscribe({
      next: res => {
        const blob = new Blob([res.convertedXml], { type: 'text/xml' });
        const convertedFile = new File([blob], 'converted.xml', { type: 'text/xml' });

        this.conversionService.viewConverted(convertedFile, 'auto').subscribe({
          next: info => {
            this.convertedInfo.set(info);
            this.isConverted.set(true);
            this.isLoading.set(false);
          },
          error: err => console.error('Error al obtener resumen convertido:', err)
        });
      },
      error: (err: HttpErrorResponse) => {
        this.errorMessage.set(err.message);
        this.isLoading.set(false);
      }
    });
  }

  goBack(): void {
    this.isConverted.set(false);
    this.selectedFile.set(null);
    this.originalInfo.set(null);
    this.convertedInfo.set(null);
    this.errorMessage.set(null);
  }
}
