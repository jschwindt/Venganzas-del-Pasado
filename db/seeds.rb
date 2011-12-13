# encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

article = Article.find_or_create_by_title("Markdown")
article.content = <<-CONTENT
Markdown es un lenguaje simple para formatear textos. Permite mediante texto plano utilizar de elementos propios de HTML.

A continuación encontrarás unos ejemplos básicos. Para mayor información, podés consultar [el sitio de su inventor](http://daringfireball.net/projects/markdown/syntax)

### Texto y Links

`*cursiva*`: *cursiva*
`_cursiva_`: _cursiva_
`**negrita**`: **negrita**
`__negrita__`: __negrita__
`[Link a VdP](http://venganzasdelpasado.com.ar/)`: [Link a VdP](http://venganzasdelpasado.com.ar/)

Citas:
`> Cómo será la laguna, que el chancho la cruza al trote`

> Cómo será la laguna, que el chancho la cruza al trote

### Listas

Listas Numeradas:
`1.  Primer Elemento`
`2.  Segundo Elemento`

1.  Primer Elemento
2.  Segundo Elemento

Listas con Viñetas
`* Un Elemento`
`* Otro Elemento`

* Un Elemento
* Otro Elemento

### Encabezados

Los encabezados se inician con <#>:

`# Encabezado 1`
`## Encabezado 2`
`### Encabezado 3`
`#### Encabezado 4`
`##### Encabezado 5`

# Encabezado 1
## Encabezado 2
### Encabezado 3
#### Encabezado 4
##### Encabezado 5
CONTENT

article.save
