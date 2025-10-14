import { ChangeDetectionStrategy, Component, input } from '@angular/core';

@Component({
  selector: 'app-file-view',
  imports: [],
  templateUrl: './file-view.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class FileViewComponent {
  // XML a mostrar: el padre lo pasa como string y aquí se expone como Signal
  xmlRaw = input<string | null>(null);
 }
