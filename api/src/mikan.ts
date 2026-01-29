import * as cheerio from 'cheerio';
import {
  Bangumi,
  BangumiDetail,
  BangumiRow,
  Carousel,
  Index,
  RecordDetail,
  RecordItem,
  SeasonGallery,
  Subgroup,
  SubgroupBangumi,
  User,
  YearSeason,
  SearchResult,
  Announcement,
  AnnouncementNode,
} from './types.js';
import {
  trim,
  formatPublishAt,
  parseTagsAndTitle,
  getWeekSectionName,
} from './utils.js';

class MikanApi {
  private static readonly MIRROR_URL_KEY = 'MIRROR_URL';
  private static readonly BASE_URLS = ['https://mikanime.tv', 'https://mikanani.me'];

  private baseUrl: string = MikanApi.BASE_URLS[MikanApi.BASE_URLS.length - 1];

  // ==================== Configuration ====================

  getBaseUrl(): string {
    return this.baseUrl;
  }

  setBaseUrl(url: string): void {
    this.baseUrl = url;
  }

  getAvailableBaseUrls(): string[] {
    return [...MikanApi.BASE_URLS];
  }

  // ==================== API Methods ====================

  async index(year?: string, seasonStr?: string): Promise<Index> {
    let url = this.baseUrl;
    if (year && seasonStr) {
      url = `${this.baseUrl}/Home/BangumiCoverFlow?year=${year}&seasonStr=${encodeURIComponent(seasonStr)}`;
    }
    const html = await this.fetchHtml(url);
    const $ = cheerio.load(html);
    return this.parseIndex($);
  }

  async season(year: string, seasonStr: string): Promise<BangumiRow[]> {
    const url = `${this.baseUrl}/Home/BangumiCoverFlowByDayOfWeek?year=${year}&seasonStr=${encodeURIComponent(seasonStr)}`;
    const html = await this.fetchHtml(url);
    const $ = cheerio.load(html);
    return this.parseSeason($);
  }

  async day(predate = 0, enddate = 1): Promise<RecordItem[]> {
    const url = `${this.baseUrl}/Home/EpisodeUpdateRows?predate=${predate}&enddate=${enddate}`;
    const html = await this.fetchHtml(url);
    const $ = cheerio.load(html);
    return this.parseDay($);
  }

  async ova(): Promise<RecordItem[]> {
    return this.day(-1, -1);
  }

  async search(searchstr: string, subgroupid = '', page = 1): Promise<SearchResult> {
    const params = new URLSearchParams({ searchstr, page: page.toString() });
    if (subgroupid) params.append('subgroupid', subgroupid);
    const url = `${this.baseUrl}/Home/Search?${params.toString()}`;
    const html = await this.fetchHtml(url);
    const $ = cheerio.load(html);
    return this.parseSearch($);
  }

  async list(page = 1): Promise<RecordItem[]> {
    const url = `${this.baseUrl}/Home/Classic/${page}`;
    const html = await this.fetchHtml(url);
    const $ = cheerio.load(html);
    return this.parseList($);
  }

  async subgroup(subgroupId: string): Promise<SeasonGallery[]> {
    const url = `${this.baseUrl}/Home/PublishGroup/${subgroupId}`;
    const html = await this.fetchHtml(url);
    const $ = cheerio.load(html);
    return this.parseSubgroup($);
  }

  async bangumi(bangumiId: string): Promise<BangumiDetail> {
    const url = `${this.baseUrl}/Home/Bangumi/${bangumiId}`;
    const html = await this.fetchHtml(url);
    const $ = cheerio.load(html);
    return this.parseBangumi($);
  }

  async bangumiMore(bangumiId: string, subtitleGroupId: string, take = 65): Promise<RecordItem[]> {
    const params = new URLSearchParams();
    params.append('bangumiId', bangumiId.toString());
    if (subtitleGroupId != null) {
      params.append('subtitleGroupId', subtitleGroupId.toString());
    }
    params.append('take', take.toString());
    const url = `${this.baseUrl}/Home/ExpandEpisodeTable?${params.toString()}`;
    const html = await this.fetchHtml(url);
    const $ = cheerio.load(html);
    return this.parseBangumiMore($);
  }

  async details(episodeId: string): Promise<RecordDetail> {
    const url = `${this.baseUrl}/Home/Episode/${episodeId}`;
    const html = await this.fetchHtml(url);
    const $ = cheerio.load(html);
    return this.parseRecordDetail($);
  }

