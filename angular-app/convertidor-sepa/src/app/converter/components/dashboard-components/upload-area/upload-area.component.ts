import { ChangeDetectionStrategy, Component, HostListener, input, output } from '@angular/core';

@Component({
  selector: 'app-upload-area',
  templateUrl: './upload-area.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class UploadAreaComponent {
  isDragOver = input(false);
  selectedFile = input<File | null>(null);
  errorMessage = input<string | null>(null);

  fileInputChange = output<Event>();
  dragOver = output<DragEvent>();
  dragLeave = output<DragEvent>();
  drop = output<DragEvent>();
  convertFile = output<void>();

  @HostListener('document:dragover', ['$event'])
  @HostListener('document:drop', ['$event'])
  preventDefaults(event: Event) { event.preventDefault(); event.stopPropagation(); }

  onFileInputChange(event: Event): void {
    this.fileInputChange.emit(event);
  }

  onDragOver(event: DragEvent) { this.preventDefaults(event); this.dragOver.emit(event); }
  onDragLeave(event: DragEvent) { this.preventDefaults(event); this.dragLeave.emit(event); }
  onDrop(event: DragEvent) {
    this.preventDefaults(event);
    this.drop.emit(event);
  }

  onConvertFile() {
    this.convertFile.emit();
  }
}