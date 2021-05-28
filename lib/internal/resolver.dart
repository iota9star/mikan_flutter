import 'dart:collection';

import "package:collection/collection.dart";
import 'package:html/dom.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mikan_flutter/internal/caches.dart';
import 'package:mikan_flutter/internal/consts.dart';
import 'package:mikan_flutter/internal/enums.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/model/bangumi.dart';
import 'package:mikan_flutter/model/bangumi_details.dart';
import 'package:mikan_flutter/model/bangumi_row.dart';
import 'package:mikan_flutter/model/carousel.dart';
import 'package:mikan_flutter/model/index.dart';
import 'package:mikan_flutter/model/record_details.dart';
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/model/search.dart';
import 'package:mikan_flutter/model/season.dart';
import 'package:mikan_flutter/model/season_gallery.dart';
import 'package:mikan_flutter/model/subgroup.dart';
import 'package:mikan_flutter/model/subgroup_bangumi.dart';
import 'package:mikan_flutter/model/user.dart';
import 'package:mikan_flutter/model/year_season.dart';

class Resolver {
  static Future<List<BangumiRow>> parseSeason(final Document document) async {
    final List<Element> rowElements =
        document.querySelectorAll("div.sk-bangumi");
    final List<BangumiRow> list = [];
    BangumiRow bangumiRow;
    Bangumi bangumi;
    List<Bangumi> bangumis;
    List<Element> bangumiElements;
    Map<dynamic, String>? attributes;
    String? temp;
    for (final Element rowEle in rowElements) {
      bangumiRow = BangumiRow();
      temp = rowEle.children[0].text.trim();
      bangumiRow.name = temp;
      temp = WeekSection.getByName(temp)?.name ?? temp;
      bangumiRow.sname = temp;
      bangumiElements = rowEle.querySelectorAll("li");
      bangumis = [];
      for (final Element ele in bangumiElements) {
        bangumi = Bangumi();
        attributes = ele.querySelector("span")?.attributes ?? {};
        bangumi.id = attributes["data-bangumiid"]?.trim() ?? "";
        bangumi.cover = MikanUrl.BASE_URL +
            (attributes["data-src"]?.split("?").first.trim() ?? "");
        bangumi.grey = ele.querySelector("span.greyout") != null;
        bangumi.updateAt = ele.querySelector(".date-text")?.text.trim() ?? "";
        attributes = (ele.querySelector(".an-text") ??
                    ele.querySelector(".date-text[title]"))
                ?.attributes ??
            {};
        bangumi.name = attributes['title']?.trim() ?? "";
        bangumi.subscribed = ele.querySelector(".active") != null;
        bangumi.num =
            int.tryParse(ele.querySelector(".num-node")?.text.trim() ?? "0") ??
                0;
        bangumis.add(bangumi);
        bangumi.week = temp;
      }
      bangumiRow.num = bangumis.length;
      bangumiRow.updatedNum =
          bangumis.where((it) => it.num != null && it.num! > 0).length;
      bangumiRow.subscribedNum =
          bangumis.where((element) => element.subscribed).length;
      bangumiRow.subscribedUpdatedNum = bangumis
          .where((it) => it.subscribed && it.num != null && it.num! > 0)
          .length;
      bangumis.sort((a, b) {
        if (a.grey && b.grey) {
          if (a.subscribed && b.subscribed) {
            return 0;
          } else if (a.subscribed) {
            return -1;
          } else {
            return 1;
          }
        } else if (a.grey) {
          return 1;
        } else if (b.grey) {
          return -1;
        }
        if (a.subscribed && b.subscribed) {
          return 0;
        } else if (a.subscribed) {
          return -1;
        } else {
          return 1;
        }
      });
      bangumiRow.bangumis = bangumis;
      list.add(bangumiRow);
    }
    return list;
  }

