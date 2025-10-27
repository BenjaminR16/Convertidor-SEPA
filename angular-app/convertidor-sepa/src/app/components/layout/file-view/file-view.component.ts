import { ChangeDetectionStrategy, Component, Input } from '@angular/core';
import { FileInfo } from '../interfaces/file-info.model';

@Component({
  selector: 'app-file-view',
  templateUrl: './file-view.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class FileViewComponent {
  @Input() originalInfo: FileInfo | null = null;
  @Input() convertedInfo: FileInfo | null = null;
}

