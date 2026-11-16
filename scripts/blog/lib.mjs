/**
 * 博客构建共用的零依赖工具：
 * - frontmatter 解析
 * - Markdown -> HTML（覆盖本站模板用到的语法子集）
 * - 统一页面骨架
 */

export const SITE = {
  name: '小鑫',
  base: 'https://bboyf.github.io/zhangxin.github.io',
  repo: 'https://github.com/bboyf/zhangxin.github.io',
  author: '小鑫'
};

export function escapeHtml(input) {
  return String(input)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function inline(text) {
  return escapeHtml(text)
    .replace(/`([^`]+)`/g, (m, code) => `<code>${code}</code>`)
    .replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>')
    .replace(/(^|[\s(])\*([^*\n]+)\*(?=[\s.,)，。:：!！?？]|$)/g, '$1<em>$2</em>')
    .replace(/\[([^\]]+)\]\(([^)\s]+)\)/g, '<a href="$2" target="_blank" rel="noopener noreferrer">$1</a>');
}

function isBlockStart(line) {
  return /^(#{1,6}\s|```|>\s?|\s*[-*+]\s|\s*\d+\.\s|---+\s*$)/.test(line);
}

function splitRow(line) {
  return line.replace(/^\s*\|/, '').replace(/\|\s*$/, '').split('|').map((c) => c.trim());
}

/** 极简 Markdown 渲染：标题/段落/代码块/列表/引用/表格/分割线/行内格式 */
export function mdToHtml(markdown) {
  const lines = String(markdown).replace(/\r\n/g, '\n').split('\n');
  const out = [];
  let i = 0;

  while (i < lines.length) {
    const line = lines[i];

    if (/^\s*$/.test(line)) { i += 1; continue; }

    // 代码块
    if (/^```/.test(line)) {
      const lang = line.slice(3).trim();
      i += 1;
      const buf = [];
      while (i < lines.length && !/^```/.test(lines[i])) buf.push(lines[i++]);
      i += 1;
      out.push(
        `<pre class="code-block" data-lang="${escapeHtml(lang || 'text')}"><code>${escapeHtml(buf.join('\n'))}</code></pre>`
      );
      continue;
    }

    // 标题
    const heading = /^(#{1,6})\s+(.*)$/.exec(line);
    if (heading) {
      const level = heading[1].length;
      out.push(`<h${level}>${inline(heading[2].trim())}</h${level}>`);
      i += 1;
      continue;
    }

    // 分割线
    if (/^\s*---+\s*$/.test(line)) { out.push('<hr>'); i += 1; continue; }

    // 表格
    if (line.includes('|') && i + 1 < lines.length && /^\s*\|?[\s:|-]+\|[\s:|-]*$/.test(lines[i + 1])) {
      const header = splitRow(line);
      i += 2;
      const rows = [];
      while (i < lines.length && lines[i].includes('|')) rows.push(splitRow(lines[i++]));
      out.push(
        '<div class="table-wrap"><table><thead><tr>' +
          header.map((c) => `<th>${inline(c)}</th>`).join('') +
          '</tr></thead><tbody>' +
          rows.map((r) => `<tr>${r.map((c) => `<td>${inline(c)}</td>`).join('')}</tr>`).join('') +
          '</tbody></table></div>'
      );
      continue;
    }

    // 引用
    if (/^>\s?/.test(line)) {
      const buf = [];
      while (i < lines.length && /^>\s?/.test(lines[i])) buf.push(lines[i++].replace(/^>\s?/, ''));
      out.push(`<blockquote><p>${inline(buf.join(' '))}</p></blockquote>`);
      continue;
    }

    // 有序 / 无序列表
    if (/^\s*\d+\.\s+/.test(line) || /^\s*[-*+]\s+/.test(line)) {
      const ordered = /^\s*\d+\.\s+/.test(line);
      const re = ordered ? /^\s*\d+\.\s+/ : /^\s*[-*+]\s+/;
      const items = [];
      while (i < lines.length && re.test(lines[i])) items.push(lines[i++].replace(re, ''));
      const tag = ordered ? 'ol' : 'ul';
      out.push(`<${tag}>${items.map((t) => `<li>${inline(t)}</li>`).join('')}</${tag}>`);
      continue;
    }

    // 段落
    const buf = [];
    while (i < lines.length && !/^\s*$/.test(lines[i]) && !isBlockStart(lines[i])) buf.push(lines[i++]);
    if (buf.length) out.push(`<p>${inline(buf.join(' '))}</p>`);
    else { out.push(`<p>${inline(lines[i])}</p>`); i += 1; }
  }

  return out.join('\n');
}

