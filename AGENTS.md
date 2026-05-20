# Guia Para Agentes

Este repositorio contiene la aplicacion Ruby on Rails de
`venganzasdelpasado.com.ar`. El sitio maneja posts, audios, comentarios,
usuarios, contribuciones, busqueda y administracion.

Usa este archivo como fuente operativa para trabajar en el proyecto. El
`README.md` puede servir de contexto historico, pero no asumas que esta
completamente actualizado.

## Stack

- Ruby `3.2.2`.
- Rails `8.1.1`.
- Node `22.18.0`.
- Base de datos MySQL.
- Redis para cache/servicios.
- MeiliSearch para indexacion y busqueda.
- Frontend con importmap, Turbo, Stimulus, Dart Sass y Bulma.
- Tests con Minitest, fixtures y system tests con Selenium/headless Chrome.

## Comandos

- Setup del entorno: `bin/setup`.
- Servidor de desarrollo: `just dev` o `bin/dev`.
- Tests principales: `bin/rails test`.
- Tests de sistema: `bin/rails test:system`.
- Suite de tests del proyecto: `just test`.
- CI completo local: `bin/ci`.
- Lint Ruby: `bin/rubocop`.
- Auditoria de gems: `just audit`.
- Analisis de seguridad: `bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error`.

`bin/ci` ejecuta setup, RuboCop, auditorias, Brakeman, tests Rails, tests de
sistema y seeds. Usalo como validacion completa antes de publicar cambios.

## Entorno Local

- `docker/docker-compose.yml` levanta MySQL, Redis y MeiliSearch.
- `config/database.yml` usa `DB_HOST` y por defecto conecta a `127.0.0.1`.
- `config/app_config.yml` define rutas locales para audios y utilidades de
  transcripcion; revisalo antes de tocar flujos de audio o speech-to-text.
- Los tests reindexan `Post`, `Comment` y `Text` en `test/test_helper.rb`, por
  lo que MeiliSearch debe estar disponible para correr suites completas.
- No modifiques credenciales, archivos `.env*`, `coverage/`, `log/` ni `tmp/`
  salvo que la tarea lo pida de forma explicita.

## Convenciones De Implementacion

- Preferi patrones Rails existentes: modelos en `app/models`, controladores
  REST en `app/controllers`, vistas ERB en `app/views` y tests Minitest en
  `test/`.
- Mantené los cambios chicos y enfocados. Evita refactors no relacionados con
  la tarea.
- Para cambios de modelo o base de datos, usa migraciones Rails y mantené
  `db/schema.rb` consistente.
- Para busqueda, respeta las definiciones MeiliSearch existentes en los
  modelos y verifica la reindexacion cuando cambien atributos buscables,
  filtrables o indexables.
- Para frontend, usa Stimulus/importmap y estilos SCSS/Bulma ya presentes.
  No introduzcas bundlers, frameworks ni toolchains nuevos sin una razon clara.
- Para permisos, respeta CanCanCan en `Ability` y los roles existentes:
  `moderator`, `editor` y `admin`.
- Para contenido generado por usuarios, comentarios y markdown, cuida
  sanitizacion, estados de moderacion y flujos de autorizacion.

## Pruebas Y Validacion

- Despues de cambios Ruby generales, corre `bin/rubocop` y `bin/rails test`.
- Despues de cambios de navegacion, formularios, JavaScript o layouts, corre
  tambien `bin/rails test:system`.
- Despues de cambios de seguridad, autorizacion o moderacion, agrega o actualiza
  tests de controller/model segun corresponda.
- Para validacion completa antes de un PR, corre `bin/ci`.
- Si una suite falla porque faltan servicios externos locales, dejalo explicito
  y recomienda levantar los servicios de `docker/docker-compose.yml`.

