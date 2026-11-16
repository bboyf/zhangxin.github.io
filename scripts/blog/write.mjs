/**
 * 用 LLM 把候选选题写成 2 篇初稿（Markdown）。
 * 需要环境变量：LLM_API_KEY（必填）、LLM_BASE_URL、LLM_MODEL
 * 用法：node scripts/blog/write.mjs [--count 2]
 * 产出：blog/posts/YYYY-MM-DD-<slug>.md
 */
import { readFileSync, writeFileSync, existsSync, readdirSync, mkdirSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { randomUUID } from 'node:crypto';
import { parseFrontmatter } from './lib.mjs';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..', '..');
const POSTS_DIR = join(ROOT, 'blog', 'posts');
const CACHE = join(ROOT, 'blog', '.cache');

const BASE_URL = (process.env.LLM_BASE_URL || 'https://opencode.ai/zen/go').replace(/\/$/, '');
const MODEL = process.env.LLM_MODEL || 'deepseek-v4.1-flash';
const API_KEY = process.env.LLM_API_KEY;
const SESSION = `sess_blog_${randomUUID().slice(0, 8)}`;

if (!API_KEY) {
  console.error('缺少 LLM_API_KEY 环境变量');
  process.exit(1);
}

const argCount = process.argv.indexOf('--count');
const COUNT = argCount > -1 ? Number(process.argv[argCount + 1]) || 2 : 2;

const TODAY = new Date().toISOString().slice(0, 10);

const AUTHOR_CONTEXT = `作者背景（写"对我的项目意味着什么"时必须落到这些具体项目上，不许编造细节）：
- 2026 世界杯 AI 预测引擎：基于 DeepSeek 的四层约束架构（资料库锁死 / 方法论固化 / 输出契约 / 动态更新），GitHub Actions 每日更新数据，强调可复现。
- HarmonyOS 智能记账 MoneyTrack：ArkTS + ArkUI，分层解耦四层架构，本地数据库，含 AI 智能记账。
- 人脸识别监控系统：Django + dlib ResNet + OpenCV，实时视频流，准确率 99.38%，摄像头权限自检。
- DjangoFilm 图书推荐：Spark 协同过滤 + Redis 缓存。
- 其他：Spring Boot 鲜花商城（协同过滤推荐 + 秒杀）、Django 投票/教务系统、HarmonyOS 与时间序列方向的研究生课题。`;

const SYSTEM_PROMPT = `你是一位中文技术博主，帮一位"Agent 应用开发 / 时间序列研究"方向的研究生写技术博客。读者是他求职时的面试官（技术负责人），因此文章必须像"人的判断"而不是"模型的总结"。

硬性规则：
1. 全文中文，技术术语和代码用英文。
2. 必须有一个明确、可被反驳的核心判断（frontmatter 的 view 字段 + 正文里论证它），不能是"各有优劣""要视情况而定"。
3. 必须有一节内容明确指出某类流行说法的问题（点名观点，不点名攻击个人），并给出你的反驳理由。
4. 必须包含至少一个可运行的代码块（Python 或 TypeScript/JavaScript），代码要真实可跑，不许伪代码、不许 \`...\` 省略关键逻辑。
5. 禁止 AI 味表达：「综上所述」「总而言之」「在当今快速发展的」「随着……的兴起」「赋能」「闭环」「值得注意的是」「毋庸置疑」「让我们深入探讨」。禁止排比式空洞排比句。
6. 不许编造数据、论文名、版本号、跑分。拿不准就写「我没有实测过，这只是我的推断」。引用来源时只能引用给定的候选链接。
7. 正文用 ## 二级标题，不要写一级标题，不要写 frontmatter。
8. 篇幅 1200–1800 字（中文字符），有具体细节和小例子，不要长句堆砌。
9. 结尾留一节「我的判断可能错在哪」，给出反方最强论点。`;

function buildPrompt(topic, others, avoid) {
  const related = others
    .map((c, i) => `${i + 1}. [${c.source}] ${c.title} — ${c.summary.slice(0, 160)}`)
    .join('\n');
  const banned = avoid.length ? avoid.map((t) => `- ${t}`).join('\n') : '（暂无）';
  return `请根据下面这条信号写一篇博客。只输出一个 JSON 对象，不要任何解释、不要代码围栏。

【本次选题】
来源：${topic.source}
标题：${topic.title}
摘要：${topic.summary || '（无）'}
链接：${topic.url || '（无）'}
时间：${topic.date || '未知'}

【同期相关信号（可作为背景参考，不要逐条罗列）】
${related || '（无）'}

【已写过的题目，不要重复这些角度】
${banned}

【输出 JSON 结构】
{
  "title": "中文标题，含蓄有观点，不超过 26 字，不要用书名号",
  "slug": "英文 kebab-case，3-5 个词",
  "tags": ["2 到 3 个标签，从 工具调用/多智能体/上下文/RAG/评测/工程化/推理成本/模型选择 里选"],
  "summary": "70 字以内摘要，说清本文的判断",
  "view": "40 字以内的一句话观点",
  "body": "Markdown 正文，## 开头的小节；必须包含代码块"
}

${AUTHOR_CONTEXT}`;
}

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function callLLM(prompt) {
  const res = await fetch(`${BASE_URL}/v1/messages`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      'x-api-key': API_KEY,
      'anthropic-version': '2023-06-01',
      'x-opencode-session': SESSION,
      'x-opencode-project': 'bboyf-blog',
      'user-agent': 'bboyf-blog-agent/1.0'
    },
    body: JSON.stringify({
      model: MODEL,
      max_tokens: 8000,
      system: SYSTEM_PROMPT,
      messages: [{ role: 'user', content: prompt }]
    })
  });

  const text = await res.text();
  if (!res.ok) throw new Error(`LLM ${res.status}: ${text.slice(0, 400)}`);

  const data = JSON.parse(text);
  return (data.content || [])
    .filter((block) => block.type === 'text')
    .map((block) => block.text)
    .join('')
    .trim();
}

