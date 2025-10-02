import { Component, signal } from '@angular/core';
import { HeaderComponent } from "./components/layout/header/header.component";
import { FooterComponent } from './components/layout/footer/footer.component';
import { FileUploadComponent } from "./components/layout/file-upload/file-upload.component";

@Component({
  selector: 'app-root',
  imports: [HeaderComponent, FooterComponent, FileUploadComponent],
  templateUrl: './app.html',
  styleUrl: './app.css'
})
export class App {
  protected readonly title = signal('convertidor-sepa');
}
