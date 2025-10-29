import { Component, input } from '@angular/core';

@Component({
  selector: 'app-xml-view',
  imports: [],
  templateUrl: './xml-view.component.html',
})
export class XmlView {
  xmlRaw = input<string | null>(null);
  xmlConverted = input<string | null>(null);
}
