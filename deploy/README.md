# Deploy de producción

El deploy de VdP usa una imagen publicada por GitHub Actions y un stack Docker
Compose almacenado en `/opt/docker/vdp`. Los archivos de esta carpeta se copian
manualmente al servidor; el workflow sólo publica la imagen y ejecuta
`rolling-update.sh` por SSH.

## Preparación del host

1. Crear los directorios persistentes y permitir escritura al usuario del
   contenedor:

   ```sh
   sudo mkdir -p /opt/docker/vdp /var/log/vdp
   sudo mkdir -p /var/www/venganzasdelpasado.com.ar/{system,uploads,sitemaps}
   sudo chown -R 1001:1001 /var/log/vdp
   sudo chown -R 1001:1001 \
     /var/www/venganzasdelpasado.com.ar/system \
     /var/www/venganzasdelpasado.com.ar/uploads \
     /var/www/venganzasdelpasado.com.ar/sitemaps
   ```

   El UID `1001` también debe poder escribir en las carpetas de audio que usa
   `PublishService`. Caddy necesita acceso de lectura a `/var/www`.

2. Verificar que exista la red externa compartida con Caddy:

   ```sh
   docker network inspect backnet
   ```

   El servicio Caddy compartido también debe montar el árbol multimedia en la
   misma ruta y en modo sólo lectura:

   ```yaml
   volumes:
     - /var/www/venganzasdelpasado.com.ar:/var/www/venganzasdelpasado.com.ar:ro
   ```

3. Copiar el contenido de `deploy/` a `/opt/docker/vdp`, crear `.env` desde
   `.env.sample` y completar los secretos. Nunca copiar `.env` al repositorio.

4. Verificar que MySQL acepte conexiones desde la red bridge de Docker y que
   Postfix acepte SMTP desde `host.docker.internal`.

5. Validar la configuración antes de desplegar:

   ```sh
   cd /opt/docker/vdp
   docker compose config --quiet
   bash -n rolling-update.sh
   ```

## Tareas programadas

Ofelia ejecuta dentro del contenedor `app`, usando la zona horaria
`America/Argentina/Buenos_Aires`:

- `bin/bundler-audit check --update`, todos los días a las 08:00.
- `bun audit`, todos los días a las 08:05.
- `bin/importmap audit`, todos los días a las 08:10.
- `bundle exec rake vdp:contribuciones:publish`, todos los días a las 05:00.

El perfil se habilita con `COMPOSE_PROFILES=scheduler` en `deploy/.env`. Para
iniciar o verificar el scheduler en el host:

```sh
docker compose up -d ofelia
docker compose ps ofelia
docker compose logs --tail 100 ofelia
```

El rolling update detiene Ofelia durante el período en que conviven dos
contenedores `app` y lo recrea al terminar, para evitar ejecuciones duplicadas
y tomar las etiquetas de la nueva imagen.

## GitHub Actions

El workflow se ejecuta con cada push a `prod` y requiere:

- Variables: `REGISTRY_URL`, `SSH_HOST`, `SSH_PORT`, `SSH_USERNAME` y
  `APP_PATH=/opt/docker/vdp`.
- Secretos: `REGISTRY_USERNAME`, `REGISTRY_PASSWORD` y `SSH_KEY`.

Los cambios en `compose.yaml`, Caddy o scripts deben copiarse manualmente al
host antes del push que los necesite.

## Primer despliegue

Después de levantar la primera imagen, crear los índices nuevos de MeiliSearch:

```sh
docker compose exec app bin/rails runner \
  'Post.reindex!(1000, true); Comment.reindex!(1000, true); Text.reindex!(1000, true)'
```

Instalar `venganzasdelpasado.com.ar.caddy` en la ruta importada por el stack de
Caddy y validar/recargar desde `/opt/docker/caddy` usando los comandos propios
de ese stack. Verificar `/up`, búsqueda, correo, cache y sitemap. Para los
audios, probar un MP3 bajo un directorio anual y otro bajo `st5`, incluyendo
una petición Range:

```sh
curl -I https://venganzasdelpasado.com.ar/2026/lavenganza_2026-07-17.mp3
curl -I -H 'Range: bytes=0-1023' \
  https://venganzasdelpasado.com.ar/2026/lavenganza_2026-07-17.mp3
curl -I https://venganzasdelpasado.com.ar/publish/archivo.mp3
```

La segunda respuesta debe ser `206 Partial Content`; la ruta bajo `publish`
no debe ser publicada por Caddy.

## Persistencia de Valkey

Valkey conserva RDB y AOF en el volumen `vdp-valkey-data`. Para verificarlo:

```sh
docker compose exec valkey valkey-cli INFO persistence
docker compose exec valkey valkey-cli SET vdp:persistence-check ok
docker compose restart valkey
docker compose exec valkey valkey-cli GET vdp:persistence-check
docker compose up -d --force-recreate valkey
docker compose exec valkey valkey-cli GET vdp:persistence-check
docker compose exec valkey valkey-cli DEL vdp:persistence-check
```

`aof_enabled` debe ser `1`; `aof_last_write_status` y
`aof_last_bgrewrite_status` deben indicar `ok`.

## Rollback

```sh
./rolling-update.sh releases
./rolling-update.sh rollback
```

El rollback cambia la imagen de Rails, pero no revierte migraciones MySQL.
