# Portfolio — Oscar Carrero

Portfolio profesional de Oscar Carrero, orientado a su experiencia como Senior QA Engineer, QA Automation Engineer y desarrollador de software.

La aplicación está construida con Flask y renderiza en el servidor una landing page estática con la experiencia profesional, el stack técnico, los proyectos y los enlaces de contacto.

## Tecnologías

- Python 3.13
- Flask
- Jinja
- Gunicorn
- HTML, CSS y JavaScript
- Docker y Docker Compose
- mypy para análisis estático de tipos
- GitHub Actions para validación y despliegue

## Funcionalidad actual

- Página principal responsive.
- Sección de presentación y perfil profesional.
- Historial de experiencia, incluyendo el puesto actual en Legrand.
- Áreas de conocimiento y tecnologías.
- Listado de proyectos destacados.
- Descarga del CV en PDF.
- Enlaces a GitHub, LinkedIn y correo electrónico.
- Endpoint de salud en `/health`.
- Imagen Docker preparada para ejecutarse con un usuario sin privilegios.
- Integración continua para pull requests y cambios en `main`.
- Despliegue a producción controlado mediante tags de versión.

## Estructura del proyecto

```text
portfolio/
├── app.py                     # Aplicación Flask y rutas
├── data/
│   ├── experience.py          # Experiencia profesional
│   ├── projects.py            # Proyectos destacados
│   ├── skills.py              # Áreas técnicas y tecnologías
│   └── models.py              # Modelos de datos inmutables
├── templates/
│   ├── base.html              # Estructura HTML común
│   └── index.html             # Contenido de la página principal
├── static/
│   ├── css/                   # Estilos del portfolio
│   ├── js/                    # Comportamiento del frontend
│   └── cv/                    # CV descargable
├── Dockerfile                 # Etapas de validación y ejecución
├── compose.prod.yml           # Ejecución del contenedor
├── requirements.txt           # Dependencias de producción
├── requirements-dev.txt       # Dependencias de desarrollo
└── pyproject.toml             # Configuración de mypy
```

## Arranque en local con Python

### Requisitos

- Python 3.13 o posterior.
- `pip`.

Se recomienda Python 3.13 porque es la versión utilizada por la imagen Docker del proyecto.

### 1. Crear y activar el entorno virtual

En macOS o Linux:

```bash
python3.13 -m venv .venv
source .venv/bin/activate
```

En Windows PowerShell:

```powershell
py -3.13 -m venv .venv
.venv\Scripts\Activate.ps1
```

### 2. Instalar las dependencias

Para desarrollar y ejecutar las comprobaciones:

```bash
python -m pip install --upgrade pip
python -m pip install -r requirements-dev.txt
```

`requirements-dev.txt` incluye también las dependencias de producción.

### 3. Ejecutar la aplicación

```bash
flask --app app run --debug
```

El portfolio estará disponible en:

- Web: <http://127.0.0.1:5000>
- Estado de la aplicación: <http://127.0.0.1:5000/health>

También se puede arrancar directamente con:

```bash
python app.py
```

Para detener el servidor, pulsa `Ctrl+C`.

## Arranque local con Gunicorn

Para aproximarse al servidor utilizado en producción:

```bash
gunicorn --bind 127.0.0.1:8000 --workers 2 app:app
```

La aplicación estará disponible en <http://127.0.0.1:8000>.

Gunicorn no funciona de forma nativa en Windows. En ese sistema se recomienda usar el servidor de desarrollo de Flask o Docker.

## Arranque con Docker

### Validar el proyecto

La etapa `test` instala las dependencias de desarrollo, ejecuta mypy y comprueba las rutas `/` y `/health`:

```bash
docker build --target test --tag portfolio:test .
```

### Construir y ejecutar la imagen

```bash
docker build --target runtime --tag portfolio:local .
docker run --rm --name portfolio-local -p 8000:8000 portfolio:local
```

Abre <http://127.0.0.1:8000> en el navegador.

### Usar Docker Compose

```bash
docker compose -f compose.prod.yml up --build
```

Con esta configuración el portfolio se publica únicamente en la interfaz local mediante <http://127.0.0.1:8001>.

Para detenerlo:

```bash
docker compose -f compose.prod.yml down
```

## Comprobaciones de desarrollo

Ejecutar el análisis estático de tipos:

```bash
mypy
```

Realizar una comprobación rápida de las dos rutas:

```bash
python -c "from app import app; client = app.test_client(); assert client.get('/').status_code == 200; assert client.get('/health').get_json() == {'status': 'ok'}"
```

Actualmente no existe una suite independiente de pruebas con pytest; las comprobaciones mínimas se ejecutan durante la construcción de la etapa `test` del Dockerfile.

## Actualización del contenido

El contenido principal se mantiene separado de las plantillas:

- Experiencia: `data/experience.py`
- Tecnologías: `data/skills.py`
- Proyectos: `data/projects.py`
- CV: `static/cv/cv_ocarrero_eng.pdf`

Las estructuras utilizadas por estos archivos están definidas en `data/models.py`.

## Producción y despliegue

La imagen de producción ejecuta Gunicorn en el puerto `8000` y dispone de un `HEALTHCHECK` sobre `/health`. El contenedor se ejecuta como un usuario sin privilegios y la configuración de Compose añade un sistema de archivos de solo lectura, elimina capabilities de Linux e impide la obtención de nuevos privilegios.

El workflow `.github/workflows/ci.yml` valida la aplicación en cada pull request dirigido a `main` y después de cada cambio integrado en esa rama. Estos eventos no despliegan la aplicación.

El workflow `.github/workflows/deploy-production.yml`:

1. Se ejecuta exclusivamente al subir un tag con formato `vX.Y.Z`.
2. Comprueba que el tag sea una versión semántica válida y que su commit pertenezca a `main`.
3. Construye la etapa Docker de validación.
4. Configura el acceso SSH mediante secretos de GitHub.
5. Ejecuta el script de despliegue configurado en el VPS.

Para publicar una versión desde un `main` actualizado:

```bash
git switch main
git pull --ff-only
git tag -a v1.0.0 -m "Portfolio v1.0.0"
git push origin v1.0.0
```

Publicar cambios o fusionar un pull request en `main` ya no provoca un despliegue. El tag debe seguir exactamente el formato `vX.Y.Z`, por ejemplo `v1.0.1` o `v1.2.0`.

El repositorio necesita los siguientes secretos para desplegar:

- `SSH_PRIVATE_KEY`
- `VPS_KNOWN_HOSTS`
- `VPS_HOST`
- `VPS_USER`

## Licencia

Este repositorio contiene el portfolio personal de Oscar Carrero. No se ha definido todavía una licencia de distribución.
