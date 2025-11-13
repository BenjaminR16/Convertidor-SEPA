import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'app-support-card',
  standalone: true,
  templateUrl: './support-card.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class SupportCardComponent { }