  async getMySubscribed(): Promise<Bangumi[]> {
    const url = `${this.baseUrl}/Home/MyBangumi`;
    const html = await this.fetchHtml(url);
    const $ = cheerio.load(html);
    return this.parseMySubscribed($);
  }

  async mySubscribedSeasonBangumi(year: string, seasonStr: string): Promise<Bangumi[]> {
    const params = new URLSearchParams({ year, seasonStr });
    const url = `${this.baseUrl}/Home/BangumiCoverFlow?${params.toString()}`;
    const html = await this.fetchHtml(url);
    const $ = cheerio.load(html);
    return this.parseMySubscribed($);
  }

  async getUser(): Promise<User | null> {
    const url = this.baseUrl;
    const html = await this.fetchHtml(url);
    const $ = cheerio.load(html);
    return this.parseUser($);
  }

  async clearCookies(): Promise<void> {
    const domain = await this.getDomainFromUrl(this.baseUrl);
    await this.bridgeCall('clearCookies', { domain });
  }

  async login(email: string, password: string, returnUrl = ''): Promise<string> {
    const loginUrl = `${this.baseUrl}/Account/Login`;
    const html = await this.fetchHtml(loginUrl);
    const $ = cheerio.load(html);
    const token = this.parseRefreshLoginToken($);

    const params = new URLSearchParams({
      UserName: email,
      Password: password,
      RememberMe: 'true',
      __RequestVerificationToken: token || ''
    });
    if (returnUrl) params.append('ReturnUrl', returnUrl);

    const cookies = await this.loadCookiesForUrl(this.baseUrl);
    const headers: Record<string, string> = {
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    if (cookies) {
      headers['Cookie'] = cookies;
    }

    const response = await fetch(`${this.baseUrl}/Account/Login`, {
      method: 'POST',
      headers,
      body: params.toString(),
      redirect: 'manual'
    });

    await this.saveCookiesFromResponse(response, this.baseUrl);

    if (response.status === 302 || response.status === 301) {
      const location = response.headers.get('location');
      if (location) {
        const redirectUrl = location.startsWith('http') ? location : `${this.baseUrl}${location}`;
        await this.fetchHtml(redirectUrl);
      }
    }

    return await response.text();
  }

  async register(email: string, password: string, confirmPassword: string): Promise<string> {
    const registerUrl = `${this.baseUrl}/Account/Register`;
    const html = await this.fetchHtml(registerUrl);
    const $ = cheerio.load(html);
    const token = this.parseRefreshRegisterToken($);

    const params = new URLSearchParams({
      Email: email,
      Password: password,
      ConfirmPassword: confirmPassword,
      __RequestVerificationToken: token || ''
    });

    const response = await fetch(registerUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: params.toString()
    });
    return await response.text();
  }