  static Future<List<RecordItem>> parseDay(final Document document) async {
    final List<Element> elements =
        document.querySelectorAll("#an-list-res .my-rss-item");
    RecordItem record;
    final List<RecordItem> list = [];
    Element? element;
    List<Element> tempEles;
    String? temp;
    String tempLowerCase;
    Set<String> tags;
    for (final ele in elements) {
      record = RecordItem();
      element = ele.querySelector("div.sk-col.rss-thumb");
      if (element != null) {
        temp = element.attributes['style'];
        if (temp != null) {
          record.cover = MikanUrl.BASE_URL +
              RegExp(r"\((.*)\)").firstMatch(temp)!.group(1)!;
        }
      }
      element = ele.querySelector("div.sk-col.rss-name > div > a");
      if (element != null) {
        record.name = element.text.trim();
        temp = element.attributes['href'];
        if (temp.isNotBlank) {
          record.id = temp!.substring(14).split("#")[0].trim();
        }
      }
      tempEles = ele.querySelectorAll("div.sk-col.rss-name > a");
      if (tempEles.isNotEmpty) {
        element = tempEles.getOrNull(0);
        if (element != null) {
          temp = element.attributes['href']?.trim() ?? "";
          if (temp.isNotBlank) {
            record.torrent = MikanUrl.BASE_URL + temp;
          }
          temp = element.querySelector("span")?.text.trim() ?? "";
          if (temp.isNotBlank) {
            record.size = temp.replaceAll(r"[", "").replaceAll(r"]", "").trim();
          }
          element.querySelector("span")?.remove();
          temp = element.text.trim();
          if (temp.isNotBlank) {
            temp = temp.replaceAll("【", "[").replaceAll("】", "]");
            tempLowerCase = temp.toLowerCase();
            tags = LinkedHashSet();
            keywords.forEach((key, value) {
              if (tempLowerCase.contains(key)) {
                tags.add(value);
              }
            });
            record.title = temp;
            record.tags = tags.toList()..sort((a, b) => b.compareTo(a));
          }
        }
        element = tempEles.getOrNull(1);
        record.magnet =
            element?.attributes['data-clipboard-text']?.trim() ?? "";
        element = tempEles.getOrNull(2);
        record.url = element?.attributes["href"]?.trim() ?? "";
      }
      temp = ele.querySelector("div.sk-col.pull-right")?.text.trim() ?? "";
      if (temp.isNotBlank &&
          RegExp(r"^\d{4}/\d{2}/\d{2}\s\d{2}:\d{2}$").hasMatch(temp)) {
        await Jiffy.locale("zh_cn");
        record.publishAt = Jiffy(temp, "yyyy/MM/dd HH:mm").yMMMdjm;
      } else {
        record.publishAt = temp;
      }
      list.add(record);
    }
    return list;
  }

  static Future<User> parseUser(final Document document) async {
    final String? name =
        document.querySelector("#user-name .text-right")?.text.trim();
    final String? avatar = document
        .querySelector("#user-welcome #head-pic")
        ?.attributes["src"]
        ?.trim();
    final String? token = document
        .querySelector("#login input[name=__RequestVerificationToken]")
        ?.attributes["value"]
        ?.trim();
    return User(
      name: name,
      avatar: avatar == null ? null : MikanUrl.BASE_URL + avatar,
      token: token,
    );
  }

  static Future<String?> parseRefreshRegisterToken(
    final Document document,
  ) async {
    final String? token = document
        .querySelector("#registerForm input[name=__RequestVerificationToken]")
        ?.attributes["value"]
        ?.trim();
    return token;
  }

  static Future<String?> parseRefreshLoginToken(final Document document) async {
    final String? token = document
        .querySelector("#login input[name=__RequestVerificationToken]")
        ?.attributes["value"]
        ?.trim();
    return token;
  }

