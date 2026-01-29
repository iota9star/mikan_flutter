import { describe, it, expect, beforeEach, vi } from 'vitest';
import * as cheerio from 'cheerio';
import MikanApi from './mikan';
import {
  indexHtml,
  seasonHtml,
  dayHtml,
  searchHtml,
  bangumiHtml,
  episodeHtml,
  listHtml,
  myBangumiHtml,
  expandEpisodeTableHtml
} from './fixtures/html-samples';

// Mock fetch globally
global.fetch = vi.fn();

describe('MikanApi - Real HTML Integration Tests', () => {
  beforeEach(() => {
    MikanApi.setBaseUrl('https://mikanani.me');
  });

  describe('parseIndex with real HTML', () => {
    it('should parse index page without errors', () => {
      const $ = cheerio.load(indexHtml);
      const result = () => (MikanApi as any)['parseIndex']($);

      expect(() => result()).not.toThrow();
    });

    it('should extract years from index page', () => {
      const $ = cheerio.load(indexHtml);
      const result = (MikanApi as any)['parseYearSeason']($);

      expect(Array.isArray(result)).toBe(true);
    });

    it('should extract bangumi rows from index page', () => {
      const $ = cheerio.load(indexHtml);
      const result = (MikanApi as any)['parseSeason']($);

      expect(Array.isArray(result)).toBe(true);
    });
  });

  describe('parseSeason with real HTML', () => {
    it('should parse season page without errors', () => {
      const $ = cheerio.load(seasonHtml);
      const result = () => (MikanApi as any)['parseSeason']($);

      expect(() => result()).not.toThrow();
    });

    it('should return array of bangumi rows', () => {
      const $ = cheerio.load(seasonHtml);
      const result = (MikanApi as any)['parseSeason']($);

      expect(Array.isArray(result)).toBe(true);
    });
  });

  describe('parseDay with real HTML', () => {
    it('should handle empty day page', () => {
      const $ = cheerio.load(dayHtml);
      const result = (MikanApi as any)['parseDay']($);

      expect(Array.isArray(result)).toBe(true);
    });
  });

  describe('parseSearch with real HTML', () => {
    it('should parse search page without errors', () => {
      const $ = cheerio.load(searchHtml);
      const result = () => (MikanApi as any)['parseSearch']($);

      expect(() => result()).not.toThrow();
    });

    it('should return search result structure', () => {
      const $ = cheerio.load(searchHtml);
      const result = (MikanApi as any)['parseSearch']($);

      expect(result).toHaveProperty('bangumis');
      expect(result).toHaveProperty('subgroups');
      expect(result).toHaveProperty('records');
    });
  });

  describe('parseBangumi with real HTML', () => {
    it('should parse bangumi detail page without errors', () => {
      const $ = cheerio.load(bangumiHtml);
      const result = () => (MikanApi as any)['parseBangumi']($);

      expect(() => result()).not.toThrow();
    });

    it('should return bangumi detail structure', () => {
      const $ = cheerio.load(bangumiHtml);
      const result = (MikanApi as any)['parseBangumi']($);

      expect(result).toHaveProperty('id');
      expect(result).toHaveProperty('name');
      expect(result).toHaveProperty('subgroupBangumis');
    });
  });

  describe('parseRecordDetail with real HTML', () => {
    it('should parse episode detail page without errors', () => {
      const $ = cheerio.load(episodeHtml);
      const result = () => (MikanApi as any)['parseRecordDetail']($);

      expect(() => result()).not.toThrow();
    });

    it('should return record detail structure', () => {
      const $ = cheerio.load(episodeHtml);
      const result = (MikanApi as any)['parseRecordDetail']($);

      expect(result).toHaveProperty('id');
      expect(result).toHaveProperty('name');
    });
  });

  describe('parseList with real HTML', () => {
    it('should parse list page without errors', () => {
      const $ = cheerio.load(listHtml);
      const result = () => (MikanApi as any)['parseList']($);

      expect(() => result()).not.toThrow();
    });

    it('should return array of records', () => {
      const $ = cheerio.load(listHtml);
      const result = (MikanApi as any)['parseList']($);

      expect(Array.isArray(result)).toBe(true);
    });
  });

  describe('parseMySubscribed with real HTML', () => {
    it('should parse subscription page without errors', () => {
      const $ = cheerio.load(myBangumiHtml);
      const result = () => (MikanApi as any)['parseMySubscribed']($);

      expect(() => result()).not.toThrow();
    });

    it('should return array of subscribed bangumi', () => {
      const $ = cheerio.load(myBangumiHtml);
      const result = (MikanApi as any)['parseMySubscribed']($);

      expect(Array.isArray(result)).toBe(true);
    });

    it('should parse subscribed bangumi with correct structure', () => {
      const $ = cheerio.load(myBangumiHtml);
      const result = (MikanApi as any)['parseMySubscribed']($);

      if (result.length > 0) {
        const first = result[0];
        expect(first).toHaveProperty('id');
        expect(first).toHaveProperty('name');
        expect(first).toHaveProperty('cover');
        expect(first).toHaveProperty('subscribed');
        expect(first).toHaveProperty('updateAt');
        expect(first.subscribed).toBe(true);
      }
    });
  });

  describe('parseBangumiMore with real HTML', () => {
    it('should parse ExpandEpisodeTable without errors', () => {
      const $ = cheerio.load(expandEpisodeTableHtml);
      const result = () => (MikanApi as any)['parseBangumiMore']($);

      expect(() => result()).not.toThrow();
    });

    it('should return array of record items', () => {
      const $ = cheerio.load(expandEpisodeTableHtml);
      const result = (MikanApi as any)['parseBangumiMore']($);

      expect(Array.isArray(result)).toBe(true);
      expect(result.length).toBeGreaterThan(0);
    });

    it('should parse record items with correct structure', () => {
      const $ = cheerio.load(expandEpisodeTableHtml);
      const result = (MikanApi as any)['parseBangumiMore']($);

      if (result.length > 0) {
        const first = result[0];
        expect(first).toHaveProperty('title');
        expect(first).toHaveProperty('tags');
        expect(first).toHaveProperty('magnet');
        expect(first).toHaveProperty('size');
        expect(first).toHaveProperty('publishAt');
        expect(first).toHaveProperty('torrent');
        expect(first).toHaveProperty('url');
      }
    });

    it('should parse tags from title correctly', () => {
      const $ = cheerio.load(expandEpisodeTableHtml);
      const result = (MikanApi as any)['parseBangumiMore']($);

      if (result.length > 0) {
        const first = result[0];
        expect(Array.isArray(first.tags)).toBe(true);
      }
    });

    it('should extract magnet links', () => {
      const $ = cheerio.load(expandEpisodeTableHtml);
      const result = (MikanApi as any)['parseBangumiMore']($);

      if (result.length > 0) {
        const first = result[0];
        expect(first.magnet).toBeTruthy();
        expect(first.magnet).toContain('magnet:');
      }
    });

    it('should extract all fields correctly from first record', () => {
      MikanApi.setBaseUrl('https://mikanani.me');
      const $ = cheerio.load(expandEpisodeTableHtml);
      const result = (MikanApi as any)['parseBangumiMore']($);

      if (result.length > 0) {
        const first = result[0];

        // 验证磁力链接（从 checkbox 的 data-magnet 属性）
        expect(first.magnet).toBe('magnet:?xt=urn:btih:test123456');

        // 验证标题（parseTagsAndTitle 不移除标签，仅替换书名号）
        expect(first.title).toBe('[清蓝字幕组]新哆啦A梦 2016生日特别篇 - 天才大雄的飞船游乐园 New Doraemon Birthday Special 2016 [455][GB][720P][MP4]');

        // 验证标签（GB → 简，按 localeCompare 降序排序 - 中文字符在 ASCII 之前）
        expect(first.tags).toEqual(['简', '特别篇', 'SP', 'MP4', '720P']);

        // 验证 URL
        expect(first.url).toBe('https://mikanani.me/Home/Episode/test123456');

        // 验证大小
        expect(first.size).toBe('763.7MB');

        // 验证发布时间
        expect(first.publishAt).toBe('9月3日周六 01:07');

        // 验证种子链接
        expect(first.torrent).toBe('https://mikanani.me/Download/20160903/test123456.torrent');
      }
    });

    it('should extract all fields correctly from second record', () => {
      MikanApi.setBaseUrl('https://mikanani.me');
      const $ = cheerio.load(expandEpisodeTableHtml);
      const result = (MikanApi as any)['parseBangumiMore']($);

      if (result.length > 1) {
        const second = result[1];

        // 验证磁力链接
        expect(second.magnet).toBe('magnet:?xt=urn:btih:test123457');

        // 验证标题
        expect(second.title).toBe('[清蓝字幕组]新哆啦A梦 - New Doraemon [445] 房间里的大自然&加入朋友线香 [GB][720P][解说音轨付]');

        // 验证标签（GB → 简，按降序排序）
        expect(second.tags).toEqual(['简', '720P']);

        // 验证 URL
        expect(second.url).toBe('https://mikanani.me/Home/Episode/test123457');

        // 验证大小
        expect(second.size).toBe('300.7MB');

        // 验证发布时间
        expect(second.publishAt).toBe('6月10日周五 21:11');

        // 验证种子链接
        expect(second.torrent).toBe('https://mikanani.me/Download/20160610/test123457.torrent');
      }
    });

    it('should extract all fields correctly from third record', () => {
      MikanApi.setBaseUrl('https://mikanani.me');
      const $ = cheerio.load(expandEpisodeTableHtml);
      const result = (MikanApi as any)['parseBangumiMore']($);

      if (result.length > 2) {
        const third = result[2];

        // 验证磁力链接
        expect(third.magnet).toBe('magnet:?xt=urn:btih:test123458');

        // 验证标题
        expect(third.title).toBe('[清蓝字幕组]新哆啦A梦 - New Doraemon [437][GB][720P]');

        // 验证标签（GB → 简，按降序排序）
        expect(third.tags).toEqual(['简', '720P']);

        // 验证 URL
        expect(third.url).toBe('https://mikanani.me/Home/Episode/test123458');

        // 验证大小
        expect(third.size).toBe('222.3MB');

        // 验证发布时间
        expect(third.publishAt).toBe('4月16日周六 13:47');

        // 验证种子链接
        expect(third.torrent).toBe('https://mikanani.me/Download/20160416/test123458.torrent');
      }
    });
  });

  describe('bangumiMore URL construction and pagination', () => {
    it('should construct correct URL with take parameter', async () => {
      MikanApi.setBaseUrl('https://mikanani.me');

      // Mock fetchHtml to capture the URL
      let capturedUrl = '';
      const originalFetchHtml = (MikanApi as any).fetchHtml;
      (MikanApi as any).fetchHtml = async (url: string) => {
        capturedUrl = url;
        return '<table><tbody><tr><td><a href="#">test</a><a data-clipboard-text="magnet:?xt=test">m</a></td><td>100MB</td><td>2024/01/01</td><td><a href="#">torrent</a></td></tr></tbody></table>';
      };

      await MikanApi.bangumiMore('681', '15', 35);

      // Restore original
      (MikanApi as any).fetchHtml = originalFetchHtml;

      expect(capturedUrl).toBe('https://mikanani.me/Home/ExpandEpisodeTable?bangumiId=681&subtitleGroupId=15&take=35');
    });

    it('should construct correct URL with default take value', async () => {
      MikanApi.setBaseUrl('https://mikanani.me');

      let capturedUrl = '';
      const originalFetchHtml = (MikanApi as any).fetchHtml;
      (MikanApi as any).fetchHtml = async (url: string) => {
        capturedUrl = url;
        return '<table><tbody><tr><td><a href="#">test</a><a data-clipboard-text="magnet:?xt=test">m</a></td><td>100MB</td><td>2024/01/01</td><td><a href="#">torrent</a></td></tr></tbody></table>';
      };

      await MikanApi.bangumiMore('681', '15');

      (MikanApi as any).fetchHtml = originalFetchHtml;

      expect(capturedUrl).toBe('https://mikanani.me/Home/ExpandEpisodeTable?bangumiId=681&subtitleGroupId=15&take=65');
    });

    it('should construct URL with empty subtitleGroupId when provided as empty string', async () => {
      MikanApi.setBaseUrl('https://mikanani.me');

      let capturedUrl = '';
      const originalFetchHtml = (MikanApi as any).fetchHtml;
      (MikanApi as any).fetchHtml = async (url: string) => {
        capturedUrl = url;
        return '<table><tbody><tr><td><a href="#">test</a><a data-clipboard-text="magnet:?xt=test">m</a></td><td>100MB</td><td>2024/01/01</td><td><a href="#">torrent</a></td></tr></tbody></table>';
      };

      await MikanApi.bangumiMore('681', '', 50);

      (MikanApi as any).fetchHtml = originalFetchHtml;

      // 空字符串非 null，故仍会添入 URL
      expect(capturedUrl).toBe('https://mikanani.me/Home/ExpandEpisodeTable?bangumiId=681&subtitleGroupId=&take=50');
    });

    it('should handle pagination with increasing take values', async () => {
      MikanApi.setBaseUrl('https://mikanani.me');

      const urls: string[] = [];
      const originalFetchHtml = (MikanApi as any).fetchHtml;
      (MikanApi as any).fetchHtml = async (url: string) => {
        urls.push(url);
        return expandEpisodeTableHtml;
      };

      // 模拟分页加载场景：初始加载 35 条
      await MikanApi.bangumiMore('681', '15', 35);
      // 继续加载更多：增加 20 条，共 55 条
      await MikanApi.bangumiMore('681', '15', 55);
      // 再加载更多：共 75 条
      await MikanApi.bangumiMore('681', '15', 75);

      (MikanApi as any).fetchHtml = originalFetchHtml;

      expect(urls[0]).toContain('take=35');
      expect(urls[1]).toContain('take=55');
      expect(urls[2]).toContain('take=75');
    });

    it('should convert bangumiId and subtitleGroupId to strings', async () => {
      MikanApi.setBaseUrl('https://mikanani.me');

      let capturedUrl = '';
      const originalFetchHtml = (MikanApi as any).fetchHtml;
      (MikanApi as any).fetchHtml = async (url: string) => {
        capturedUrl = url;
        return '<table><tbody><tr><td><a href="#">test</a><a data-clipboard-text="magnet:?xt=test">m</a></td><td>100MB</td><td>2024/01/01</td><td><a href="#">torrent</a></td></tr></tbody></table>';
      };

      // 传入数字类型，应正确转换为字符串
      await MikanApi.bangumiMore(681 as any, 15 as any, 35);

      (MikanApi as any).fetchHtml = originalFetchHtml;

      expect(capturedUrl).toBe('https://mikanani.me/Home/ExpandEpisodeTable?bangumiId=681&subtitleGroupId=15&take=35');
    });
  });
});