  async forgotPassword(email: string): Promise<string> {
    const forgotUrl = `${this.baseUrl}/Account/ForgotPassword`;
    const html = await this.fetchHtml(forgotUrl);
    const $ = cheerio.load(html);
    const token = this.parseRefreshForgotPasswordToken($);

    const params = new URLSearchParams({
      Email: email,
      __RequestVerificationToken: token || ''
    });

    const response = await fetch(forgotUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: params.toString()
    });
    return await response.text();
  }

  async subscribeBangumi(bangumiId: string, subtitleGroupId?: string): Promise<string> {
    const data: Record<string, any> = {
      BangumiID: bangumiId,
    };
    if (subtitleGroupId) {
      data.SubtitleGroupID = subtitleGroupId;
    }

    const cookies = await this.loadCookiesForUrl(this.baseUrl);
    const headers: Record<string, string> = {
      'Content-Type': 'application/json'
    };
    if (cookies) {
      headers['Cookie'] = cookies;
    }

    const response = await fetch(`${this.baseUrl}/Home/SubscribeBangumi`, {
      method: 'POST',
      headers,
      body: JSON.stringify(data)
    });

    return await response.text();
  }

  async unsubscribeBangumi(bangumiId: string, subtitleGroupId?: string): Promise<string> {
    const data: Record<string, any> = {
      BangumiID: bangumiId,
    };
    if (subtitleGroupId) {
      data.SubtitleGroupID = subtitleGroupId;
    }

    const cookies = await this.loadCookiesForUrl(this.baseUrl);
    const headers: Record<string, string> = {
      'Content-Type': 'application/json'
    };
    if (cookies) {
      headers['Cookie'] = cookies;
    }

    const response = await fetch(`${this.baseUrl}/Home/UnsubscribeBangumi`, {
      method: 'POST',
      headers,
      body: JSON.stringify(data)
    });

    return await response.text();
  }

  // ==================== Parse Methods ====================

  parseIndex($: cheerio.CheerioAPI): Index {
    const bangumiRows = this.parseSeason($);
    const rss = this.parseDay($);
    const carousels = this.parseCarousel($);
    const years = this.parseYearSeason($);
    const user = this.parseUser($);
    const announcements = this.parseAnnouncement($);

    const groupedRss = rss.reduce((acc, item) => {
      if (item.id && !acc[item.id]) acc[item.id] = [];
      if (item.id) acc[item.id].push(item);
      return acc;
    }, {} as Record<string, RecordItem[]>);

    return {
      years,
      bangumiRows,
      rss: groupedRss,
      carousels,
      user: user || undefined,
      announcements: announcements.length > 0 ? announcements : undefined
    };
  }

  parseSeason($: cheerio.CheerioAPI): BangumiRow[] {
    const rows: BangumiRow[] = [];
    $('div.sk-bangumi').each((_, rowEle) => {
      const $row = $(rowEle);
      const row: BangumiRow = {
        name: trim($row.children().first().text()),
        sname: getWeekSectionName(trim($row.children().first().text())),
        num: 0,
        updatedNum: 0,
        subscribedNum: 0,
        subscribedUpdatedNum: 0,
        bangumis: []
      };

      const bangumis: Bangumi[] = [];
      $row.find('li').each((_, ele) => {
        const $li = $(ele);
        const $span = $li.find('span').first();
        const dataSrc = $span.attr('data-src')?.split('?')[0]?.trim() || '';
        const $anText = $li.find('.an-text');
        const $dateTextTitle = $li.find('.date-text[title]');

        const $dateTexts = $li.find('.date-text');
        let updateAt = '';
        if ($dateTexts.length > 0) {
          // Only take the first .date-text element's text
          updateAt = $dateTexts.first().text().trim() || '';
        }
        const bangumi: Bangumi = {
          id: $span.attr('data-bangumiid')?.trim() || '',
          cover: this.baseUrl + dataSrc,
          name: trim($anText.attr('title') || $dateTextTitle.attr('title') || ''),
          subscribed: $li.find('.active').length > 0,
          num: parseInt($li.find('.num-node').text().trim() || '0', 10) || 0,
          grey: $li.find('span.greyout').length > 0,
          updateAt: updateAt,
          week: row.name
        };
        bangumis.push(bangumi);
      });

      row.num = bangumis.length;
      row.updatedNum = bangumis.filter(b => (b.num ?? 0) > 0).length;
      row.subscribedNum = bangumis.filter(b => b.subscribed).length;
      row.subscribedUpdatedNum = bangumis.filter(b => b.subscribed && (b.num ?? 0) > 0).length;

      bangumis.sort((a, b) => {
        if (a.grey && b.grey) {
          if (a.subscribed && b.subscribed) return 0;
          return a.subscribed ? -1 : 1;
        }
        if (a.grey) return 1;
        if (b.grey) return -1;
        if (a.subscribed && b.subscribed) return 0;
        return a.subscribed ? -1 : 1;
      });

      row.bangumis = bangumis;
      rows.push(row);
    });
    return rows;
  }

  parseDay($: cheerio.CheerioAPI): RecordItem[] {
    const items: RecordItem[] = [];
    $('#an-list-res .my-rss-item').each((_, ele) => {
      const $item = $(ele);
      const record: RecordItem = { id: '', name: '', title: '', tags: [], cover: '', torrent: '', magnet: '', url: '', size: '', publishAt: '', groups: [] };

      const $thumb = $item.find('div.sk-col.rss-thumb');
      const style = $thumb.attr('style');
      if (style) {
        const match = style.match(/\((.*)\)/);
        if (match) record.cover = this.baseUrl + match[1];
      }

      const $nameLink = $item.find('div.sk-col.rss-name > div > a');
      if ($nameLink.length > 0) {
        record.name = trim($nameLink.text());
        const href = $nameLink.attr('href');
        if (href) {
          const idMatch = href.substring(14).split('#')[0];
          record.id = idMatch;
        }
      }

      const $links = $item.find('div.sk-col.rss-name > a');
      if ($links.length > 0) {
        const $link0 = $links.eq(0);
        record.torrent = this.baseUrl + ($link0.attr('href') || '');

        const $span = $link0.find('span');
        let titleText = $link0.text();
        if ($span.length > 0) {
          record.size = $span.text().replace(/[\[\]]/g, '').trim();
          $span.remove();
          titleText = $link0.text();
        }

        if (titleText) {
          const result = parseTagsAndTitle(titleText);
          record.title = result.title;
          record.tags = result.tags;
        }

        const $link1 = $links.eq(1);
        record.magnet = $link1.attr('data-clipboard-text') || '';

        const $link2 = $links.eq(2);
        record.url = this.baseUrl + ($link2.attr('href') || '');
      }

      const publishAtText = $item.find('div.sk-col.pull-right').text() || '';
      record.publishAt = formatPublishAt(publishAtText.trim());

      items.push(record);
    });
    return items;
  }

  parseUser($: cheerio.CheerioAPI): User | null {
    const name = trim($('#user-name .text-right').first().text() || '');
    const avatar = trim($('#user-welcome #head-pic').attr('src') || '');
    const token = trim($('#login input[name=__RequestVerificationToken]').attr('value') || '');
    const rss = trim($('#an-episode-updates .mikan-rss').attr('href') || '');

    if (!name && !avatar && !token && !rss) {
      return null;
    }

    return {
      name: name || undefined,
      avatar: avatar ? this.baseUrl + avatar : undefined,
      token: token || undefined,
      rss: rss ? this.baseUrl + rss : undefined
    };
  }

  parseRefreshLoginToken($: cheerio.CheerioAPI): string | null {
    return trim($('#login input[name=__RequestVerificationToken]').attr('value') || '') || null;
  }

  parseRefreshRegisterToken($: cheerio.CheerioAPI): string | null {
    return trim($('input[name=__RequestVerificationToken]').attr('value') || '') || null;
  }

  parseRefreshForgotPasswordToken($: cheerio.CheerioAPI): string | null {
    return trim($('input[name=__RequestVerificationToken]').attr('value') || '') || null;
  }

  parseSearch($: cheerio.CheerioAPI): SearchResult {
    const subgroups: Subgroup[] = [];
    $('div.leftbar-container .leftbar-item .subgroup-longname').each((_, ele) => {
      const $ele = $(ele);
      const id = $ele.attr('data-subgroupid')?.trim();
      if (id) {
        subgroups.push({ id, name: trim($ele.text()) });
      }
    });

    const bangumis: Bangumi[] = [];
    $('div.central-container > ul > li').each((_, ele) => {
      const $ele = $(ele);
      const href = trim($ele.find('a').attr('href') || '');
      const dataSrc = $ele.find('span').attr('data-src')?.split('?')[0]?.trim() || '';
      bangumis.push({
        id: href.replace('/Home/Bangumi/', ''),
        cover: this.baseUrl + dataSrc,
        name: trim($ele.find('.an-text').attr('title') || ''),
        subscribed: false,
        grey: false,
        updateAt: '',
        week: '',
        num: 0
      });
    });

    const records: RecordItem[] = [];
    $('tr.js-search-results-row').each((_, ele) => {
      const $row = $(ele);
      const $tds = $row.find('td');
      if ($tds.length < 5) return;

      const $link = $tds.eq(1).children().first();
      const titleText = trim($link.text() || '');
      const result = parseTagsAndTitle(titleText);

      records.push({
        url: this.baseUrl + ($link.attr('href') || ''),
        title: result.title,
        tags: result.tags,
        size: trim($tds.eq(2).text() || ''),
        publishAt: formatPublishAt(trim($tds.eq(3).text() || '')),
        magnet: $tds.eq(1).children().eq(1).attr('data-clipboard-text') || '',
        torrent: this.baseUrl + ($tds.eq(4).children().first().attr('href') || '')
      });
    });

    return { bangumis, subgroups, records };
  }

  parseList($: cheerio.CheerioAPI): RecordItem[] {
    const records: RecordItem[] = [];
    $('#sk-body > table > tbody > tr').each((_, ele) => {
      const $row = $(ele);
      const $tds = $row.children();
      if ($tds.length < 5) return;

      const record: RecordItem = { groups: [], title: '', tags: [], url: '', magnet: '', size: '', torrent: '', publishAt: '' };

      const publishAtText = trim($tds.eq(0).text() || '');
      record.publishAt = formatPublishAt(publishAtText);

      const $groupsTd = $tds.eq(1);
      const $lis = $groupsTd.find('li');
      const groups: Subgroup[] = [];

      if ($lis.length > 0) {
        $lis.each((_, li) => {
          const $li = $(li);
          const $a = $li.children().first();
          groups.push({
            id: $a.attr('href')?.substring(19),
            name: trim($a.text())
          });
        });
      } else if ($groupsTd.children().length > 0) {
        const $a = $groupsTd.children().first();
        groups.push({
          id: $a.attr('href')?.substring(19),
          name: trim($a.text())
        });
      } else {
        groups.push({ name: trim($groupsTd.text()) });
      }
      record.groups = groups;

      const $link = $tds.eq(2).children().first();
      const titleText = trim($link.text() || '');
      if (titleText) {
        const result = parseTagsAndTitle(titleText);
        record.title = result.title;
        record.tags = result.tags;
      }
      record.url = this.baseUrl + ($link.attr('href') || '');
      record.magnet = $tds.eq(2).children().eq(1).attr('data-clipboard-text') || '';
      record.size = trim($tds.eq(3).text() || '');
      record.torrent = this.baseUrl + ($tds.eq(4).children().first().attr('href') || '');

      records.push(record);
    });
    return records;
  }

  parseCarousel($: cheerio.CheerioAPI): Carousel[] {
    const carousels: Carousel[] = [];
    $('#myCarousel > div.carousel-inner > div.item.carousel-bg').each((_, ele) => {
      const $ele = $(ele);
      const style = $ele.attr('style') || '';
      const coverMatch = style.match(/'([^']+)'/);
      const onClick = $ele.attr('onclick') || '';
      const idMatch = onClick.match(/'([^']+)'/);

      carousels.push({
        cover: this.baseUrl + (coverMatch ? coverMatch[1] : ''),
        id: idMatch ? idMatch[1].substring(idMatch[1].lastIndexOf('/') + 1) : ''
      });
    });
    return carousels;
  }

  parseYearSeason($: cheerio.CheerioAPI): YearSeason[] {
    const selected = trim($('#sk-data-nav .date-select div.date-text').text() || '');
    const yearSeasons: YearSeason[] = [];

    $('#sk-data-nav > div > ul.navbar-nav.date-select > li > ul > li').each((_, ele) => {
      const $li = $(ele);
      const year: YearSeason = {
        year: trim($li.children().first().text()),
        seasons: []
      };

      $li.children().eq(1).children().each((_, e) => {
        const $e = $(e);
        const $a = $e.children().first();
        const y = trim($a.attr('data-year') || '');
        const s = $a.attr('data-season') || '';
        const title = `${y} ${trim($a.text())}`;
        year.seasons.push({
          year: y,
          season: s,
          title,
          active: title === selected
        });
      });

      yearSeasons.push(year);
    });

    return yearSeasons;
  }

  parseSubgroup($: cheerio.CheerioAPI): SeasonGallery[] {
    const galleries: SeasonGallery[] = [];
    $('#js-sort-wrapper > div.pubgroup-timeline-item[data-index]').each((_, ele) => {
      const $item = $(ele);
      const title = `${trim($item.find('.pubgroup-date').text())} ${trim($item.find('.pubgroup-season').text())}`;

      const bangumis: Bangumi[] = [];
      $item.find('li[data-bangumiid]').each((_, e) => {
        const $e = $(e);
        bangumis.push({
          id: $e.attr('data-bangumiid')?.trim() || '',
          name: trim($e.find('div.an-info-group > a').attr('title') || ''),
          subscribed: $e.find('.an-info-icon.active').length > 0,
          grey: false,
          updateAt: '',
          week: '',
          cover: this.baseUrl + ($e.find('span[data-bangumiid]').attr('data-src')?.split('?')[0]?.trim() || ''),
          num: 0
        });
      });

      // Remove duplicates
      const uniqueBangumis = Array.from(new Map(bangumis.map(b => [b.id, b])).values());

      uniqueBangumis.sort((a, b) => {
        if (a.subscribed && b.subscribed) return 0;
        return a.subscribed ? -1 : 1;
      });

      galleries.push({
        year: title.split(' ')[0] || '',
        season: title.split(' ').slice(1).join(' ') || '',
        title,
        active: $item.find('.pubgroup-season.current-season').length > 0,
        bangumis: uniqueBangumis
      });
    });
    return galleries;
  }

  parseBangumi($: cheerio.CheerioAPI): BangumiDetail {
    const $link = $('#sk-container > div.pull-left.leftbar-container > p.bangumi-title > a');
    const id = $link.attr('href')?.split('=')[1] || '';

    const $poster = $('#sk-container > div.pull-left.leftbar-container > div.bangumi-poster');
    const posterStyle = $poster.attr('style') || '';
    const coverMatch = posterStyle.match(/'([^']+)'/);
    const cover = this.baseUrl + (coverMatch ? coverMatch[1].split('?')[0] : '');

    const name = trim($('#sk-container > div.pull-left.leftbar-container > p.bangumi-title').text() || '');
    let intro = trim($('#sk-container > div.central-container > p').text() || '');
    if (intro) {
      intro = '\u3000\u3000' + intro.replace(/\n/g, '\n\u3000\u3000');
    }

    const $subscribedBadge = $('#sk-container .subscribed-badge');
    const subscribed = $subscribedBadge.length > 0 ? ($subscribedBadge.attr('style') || '').trim().length === 0 : false;

    const more: Record<string, string> = {};
    $('#sk-container > div.pull-left.leftbar-container > p.bangumi-info').each((_, ele) => {
      const $ele = $(ele);
      const text = trim($ele.text());
      const parts = text.split('：');
      if (parts.length === 2) {
        more[trim(parts[0].replace('番组计划链接', ''))] = trim(parts[1]);
      }
    });

    const subgroupBangumis: Record<string, SubgroupBangumi> = {};
    const $tables = $('#sk-container > div.central-container > div.episode-table > table');
    const $subs = $('.subgroup-text');

    $tables.each((i, table) => {
      const $sub = $subs.eq(i);
      const subgroupBangumi = this.parseSubgroupBangumi($sub);

      const records: RecordItem[] = [];
      $(table).find('tbody > tr').each((_, tr) => {
        records.push(this.parseRecordItemFromRow($(tr)));
      });
      subgroupBangumi.records = records;

      subgroupBangumis[subgroupBangumi.dataId] = subgroupBangumi;
    });

    return {
      id,
      cover,
      name,
      intro,
      subscribed,
      more,
      subgroupBangumis
    };
  }

  parseSubgroupBangumi($sub: cheerio.Cheerio<any>): SubgroupBangumi {
    const dataId = $sub.attr('id') || '';

    // 解析字幕组名称
    let name = '';
    const $firstNode = $sub.children().first();

    if ($firstNode.length > 0) {
      // 获取第一个文本节点，而不是包含所有子元素的文本
      const contents = $firstNode.contents();
      let firstNodeText = '';

      for (let i = 0; i < contents.length; i++) {
        const node = contents[i];
        const nodeType = (node as any).type;
        const nodeText = (node as any).nodeValue || '';
        const trimmedText = nodeText.trim();

        // 找第一个非空文本节点 (nodeType === 'text')
        if (!firstNodeText && nodeType === 'text' && trimmedText) {
          firstNodeText = trim(trimmedText);
          break;
        }
      }

      if (firstNodeText) {
        name = firstNodeText;
      } else {
        // fallback: 使用 dropdown
        const $dropdown = $sub.find('.dropdown span');
        if ($dropdown.length > 0) {
          name = trim($dropdown.text());
        } else {
          const $firstChild = $firstNode.children().first();
          name = $firstChild.length > 0 ? trim($firstChild.text()) : trim($firstNode.text());
        }
      }
    }

    // 如果字幕组名称为空，设置为默认值
    if (!name || name.trim() === '') {
      name = '生肉/不明字幕';
    }

    const $subele = $sub.find('.subscribed');
    const subscribed = $subele.attr('style') === undefined;
    const sublang = trim($subele.text() || '');

    let state = -1;
    if (subscribed) {
      if (sublang === '简中') state = 1;
      else if (sublang === '繁中') state = 2;
      else state = 0;
    }

    const $rss = $sub.find('.mikan-rss');
    const rssHref = $rss.attr('href');
    const rss = rssHref ? this.baseUrl + rssHref : undefined;

    const subgroups: Subgroup[] = [];
    $sub.find('ul > li > a').each((_, ele) => {
      const $a = cheerio.load(ele);
      subgroups.push({
        id: $a('a').attr('href')?.split('/').pop(),
        name: trim($a('a').text())
      });
    });

    return {
      dataId,
      name,
      subscribed,
      sublang: sublang || undefined,
      rss,
      state,
      subgroups,
      records: []
    };
  }

  parseRecordItemFromRow($row: cheerio.Cheerio<any>): RecordItem {
    const $td1 = $row.children().eq(1);
    const magnet = $td1.children().eq(1).attr('data-clipboard-text') || '';

    const $link = $td1.children().first();
    const titleText = trim($link.text() || '');
    const result = parseTagsAndTitle(titleText);

    const $td2 = $row.children().eq(2);
    const sizeText = trim($td2.text() || '');

    const $td3 = $row.children().eq(3);
    const publishAtText = trim($td3.text() || '');

    const $td4 = $row.children().eq(4);
    const torrentHref = $td4.children().first().attr('href') || '';

    return {
      magnet,
      title: result.title,
      tags: result.tags,
      url: this.baseUrl + ($link.attr('href') || ''),
      size: sizeText,
      publishAt: formatPublishAt(publishAtText),
      torrent: this.baseUrl + torrentHref
    };
  }

  parseRecordItemFromRowAlt($row: cheerio.Cheerio<any>): RecordItem {
    // 第1列：checkbox 的 data-magnet 属性
    const $td0 = $row.children().eq(0);
    const magnet = $td0.find('input').attr('data-magnet') || '';

    // 第2列：番组名，包含链接和磁力复制
    const $td1 = $row.children().eq(1);
    const $link = $td1.find('a.magnet-link-wrap').first();
    const titleText = trim($link.text() || '');
    const result = parseTagsAndTitle(titleText);

    // 第3列：大小
    const $td2 = $row.children().eq(2);
    const size = trim($td2.text() || '');

    // 第4列：时间
    const $td3 = $row.children().eq(3);
    const publishAt = formatPublishAt(trim($td3.text() || ''));

    // 第5列：下载链接
    const $td4 = $row.children().eq(4);
    const torrent = this.baseUrl + ($td4.find('a').attr('href') || '');

    return {
      magnet,
      title: result.title,
      tags: result.tags,
      url: this.baseUrl + ($link.attr('href') || ''),
      size,
      publishAt,
      torrent
    };
  }

  parseRecordDetail($: cheerio.CheerioAPI): RecordDetail {
    const id = $('#sk-container > div.pull-left.leftbar-container > div.leftbar-nav > button').attr('data-bangumiid') || '';

    const $poster = $('#sk-container > div.pull-left.leftbar-container > div.bangumi-poster');
    const posterStyle = $poster.attr('style') || '';
    const coverMatch = posterStyle.match(/'([^']+)'/);
    const cover = this.baseUrl + (coverMatch ? coverMatch[1].split('?')[0] : '');

    const name = trim($('#sk-container > div.pull-left.leftbar-container > p.bangumi-title').text() || '');

    const title = trim($('#sk-container > div.central-container > div.episode-header > p').text() || '');
    let tags: string[] = [];
    let parsedTitle = '';
    if (title) {
      const result = parseTagsAndTitle(title);
      parsedTitle = result.title;
      tags = result.tags;
    }

    const $subscribedBadge = $('#sk-container .subscribed-badge');
    const subscribed = $subscribedBadge.length > 0 ? ($subscribedBadge.attr('style') || '').trim().length === 0 : false;

    const more: Record<string, string> = {};
    $('#sk-container > div.pull-left.leftbar-container > p.bangumi-info').each((_, ele) => {
      const $ele = $(ele);
      const text = trim($ele.text());
      const parts = text.split('：');
      if (parts.length === 2) {
        more[trim(parts[0])] = trim(parts[1]);
      }
    });

    let torrent = '';
    let magnet = '';
    $('#sk-container > div.pull-left.leftbar-container > div.leftbar-nav > a').each((_, ele) => {
      const $a = $(ele);
      const text = trim($a.text());
      if (text === '下载种子') {
        torrent = this.baseUrl + ($a.attr('href') || '');
      } else if (text === '磁力链接') {
        magnet = $a.attr('href') || '';
      }
    });

    const $desc = $('#sk-container > div.central-container > div.episode-desc');
    $desc.children().each((_, ele) => {
      const $ele = $(ele);
      if ($ele.attr('style')?.trim() === 'margin-top: -10px; margin-bottom: 10px;') {
        $ele.remove();
      }
    });
    const intro = trim($desc.html() || '');

    return {
      id,
      cover,
      name,
      title: parsedTitle,
      tags,
      subscribed,
      more,
      torrent,
      magnet,
      intro
    };
  }

  parseBangumiMore($: cheerio.CheerioAPI): RecordItem[] {
    const records: RecordItem[] = [];
    $('tbody > tr').each((_, ele) => {
      records.push(this.parseRecordItemFromRowAlt($(ele)));
    });
    return records;
  }

  parseMySubscribed($: cheerio.CheerioAPI): Bangumi[] {
    const bangumis: Bangumi[] = [];
    $('li').each((_, ele) => {
      const $li = $(ele);
      const $span = $li.find('span').first();

      // Get bangumi ID from span's data-bangumiid attribute
      const bangumiId = $span.attr('data-bangumiid');
      if (!bangumiId) return; // Skip li elements without bangumi data

      const $dateTexts = $li.find('.date-text');
      let updateAt = '';
      if ($dateTexts.length > 0) {
        // Only take the first .date-text element's text
        updateAt = $dateTexts.first().text().trim() || '';
      }
      const name = trim($li.find('.an-text').attr('title') || $li.find('.date-text[title]').attr('title') || '');

      bangumis.push({
        id: bangumiId.trim(),
        cover: this.baseUrl + ($span.attr('data-src')?.split('?')[0]?.trim() || ''),
        name: name,
        subscribed: $li.find('.active').length > 0,
        num: parseInt($li.find('.num-node').text().trim() || '0', 10) || 0,
        grey: $li.find('span.greyout').length > 0,
        updateAt: updateAt,
        week: ''
      });
    });
    return bangumis;
  }

  parseAnnouncement($: cheerio.CheerioAPI): Announcement[] {
    const announcements: Announcement[] = [];
    $('.announcement-popover-content > div').each((_, ele) => {
      const $div = $(ele);
      const $date = $div.find('.anndate');
      const date = trim($date.text() || '');
      $date.remove();

      const nodes: AnnouncementNode[] = [];
      $div.contents().each((_, node) => {
        if (node.type === 'text') {
          nodes.push({ text: trim(node.nodeValue || '') });
        } else if (node.type === 'tag') {
          const $tag = $(node);
          if (node.tagName === 'a') {
            nodes.push({ text: `{${trim($tag.text())}}`, place: $tag.attr('href'), type: 'url' });
          } else if (node.tagName === 'b') {
            nodes.push({ text: `{${trim($tag.text())}}`, type: 'bold' });
          } else {
            nodes.push({ text: trim($tag.text()) });
          }
        }
      });

      announcements.push({ date, nodes });
    });
    return announcements;
  }

  // ==================== Helper Methods ====================

  private async bridgeCall(action: string, data?: any): Promise<any> {
    try {
      // @ts-ignore - fjs is available at runtime
      return await fjs.bridge_call({ action, ...data });
    } catch (e) {
      return null;
    }
  }

  private async getDomainFromUrl(url: string): Promise<string> {
    try {
      const urlObj = new URL(url);
      return urlObj.hostname;
    } catch {
      return 'mikanani.me';
    }
  }

  private async loadCookiesForUrl(url: string): Promise<string> {
    const domain = await this.getDomainFromUrl(url);
    // loadCookies now returns a pre-formatted Cookie header string directly
    const cookieString = await this.bridgeCall('loadCookies', { domain });
    if (cookieString && typeof cookieString === 'string' && cookieString.length > 0) {
      return cookieString;
    }
    return '';
  }

  private async saveCookiesFromResponse(response: Response, url: string): Promise<void> {
    const domain = await this.getDomainFromUrl(url);

    // IMPORTANT: response.headers.get('set-cookie') only returns the FIRST Set-Cookie header
    // We need to iterate through all headers to get ALL Set-Cookie headers
    const cookieHeaders: string[] = [];
    for (const [name, value] of response.headers.entries()) {
      if (name.toLowerCase() === 'set-cookie') {
        cookieHeaders.push(value);
      }
    }

    if (cookieHeaders.length === 0) {
      return;
    }

    // Pass each Set-Cookie header string directly to Dart for proper parsing
    // using Dart's Cookie.fromSetCookieValue() which handles all edge cases
    for (const header of cookieHeaders) {
      const trimmed = header.trim();
      if (trimmed) {
        await this.bridgeCall('saveCookieHeader', { domain, header: trimmed });
      }
    }
  }

  async release(): Promise<any> {
    const url = 'https://api.github.com/repos/iota9star/mikan_flutter/releases/latest';
    const response = await fetch(url, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36 MikanProject/1.0.0',
        'Accept': 'application/vnd.github.v3+json'
      }
    });
    return await response.json();
  }

  async fonts(): Promise<any> {
    const url = 'https://fonts.bytex.space/fonts-manifest.json';
    const response = await fetch(url, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36 MikanProject/1.0.0',
        'Accept': 'application/json'
      }
    });
    return await response.json();
  }

  private async fetchHtml(url: string): Promise<string> {
    const cookies = await this.loadCookiesForUrl(url);

    const headers: Record<string, string> = {
      'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36 MikanProject/1.0.0'
    };

    if (cookies) {
      headers['Cookie'] = cookies;
    }

    const response = await fetch(url, { headers });

    // Save cookies from response
    await this.saveCookiesFromResponse(response, url);

    return await response.text();
  }
}

// Export singleton instance
export default new MikanApi();
