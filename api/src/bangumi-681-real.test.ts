// Test with REAL HTML from mikanani.me
import { describe, it, expect } from 'vitest';
import * as cheerio from 'cheerio';
import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

async function importParseSubgroupBangumi() {
  const mikanModule = await import('./mikan.js');
  const api = mikanModule.default;
  return (api as any)['parseSubgroupBangumi'].bind(api);
}

async function importParseBangumi() {
  const mikanModule = await import('./mikan.js');
  const api = mikanModule.default;
  return (api as any)['parseBangumi'].bind(api);
}

function loadRealFixture(): string {
  return readFileSync(join(__dirname, 'fixtures', 'bangumi-681-real.html'), 'utf-8');
}

describe('parseSubgroupBangumi with REAL HTML', () => {
  it('should parse 夜猫工作室 subgroup from real HTML', async () => {
    const html = loadRealFixture();
    const $ = cheerio.load(html);
    const parseSubgroupBangumi = await importParseSubgroupBangumi();

    const $sub = $('.subgroup-text#124');
    expect($sub.length).toBeGreaterThan(0, 'Should find subgroup #124');

    const result = parseSubgroupBangumi($sub);

    console.log('=== 夜猫工作室 解析结果 ===');
    console.log('dataId:', result.dataId);
    console.log('name:', result.name);
    console.log('subscribed:', result.subscribed);
    console.log('sublang:', result.sublang);
    console.log('rss:', result.rss);
    console.log('subgroups:', result.subgroups);
    console.log('subgroups length:', result.subgroups.length);

    // 验证基本字段
    expect(result.dataId).toBe('124');
    expect(result.name).toContain('夜莺');
    expect(result.subscribed).toBe(false); // style="display:none" means not subscribed

    // 关键修复：subgroups 应该包含字幕组信息
    expect(result.subgroups).toHaveLength(1);
    expect(result.subgroups[0].id).toBe('117');
    expect(result.subgroups[0].name).toBe('夜莺工作室');
  });

  it('should parse 梦蓝字幕组 subgroup from real HTML', async () => {
    const html = loadRealFixture();
    const $ = cheerio.load(html);
    const parseSubgroupBangumi = await importParseSubgroupBangumi();

    const $sub = $('.subgroup-text#162');
    expect($sub.length).toBeGreaterThan(0, 'Should find subgroup #162');

    const result = parseSubgroupBangumi($sub);

    console.log('=== 梦蓝字幕组 解析结果 ===');
    console.log('dataId:', result.dataId);
    console.log('name:', result.name);
    console.log('subgroups:', result.subgroups);
    console.log('subgroups length:', result.subgroups.length);

    expect(result.dataId).toBe('162');
    expect(result.name).toContain('梦蓝');
  });

  it('should parse full bangumi page and check all subgroupBangumis', async () => {
    const html = loadRealFixture();
    const $ = cheerio.load(html);
    const parseBangumi = await importParseBangumi();

    const result = parseBangumi($);

    console.log('=== 完整 Bangumi 解析结果 ===');
    console.log('ID:', result.id);
    console.log('Name:', result.name);
    console.log('SubgroupBangumis count:', Object.keys(result.subgroupBangumis).length);

    // 列出所有 subgroupBangumi
    Object.entries(result.subgroupBangumis).forEach(([key, sb]: [string, any]) => {
      console.log(`\n--- ${sb.name} (${key}) ---`);
      console.log('  subgroups:', sb.subgroups);
      console.log('  subgroups.length:', sb.subgroups.length);
      console.log('  records:', sb.records.length);
    });

    // 核心问题：验证 subgroups 是否为空
    const subgroupKeys = Object.keys(result.subgroupBangumis);
    expect(subgroupKeys.length).toBeGreaterThan(0);

    // 检查每个 subgroupBangumi 的 subgroups 字段
    subgroupKeys.forEach(key => {
      const sb = result.subgroupBangumis[key];
      console.log(`\n${sb.name}: subgroups.length = ${sb.subgroups.length}`);
    });
  });

  it('should show HTML structure for debugging', async () => {
    const html = loadRealFixture();
    const $ = cheerio.load(html);

    console.log('=== HTML 结构分析 ===');

    // 查看第一个 subgroup-text 的结构
    const $firstSubgroup = $('.subgroup-text').first();
    console.log('\n第一个 subgroup-text 的 HTML:');
    console.log($firstSubgroup.html() || 'empty');

    // 查找所有 ul 元素
    const $ulInSubgroup = $firstSubgroup.find('ul');
    console.log('\nul 元素数量:', $ulInSubgroup.length);
    console.log('ul > li > a 数量:', $firstSubgroup.find('ul > li > a').length);

    // 查找所有 a 元素
    const $allLinks = $firstSubgroup.find('a');
    console.log('\n所有 a 元素:');
    $allLinks.each((i, elem) => {
      const $a = $(elem);
      console.log(`  [${i}] href="${$a.attr('href')}" text="${$a.text().trim()}"`);
    });
  });
});
