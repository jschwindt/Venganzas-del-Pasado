# Informe de seguridad y modernización

Fecha: 25 de septiembre de 2026  
Aplicación: `venganzasdelpasado.com.ar`  
Rama revisada: `main` (`9d54965`)

## Resumen ejecutivo

La aplicación utiliza versiones modernas de Ruby, Rails y sus dependencias, y el despliegue actual está basado en GitHub Actions, una imagen Docker y Caddy como proxy reverso. Hay buenas bases: el contenedor ejecuta como usuario no root, las claves están excluidas del contexto Docker, la API nueva usa comparación constante de tokens, existe validación de rutas de audio y el sitio público entrega HTTPS, HSTS, cookies seguras, `nosniff` y `SAMEORIGIN`.

Sin embargo, no debe considerarse endurecida para producción hasta resolver dos riesgos críticos:

1. Se versionan claves de cifrado de credenciales Rails y un archivo de entorno con secretos.
2. El contenido Markdown puede producir XSS almacenado, incluyendo una ruta de escalamiento hacia cuentas administrativas durante la moderación.

También hay riesgos altos en uploads, cadena de suministro del deploy y el scheduler con acceso al socket Docker, además de varias mejoras necesarias en autenticación, autorización, SSRF, backups, límites de recursos y observabilidad.

Este informe es una auditoría estática y de configuración. No descifra credenciales ni incluye sus valores.

## Alcance y metodología

Se revisaron:

- Rutas, controladores, modelos, servicios, vistas y helpers Rails.
- Devise, CanCanCan, CSRF, sesiones y autenticación de APIs.
- Markdown, contenido generado por usuarios y uploads.
- Dockerfile, `.dockerignore`, Compose, Caddy, scripts de rolling deploy y workflows GitHub Actions.
- Esquema y migraciones de base de datos.
- Dependencias Ruby, JavaScript e importmap.
- Cabeceras reales del sitio público.

Validaciones ejecutadas:

- Brakeman 8.0.6.
- Bundler-audit con RubySec actualizado el 23/09/2026.
- `bun audit` 1.2.23.
- Auditoría de paquetes importmap.
- Sintaxis Ruby, YAML y shell.
- Inspección de cobertura existente.
- Prueba directa del comportamiento de Redcarpet con payloads HTML y `javascript:`.

La suite Rails completa no pudo ejecutarse en este host porque falta la dependencia nativa de MySQL necesaria para compilar `mysql2`; además, los tests completos requieren MySQL y MeiliSearch disponibles.

## Hallazgos críticos

### C1. Claves Rails y secretos versionados

Git contiene las claves de:

- `config/credentials/production.key`
- `config/credentials/development.key`
- `config/credentials/test.key`

También contiene `docker/.env`, que no está ignorado por la regla actual. Las claves fueron incorporadas al historial del repositorio. Aunque los archivos `*.key` están excluidos por `.dockerignore`, siguen siendo accesibles para cualquier persona, fork, runner o acción que pueda leer el repositorio.

La regla de [.gitignore](/home/jschwindt/Work/vdp8/.gitignore:35) sólo contempla `/config/*.key`; no cubre `config/credentials/*.key`.

Impacto:

- Descifrado de credenciales Rails históricas.
- Compromiso potencial de producción si esas credenciales aún se utilizan.
- Exposición a acciones de GitHub comprometidas, porque el checkout contiene los archivos.
- Persistencia del secreto en el historial incluso después de borrarlo de la rama actual.

Remediación urgente:

1. Rotar todos los secretos contenidos en las credenciales cifradas: `secret_key_base`, MeiliSearch, reCAPTCHA, API de audio, SMTP y cualquier otro valor presente.
2. Eliminar del índice las claves y `docker/.env`.
3. Ampliar `.gitignore` para cubrir `config/credentials/*.key` y archivos `.env` anidados, conservando únicamente ejemplos.
4. Reescribir el historial con `git-filter-repo` o BFG.
5. Revocar copias, artefactos y caches que contengan las claves antiguas.
6. Verificar que producción use exclusivamente secretos externos y que las credenciales cifradas obsoletas no se carguen como fallback.

