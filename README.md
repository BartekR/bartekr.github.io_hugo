# blog.bartekr.net - backend

To write my blog I use markdown, hugo and GitHub Pages. This is the source repository for the blog content. Initially I used the [hugo-future-imperfect-slim](https://themes.gohugo.io/hugo-future-imperfect-slim/) theme, and switched to [Stack](https://github.com/CaiJimmy/hugo-theme-stack) in 2024.

* build (in `bartekr.github.io_hugo`): `hugo -d ..\bartekr.github.io\`
* build with future posts (in `bartekr.github.io_hugo`): `hugo -d ..\bartekr.github.io\ --buildFuture`
* create a new post (in `bartekr.github.io_hugo`): `hugo new --kind post-bundle post/2021/01/post-name`
* for work-in-progress (in `bartekr.github.io_hugo`): `hugo server -D`