function parseJson(text) {
  const cleaned = text.replace(/^```(?:json)?\s*/i, '').replace(/```\s*$/i, '').trim();
  const start = cleaned.indexOf('{');
  const end = cleaned.lastIndexOf('}');
  if (start === -1 || end === -1) throw new Error('返回内容里没有 JSON 对象');
  return JSON.parse(cleaned.slice(start, end + 1));
}

function slugify(value, fallback) {
  const slug = String(value || '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .slice(0, 60);
  return slug || fallback;
}

function validate(post) {
  const problems = [];
  if (!post.title || post.title.length < 6) problems.push('标题缺失或过短');
  if (!post.body || post.body.length < 900) problems.push(`正文过短(${(post.body || '').length})`);
  if (!/^##\s/m.test(post.body || '')) problems.push('正文缺少 ## 小节');
  if (!/```/.test(post.body || '')) problems.push('正文缺少代码块');
  if (!post.view) problems.push('缺少一句话观点');
  if (/(综上所述|总而言之|在当今快速发展|随着.{0,8}的兴起|赋能|毋庸置疑)/.test(post.body || '')) {
    problems.push('命中 AI 味禁用词');
  }
  return problems;
}

function existingTitles() {
  if (!existsSync(POSTS_DIR)) return [];
  return readdirSync(POSTS_DIR)
    .filter((f) => f.endsWith('.md'))
    .map((f) => parseFrontmatter(readFileSync(join(POSTS_DIR, f), 'utf8')).data)
    .map((d) => String(d.title || ''))
    .filter(Boolean);
}

const candidatesPath = join(CACHE, 'candidates.json');
if (!existsSync(candidatesPath)) {
  console.error('缺少 blog/.cache/candidates.json，请先运行 node scripts/blog/collect.mjs');
  process.exit(1);
}

const { candidates } = JSON.parse(readFileSync(candidatesPath, 'utf8'));
const skip = new Set((process.env.SKIP_TOPICS || '').split('|').filter(Boolean));
const pool = candidates.filter((c) => !skip.has(c.title)).slice(0, Math.max(COUNT, 3));
const written = existingTitles();
const created = [];

mkdirSync(POSTS_DIR, { recursive: true });

for (const topic of pool) {
  if (created.length >= COUNT) break;

  let post = null;
  for (let attempt = 1; attempt <= 2 && !post; attempt += 1) {
    try {
      const raw = await callLLM(buildPrompt(topic, pool.filter((c) => c !== topic), written));
      const parsed = parseJson(raw);
      const problems = validate(parsed);
      if (problems.length) throw new Error(`校验未通过: ${problems.join('；')}`);
      post = parsed;
    } catch (err) {
      console.warn(`选题「${topic.title}」第 ${attempt} 次生成失败：${err.message}`);
      if (attempt === 1) await sleep(3000);
    }
  }

  if (!post) {
    console.warn(`跳过选题：${topic.title}`);
    continue;
  }

  const slug = slugify(post.slug, slugify(topic.title, 'agent-note'));
  const file = join(POSTS_DIR, `${TODAY}-${slug}.md`);
  if (existsSync(file)) {
    console.warn(`文件已存在，跳过：${file}`);
    continue;
  }

  const tags = Array.isArray(post.tags) ? post.tags.join(', ') : String(post.tags || '工程化');
  const frontmatter = [
    '---',
    `title: ${post.title}`,
    `date: ${TODAY}`,
    `tags: ${tags}`,
    `summary: ${post.summary || ''}`,
    `view: ${post.view}`,
    `source: ${topic.url || ''}`,
    'draft: false',
    '---',
    ''
  ].join('\n');

  writeFileSync(file, `${frontmatter}${post.body.trim()}\n`, 'utf8');
  written.push(post.title);
  created.push(post.title);
  console.log(`已生成：blog/posts/${TODAY}-${slug}.md — ${post.title}`);
  await sleep(1500);
}

// 记录已写题目，供下次去重
const historyPath = join(CACHE, 'history.json');
const history = existsSync(historyPath) ? JSON.parse(readFileSync(historyPath, 'utf8')) : [];
writeFileSync(
  historyPath,
  JSON.stringify([...new Set([...history, ...written])].slice(-120), null, 2),
  'utf8'
);

console.log(`\n本次生成 ${created.length} 篇`);
if (!created.length) process.exitCode = 1;