  static Future<SearchResult> parseSearch(final Document document) async {
    List<Element> eles = document.querySelectorAll(
        "div.leftbar-container .leftbar-item .subgroup-longname");
    final List<Subgroup> subgroups = [];
    String? temp;
    Subgroup subgroup;
    for (final Element ele in eles) {
      temp = ele.attributes['data-subgroupid']?.trim();
      if (temp.isNotBlank) {
        subgroup = Subgroup(id: temp!, name: ele.text.trim());
        subgroups.add(subgroup);
      }
    }
    eles = document.querySelectorAll("div.central-container > ul > li");
    final List<Bangumi> bangumis = [];
    Bangumi bangumi;
    for (final Element ele in eles) {
      bangumi = Bangumi();
      temp = ele.querySelector("a")?.attributes['href']?.trim();
      bangumi.id = temp?.replaceAll("/Home/Bangumi/", "") ?? "";
      bangumi.cover = MikanUrl.BASE_URL +
          (ele
                  .querySelector("span")
                  ?.attributes["data-src"]
                  ?.split("?")
                  .first
                  .trim() ??
              "");
      bangumi.name =
          ele.querySelector(".an-text")?.attributes['title']?.trim() ?? "";
      bangumis.add(bangumi);
    }
    eles = document.querySelectorAll("tr.js-search-results-row");
    RecordItem record;
    List<RecordItem> searchs = [];
    List<Element> elements;
    String tempLowerCase;
    Set<String> tags;
    for (final Element ele in eles) {
      record = RecordItem();
      elements = ele.querySelectorAll("td");
      record.url = MikanUrl.BASE_URL +
          (elements[0].children[0].attributes['href']?.trim() ?? "");
      temp = elements.getOrNull(0)?.children.getOrNull(0)?.text.trim();
      if (temp.isNotBlank) {
        temp = temp!.trim().replaceAll("【", "[").replaceAll("】", "]");
        tags = LinkedHashSet();
        tempLowerCase = temp.toLowerCase();
        keywords.forEach((key, value) {
          if (tempLowerCase.contains(key)) {
            tags.add(value);
          }
        });
        record.tags = tags.toList()..sort((a, b) => b.compareTo(a));
        record.title = temp;
      }
      record.size = elements[1].text.trim();
      temp = elements[2].text.trim();
      if (temp.isNotBlank &&
          RegExp(r"^\d{4}/\d{2}/\d{2}\s\d{2}:\d{2}$").hasMatch(temp)) {
        await Jiffy.locale("zh_cn");
        record.publishAt = Jiffy(temp, "yyyy/MM/dd HH:mm").yMMMdjm;
      } else {
        record.publishAt = temp;
      }
      record.magnet =
          elements[0].children[1].attributes["data-clipboard-text"] ?? "";
      record.torrent = MikanUrl.BASE_URL +
          (elements[3].children[0].attributes["href"] ?? "");
      searchs.add(record);
    }
    return SearchResult(
      bangumis: bangumis,
      subgroups: subgroups,
      records: searchs,
    );
  }

  static Future<List<RecordItem>> parseList(final Document document) async {
    final List<Element> eles =
        document.querySelectorAll("#sk-body > table > tbody > tr");
    final List<RecordItem> records = [];
    RecordItem record;
    Subgroup subgroup;
    List<Subgroup> subgroups;
    Element element;
    Element tempElement;
    List<Element> elements;
    List<Element> tempElements;
    String temp;
    String tempLowerCase;
    Set<String> tags;
    for (final Element ele in eles) {
      elements = ele.children;
      record = RecordItem();
      temp = elements[0].text.trim();
      if (temp.isNotBlank &&
          RegExp(r"^\d{4}/\d{2}/\d{2}\s\d{2}:\d{2}$").hasMatch(temp)) {
        await Jiffy.locale("zh_cn");
        record.publishAt = Jiffy(temp, "yyyy/MM/dd HH:mm").yMMMdjm;
      } else {
        record.publishAt = temp;
      }
      element = elements[1];
      tempElements = element.querySelectorAll("li");
      subgroups = [];
      if (tempElements.isNotEmpty) {
        for (Element ele in tempElements) {
          tempElement = ele.children[0];
          subgroup = Subgroup(
              id: tempElement.attributes['href']?.substring(19),
              name: tempElement.text.trim());
          subgroups.add(subgroup);
        }
      } else if (element.children.length > 0) {
        tempElement = element.children[0];
        subgroup = Subgroup(
          id: tempElement.attributes['href']?.substring(19),
          name: tempElement.text.trim(),
        );
        subgroups.add(subgroup);
      } else {
        subgroup = Subgroup(name: element.text.trim());
        subgroups.add(subgroup);
      }
      record.groups = subgroups;
      tempElements = elements[2].children;
      tempElement = tempElements[0];
      temp = tempElement.text;
      if (temp.isNotBlank) {
        temp = temp.trim().replaceAll("【", "[").replaceAll("】", "]");
        tags = LinkedHashSet();
        tempLowerCase = temp.toLowerCase();
        keywords.forEach((key, value) {
          if (tempLowerCase.contains(key)) {
            tags.add(value);
          }
        });
        record.tags = tags.toList()..sort((a, b) => b.compareTo(a));
        record.title = temp;
      }
      record.url =
          MikanUrl.BASE_URL + (tempElement.attributes['href']?.trim() ?? "");
      record.magnet =
          tempElements[1].attributes['data-clipboard-text']?.trim() ?? "";
      record.size = elements[3].text.trim();
      record.torrent = MikanUrl.BASE_URL +
          (elements[4].children[0].attributes['href']?.trim() ?? "");
      records.add(record);
    }
    return records;
  }

