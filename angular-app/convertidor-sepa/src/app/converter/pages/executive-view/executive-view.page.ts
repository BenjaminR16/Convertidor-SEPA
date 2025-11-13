import { Component, inject, signal } from '@angular/core';
import { Router } from '@angular/router';
import { XmlView } from '../../components/executive-components/xml-view/xml-view.component';
import { ExecutiveIntroComponent } from '../../components/executive-components/hero-section/executive-intro.component';
import { ConversionInfoGridComponent } from '../../components/executive-components/info-grid/conversion-info-grid.component';
import { ConversionActionsComponent } from '../../components/executive-components/actions/conversion-actions.component';
import { SupportCardComponent } from '../../components/executive-components/support-card/support-card.component';

@Component({
    selector: 'app-executive-view-page',
    standalone: true,
    imports: [XmlView, ExecutiveIntroComponent, ConversionInfoGridComponent, ConversionActionsComponent, SupportCardComponent],
    templateUrl: './executive-view.page.html',
})
export class ExecutiveViewPage {
    private router = inject(Router);

    private readonly navigationState = (this.router.currentNavigation()?.extras.state) ??
        (typeof window !== 'undefined' ? window.history.state : null);

    readonly xmlRaw = signal<string | null>(this.navigationState?.xmlRaw ?? null);
    readonly xmlConverted = signal<string | null>(this.navigationState?.xmlConverted ?? null);
}
