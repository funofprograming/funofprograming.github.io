import syntaxHighlight from "@11ty/eleventy-plugin-syntaxhighlight";
import markdownIt from "markdown-it";
import { tab } from "@mdit/plugin-tab";

export default function(eleventyConfig) {
  eleventyConfig.setInputDirectory("src");
  eleventyConfig.setIncludesDirectory("_includes");
  eleventyConfig.setDataDirectory("_data");
  eleventyConfig.setOutputDirectory("_site");
  eleventyConfig.setTemplateFormats("html,liquid,njk,mdx,md");
  eleventyConfig.addPlugin(syntaxHighlight);
  eleventyConfig.addPassthroughCopy("src/assets/prism-copy-without-shadows.css");

  let options = {
  		html: true,
  		breaks: true,
  		linkify: true,
  	};
  eleventyConfig.setLibrary("md", markdownIt(options));
  eleventyConfig.amendLibrary("md", (mdLib) => mdLib.use(tab, {name: "tabs"}));

};

