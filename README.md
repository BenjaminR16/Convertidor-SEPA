# Convertidor SEPA

El **Convertidor SEPA** es una aplicación compuesta por un **frontend Angular** y un **backend Spring Boot** que permite convertir ficheros SEPA entre distintos formatos (SCT ↔ SDD) mediante transformaciones **XSLT** y validaciones **XSD**.  

Incluye gestión de errores, previsualización de resultados y descarga del fichero convertido.

---

## 1. Estructura del proyecto

```text
Convertidor-SEPA/
├─ angular-app/
│  └─ convertidor-sepa/      # Aplicación Angular (frontend)
└─ springboot-app/
   └─ convertidor-sepa/      # Aplicación Spring Boot (backend)
```

---

## 2. Requisitos previos

Asegúrate de tener instalado:

- Git  
- Node.js (versión LTS recomendada) y npm  
- Java 17 (o la versión indicada en el `pom.xml`)  
- Maven (solo si no se usa el wrapper `mvnw` incluido)

---

## 3. Instalación

### 3.1 Clonar el repositorio

```bash
git clone https://github.com/usuario/convertidor-sepa.git
cd convertidor-sepa
```

---

## 4. Backend (Spring Boot)

### 4.1 Acceder al proyecto backend

```bash
cd springboot-app/convertidor-sepa
```

### 4.2 Ejecutar con Maven wrapper

```bash
./mvnw spring-boot:run
```

En Windows:

```bash
mvnw.cmd spring-boot:run
```

O usando Maven instalado:

```bash
mvn spring-boot:run
```

### 4.3 URL del backend

```text
http://localhost:8080
```

### 4.4 Endpoints principales

> Nota: los endpoints reales del proyecto son:

| Método | Endpoint                          | Función                                                                 |
|--------|-----------------------------------|-------------------------------------------------------------------------|
| POST   | `/api/v1/convert`                | Convierte ficheros SEPA (detección automática SCT → SDD / SDD → SCT)   |
| POST   | `/api/v1/convert/download`       | Devuelve el fichero convertido como descarga XML                       |
| POST   | `/api/v1/convert/executive-view` | Devuelve metadatos/resumen del XML convertido (vista ejecutiva)        |

---

## 5. Frontend (Angular)

### 5.1 Acceder al proyecto Angular

```bash
cd angular-app/convertidor-sepa
```

### 5.2 Instalar dependencias

```bash
npm install
```

### 5.3 Ejecutar el frontend

```bash
npm start
# o
ng serve
```

### 5.4 URL del frontend

```text
http://localhost:4200
```

---

## 6. Funcionamiento

1. El usuario sube un fichero SEPA (XML) desde la interfaz web.
2. El sistema detecta automáticamente si el fichero es:
   - SCT (`pain.001.*.*`)
   - SDD (`pain.008.*.*`)
3. Según el tipo, aplica la conversión:
   - SCT → SDD
   - SDD → SCT
4. El frontend envía el archivo al backend.
5. El backend:
   - Valida el XML usando los XSD correspondientes.
   - Aplica la transformación XSLT adecuada (según versión).
   - Devuelve el fichero convertido.
6. El usuario puede:
   - Previsualizar el XML original y el convertido.
   - Ver un resumen ejecutivo de la conversión.
   - Descargar el XML resultante o un PDF resumen.

---

## 7. Tecnologías utilizadas

### Backend

- Java 17 / 21  
- Spring Boot (REST API)  
- Validación con XSD (ISO 20022: `pain.001`, `pain.008`)  
- Transformaciones XSLT entre:
  - `pain.001.001.03`, `pain.001.003.03`, `pain.001.001.09`
  - `pain.008.001.02`, `pain.008.001.08`, `pain.008.003.02`

### Frontend

- Angular 20  
- Servicios HTTP (`HttpClient`)  
- Manejo de ficheros (drag & drop, validación básica)  
- Vista comparativa XML original / convertido  
- Generación de PDF resumen (jsPDF)

---

## 8. Estructura de ficheros XSLT y XSD (backend)

```text
springboot-app/convertidor-sepa/
└── src/
    └── main/
        ├── resources/
        │   ├── xslt/
        │   │   ├── sct103-to-sdd108.xslt   # pain.001.001.03 → pain.008.001.08
        │   │   ├── sct303-to-sdd108.xslt   # pain.001.003.03 → pain.008.001.08
        │   │   ├── sct109-to-sdd108.xslt   # pain.001.001.09 → pain.008.001.08
        │   │   ├── sdd102-to-sct109.xslt   # pain.008.001.02 → pain.001.001.09
        │   │   ├── sdd302-to-sct109.xslt   # pain.008.003.02 → pain.001.001.09
        │   │   └── sdd108-to-sct109.xslt   # pain.008.001.08 → pain.001.001.09
        │   └── xsd/
        │       ├── pain.001.001.03.xsd
        │       ├── pain.001.003.03.xsd
        │       ├── pain.001.001.09.xsd
        │       ├── pain.008.001.02.xsd
        │       ├── pain.008.001.08.xsd
        │       └── pain.008.003.02.xsd
```

---

## 9. Errores frecuentes

###  “El fichero XML no cumple el esquema XSD”

- El archivo no coincide con el estándar SEPA esperado (`pain.001`, `pain.008`, versión incorrecta, etc.).
- Puede deberse a:
  - Falta de campos obligatorios.
  - Namespace incorrecto.
  - Estructura no compatible con las versiones soportadas.

###  Problemas CORS entre Angular y Spring Boot

Si el frontend no puede llamar al backend (errores CORS en consola):

- Verifica que el backend expone CORS para `http://localhost:4200`.  
- En este proyecto se configura en:

```java
// AppConfig.java
registry.addMapping("/api/**")
        .allowedOrigins("http://localhost:4200")
        .allowedMethods("POST", "OPTIONS")
        .allowedHeaders("*");
```

---

## 10. Contribuir

1. Crea una rama a partir de `main`.  
2. Realiza tus cambios en frontend y/o backend.  
3. Ejecuta los proyectos y verifica que las conversiones funcionan.  
4. Envía un *pull request* describiendo los cambios realizados.