### C2. XSS almacenado en Markdown y contenido automático

El helper marca el HTML renderizado como seguro en [application_helper.rb](/home/jschwindt/Work/vdp8/app/helpers/application_helper.rb:40). Posts, artículos y transcripciones desactivan el filtrado HTML en [_post.html.erb](/home/jschwindt/Work/vdp8/app/views/posts/_post.html.erb:41), y el renderer de Marksmith también usa `filter_html: false` en [renderer.rb](/home/jschwindt/Work/vdp8/app/models/marksmith/renderer.rb:17).

La prueba directa contra Redcarpet mostró:

- Con `filter_html: false`, `<script>alert(1)</script>` se conserva.
- Con `filter_html: true`, un enlace `[clic](javascript:alert(1))` sigue generando un enlace JavaScript si no se activa `safe_links_only`.

Una contribución maliciosa puede ejecutarse cuando un moderador o administrador abre el contenido pendiente. El script tendría acceso al origen de la aplicación y podría ejecutar acciones administrativas autenticadas. Las transcripciones y resúmenes provenientes de APIs también se tratan actualmente como HTML confiable.

Remediación:

- Usar `filter_html: true` y `safe_links_only: true`.
- Aplicar `sanitize` con una allowlist reducida de etiquetas, atributos y protocolos.
- Compartir el mismo renderer seguro entre vistas, previews, RSS y correo.
- Auditar y limpiar contenido existente.
- Rechazar `javascript:`, `data:` peligrosos y atributos `on*`.
- Añadir pruebas con `<script>`, eventos HTML, URLs JavaScript, imágenes remotas y HTML anidado.
- Activar CSP como defensa en profundidad.

## Hallazgos de alta prioridad

### H1. Uploads sin límites efectivos

El formulario afirma un límite de 30 MB, pero no hay validación equivalente en servidor. [media_uploader.rb](/home/jschwindt/Work/vdp8/app/uploaders/media_uploader.rb:21) permite imágenes y MP3, procesa imágenes con ImageMagick y no limita tamaño, dimensiones, cantidad total ni cantidad de nested attributes.

Los archivos pendientes se almacenan bajo `public/system` y Caddy los publica directamente en [venganzasdelpasado.com.ar.caddy](/home/jschwindt/Work/vdp8/deploy/venganzasdelpasado.com.ar.caddy:16). Esto permite enumeración o acceso público a material aún no aprobado y deja una superficie de abuso de almacenamiento y procesamiento.

Recomendaciones:

- Quarantine privado para archivos pendientes.
- Allowlist real de MP3, validación por contenido y `ffprobe`.
- Máximo cuatro segmentos y 30 MB totales por contribución.
- Límite de request en Caddy y en la aplicación.
- Cuotas por usuario y limpieza de archivos rechazados o abandonados.
- No ejecutar ImageMagick sobre entradas que deben ser únicamente audio.

### H2. El deploy no depende de CI

El workflow de CI está deshabilitado por nombre: [.github/workflows/ci.yml-disabled](/home/jschwindt/Work/vdp8/.github/workflows/ci.yml-disabled:1). El workflow de deploy construye y publica directamente en [.github/workflows/deploy.yaml](/home/jschwindt/Work/vdp8/.github/workflows/deploy.yaml:42).

Por lo tanto, un push a `prod` puede publicar una imagen aunque fallen tests, Brakeman, auditorías o RuboCop.

Recomendaciones:

- Reactivar CI y hacer que el build/deploy dependa de sus resultados.
- Proteger `prod` y exigir GitHub Environment con aprobación.
- Ejecutar Brakeman, bundler-audit, Bun/importmap audit, tests y escaneo de imagen antes de publicar.
- Generar SBOM y provenance.
- Desplegar por digest, no sólo por tag.
- Fijar acciones GitHub por SHA.

### H3. Ofelia usa `latest` y acceso al socket Docker