function parseScalar(raw) {
  const value = raw.trim();
  if (!value) return '';
  if (/^["'].*["']$/.test(value)) return value.slice(1, -1);
  if (value.startsWith('[') && value.endsWith(']')) {
    return value.slice(1, -1).split(',').map((v) => v.trim().replace(/^["']|["']$/g, '')).filter(Boolean);
  }
  if (value === 'true') return true;
  if (value === 'false') return false;
  return value;
}

/** 解析 `---` 包裹的 frontmatter */
export function parseFrontmatter(raw) {
  const text = String(raw).replace(/\r\n/g, '\n');
  if (!text.startsWith('---')) return { data: {}, body: text.trim() };
  const end = text.indexOf('\n---', 3);
  if (end === -1) return { data: {}, body: text.trim() };

  const data = {};
  for (const line of text.slice(3, end).split('\n')) {
    const match = /^([A-Za-z0-9_-]+)\s*:\s*(.*)$/.exec(line.trim());
    if (match) data[match[1]] = parseScalar(match[2]);
  }
  return { data, body: text.slice(end + 4).replace(/^\n+/, '').trim() };
}

export function normalizeTags(value) {
  if (Array.isArray(value)) return value.map((t) => String(t).trim()).filter(Boolean);
  if (!value) return [];
  return String(value).split(/[,，、|]/).map((t) => t.trim()).filter(Boolean);
}

export function formatDate(value) {
  const text = String(value || '').slice(0, 10);
  return text || new Date().toISOString().slice(0, 10);
}

export function readingTime(html) {
  const chars = String(html).replace(/<[^>]+>/g, '').replace(/\s+/g, '').length;
  return Math.max(1, Math.round(chars / 400));
}

/** 文章页 HTML 骨架 */
export function articlePage(post, bodyHtml) {
  const url = `${SITE.base}/blog/${post.slug}.html`;
  const tags = post.tags.map((t) => `<span class="tag">${escapeHtml(t)}</span>`).join('');
  return `<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>${escapeHtml(post.title)} | ${SITE.name}的技术博客</title>
<meta name="description" content="${escapeHtml(post.summary)}">
<meta name="author" content="${SITE.author}">
<meta name="theme-color" content="#121212">
<link rel="canonical" href="${url}">
<meta property="og:type" content="article">
<meta property="og:title" content="${escapeHtml(post.title)}">
<meta property="og:description" content="${escapeHtml(post.summary)}">
<meta property="og:url" content="${url}">
<meta property="og:image" content="${SITE.base}/assets/og-card.png">
<meta property="article:published_time" content="${post.date}">
<link rel="icon" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'%3E%3Crect width='100' height='100' rx='22' fill='%23121212'/%3E%3Ctext x='50' y='52' font-family='Microsoft YaHei,PingFang SC,sans-serif' font-size='58' font-weight='700' fill='%23ffffff' text-anchor='middle' dominant-baseline='central'%3E%E9%91%AB%3C/text%3E%3C/svg%3E">
<link rel="stylesheet" href="../vendor/fonts.css">
<link rel="stylesheet" href="blog.css">
</head>
<body>
<div class="noise" aria-hidden="true"></div>
<header class="topbar">
  <a class="brand" href="../index.html">${SITE.name}</a>
  <nav class="topnav">
    <a href="../index.html#blog">全部文章</a>
    <a href="../index.html">主页</a>
  </nav>
</header>
<main class="article">
  <p class="crumbs"><a href="../index.html#blog">技术博客</a> / <span>${post.date}</span></p>
  <h1>${escapeHtml(post.title)}</h1>
  <div class="meta">
    <span>${post.date}</span><span>约 ${post.readingTime} 分钟</span>${tags}
  </div>
  ${post.view ? `<p class="view-line"><strong>一句话观点：</strong>${escapeHtml(post.view)}</p>` : ''}
  <article class="content">
${bodyHtml}
  </article>
  <footer class="article-footer">
    <p>本文为个人技术观察，欢迎在 <a href="${post.issueUrl || SITE.repo}" target="_blank" rel="noopener noreferrer">GitHub</a> 上讨论或指正。</p>
    <a class="back" href="../index.html#blog">← 返回文章列表</a>
  </footer>
</main>
</body>
</html>
`;
}

/** 文章列表页 HTML */
export function listPage(posts) {
  const cards = posts
    .map(
      (p) => `      <li class="post-card">
        <a href="${p.slug}.html">
          <div class="post-head"><span class="post-date">${p.date}</span><span class="post-tags">${p.tags
        .map((t) => `<span class="tag">${escapeHtml(t)}</span>`)
        .join('')}</span></div>
          <h2>${escapeHtml(p.title)}</h2>
          <p>${escapeHtml(p.summary)}</p>
        </a>
      </li>`
    )
    .join('\n');

  return `<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>技术博客 | ${SITE.name}</title>
<meta name="description" content="${SITE.name}的 Agent 技术博客：每周记录 Agent 架构、工具调用、RAG 与评测方面的观察和判断。">
<meta name="theme-color" content="#121212">
<link rel="canonical" href="${SITE.base}/blog/">
<link rel="icon" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'%3E%3Crect width='100' height='100' rx='22' fill='%23121212'/%3E%3Ctext x='50' y='52' font-family='Microsoft YaHei,PingFang SC,sans-serif' font-size='58' font-weight='700' fill='%23ffffff' text-anchor='middle' dominant-baseline='central'%3E%E9%91%AB%3C/text%3E%3C/svg%3E">
<link rel="stylesheet" href="../vendor/fonts.css">
<link rel="stylesheet" href="blog.css">
</head>
<body>
<div class="noise" aria-hidden="true"></div>
<header class="topbar">
  <a class="brand" href="../index.html">${SITE.name}</a>
  <nav class="topnav"><a href="../index.html">主页</a></nav>
</header>
<main class="article">
  <h1>技术博客</h1>
  <p class="lede">Agent 架构、工具调用、RAG 与评测的持续记录。每篇都尽量给出一个明确判断，而不是转述新闻。</p>
  <ul class="post-list">
${cards}
  </ul>
</main>
</body>
</html>
`;
}
