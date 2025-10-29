import { ChangeDetectionStrategy, Component, input } from '@angular/core';

@Component({
  selector: 'app-file-view',
  templateUrl: './file-view.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class FileViewComponent {
  xmlRaw = input<string | null>(null);

  // XML convertido (nuevo)
  xmlConverted = input<string | null>(null);
}

