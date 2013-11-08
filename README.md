docpad-plugin-bem
=================

DocPad plugin intended to streamline development based [BEM](http://bem.info/) methodology.

Project is in incubating status.

## Features
 - automatic blocks assets (js, css) including (into docpad's scripts and styles blocks)
 - livereload support (of course, with docpad-plugin-livereload)
 - multiple blocks directories
 - asyncronous blocks rendering (like a partials)
 - flexible block container generation (customize tag, append classes, apply modificators, append attributes)

## Roadmap
 - blocks
   - review performance, caching, security, escaping
   - support for block libraries
 - assets
   - concatenate assets for production
   - integrate group-css-media-queries to asset pipeline

## Installation
```bash
docpad install bem
```

## Examples
Directory structure
```
src/
|- documents/
|  |- index.html.jade
|  ...
|- blocks/
|  |- menu/
|  |  |- menu.html.jade
|  |  |- menu.css.styl
|  |- copyright/
|  |  |- copyright.html.jade
|  ...
|- docpad.coffee
```

File docpad.coffee:
```coffee
...
  templateData:
    mainMenuItems: [ # define our main menu items as an array of objects with title and href fields
      { title: "Home", href: "/" }
      { title: "About", href: "/about" }
      { title: "Contact", href: "/contact" }
    ]
    footerMenuItems: [
      { title: "Terms and conditions" }
    ]
    copyright:
      name: "Example project"
      
...
```

File src/documents/index.html.jade:
```jade
---
title: Document title here
---

!!! 5
html
  head
    meta(charset="utf8")
    != getBlock("meta").toHTML()
    title= document.title
    != getBlock("styles").toHTML()
  body
    header
      != block("menu", { items: mainMenuItems })
      
    main
      h1= document.title
    
    footer
      != block("menu", { items: footerMenuItems })
      != block("copyright", { copyright: copyright })
    
    != getBlock("scripts").toHTML()
```

File src/blocks/menu/menu.html.jade
```jade
ul.menu__list
  each item in items
    li.menu__item
      a.menu__item-link(href=item.href, title=item.title)= item.title
```

File src/blocks/menu/menu.css.styl
```styl
.menu
  &__list
    list-style none
  &__item
    list-style none
    float left
    margin 0 10px
  &__item-link
    color blue
    &:hover
      color blue
```

File src/blocks/copyright/copyright.html.jade
```jade
p &copy; #{copyright.name}
```

## Authors
 - [Se7enSky studio](http://www.se7ensky.com/)
 - [Ivan Kravchenko](http://github.com/krava)
 - [Roma Vabishchevych](http://github.com/romavab)

## License

(The MIT License)

Copyright (c) 2008-2013 Se7enSky studio &lt;info@se7ensky.com&gt;

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