El scheduler usa `mcuadros/ofelia:latest` y monta `/var/run/docker.sock` en [compose.yaml](/home/jschwindt/Work/vdp8/deploy/compose.yaml:64). El montaje `:ro` no restringe las operaciones de la API Docker; una imagen comprometida podría controlar contenedores y, en la práctica, el host.

Recomendaciones:

- Fijar versión y digest.
- Sustituir Ofelia por timers de systemd u otro scheduler sin socket.
- Si el socket es indispensable, utilizar un proxy Docker con allowlist de operaciones.
- Añadir `read_only`, `cap_drop`, `no-new-privileges`, `tmpfs` y límites de CPU/memoria/PIDs.

### H4. Operaciones mutantes mediante GET

Las acciones de aprobación usan GET en [routes.rb](/home/jschwindt/Work/vdp8/config/routes.rb:65), y Devise configura logout por GET en [devise.rb](/home/jschwindt/Work/vdp8/config/initializers/devise.rb:268).

Esto habilita acciones involuntarias por enlaces, prefetch, scanners de correo o navegación cruzada.

Recomendaciones:

- Aprobar mediante `PATCH`/`POST`.
- Eliminar por `DELETE`.
- Logout mediante `DELETE`.
- Mantener CSRF y autorización explícita en cada acción personalizada.
- Agregar tests que rechacen métodos inseguros.

## Hallazgos medios

### M1. SSRF en metadata de afiliados

`AffiliateLink.metadata_for` entrega una URL administrable a MetaInspector en [affiliate_link.rb](/home/jschwindt/Work/vdp8/app/models/affiliate_link.rb:20). Un administrador puede hacer que el servidor consulte localhost, rangos privados o endpoints internos.

Validar HTTPS, bloquear IPs privadas/loopback/link-local, resolver DNS de cada redirección y permitir sólo dominios de proveedores esperados cuando sea posible.

### M2. Posible command injection detectada por Brakeman

Brakeman reportó dos advertencias:

- [post.rb](/home/jschwindt/Work/vdp8/app/models/post.rb:168), al ejecutar `s3cmd`.
- [publish_service.rb](/home/jschwindt/Work/vdp8/app/models/publish_service.rb:42), al ejecutar `aws` mediante backticks.

Aunque algunos valores actuales están restringidos por regex o configuración, deben reemplazarse por `system(programa, argumento1, argumento2)` u `Open3.capture3`, comprobar el código de salida y abortar ante fallos.

Además, la imagen Docker no instala `s3cmd` ni AWS CLI, mientras que la tarea de publicación los utiliza. El error se ignora y puede dejar publicaciones en estado inconsistente.

### M3. API heredada de speech-to-text

[speech_to_text_controller.rb](/home/jschwindt/Work/vdp8/app/controllers/speech_to_text_controller.rb:1) deshabilita CSRF y autentica una petición simulando el inicio de sesión de un usuario real mediante un token estático.

Debe migrarse a una identidad de máquina independiente, token rotatorio, scopes por operación, límites de tamaño y rate limiting. La API nueva de audio pipeline ya tiene una base mejor al comparar hashes de tokens con tiempo constante.

### M4. Autenticación administrativa débil

La contraseña mínima es de seis caracteres y el coste bcrypt explícito es 11. No hay timeout de sesión ni MFA específico para roles privilegiados. Se recomienda:

- Mínimo 12 caracteres.
- Coste bcrypt medido con el hardware real.
- `timeoutable` y reautenticación para acciones sensibles.
- MFA/WebAuthn para administradores.
- `paranoid` en recuperación de cuenta.
- Notificaciones de cambios de contraseña y email.
- Rate limiting para login, reset, comentarios y búsquedas.

### M5. CSP y host authorization ausentes

La configuración CSP está comentada en [content_security_policy.rb](/home/jschwindt/Work/vdp8/config/initializers/content_security_policy.rb:7). La comprobación real del sitio público mostró buenas cabeceras de transporte y cookies, pero no `Content-Security-Policy` ni `Permissions-Policy`.

También está comentada la allowlist de hosts en [production.rb](/home/jschwindt/Work/vdp8/config/environments/production.rb:64). Deben configurarse los dominios públicos y cualquier hostname interno estrictamente necesario.

