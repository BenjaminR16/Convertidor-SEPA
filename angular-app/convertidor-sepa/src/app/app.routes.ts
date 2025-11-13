import { Routes } from '@angular/router';

export const routes: Routes = [
    {
        path: 'dashboard',
        loadComponent: () =>
            import('./converter/pages/dashboard/dashboard.page').then((m: any) => m.DashboardPage),
    },
    {
        path: 'executive-view',
        loadComponent: () =>
            import('./converter/pages/executive-view/executive-view.page').then(m => m.ExecutiveViewPage),
    },
    { path: '**', redirectTo: 'dashboard' },
];
