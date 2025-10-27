import { Injectable } from '@angular/core';
import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { ConversionResult } from '../interfaces/conversion-result.model';
import { FileInfo } from '../interfaces/file-info.model';

@Injectable({
  providedIn: 'root'
})
export class ConversionService {

  private apiUrl = 'http://localhost:8080/api/v1/convert';

  constructor(private http: HttpClient) { }

  // Convierte archivo y devuelve JSON con convertedXml
  convertFile(file: File, direction?: string): Observable<ConversionResult> {
    const formData = new FormData();
    formData.append('file', file);
    if (direction) formData.append('direction', direction);

    return this.http.post<ConversionResult>(`${this.apiUrl}`, formData)
      .pipe(catchError(this.handleError));
  }

  // Descarga archivo convertido
  downloadFile(file: File, direction?: string): Observable<Blob> {
    const formData = new FormData();
    formData.append('file', file);
    if (direction) formData.append('direction', direction);

    return this.http.post(`${this.apiUrl}/download`, formData, {
      responseType: 'blob'
    }).pipe(catchError(this.handleError));
  }

  // Muestra metadata del archivo convertido
  viewConverted(file: File, direction?: string): Observable<FileInfo> {
    const formData = new FormData();
    formData.append('file', file);
    if (direction) formData.append('direction', direction);

    return this.http.post<FileInfo>(`${this.apiUrl}/executive-view`, formData)
      .pipe(catchError(this.handleError));
  }

  private handleError(error: HttpErrorResponse) {
    let message = 'Error desconocido';
    if (error.error instanceof ErrorEvent) {
      message = `Error del cliente: ${error.error.message}`;
    } else {
      message = `Error del servidor (${error.status}): ${error.error}`;
    }
    return throwError(() => new Error(message));
  }
}