  static Future<Index> parseIndex(final Document document) async {
    final List<BangumiRow> bangumiRows = await parseSeason(document);
    final List<RecordItem> rss = await parseDay(document);
    final List<Carousel> carousels = await parseCarousel(document);
    final List<YearSeason> years = await parseYearSeason(document);
    final User user = await parseUser(document);
    final Map<String, List<RecordItem>> _rss = groupBy(rss, (it) => it.id!);
    return Index(
      years: years,
      bangumiRows: bangumiRows,
      rss: _rss,
      carousels: carousels,
      user: user,
    );
  }

  static Future<List<Carousel>> parseCarousel(final Document document) async {
    final List<Element> eles = document.querySelectorAll(
        "#myCarousel > div.carousel-inner > div.item.carousel-bg");
    final List<Carousel> carousels = [];
    Carousel carousel;
    String? temp;
    for (final Element ele in eles) {
      carousel = Carousel();
      temp = ele.attributes['style']?.trim();
      carousel.cover = MikanUrl.BASE_URL + (temp?.split("'")[1] ?? "");
      temp = ele.attributes["onclick"];
      temp = temp?.split("'")[1];
      carousel.id = temp?.substring(temp.lastIndexOf("/") + 1) ?? "";
      carousels.add(carousel);
    }
    return carousels;
  }

  static Future<List<YearSeason>> parseYearSeason(
      final Document document) async {
    final List<Element> eles = document.querySelectorAll(
        "#sk-data-nav > div > ul.navbar-nav.date-select > li > ul > li");
    final String? selected = document
        .querySelector("#sk-data-nav  .date-select  div.date-text")
        ?.text
        .trim();
    List<YearSeason> yearSeasons = [];
    YearSeason yearSeason;
    List<Season> seasons;
    Season season;
    Map attributes;
    for (final Element ele in eles) {
      yearSeason = YearSeason();
      yearSeason.year = ele.children[0].text.trim();
      seasons = [];
      Element element;
      for (final Element e in ele.children[1].children) {
        season = Season.empty();
        element = e.children[0];
        attributes = element.attributes;
        season.year = attributes["data-year"].trim();
        season.season = attributes["data-season"];
        season.title = season.year + ' ' + element.text.trim();
        season.active = season.title == selected;
        seasons.add(season);
      }
      yearSeason.seasons = seasons;
      yearSeasons.add(yearSeason);
    }
    return yearSeasons;
  }

