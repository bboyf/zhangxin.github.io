/**
 * 把 blog/posts/*.md 渲染成：
 *   blog/<slug>.html      单篇文章
 *   blog/index.html       文章列表
 *   blog/index.json       首页卡片用的数据
 *   sitemap.xml           在 <!-- blog:start/end --> 之间写入文章 URL
 *
 * 用法：node scripts/blog/build.mjs
 */
import { readFileSync, writeFileSync, readdirSync, existsSync, unlinkSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import {
  SITE,
  articlePage,
  listPage,
  mdToHtml,
  normalizeTags,
  parseFrontmatter,
  readingTime
} from './lib.mjs';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..', '..');
const POSTS_DIR = join(ROOT, 'blog', 'posts');
const OUT_DIR = join(ROOT, 'blog');

function loadPosts() {
  if (!existsSync(POSTS_DIR)) return [];
  const posts = [];
  for (const file of readdirSync(POSTS_DIR)) {
    if (!file.endsWith('.md')) continue;
    const raw = readFileSync(join(POSTS_DIR, file), 'utf8');
    const { data, body } = parseFrontmatter(raw);
    if (data.draft === true) continue;

    const slug = file.replace(/\.md$/, '');
    const html = mdToHtml(body);
    posts.push({
      slug,
      title: String(data.title || slug).trim(),
      date: String(data.date || '').slice(0, 10) || new Date().toISOString().slice(0, 10),
      tags: normalizeTags(data.tags),
      summary: String(data.summary || body.replace(/[#>*`\[\]]/g, '').replace(/\s+/g, ' ').trim().slice(0, 110)),
      view: data.view ? String(data.view) : '',
      readingTime: readingTime(html),
      html,
      source: data.source ? String(data.source) : ''
    });
  }
  return posts.sort((a, b) => (a.date < b.date ? 1 : a.date > b.date ? -1 : a.slug < b.slug ? 1 : -1));
}

function writeSitemap(posts) {
  const path = join(ROOT, 'sitemap.xml');
  const startTag = '<!-- blog:start -->';
  const endTag = '<!-- blog:end -->';
  const entries = [
    `    <url><loc>${SITE.base}/blog/</loc><changefreq>weekly</changefreq><priority>0.8</priority></url>`,
    ...posts.map(
      (p) =>
        `    <url><loc>${SITE.base}/blog/${p.slug}.html</loc><lastmod>${p.date}</lastmod><changefreq>monthly</changefreq><priority>0.6</priority></url>`
    )
  ].join('\n');
  const block = `${startTag}\n${entries}\n${endTag}`;

  let xml = existsSync(path)
    ? readFileSync(path, 'utf8')
    : '<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n</urlset>\n';

  const pattern = new RegExp(`${startTag}[\\s\\S]*?${endTag}`);
  if (pattern.test(xml)) {
    xml = xml.replace(pattern, block);
  } else {
    xml = xml.replace(/<\/urlset>/, `${block}\n</urlset>`);
  }
  writeFileSync(path, xml, 'utf8');
}

function cleanStale(posts) {
  const keep = new Set(['index.html', 'blog.css', ...posts.map((p) => `${p.slug}.html`)]);
  for (const file of readdirSync(OUT_DIR)) {
    if (file.endsWith('.html') && !keep.has(file)) {
      unlinkSync(join(OUT_DIR, file));
      console.log(`删除过期页面: blog/${file}`);
    }
  }
}

const posts = loadPosts();

for (const post of posts) {
  writeFileSync(join(OUT_DIR, `${post.slug}.html`), articlePage(post, post.html), 'utf8');
}
writeFileSync(join(OUT_DIR, 'index.html'), listPage(posts), 'utf8');
writeFileSync(
  join(OUT_DIR, 'index.json'),
  JSON.stringify(
    {
      updated: posts[0] ? posts[0].date : '',
      count: posts.length,
      posts: posts.slice(0, 12).map((p) => ({
        title: p.title,
        slug: p.slug,
        date: p.date,
        tags: p.tags,
        summary: p.summary,
        view: p.view,
        readingTime: p.readingTime,
        url: `blog/${p.slug}.html`
      }))
    },
    null,
    2
  ) + '\n',
  'utf8'
);
cleanStale(posts);
writeSitemap(posts);

console.log(`构建完成：${posts.length} 篇 -> blog/`);
