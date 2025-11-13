import { ChangeDetectionStrategy, Component, computed, input } from '@angular/core';
import { XmlInfo } from '../models/xml-info.model';

@Component({
  selector: 'app-conversion-info-grid',
  standalone: true,
  imports: [],
  templateUrl: './conversion-info-grid.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ConversionInfoGridComponent {
  xml = input<string | null>(null);

  readonly items = computed(() => buildXmlInfo(this.xml()));
}

export function buildXmlInfo(xml: string | null): XmlInfo[] {
  if (!xml) return [];

  const parser = new DOMParser();
  const xmlDoc = parser.parseFromString(xml, 'text/xml');
  const info: XmlInfo[] = [];

  const messageType = xmlDoc.documentElement?.tagName || 'Desconocido';
  info.push({
    label: 'Tipo de Mensaje',
    value: messageType,
    icon: '📄',
  });

  const messageId = xmlDoc.querySelector('MsgId')?.textContent ||
    xmlDoc.querySelector('GrpHdr MsgId')?.textContent ||
    'No disponible';
  info.push({
    label: 'ID del Mensaje',
    value: messageId,
    icon: '🆔',
  });

  const creationDate = xmlDoc.querySelector('CreDtTm')?.textContent ||
    xmlDoc.querySelector('GrpHdr CreDtTm')?.textContent ||
    'No disponible';
  if (creationDate !== 'No disponible') {
    const date = new Date(creationDate).toLocaleString('es-ES');
    info.push({
      label: 'Fecha de Creación',
      value: date,
      icon: '📅',
    });
  }

  const transactions = xmlDoc.querySelectorAll('CdtTrfTxInf, DrctDbtTxInf');
  if (transactions.length > 0) {
    info.push({
      label: 'Número de Transacciones',
      value: transactions.length.toString(),
      icon: '🔢',
    });
  }

  let totalAmount = 0;
  const amounts = xmlDoc.querySelectorAll('Amt');
  amounts.forEach(amount => {
    const value = parseFloat(amount.textContent || '0');
    if (!isNaN(value)) {
      totalAmount += value;
    }
  });

  if (totalAmount > 0) {
    info.push({
      label: 'Monto Total',
      value: `€${totalAmount.toFixed(2)}`,
      icon: '💰',
    });
  }

  const debtorName = xmlDoc.querySelector('Dbtr Nm')?.textContent ||
    xmlDoc.querySelector('InitgPty Nm')?.textContent ||
    'No disponible';
  if (debtorName !== 'No disponible') {
    info.push({
      label: 'Ordenante',
      value: debtorName,
      icon: '👤',
    });
  }

  const debtorIban = xmlDoc.querySelector('DbtrAcct Id IBAN')?.textContent ||
    xmlDoc.querySelector('DbtrAcct Id Othr Id')?.textContent ||
    'No disponible';
  if (debtorIban !== 'No disponible') {
    info.push({
      label: 'IBAN Ordenante',
      value: debtorIban,
      icon: '🏦',
    });
  }

  return info;
}
