import { ChangeDetectionStrategy, Component, HostListener, inject, signal } from '@angular/core';
import { Router } from '@angular/router';
import { ConversionService } from '../../services/conversion.service';
import { ConversionResult } from '../../interface/conversion-result';
import { HeroSectionComponent } from '../../components/dashboard-components/hero-section/hero-section.component';
import { HowItWorksComponent } from '../../components/dashboard-components/how-it-works/how-it-works.component';
import { UploadAreaComponent } from '../../components/dashboard-components/upload-area/upload-area.component';
import { ConversionsAvailableComponent } from '../../components/dashboard-components/conversions-available/conversions-available.component';

@Component({
    selector: 'app-dashboard-page',
    standalone: true,
    imports: [
        HeroSectionComponent,
        HowItWorksComponent,
        UploadAreaComponent,
        ConversionsAvailableComponent
    ],
    templateUrl: './dashboard.page.html',
    changeDetection: ChangeDetectionStrategy.OnPush,
})
export class DashboardPage {
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
        reader.onload = () => {
            const content = String(reader.result ?? '');
            const validationError = this.validateXml(content);
            if (validationError) {
                this.selectedFile.set(null);
                this.xmlRaw.set(null);
                this.errorMessage.set(validationError);
                return;
            }
            this.xmlRaw.set(content);
        };
        reader.onerror = () => { this.xmlRaw.set(null); this.errorMessage.set('Error leyendo archivo'); };
        reader.readAsText(file);
    }

    private validateXml(content: string): string | null {
        if (!content.trim()) return 'El archivo XML está vacío';
        if (typeof DOMParser === 'undefined') return null;

        const parser = new DOMParser();
        const doc = parser.parseFromString(content, 'application/xml');
        const parserError = doc.querySelector('parsererror');
        if (parserError) return 'El XML tiene errores de formato.';

        
        const root = doc.documentElement;
        if (!root || root.localName.toLowerCase() !== 'document') {
            return 'El XML debe tener un nodo raíz <Document>.';
        }

        const namespace = root.namespaceURI ?? '';
        const isSepaNamespace = /pain\.\d{3}\.\d{3}\.\d{2}/.test(namespace);
        if (!isSepaNamespace) return 'El XML no pertenece a un esquema SEPA reconocido.';

        return null;
    }

    convertFile() {
        const file = this.selectedFile();
        if (!file) { this.errorMessage.set('No hay archivo seleccionado'); return; }

        this.isLoading.set(true);
        this.conversionService.convertFile(file, 'auto').subscribe({
            next: (res: ConversionResult) => {
                this.router.navigate(['/executive-view'], {
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
