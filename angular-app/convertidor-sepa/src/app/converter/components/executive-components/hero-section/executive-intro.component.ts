import { ChangeDetectionStrategy, Component, input } from '@angular/core';

@Component({
  selector: 'app-executive-intro',
  standalone: true,
  templateUrl: './executive-intro.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ExecutiveIntroComponent {
  title = input('Resultado de Conversión');
  description = input('Revisa y descarga tu archivo XML convertido. Compara el original con el resultado final.');
}
