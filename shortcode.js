export default function(eleventyConfig) {
eleventyConfig.addShortcode("pc",(content) =>`<pre><code>{% ${content} %}</code></pre> `,);
eleventyConfig.addShortcode("linkprimary",(content,url) =>`<a href="${url}" class="primary">${content}</a> `,);
eleventyConfig.addShortcode("linksecondary",(content,url) =>`<a href="${url}" class="secondary">${content}</a> `,);
eleventyConfig.addShortcode("linkcontrast",(content,url) =>`<a href="${url}" class="contrast">${content}</a> `,);
eleventyConfig.addShortcode("buttonprimary",(content,url) =>`<a href="${url}" type="button" class="primary">${content}</a> `,);
eleventyConfig.addShortcode("buttonsecondary",(content,url) =>`<a href="${url}" type="button" class="secondary">${content}</a> `,);
eleventyConfig.addShortcode("buttoncontrast",(content,url) =>`<a href="${url}" type="button" class="contrast">${content}</a> `,);
eleventyConfig.addShortcode("blockquote",(content,cite) =>`<blockquote>“${content}“<footer><cite>— ${cite}</cite></footer></blockquote>`,);
eleventyConfig.addShortcode("blockquotesmall",(content,cite) =>`<div class="grid"><div><blockquote>“${content}“<footer><cite>— ${cite}</cite></footer></blockquote></div><div></div></div>`,);
eleventyConfig.addShortcode("card",(header,content,footer) =>`<article><header>${header}</header>${content}<footer>${footer}</footer></article>`,);
eleventyConfig.addShortcode("cardsmall",(header,content,footer) =>`<div class="grid"><div><article><header>${header}</header>${content}<footer>${footer}</footer></article></div><div></div></div>`,);
eleventyConfig.addShortcode("sidenotes",(content,notes) =>`<section><div class="grid"><div><p>${content}</p></div><div><p><cite><small>${notes}</small></cite></p></div></div></section>`,);
eleventyConfig.addShortcode("sidenoteslink",(content,notes,text,link) =>`<section><div class="grid"><div><p>${content}</p></div><div><p><cite><small>${notes} <a href="${link}">${text}</a></small></cite></p></div></div></section>`,);
eleventyConfig.addShortcode("sidenotesblockquote",(content,text,footer) =>`<div class="grid"><div>${content}</div><div><blockquote>“${text}“<footer><cite>— ${footer}</cite></footer></blockquote></div></div>`,);
eleventyConfig.addShortcode("sidenotesimage",(content,text,image) =>`<section><div class="grid"><div><p>${content}</p></div><div><img loading="lazy" src="${image}" alt="${text}"/"><p><cite><small>${text}</small></cite></p></div></div></section>`,);
eleventyConfig.addShortcode("sidenotesimagelink",(content,text,image,footer,link) =>`<section><div class="grid"><div><p>${content}</p></div><div><img loading="lazy"  src="${image}" alt="${footer}"/"><p><cite><small>${text} <a href="${link}">${footer}</a></small></cite></p></div></div></section>`,);
eleventyConfig.addShortcode("sidenotesvideolink",(content,text,video,footer,link) =>`<section><div class="grid"><div><p>${content}</p></div><div><iframe title="${footer}" loading="lazy" src="${video}"></iframe><p><cite><small>${text} <a href="${link}">${footer}</a></small></cite></p></div></div></section>`,);
eleventyConfig.addShortcode("sidenotesvideo",(content,text,video) =>`<section><div class="grid"><div><p>${content}</p></div><div><iframe title="${text}" loading="lazy" src="${video}"></iframe><p><cite><small>${text} </small></cite></p></div></div></section>`,);
eleventyConfig.addShortcode("sidenotesid",(content,notes) =>`<section class="sn"><div class="grid"><div><p>${content}</p></div><div><p><cite><small><sup class="snt"></sup> ${notes}</small></cite></p></div></div></section>`,);
eleventyConfig.addShortcode("sidenotesidlink",(content,notes,text,link) =>`<section class="sn"><div class="grid"><div><p>${content}</p></div><div><p><cite><small><sup class="snt"></sup> ${notes} <a href="${link}">${text}</a></small></cite></p></div></div></section>`,);
eleventyConfig.addShortcode("sidenotesidblockquote",(content,text,footer) =>`<section class="sn"><div class="grid"><div>${content}</div><div><blockquote><sup class="snt"></sup> “${text}“<footer><cite>— ${footer}</cite></footer></blockquote></div></div></section>`,);
eleventyConfig.addShortcode("sidenotesidimage",(content,text,image) =>`<section><div class="grid"><div><p>${content}</p></div><div><img loading="lazy" src="${image}" alt="${text}"/"><p><cite><small><sup class="snt"></sup> ${text}</small></cite></p></div></div></section>`,);
eleventyConfig.addShortcode("sidenotesidimagelink",(content,text,image,footer,link) =>`<section class="sn"><div class="grid"><div><p>${content}</p></div><div><img loading="lazy"  src="${image}" alt="${footer}"/"><p><cite><small><sup class="snt"></sup> ${text} <a href="${link}">${footer}</a></small></cite></p></div></div></section>`,);
eleventyConfig.addShortcode("sidenotesidvideolink",(content,text,video,footer,link) =>`<section class="sn"><div class="grid"><div><p>${content}</p></div><div><iframe title="${footer}" loading="lazy" src="${video}"></iframe><p><cite><small><sup class="snt"></sup> ${text} <a href="${link}">${footer}</a></small></cite></p></div></div></section>`,);
eleventyConfig.addShortcode("sidenotesidvideo",(content,text,video) =>`<section class="sn"><div class="grid"><div><p>${content}</p></div><div><iframe title="${text}" loading="lazy" src="${video}"></iframe><p><cite><small><sup class="snt"></sup> ${text} </small></cite></p></div></div></section>`,);
eleventyConfig.addShortcode("sidenotesidurl",(id,content,notes) =>`<section class="sn"  id="${id}"><div class="grid"><div><p>${content}</p></div><div><p><cite><small><a href="#${id}"><sup class="snl"></sup></a> ${notes}</small></cite></p></div></div></section>`,);
eleventyConfig.addShortcode("sidenotesidurllink",(id,content,notes,text,link) =>`<section class="sn"  id="${id}"><div class="grid"><div><p>${content}</p></div><div><p><cite><small><a href="#${id}"><sup class="snl"></sup></a> ${notes} <a href="${link}">${text}</a></small></cite></p></div></div></section>`,);
eleventyConfig.addShortcode("sidenotesidurlblockquote",(id,content,text,footer) =>`<section class="sn"  id="${id}"><div class="grid"><div>${content}</div><div><blockquote><a href="#${id}"><sup class="snl"></sup></a> “${text}“<footer><cite>— ${footer}</cite></footer></blockquote></div></div></section>`,);
eleventyConfig.addShortcode("sidenotesidurlimage",(id,content,text,image) =>`<section><div class="grid"><div><p>${content}</p></div><div><img loading="lazy" src="${image}" alt="${text}"/"><p><cite><small><a href="#${id}"><sup class="snl"></sup></a> ${text}</small></cite></p></div></div></section>`,);
eleventyConfig.addShortcode("sidenotesidurlimagelink",(id,content,text,image,footer,link) =>`<section class="sn"  id="${id}"><div class="grid"><div><p>${content}</p></div><div><img loading="lazy"  src="${image}" alt="${footer}"/"><p><cite><small><a href="#${id}"><sup class="snl"></sup></a> ${text} <a href="${link}">${footer}</a></small></cite></p></div></div></section>`,);
eleventyConfig.addShortcode("sidenotesidurlvideolink",(id,content,text,video,footer,link) =>`<section class="sn"  id="${id}"><div class="grid"><div><p>${content}</p></div><div><iframe title="${footer}" loading="lazy" src="${video}"></iframe><p><cite><small><a href="#${id}"><sup class="snl"></sup></a> ${text} <a href="${link}">${footer}</a></small></cite></p></div></div></section>`,);
eleventyConfig.addShortcode("sidenotesidurlvideo",(id,content,text,video) =>`<section class="sn"  id="${id}"><div class="grid"><div><p>${content}</p></div><div><iframe title="${text}" loading="lazy" src="${video}"></iframe><p><cite><small><a href="#${id}"><sup class="snl"></sup></a> ${text} </small></cite></p></div></div></section>`,);
eleventyConfig.addShortcode("image",(image,title) =>`<img src="${image}" loading="lazy" title="${title}"/>`,);
eleventyConfig.addShortcode("imagesmall",(image,title) =>`<div class="grid"><div><img src="${image}" loading="lazy" title="${title}"/></div><div></div></div>`,);
eleventyConfig.addShortcode("video",(video,title) =>`<iframe title="${title}" loading="lazy" src="${video}"></iframe>`,);
eleventyConfig.addShortcode("videosmall",(video,title) =>`<div class="grid"><div><iframe title="${title}" loading="lazy" src="${video}"></iframe></div><div></div></div>`,);
eleventyConfig.addShortcode("github",(title, url) =>`<div><img src="/static/images/github-mark.png" loading="lazy" title="${title}" height="56px", width="50px"/> <a href="${url}" class="primary">${title}</a></div>`,);
eleventyConfig.addShortcode("downloadsourcefilenote", (optionalnote)=>{
    let note = optionalnote
    if(!optionalnote)
        note = "**click 'Download' at top right corner of code block for whole file"
    return `<sup><sub>${note}</sub></sup>`
});
eleventyConfig.addShortcode("indent", (optionalnumber)=>{
    let number = optionalnumber
    if(!optionalnumber)
        number=4
    let indent = ""
    for(let i=0;i<number;i++)
        indent = `${indent}&nbsp;`
    return indent
});
};
