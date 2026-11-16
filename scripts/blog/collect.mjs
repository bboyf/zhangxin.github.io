/**
 * 采集各平台 Agent 热点，打分后输出候选选题。
 * 用法：node scripts/blog/collect.mjs [--limit 8]
 * 产出：blog/.cache/candidates.json
 */
import { writeFileSync, mkdirSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..', '..');
const CACHE = join(ROOT, 'blog', '.cache');

const KEYWORDS = [
  ['agent', 3], ['multi-agent', 3], ['mcp', 3], ['tool call', 3], ['tool use', 2],
  ['rag', 2], ['retrieval', 1], ['eval', 2], ['benchmark', 2], ['memory', 2],
  ['context window', 2], ['prompt', 1], ['workflow', 1], ['orchestration', 2],
  ['reasoning', 2], ['harness', 2], ['coding agent', 3], ['sandbox', 2],
  ['推理', 1], ['智能体', 3], ['上下文', 2], ['评测', 2], ['工具调用', 3]
];

const RSS_FEEDS = [
  { name: '机器之心', url: 'https://www.jiqizhixin.com/rss' },
  { name: 'InfoQ 中文', url: 'https://www.infoq.cn/feed' },
  { name: 'LangChain Blog', url: 'https://blog.langchain.dev/rss/' },
  { name: 'OpenAI News', url: 'https://openai.com/news/rss.xml' },
  { name: 'Google AI Blog', url: 'https://blog.google/technology/ai/rss/' },
  { name: 'r/LocalLLaMA', url: 'https://www.reddit.com/r/LocalLLaMA/top/.rss?t=week' }
];

async function get(url, opts = {}) {
  const ac = new AbortController();
  const timer = setTimeout(() => ac.abort(), opts.timeout || 15000);
  try {
    const res = await fetch(url, {
      signal: ac.signal,
      headers: {
        'user-agent': 'bboyf-blog-agent/1.0 (+https://github.com/bboyf)',
        accept: opts.accept || '*/*',
        ...(opts.headers || {})
      }
    });
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    return await res.text();
  } finally {
    clearTimeout(timer);
  }
}

function strip(html) {
  return String(html || '')
    .replace(/<!\[CDATA\[|\]\]>/g, '')
    .replace(/<[^>]+>/g, ' ')
    .replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&amp;/g, '&')
    .replace(/&quot;/g, '"').replace(/&#39;/g, "'").replace(/&nbsp;/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

function pick(block, tags) {
  for (const tag of tags) {
    const re = new RegExp(`<${tag}[^>]*>([\\s\\S]*?)</${tag}>`, 'i');
    const m = re.exec(block);
    if (m) return strip(m[1]);
  }
  return '';
}

function parseFeed(xml) {
  const items = [];
  const blocks = xml.match(/<(item|entry)\b[\s\S]*?<\/(item|entry)>/gi) || [];
  for (const block of blocks) {
    const link =
      (/<link[^>]*href="([^"]+)"/i.exec(block) || [])[1] ||
      pick(block, ['link', 'guid', 'id']);
    items.push({
      title: pick(block, ['title']),
      summary: pick(block, ['description', 'summary', 'content']).slice(0, 400),
      url: link,
      date: pick(block, ['pubDate', 'published', 'updated', 'dc:date'])
    });
  }
  return items;
}

const candidates = [];
function add(source, item, baseScore = 0) {
  if (!item.title || item.title.length < 8) return;
  candidates.push({
    source,
    title: item.title.slice(0, 200),
    summary: (item.summary || '').slice(0, 400),
    url: item.url || '',
    date: item.date ? new Date(item.date).toISOString().slice(0, 10) : '',
    baseScore,
    extra: item.extra || {}
  });
}

async function collectHackerNews() {
  const since = Math.floor(Date.now() / 1000) - 7 * 86400;
  const url = `https://hn.algolia.com/api/v1/search?query=agent%20OR%20llm%20OR%20mcp&tags=story&numericFilters=points>80,created_at_i>${since}&hitsPerPage=25`;
  const data = JSON.parse(await get(url, { accept: 'application/json' }));
  for (const hit of data.hits || []) {
    add('Hacker News', {
      title: hit.title,
      summary: hit.story_text || '',
      url: hit.url || `https://news.ycombinator.com/item?id=${hit.objectID}`,
      date: hit.created_at,
      extra: { points: hit.points, comments: hit.num_comments }
    }, Math.min(10, Math.round((hit.points || 0) / 100)));
  }
}

async function collectArxiv() {
  const url =
    'http://export.arxiv.org/api/query?search_query=cat:cs.AI+AND+(all:agent+OR+all:LLM)&sortBy=submittedDate&sortOrder=descending&max_results=15';
  const items = parseFeed(await get(url, { accept: 'application/atom+xml' }));
  for (const item of items) add('arXiv', item, 1);
}

async function collectGitHub() {
  const since = new Date(Date.now() - 10 * 86400).toISOString().slice(0, 10);
  const url = `https://api.github.com/search/repositories?q=topic:ai-agents+pushed:>${since}&sort=stars&order=desc&per_page=15`;
  const headers = { accept: 'application/vnd.github+json' };
  if (process.env.GITHUB_TOKEN) headers.authorization = `Bearer ${process.env.GITHUB_TOKEN}`;
  const data = JSON.parse(await get(url, { headers }));
  for (const repo of data.items || []) {
    add('GitHub Trending', {
      title: `${repo.full_name}：${repo.description || 'Agent 相关开源项目'}`,
      summary: repo.description || '',
      url: repo.html_url,
      date: repo.pushed_at,
      extra: { stars: repo.stargazers_count }
    }, Math.min(8, Math.round((repo.stargazers_count || 0) / 1500)));
  }
}

async function collectFeeds() {
  for (const feed of RSS_FEEDS) {
    try {
      const items = parseFeed(await get(feed.url, { accept: 'application/rss+xml, application/xml' }));
      for (const item of items.slice(0, 15)) add(feed.name, item, 0);
      console.log(`  ${feed.name}: ${items.length} 条`);
    } catch (err) {
      console.warn(`  ${feed.name}: 跳过（${err.message}）`);
    }
  }
}

function score(item) {
  const text = `${item.title} ${item.summary}`.toLowerCase();
  let s = item.baseScore;
  for (const [word, weight] of KEYWORDS) if (text.includes(word)) s += weight;
  const ageDays = item.date ? (Date.now() - new Date(item.date).getTime()) / 86400000 : 30;
  if (ageDays <= 3) s += 3;
  else if (ageDays <= 7) s += 1;
  if (item.title.length > 140) s -= 1;
  return s;
}

const sources = { hn: collectHackerNews, arxiv: collectArxiv, github: collectGitHub, feeds: collectFeeds };
for (const [name, fn] of Object.entries(sources)) {
  try {
    await fn();
    console.log(`采集 ${name} 完成`);
  } catch (err) {
    console.warn(`采集 ${name} 失败（${err.message}），继续`);
  }
}

const seen = new Set();
const ranked = candidates
  .map((item) => ({ ...item, score: score(item) }))
  .filter((item) => {
    const key = item.title.toLowerCase().replace(/[^\p{L}\p{N}]/gu, '').slice(0, 60);
    if (seen.has(key)) return false;
    seen.add(key);
    return true;
  })
  .sort((a, b) => b.score - a.score);

const limit = Number(process.argv[process.argv.indexOf('--limit') + 1]) || 8;
const top = ranked.slice(0, limit);

mkdirSync(CACHE, { recursive: true });
writeFileSync(
  join(CACHE, 'candidates.json'),
  JSON.stringify({ generatedAt: new Date().toISOString(), total: ranked.length, candidates: top }, null, 2),
  'utf8'
);

console.log(`\n候选选题 Top ${top.length}（共 ${ranked.length} 条原始信号）：`);
for (const [i, item] of top.entries()) {
  console.log(`${i + 1}. [${item.score}] ${item.source} | ${item.title}`);
  console.log(`   ${item.url}`);
}
