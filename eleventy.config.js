import { IdAttributePlugin, InputPathToUrlTransformPlugin, HtmlBasePlugin } from "@11ty/eleventy";
import navigation from "@11ty/eleventy-navigation"
import markdownIt from "markdown-it";
import markdownItAttr from "markdown-it-attrs";
import {tabber, tab} from "./tabs.js"
import pluginFilters from "./filters.js";
import pluginShortcodes from "./shortcode.js";
import CleanCSS from "clean-css";
import { execSync } from 'child_process';

export default function (eleventyConfig) {

    // PLUGINS
    eleventyConfig.addPlugin(navigation);
	eleventyConfig.addPlugin(HtmlBasePlugin);
	eleventyConfig.addPlugin(InputPathToUrlTransformPlugin);
    eleventyConfig.addPlugin(IdAttributePlugin, {
        checkDuplicates: "false"
    });
    eleventyConfig.addPlugin(pluginFilters);
    eleventyConfig.addPlugin(pluginShortcodes);

    // DEEP DATA MERGE
    eleventyConfig.setDataDeepMerge(true)

    
    let options = {
        html: true,
        breaks: false,
        linkify: true,
    };
    eleventyConfig.setLibrary("md", markdownIt(options));
    eleventyConfig.amendLibrary("md", (mdLib) => mdLib.disable("code"))
    eleventyConfig.amendLibrary("md", (mdLib) => mdLib.use(markdownItAttr))
    eleventyConfig.addPassthroughCopy("static")
    eleventyConfig.addPassthroughCopy({"node_modules/@11ty/is-land/*.js": "static/js/"});
    eleventyConfig.addPassthroughCopy({"node_modules/@zachleat/heading-anchors/heading-anchors.js": "static/js/heading-anchors.js"});

    eleventyConfig.addPairedShortcode("tabber", tabber)
    eleventyConfig.addPairedShortcode("tab", tab)
    eleventyConfig.addShortcode("currentBuildDate", () => {
		return (new Date()).toISOString();
	});
    
    // Adds the {% css %} paired shortcode
    eleventyConfig.addBundle("css", {
        toFileDirectory: "_site/static/css/",
    });
    // Adds the {% js %} paired shortcode
    eleventyConfig.addBundle("js", {
        toFileDirectory: "_site/static/js/",
    });
    
    eleventyConfig.addFilter("cssmin", function (code) {return new CleanCSS({}).minify(code).styles;});
	eleventyConfig.on('eleventy.after', () => {execSync(`npx pagefind --site _site --glob \"**/*.html\"`, { encoding: 'utf-8' })})

    eleventyConfig.addGlobalData("ELEVENTY_RUN_MODE", process.env.ELEVENTY_RUN_MODE);
};

export const config = {
    dir: {
            input: 'src',
            includes: "_config/includes",
            data: "_config/data",
            output: '_site'
        },
    templateFormats: ['md', 'njk', 'html'],
    markdownTemplateEngine: "njk",
    htmlTemplateEngine: "njk",
    passthroughFileCopy: true,
};
