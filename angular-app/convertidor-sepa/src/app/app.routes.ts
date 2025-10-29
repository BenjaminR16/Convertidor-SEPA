import { Routes } from '@angular/router';

export const routes: Routes = [
    {
        path: 'dashboard',
        loadComponent: () =>
            import('./converter/pages/dashboard.pages/dashboard.pages').then((m: any) => m.DashboardPages),
        children: [
            {
                path: '',
                pathMatch: 'full',
                loadComponent: () =>
                    import('./converter/components/file-upload/file-upload.component').then(m => m.FileUploadComponent),
            },
            {
                path: 'executive-view',
                loadComponent: () =>
                    import('./converter/pages/executive-view.pages/executive-view.pages').then(m => m.ExecutiveViewPages),
            },
        ],
    },
    { path: '**', redirectTo: 'dashboard' },
];
