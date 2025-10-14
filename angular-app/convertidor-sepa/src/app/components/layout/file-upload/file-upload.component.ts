import { ChangeDetectionStrategy, Component, HostListener, signal } from '@angular/core';

@Component({
  selector: 'app-file-upload',
  imports: [],
  templateUrl: './file-upload.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class FileUploadComponent {

  protected readonly isDragOver = signal(false);
  protected readonly selectedFile = signal<File | null>(null);
  protected readonly errorMessage = signal<string | null>(null);

  //Cambio de input desde el selector de archivos
  onFileInputChange(event: Event): void {
    const input = event.target as HTMLInputElement;
    if (input?.files && input.files.length > 0) {
      this.handleFiles(input.files);
      // Permitir seleccionar el mismo archivo nuevamente limpiando el valor
      input.value = '';
    }
  } 

  onDragOver(event: DragEvent): void {
    this.preventDefaults(event);
    this.isDragOver.set(true);
  }

  onDragLeave(event: DragEvent): void {
    this.preventDefaults(event);
    this.isDragOver.set(false);
  }

  onDrop(event: DragEvent): void {
    this.preventDefaults(event);
    this.isDragOver.set(false);
    const files = event.dataTransfer?.files;
    if (files && files.length > 0) {
      this.handleFiles(files);
    }
  }

  // Prevenir que se abra el archivo si fallas el drop
  @HostListener('document:dragover', ['$event'])
  onDocumentDragOver(event: DragEvent): void {
      event.preventDefault(); 
  }

  @HostListener('document:drop', ['$event'])
  onDocumentDrop(event: DragEvent): void {
      event.preventDefault();
    
  }

  private handleFiles(files: FileList): void {
    this.errorMessage.set(null);
    const file = files[0];
    if (!file) return;

    // Validaciones: solo .xml, max 10MB
    const maxBytes = 10 * 1024 * 1024;
    const isXmlByExt = file.name.toLowerCase().endsWith('.xml');
    const isXmlByType = (file.type || '').toLowerCase().includes('xml');

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
  }

  private preventDefaults(event: Event): void {
    event.preventDefault();
    event.stopPropagation();
  }


}
