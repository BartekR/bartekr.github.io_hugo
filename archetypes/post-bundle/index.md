---
title: "{{ replace .Name "-" " " | title }}" # Title of the blog post.
date: {{dateFormat "2020-12-01" .Date}} # Date of post creation.
draft: true # Sets whether to render this page. Draft of true will not be rendered.
toc: false # Controls if a table of contents should be generated for first-level links automatically.
images:
  - src: "2020/11/01/migrating-to-github-pages/images/GitHubPages.png"
    alt: ""
    stretch: ""
tags: ['tag1', 'tag2', 'tag3']
categories: ['category1']
---

## Header lvl 2

...content...
