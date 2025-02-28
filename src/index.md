---
title: "Fun of Programing"
layout: "base.njk"
---

{%- for post in collections.posts -%}
  - [{{ post.data.title }}]({{ post.url }})
{%- endfor -%}