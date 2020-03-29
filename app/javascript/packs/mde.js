const InscrybMDE = require('inscrybmde')

$(document).ready(() => {
    const elem = document.getElementById("markdownify")
    if (!elem) {
        return
    }
    const inscrybmde = new InscrybMDE({
        element: elem,
        spellChecker: false,
        autofocus: true,
        forceSync: true,
        indentWithTabs: false,
        lineWrapping: false,
        blockStyles: {
            bold: "**",
            italic: "_"
        },
        insertTexts: {
            link: ["[", "](#play-)"]
        },
        toolbar: [
            "heading", "bold", "italic", "strikethrough", "|", "unordered-list", "ordered-list", "code", "quote", "link", "|", "preview", "side-by-side", "fullscreen", "|", {
                name: 'guide',
                action: 'https://venganzasdelpasado.com.ar/articles/como-editar-posts',
                className: 'fa fa-info-circle',
                noDisable: true,
                title: 'Editor\'s Guide',
                "default": true
            }, {
                name: 'guide',
                action: 'https://venganzasdelpasado.com.ar/articles/markdown',
                className: 'fa fa-question-circle',
                noDisable: true,
                title: 'Markdown Guide',
                "default": true
            }
        ]
    });
    inscrybmde.codemirror.on('refresh', () => {
        if (inscrybmde.isFullscreenActive()) {
            return $('.navbar').hide();
        } else {
            return $('.navbar').show();
        }
    });
})
