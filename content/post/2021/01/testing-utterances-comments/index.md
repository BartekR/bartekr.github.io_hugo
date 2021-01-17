---
title: "Testing Utterances Comments" # Title of the blog post.
date: "2021-01-17" # Date of post creation.
draft: false # Sets whether to render this page. Draft of true will not be rendered.
toc: false # Controls if a table of contents should be generated for first-level links automatically.
images:
  - src: "2021/01/17/testing-utterances-comments/images/utterances.png"
    alt: ""
    stretch: ""
tags: ['Hugo', 'Comments']
categories: ['Admin']
---

When I switched to Hugo, I knew my new blog would not have the comments enabled. I planned it "for later", as I didn't want to use Disqus (available by default in Hugo).

When I chose the [hugo-future-imperfect-slim](https://github.com/pacollins/hugo-future-imperfect-slim) theme, I saw I could integrate Staticman, which creates the comments as the Pull Request in GitHub. Brilliant idea, but it involves some additional setup (either authorising Staticman GitHub account or hosting an own API instance). That's why I skipped it when I migrated to Hugo. I decided to go back to the comments once I am more prepared for it.

## A month later

I started reading more about [Staticman integration](https://travisdowns.github.io/blog/2020/02/05/now-with-comments.html), [nested](https://yasoob.me/posts/running_staticman_on_static_hugo_blog_with_nested_comments/) [comments](https://dancwilliams.com/hugo-staticman-nested-replies-and-email-notifications/), [using an Azure App Service](https://hajekj.net/2020/04/15/staticman-setup-in-app-service/) or [converting to Azure Function](https://github.com/UliPlabst/staticman-azure-fn) (excellent idea) and so on. But - after some internal tests, I was not amazed. Even more - I didn't like it. Yes, it was doing what it was supposed to do, but I wanted a Wow effect. Something easy to set up, looking nice and something that makes me feel comfortable - "yes, this one fits perfectly". So I started looking [for](https://lisakov.com/projects/open-source-comments/) [the](https://fedidat.com/530-blog-comments/) [alternatives](https://cavelab.dev/wiki/Commenting_systems_for_websites) and this time I found something - use GitHub Issues system as the comments.

The pros - I want something out-of-the-box, what works, what would be easy to use by the technical people and give me no headaches.
The cons - tight GitHub integration, to comment, users must use a GitHub account.

I found two implementations:

- [utterances](https://utteranc.es/)
- [custom API calls](http://donw.io/post/github-comments/)

The first is something I decided to try. The second is something to have in mind for the future.

## The setup

The documentation is clear:

1. Install the app in the repository used for the comments (must be public)
2. Decide what the issue name will look like (I chose the full post URL)
3. Optionally set the (already existing) label for the issue (I use `blog-comment`)
4. Optionally select a theme

All those steps fill the template to paste in the comments page. In my case - I have overwritten the `comments.html` used in the theme.

![custom layout partial](images/LayoutCommentsPartial.png#center)

```html
<script src="https://utteranc.es/client.js"
        repo="[ENTER REPO HERE]"
        issue-term="pathname"
        theme="github-light"
        crossorigin="anonymous"
        async>
</script>
```

My setup:

```html
<script src="https://utteranc.es/client.js"
        repo="BartekR/bartekr.github.io"
        issue-term="url"
        label="blog-comment"
        theme="github-light"
        crossorigin="anonymous"
        async>
</script>
```

For now - it's to check whether it's useful, maintainable and so on. I still wonder if I should port the comments from the previous WordPress blog (I think I should) and how to do it. I'll wait to see how the situation develops.