La CSP debe diseñarse considerando importmap, Google Analytics/Ads, fuentes externas y los scripts inline actuales.

### M6. Backups incompletos o no demostrados

[backup.sh](/home/jschwindt/Work/vdp8/deploy/backup.sh:32) sincroniza sólo ciertos directorios de audio. No demuestra backup restaurable de MySQL, uploads, configuración ni secretos operativos. MeiliSearch puede reconstruirse, pero la base de datos y los uploads requieren una estrategia explícita.

Implementar backups cifrados, retención, pruebas automáticas de restauración y monitoreo de fallos.

## Integridad de datos y modernización

Se recomienda planificar las siguientes mejoras:

- Agregar foreign keys, `NOT NULL`, checks para estados/roles e índices compuestos.
- Añadir índice único de `Audio.url` en base de datos, no sólo validación Rails.
- Migrar tablas `utf8mb3` a `utf8mb4`.
- Cambiar precios `float` por `decimal`.
- Limitar longitud y cantidad de bloques de transcripción y resúmenes.
- Evitar `delete_all` al reemplazar textos si se necesita mantener sincronizado MeiliSearch; usar callbacks o reindexación explícita.
- Separar fecha editorial del `created_at` técnico.
- Mover servicios ubicados en `app/models` a `app/services`.
- Usar Active Job para correos, sitemap, indexación y publicación.
- Evitar `deliver_now` dentro de requests.
- Corregir N+1 en posts, comentarios, audios y afiliados.
- Eliminar o verificar dependencias aparentemente no utilizadas.
- Revisar el bug de [post.rb](/home/jschwindt/Work/vdp8/app/models/post.rb:96): la interpolación escapada puede hacer que publicaciones creadas desde archivos usen la fecha actual en lugar de la fecha del audio.
- Mantener migraciones backward-compatible durante rolling deploy; el entrypoint ejecuta `db:prepare` al iniciar el servidor.

## Resultados de herramientas

| Control | Resultado |
|---|---|
| Brakeman 8.0.6 | 2 advertencias de posible command injection |
| bundler-audit + RubySec actualizado | Sin vulnerabilidades conocidas |
| Bun audit 1.2.23 | Sin vulnerabilidades reportadas |
| Auditoría importmap | Sin vulnerabilidades reportadas |
| Sintaxis Ruby | Correcta |
| Sintaxis YAML | Correcta |
| Sintaxis shell | Correcta |
| RuboCop | 137 infracciones de estilo/formato |
| Cobertura existente | 66,27% |
| Tests Rails completos | No ejecutados: falta dependencia nativa de MySQL y servicios externos |

## Plan de remediación priorizado

### Inmediato

1. Rotar secretos y eliminar claves del repositorio e historial.
2. Bloquear HTML y URLs peligrosas en todo Markdown.
3. Reactivar CI y convertirlo en requisito de deploy.
4. Fijar Ofelia por digest o reemplazarlo.
5. Cambiar acciones administrativas y logout a métodos HTTP seguros.

### Primera semana

1. Endurecer uploads y mover pendientes fuera de rutas públicas.
2. Añadir rate limiting.
3. Corregir SSRF y command execution.
4. Revisar permisos de preview y acciones custom de CanCanCan.
5. Añadir tests de XSS, CSRF, SSRF, uploads, límites y API.
6. Definir backups y probar restauración.

### Evolución posterior

1. CSP, Permissions Policy y host allowlist.
2. MFA para administradores.
3. Contenedor read-only y con capabilities mínimas.
4. Jobs asíncronos y reindexación controlada.
5. Constraints, índices y normalización del esquema.
6. SBOM, firma/verificación de imágenes, escaneo continuo y monitoreo de errores.

## Conclusión

La plataforma de despliegue actual es razonable como base y tiene varias decisiones correctas, pero la exposición de claves y el XSS almacenado requieren tratamiento inmediato. El siguiente despliegue debería bloquearse hasta resolver ambos puntos y habilitar un pipeline CI que impida publicar imágenes sin análisis y tests exitosos.