  static Future<List<SeasonGallery>> parseSubgroup(
    final Document document,
  ) async {
    final List<Element> eles = document.querySelectorAll(
        "#js-sort-wrapper > div.pubgroup-timeline-item[data-index]");
    List<SeasonGallery> list = [];
    SeasonGallery subgroupGallery;
    Bangumi bangumi;
    List<Bangumi> bangumis;
    List<Element> elements;
    Map attributes;
    for (final Element ele in eles) {
      subgroupGallery = SeasonGallery.empty();
      subgroupGallery.title =
          "${ele.querySelector(".pubgroup-date")?.text.trim()} "
          "${ele.querySelector(".pubgroup-season")?.text.trim()}";
      subgroupGallery.isCurrentSeason =
          ele.querySelector(".pubgroup-season.current-season") != null;
      elements = ele.querySelectorAll("li[data-bangumiid]");
      bangumis = [];
      for (final Element e in elements) {
        bangumi = Bangumi();
        bangumi.id = e.attributes['data-bangumiid']?.trim() ?? "";
        attributes = e.querySelector("div.an-info-group > a")?.attributes ?? {};
        bangumi.name = attributes['title']?.trim();
        bangumi.subscribed = e.querySelector(".an-info-icon.active") != null;
        bangumi.cover = MikanUrl.BASE_URL +
            (e
                    .querySelector("span[data-bangumiid]")
                    ?.attributes['data-src']
                    ?.split("?")
                    .elementAt(0)
                    .trim() ??
                "");
        bangumis.add(bangumi);
      }
      bangumis = HashSet.from(bangumis).toList().cast<Bangumi>();
      bangumis.sort((a, b) {
        if (a.subscribed && b.subscribed) {
          return 0;
        } else if (a.subscribed) {
          return -1;
        } else {
          return 1;
        }
      });
      subgroupGallery.bangumis = bangumis;
      list.add(subgroupGallery);
    }
    return list;
  }

  static Future<BangumiDetail> parseBangumi(final Document document) async {
    final BangumiDetail detail = BangumiDetail();
    detail.id = document
            .querySelector("#sk-container "
                "> div.pull-left.leftbar-container "
                "> p.bangumi-title "
                "> a")
            ?.attributes["href"]
            ?.split("=")
            .getOrNull(1)
            ?.trim() ??
        "";
    detail.cover = MikanUrl.BASE_URL +
        (document
                .querySelector("#sk-container "
                    "> div.pull-left.leftbar-container "
                    "> div.bangumi-poster")
                ?.attributes["style"]
                ?.split("'")
                .elementAt(1)
                .split("?")
                .elementAt(0)
                .trim() ??
            '');
    detail.name = document
            .querySelector(
                "#sk-container > div.pull-left.leftbar-container > p.bangumi-title")
            ?.text
            .trim() ??
        "";
    String? _intro = document
        .querySelector("#sk-container > div.central-container > p")
        ?.text
        .trim();
    if (_intro.isNotBlank) {
      _intro = "\u3000\u3000" + _intro!.replaceAll("\n", "\n\u3000\u3000");
    }
    detail.intro = _intro;
    detail.subscribed = document
            .querySelector(".subscribed-badge")
            ?.attributes["style"]
            ?.isNullOrBlank ??
        false;
    final more = document
        .querySelectorAll(
            "#sk-container > div.pull-left.leftbar-container > p.bangumi-info")
        .map((e) => e.text.split("："));
    final Map<String, String> map = {};
    more.forEach((element) {
      map[element[0].trim()] = element[1].trim();
    });
    detail.more = map;
    final List<Element> tables = document
        .querySelectorAll("#sk-container > div.central-container > table");
    final List<Element> subs = document.querySelectorAll(".subgroup-text");
    detail.subgroupBangumis = [];
    SubgroupBangumi subgroupBangumi;
    Element? element;
    List<Element> elements;
    String? temp;
    List<RecordItem> records;
    RecordItem record;
    String tempLowerCase;
    Set<String> tags;
    List<Subgroup> subgroups;
    Subgroup subgroup;
    if (tables.length == subs.length) {
      for (int i = 0; i < tables.length; i++) {
        subgroupBangumi = SubgroupBangumi();
        element = subs.elementAt(i);
        temp = element.children[0].attributes["href"]?.trim();
        subgroupBangumi.dataId = element.attributes["id"]?.trim() ?? "";
        temp = element.nodes.getOrNull(0)?.text?.trim();
        if (temp.isNullOrBlank) {
          final Element child =
              element.querySelector(".dropdown span") ?? element.children[0];
          subgroupBangumi.name = child.text.trim();
        } else {
          subgroupBangumi.name = temp!;
        }
        subgroupBangumi.subscribed =
            element.querySelector(".subscribed")?.text.trim() == "已订阅";
        subgroups = [];
        elements = element.querySelectorAll("ul > li > a");
        if (elements.isSafeNotEmpty) {
          for (final Element ele in elements) {
            subgroup = Subgroup(
              id: ele.attributes["href"]?.split("/").last.trim(),
              name: ele.text.trim(),
            );
            subgroups.add(subgroup);
          }
        }
        if (subgroups.isEmpty) {
          element = element.querySelector("a:nth-child(1)");
          if (element != null) {
            temp = element.attributes["href"];
            if (temp?.startsWith("/Home/PublishGroup") == true) {
              subgroup = Subgroup(
                id: temp?.split("/").last.trim(),
                name: element.text.trim(),
              );
              subgroups.add(subgroup);
            }
          }
        }
        subgroupBangumi.subgroups = subgroups;
        records = [];
        element = tables.elementAt(i);
        elements = element.querySelectorAll("tbody > tr");
        for (final Element ele in elements) {
          record = RecordItem();
          element = ele.children[0];
          record.magnet =
              element.children[1].attributes['data-clipboard-text']?.trim() ??
                  "";
          element = element.children[0];
          temp = element.text;
          if (temp.isNotBlank) {
            temp = temp.trim().replaceAll("【", "[").replaceAll("】", "]");
            tempLowerCase = temp.toLowerCase();
            tags = LinkedHashSet();
            keywords.forEach((key, value) {
              if (tempLowerCase.contains(key)) {
                tags.add(value);
              }
            });
            record.title = temp;
            record.tags = tags.toList()..sort((a, b) => b.compareTo(a));
          }
          record.url = MikanUrl.BASE_URL + (element.attributes["href"] ?? "");
          record.size = ele.children[1].text.trim();
          temp = ele.children[2].text.trim();
          if (temp.isNotBlank &&
              RegExp(r"^\d{4}/\d{2}/\d{2}\s\d{2}:\d{2}$").hasMatch(temp)) {
            await Jiffy.locale("zh_cn");
            record.publishAt = Jiffy(temp, "yyyy/MM/dd HH:mm").yMMMdjm;
          } else {
            record.publishAt = temp;
          }
          record.torrent = MikanUrl.BASE_URL +
              (ele.children[3].children[0].attributes["href"]?.trim() ?? "");
          records.add(record);
        }
        subgroupBangumi.records = records;
        detail.subgroupBangumis.add(subgroupBangumi);
      }
    }
    return detail;
  }

