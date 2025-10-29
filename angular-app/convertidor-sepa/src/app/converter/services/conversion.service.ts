import { Injectable } from '@angular/core';
import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { ConversionResult } from '../interface/conversion-result';
import { FileInfo } from '../interface/file-info.model';

@Injectable({
  providedIn: 'root'
})
export class ConversionService {

  private readonly apiUrl = 'http://localhost:8080/api/v1/convert';

  constructor(private http: HttpClient) { }

  convertFile(file: File, direction: string = 'auto'): Observable<ConversionResult> {
    const formData = new FormData();
    formData.append('file', file);
    formData.append('direction', direction);

    return this.http
      .post<ConversionResult>(this.apiUrl, formData)
      .pipe(catchError(this.handleError));
  }


  downloadFile(file: File, direction: string = 'auto'): Observable<Blob> {
    const formData = new FormData();
    formData.append('file', file);
    formData.append('direction', direction);

    return this.http
      .post(`${this.apiUrl}/download`, formData, { responseType: 'blob' })
      .pipe(catchError(this.handleError));
  }

  viewConverted(file: File, direction: string = 'auto'): Observable<FileInfo> {
    const formData = new FormData();
    formData.append('file', file);
    formData.append('direction', direction);

    return this.http
      .post<FileInfo>(`${this.apiUrl}/executive-view`, formData)
      .pipe(catchError(this.handleError));
  }


  private handleError(error: HttpErrorResponse) {
    let message: string;

    if (error.error instanceof ErrorEvent) {
      // Error del lado del cliente o de red
      message = `Error del cliente: ${error.error.message}`;
    } else {
      // Errores devueltos por el backend 
      if (typeof error.error === 'string') {
        message = error.error;
      } else if (error.error?.message) {
        message = error.error.message;
      } else {
        message = `Error del servidor (${error.status}): ${error.statusText}`;
      }
    }

    console.error('Error HTTP capturado:', error);
    return throwError(() => new Error(message));
  }

}