  static Future<RecordDetail> parseRecordDetail(final Document document) async {
    final RecordDetail recordDetail = RecordDetail();
    recordDetail.id = document
            .querySelector(
                "#sk-container > div.pull-left.leftbar-container > div.leftbar-nav > button")
            ?.attributes["data-bangumiid"]
            ?.trim() ??
        "";
    recordDetail.cover = MikanUrl.BASE_URL +
        (document
                .querySelector(
                    "#sk-container > div.pull-left.leftbar-container > div.bangumi-poster")
                ?.attributes["style"]
                ?.split("'")
                .elementAt(1)
                .split("?")
                .elementAt(0)
                .trim() ??
            '');
    recordDetail.name = document
            .querySelector(
                "#sk-container > div.pull-left.leftbar-container > p.bangumi-title")
            ?.text
            .trim() ??
        "";
    String title = document
            .querySelector(
                "#sk-container > div.central-container > div.episode-header > p")
            ?.text
            .trim() ??
        "";
    final Set<String> tags = LinkedHashSet();
    if (title.isNotBlank) {
      title = title.trim().replaceAll("【", "[").replaceAll("】", "]");
      recordDetail.title = title;
      final String lowerCaseTitle = title.toLowerCase();
      keywords.forEach((key, value) {
        if (lowerCaseTitle.contains(key)) {
          tags.add(value);
        }
      });
      recordDetail.tags = tags.toList()..sort((a, b) => b.compareTo(a));
    }
    recordDetail.subscribed = document
            .querySelector(".subscribed-badge")
            ?.attributes["style"]
            ?.isNullOrBlank ??
        false;
    final more = document
        .querySelectorAll(
            "#sk-container > div.pull-left.leftbar-container > p.bangumi-info")
        .map((e) => e.text.split("："));
    final Map<String, String> map = {};
    more.forEach((element) {
      map[element[0].trim()] = element[1].trim();
    });
    recordDetail.more = map;
    String? temp;
    List<Element> elements = document.querySelectorAll(
        "#sk-container > div.pull-left.leftbar-container > div.leftbar-nav > a");
    elements.forEach((element) {
      temp = element.text.trim();
      if (temp == "下载种子") {
        recordDetail.torrent =
            MikanUrl.BASE_URL + (element.attributes["href"]?.trim() ?? "");
      } else if (temp == "磁力链接") {
        recordDetail.magnet = (element.attributes['href']?.trim() ?? "");
      }
    });
    final Element? element = document.querySelector(
        "#sk-container > div.central-container > div.episode-desc");
    element?.children.forEach((ele) {
      final style = ele.attributes['style']?.trim();
      if (style == "margin-top: -10px; margin-bottom: 10px;") {
        ele.remove();
      }
    });
    recordDetail.intro = element?.innerHtml.trim() ?? "";
    return recordDetail;
  }

  static Future<List<RecordItem>> parseBangumiMore(
    final Document document,
  ) async {
    final elements = document.querySelectorAll("tbody > tr");
    RecordItem record;
    Element element;
    List<RecordItem> records = [];
    String tempLowerCase;
    Set<String> tags;
    String temp;
    for (final Element ele in elements) {
      record = RecordItem();
      element = ele.children[0];
      record.magnet =
          element.children[1].attributes['data-clipboard-text']?.trim() ?? "";
      element = element.children[0];
      temp = element.text;
      if (temp.isNotBlank) {
        temp = temp.trim().replaceAll("【", "[").replaceAll("】", "]");
        tempLowerCase = temp.toLowerCase();
        tags = LinkedHashSet();
        keywords.forEach((key, value) {
          if (tempLowerCase.contains(key)) {
            tags.add(value);
          }
        });
        record.title = temp;
        record.tags = tags.toList()..sort((a, b) => b.compareTo(a));
      }
      record.url = MikanUrl.BASE_URL + (element.attributes["href"] ?? "");
      record.size = ele.children[1].text.trim();
      temp = ele.children[2].text.trim();
      if (temp.isNotBlank &&
          RegExp(r"^\d{4}/\d{2}/\d{2}\s\d{2}:\d{2}$").hasMatch(temp)) {
        await Jiffy.locale("zh_cn");
        record.publishAt = Jiffy(temp, "yyyy/MM/dd HH:mm").yMMMdjm;
      } else {
        record.publishAt = temp;
      }
      record.torrent = MikanUrl.BASE_URL +
          (ele.children[3].children[0].attributes["href"] ?? "");
      records.add(record);
    }
    return records;
  }

  static Future<List<Bangumi>> parseMySubscribed(
    final Document document,
  ) async {
    final List<Element> elements = document.querySelectorAll("li");
    Bangumi bangumi;
    Map<dynamic, String> attributes;
    List<Bangumi> bangumis = [];
    for (final Element ele in elements) {
      bangumi = Bangumi();
      attributes = ele.querySelector("span")?.attributes ?? {};
      bangumi.id = attributes["data-bangumiid"]?.trim() ?? "";
      bangumi.cover = MikanUrl.BASE_URL +
          (attributes["data-src"]?.split("?")[0].trim() ?? "");
      bangumi.grey = ele.querySelector("span.greyout") != null;
      bangumi.updateAt = ele.querySelector(".date-text")?.text.trim() ?? "";
      attributes = (ele.querySelector(".an-text") ??
                  ele.querySelector(".date-text[title]"))
              ?.attributes ??
          {};
      bangumi.name = attributes['title']?.trim() ?? "";
      bangumi.subscribed = ele.querySelector(".active") != null;
      bangumi.num =
          int.tryParse(ele.querySelector(".num-node")?.text.trim() ?? "0") ?? 0;
      bangumis.add(bangumi);
    }
    return bangumis;
  }
}
