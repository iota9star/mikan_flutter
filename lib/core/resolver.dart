import 'dart:collection';

import 'package:html/dom.dart';
import 'package:mikan_flutter/core/caches.dart';
import 'package:mikan_flutter/core/consts.dart';
import 'package:mikan_flutter/ext/extension.dart';
import 'package:mikan_flutter/model/bangumi.dart';
import 'package:mikan_flutter/model/bangumi_details.dart';
import 'package:mikan_flutter/model/bangumi_home.dart';
import 'package:mikan_flutter/model/bangumi_row.dart';
import 'package:mikan_flutter/model/carousel.dart';
import 'package:mikan_flutter/model/index.dart';
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/model/search.dart';
import 'package:mikan_flutter/model/season.dart';
import 'package:mikan_flutter/model/subgroup.dart';
import 'package:mikan_flutter/model/subgroup_bangumi.dart';
import 'package:mikan_flutter/model/subgroup_gallery.dart';
import 'package:mikan_flutter/model/user.dart';
import 'package:mikan_flutter/model/year_season.dart';

class Resolver {
  static Future<List<BangumiRow>> parseSeason(final Document document) async {
    final List<Element> rowElements =
        document.querySelectorAll("div.sk-bangumi") ?? [];
    final List<BangumiRow> list = [];
    BangumiRow bangumiRow;
    Bangumi bangumi;
    List<Bangumi> bangumis;
    List<Element> bangumiElements;
    Map<dynamic, String> attributes;
    for (final Element rowEle in rowElements) {
      bangumiRow = BangumiRow();
      bangumiRow.name = rowEle.children[0].text.trim();
      bangumiElements = rowEle.querySelectorAll("li") ?? [];
      bangumis = [];
      for (final Element ele in bangumiElements) {
        bangumi = Bangumi();
        attributes = ele.querySelector("span").attributes;
        bangumi.id = attributes["data-bangumiid"];
        bangumi.cover =
            MikanUrl.BASE_URL + attributes["data-src"].split("?")[0];
        bangumi.grey = ele.querySelector("span.greyout") != null;
        bangumi.updateAt = ele.querySelector(".date-text").text.trim();
        attributes = (ele.querySelector(".an-text") ??
                ele.querySelector(".date-text[title]"))
            .attributes;
        bangumi.name = attributes['title'];
        bangumi.subscribed = ele.querySelector(".active") != null;
        bangumi.num =
            int.tryParse(ele.querySelector(".num-node")?.text ?? "0") ?? 0;
        bangumis.add(bangumi);
      }
      bangumiRow.bangumis = bangumis;
      list.add(bangumiRow);
    }
    return list;
  }

  static Future<List<RecordItem>> parseDay(final Document document) async {
    final List<Element> elements =
        document.querySelectorAll("#an-list-res .my-rss-item") ?? [];
    RecordItem recordItem;
    final List<RecordItem> list = [];
    Element element;
    String temp;
    for (final ele in elements) {
      recordItem = RecordItem();
      element = ele.querySelector("div.sk-col.rss-name > div > a");
      if (element != null) {
        recordItem.name = element.text.trim();
        temp = element.attributes['href'];
        if (temp.isNotBlank) {
          recordItem.id = temp.substring(14).split("#")[0];
        }
      }
      element = ele.querySelector("div.sk-col.rss-name > a:nth-child(2)");
      if (element != null) {
        temp = element.attributes['href'];
        if (temp.isNotBlank) {
          recordItem.torrent = MikanUrl.BASE_URL + temp;
        }
        recordItem.title =
            element.text.trim().replaceAll("【", "[").replaceAll("】", "]");
        temp = element.querySelector("span")?.text;
        if (temp.isNotBlank) {
          recordItem.size = temp.replaceAll("\[|\]", "");
        }
      }
      recordItem.magnet = ele
          .querySelector("div.sk-col.rss-name > a.rss-episode-name")
          ?.attributes
          ?.getOrNull('data-clipboard-text');
      recordItem.url = ele
          .querySelector("div.sk-col.rss-name > a:nth-child(4)")
          ?.attributes
          ?.getOrNull("href");
      recordItem.publishAt =
          ele.querySelector("div.sk-col.pull-right.publish-date")?.text?.trim();
      list.add(recordItem);
    }
    return list;
  }

  static Future<User> parseUser(final Document document) async {
    final String name =
        document.querySelector("#user-name .text-right")?.text?.trim();
    final String avatar = document
        ?.querySelector("#user-welcome #head-pic")
        ?.attributes
        ?.getOrNull("src");
    final String token = document
        .querySelector("#login input[name=__RequestVerificationToken]")
        ?.attributes
        ?.getOrNull("value");
    return User(
      name: name,
      avatar: avatar == null ? null : MikanUrl.BASE_URL + avatar,
      token: token,
    );
  }

  static Future<Search> parseSearch(final Document document) async {
    List<Element> eles = document.querySelectorAll(
            "div.leftbar-container .leftbar-item .subgroup-longname") ??
        [];
    final List<Subgroup> subgroups = [];
    String temp;
    Subgroup subgroup;
    for (final Element ele in eles) {
      temp = ele.attributes['data-subgroupid'];
      if (temp.isNotBlank) {
        subgroup = Subgroup();
        subgroup.id = temp;
        subgroup.name = ele.text.trim();
        subgroups.add(subgroup);
      }
    }
    eles = document.querySelectorAll("div.central-container > ul > li") ?? [];
    final List<Bangumi> bangumis = [];
    Bangumi bangumi;
    for (final Element ele in eles) {
      bangumi = Bangumi();
      temp = ele.querySelector("a").attributes['href'];
      bangumi.id = temp.replaceAll("/Home/Bangumi/", "");
      bangumi.cover = MikanUrl.BASE_URL +
          ele.querySelector("span").attributes["data-src"].split("?")[0];
      bangumi.name = ele.querySelector(".an-text").attributes['title'].trim();
      bangumis.add(bangumi);
    }
    eles = document.querySelectorAll("tr.js-search-results-row") ?? [];
    RecordItem recordItem;
    List<RecordItem> searchs = [];
    List<Element> elements;
    for (final Element ele in eles) {
      recordItem = RecordItem();
      elements = ele.querySelectorAll("td");
      recordItem.url =
          MikanUrl.BASE_URL + elements[0].children[0].attributes['href'];
      recordItem.title = elements[0]
          .children[0]
          .text
          .trim()
          .replaceAll("【", "[")
          .replaceAll("】", "]");
      recordItem.size = elements[1].text.trim();
      recordItem.publishAt = elements[2].text.trim();
      recordItem.magnet =
          elements[0].children[1].attributes["data-clipboard-text"];
      recordItem.torrent =
          MikanUrl.BASE_URL + elements[3].children[0].attributes["href"];
      searchs.add(recordItem);
    }
    return Search(bangumis: bangumis, subgroups: subgroups, searchs: searchs);
  }

  static Future<List<RecordItem>> parseList(final Document document) async {
    final List<Element> eles =
        document.querySelectorAll("#sk-body > table > tbody > tr") ?? [];
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
      elements = ele.children ?? [];
      record = RecordItem();
      record.publishAt = elements[0].text.trim();
      element = elements[1];
      tempElements = element.querySelectorAll("li");
      subgroups = [];
      if (tempElements != null && tempElements.length > 0) {
        for (Element ele in tempElements) {
          tempElement = ele.children[0];
          subgroup = Subgroup();
          temp = tempElement.attributes['href'];
          subgroup.id = temp.substring(19);
          subgroup.name = tempElement.text.trim();
          subgroups.add(subgroup);
        }
      } else if (element.children.length > 0) {
        tempElement = element.children[0];
        subgroup = Subgroup();
        temp = tempElement.attributes['href'];
        subgroup.id = temp.substring(19);
        subgroup.name = tempElement.text.trim();
        subgroups.add(subgroup);
      } else {
        subgroup = Subgroup();
        subgroup.name = element.text.trim();
        subgroups.add(subgroup);
      }
      record.groups = subgroups;
      tempElements = elements[2].children;
      tempElement = tempElements[0];
      temp = ("/" +
              tempElement.text
                  .replaceAll(RegExp("]\\s*\\[|\\[|]|】\\s*【|】|【"), "/") +
              "/")
          .replaceAll(RegExp("/\\s*/+"), "/");
      tags = LinkedHashSet();
      tempLowerCase = temp.toLowerCase();
      keywords.forEach((key, value) {
        if (tempLowerCase.contains(key)) {
          tags.add(value);
        }
      });
      record.tags = tags.toList()..sort((a, b) => a.compareTo(b));
      record.title = temp;
      record.url = MikanUrl.BASE_URL + tempElement.attributes['href'];
      record.magnet = tempElements[1].attributes['data-clipboard-text'];
      record.size = elements[3].text.trim();
      record.torrent =
          MikanUrl.BASE_URL + elements[4].children[0].attributes['href'];
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
    return Index(
      years: years,
      bangumiRows: bangumiRows,
      rss: rss,
      carousels: carousels,
      user: user,
    );
  }

  static Future<List<Carousel>> parseCarousel(final Document document) async {
    final List<Element> eles = document.querySelectorAll(
            "#myCarousel > div.carousel-inner > div.item.carousel-bg") ??
        [];
    final List<Carousel> carousels = [];
    Carousel carousel;
    String temp;
    for (final Element ele in eles) {
      carousel = Carousel();
      temp = ele.attributes['style'];
      carousel.cover = MikanUrl.BASE_URL + temp.split("'")[1];
      temp = ele.attributes["onclick"];
      temp = temp.split("'")[1];
      carousel.id = temp.substring(temp.lastIndexOf("/") + 1);
      carousels.add(carousel);
    }
    return carousels;
  }

  static Future<List<YearSeason>> parseYearSeason(
      final Document document) async {
    final List<Element> eles = document.querySelectorAll(
            "#sk-data-nav > div > ul.navbar-nav.date-select > li > ul > li") ??
        [];
    final String selected = document
        .querySelector("#sk-data-nav  .date-select  div.date-text")
        ?.text
        ?.trim();
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
        season = Season();
        element = e.children[0];
        attributes = element.attributes;
        season.year = attributes["data-year"];
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

  static Future<List<SubgroupGallery>> parseSubgroup(
      final Document document) async {
    final List<Element> eles = document.querySelectorAll(
        "#js-sort-wrapper > div.pubgroup-timeline-item[data-index]");
    List<SubgroupGallery> list = [];
    SubgroupGallery subgroupGallery;
    Bangumi bangumi;
    List<Bangumi> bangumis;
    List<Element> elements;
    Map attributes;
    for (final Element ele in eles) {
      subgroupGallery = SubgroupGallery();
      subgroupGallery.date = ele.querySelector(".pubgroup-date").text.trim();
      subgroupGallery.season =
          ele.querySelector(".pubgroup-season").text.trim();
      subgroupGallery.isCurrentSeason =
          ele.querySelector(".pubgroup-season.current-season") != null;
      elements = ele.querySelectorAll("li[data-bangumiid]") ?? [];
      bangumis = [];
      for (final Element e in elements) {
        bangumi = Bangumi();
        bangumi.id = e.attributes['data-bangumiid'];
        attributes = e.querySelector("div.an-info-group > a").attributes;
        bangumi.name = attributes['title'];
        bangumi.cover = MikanUrl.BASE_URL + attributes['href'];
        bangumi.subscribed = e.querySelector(".an-info-icon.active") != null;
        bangumi.cover = e
            .querySelector("span[data-bangumiid]")
            ?.attributes
            ?.getOrNull('data-src')
            ?.split("?")
            ?.elementAt(0);
        bangumis.add(bangumi);
      }
      subgroupGallery.bangumis = bangumis;
      list.add(subgroupGallery);
    }
    return list;
  }

  static Future<BangumiHome> parseBangumi(final Document document) async {
    final BangumiHome bangumiHome = BangumiHome();
    bangumiHome.id = document
        .querySelector(
            "#sk-container > div.pull-left.leftbar-container > p.bangumi-title > a")
        ?.attributes
        ?.getOrNull("href")
        ?.split("=")
        ?.getOrNull(1);
    bangumiHome.cover = MikanUrl.BASE_URL +
            document
                .querySelector(
                    "#sk-container > div.pull-left.leftbar-container > div.bangumi-poster")
                ?.attributes
                ?.getOrNull("style")
                ?.split("'")
                ?.elementAt(1)
                ?.split("?")
                ?.elementAt(0) ??
        '';
    bangumiHome.name = document
        .querySelector(
        "#sk-container > div.pull-left.leftbar-container > p.bangumi-title")
        ?.text
        ?.trim();
    String _intro = document
        .querySelector("#sk-container > div.central-container > p")
        ?.text
        ?.trim();
    if (_intro.isNotBlank) {
      _intro = "\u3000\u3000" + _intro.replaceAll("\n", "\n\u3000\u3000");
    }
    bangumiHome.intro = _intro;
    bangumiHome.subscribed = document
        .querySelector(".subscribed-badge")
        ?.attributes
        ?.getOrNull("style")
        ?.isNullOrBlank ??
        false;
    final more = document
        .querySelectorAll(
        "#sk-container > div.pull-left.leftbar-container > p.bangumi-info")
        ?.map((e) => e.text.split("：")) ??
        [];
    final Map<String, String> map = {};
    more.forEach((element) {
      map[element[0].trim()] = element[1].trim();
    });
    bangumiHome.more = map;
    final List<Element> tables = document
        .querySelectorAll("#sk-container > div.central-container > table");
    final List<Element> subs = document.querySelectorAll(".subgroup-text");
    bangumiHome.subgroupBangumis = [];
    SubgroupBangumi subgroupBangumi;
    Element element;
    List<Element> elements;
    String temp;
    List<RecordItem> records;
    RecordItem recordItem;
    if (tables.length == subs.length) {
      for (int i = 0; i < tables.length; i++) {
        subgroupBangumi = SubgroupBangumi();
        element = subs.elementAt(i);
        temp = element.children[0].attributes["href"];
        subgroupBangumi.subgroupId = temp.substring(temp.lastIndexOf("/") + 1);
        temp = element.nodes.getOrNull(0)?.text?.trim();
        subgroupBangumi.name = temp.isNullOrBlank
            ? element.children.getOrNull(0)?.text?.trim()
            : temp;
        subgroupBangumi.subscribed =
            element?.querySelector(".subscribed")?.text?.trim() == "已订阅";
        records = [];
        element = tables.elementAt(i);
        elements = element.querySelectorAll("tbody > tr");
        for (final Element ele in elements) {
          recordItem = RecordItem();
          element = ele.children[0];
          recordItem.magnet =
              element.children[1].attributes['data-clipboard-text'];
          element = element.children[0];
          recordItem.title = element.text.trim();
          recordItem.url = MikanUrl.BASE_URL + element.attributes["href"];
          recordItem.size = ele.children[1].text.trim();
          recordItem.publishAt = ele.children[2].text.trim();
          recordItem.torrent = MikanUrl.BASE_URL +
              ele.children[3].children[0].attributes["href"];
          records.add(recordItem);
        }
        subgroupBangumi.records = records;
        bangumiHome.subgroupBangumis.add(subgroupBangumi);
      }
    }
    return bangumiHome;
  }

  static Future<BangumiDetails> parseDetails(final Document document) async {
    final BangumiDetails bangumiDetails = BangumiDetails();
    bangumiDetails.id = document
        .querySelector(
            "#sk-container > div.pull-left.leftbar-container > div.leftbar-nav > button")
        ?.attributes
        ?.getOrNull("data-bangumiid");
    bangumiDetails.cover = MikanUrl.BASE_URL +
            document
                .querySelector(
                    "#sk-container > div.pull-left.leftbar-container > div.bangumi-poster")
                ?.attributes
                ?.getOrNull("style")
                ?.split("'")
                ?.elementAt(1)
                ?.split("?")
                ?.elementAt(0) ??
        '';
    bangumiDetails.name = document
        .querySelector(
            "#sk-container > div.pull-left.leftbar-container > p.bangumi-title")
        ?.text
        ?.trim();
    String title = document
        .querySelector(
            "#sk-container > div.central-container > div.episode-header > p")
        ?.text
        ?.trim();
    final Set<String> tags = LinkedHashSet();
    if (title.isNotBlank) {
      title = ("/" +
              title.replaceAll(RegExp("]\\s*\\[|\\[|]|】\\s*【|】|【"), "/") +
              "/")
          .replaceAll(RegExp("/\\s*/+"), "/");
      bangumiDetails.title = title;
      final String lowerCaseTitle = title.toLowerCase();
      keywords.forEach((key, value) {
        if (lowerCaseTitle.contains(key)) {
          tags.add(value);
        }
      });
      bangumiDetails.tags = tags.toList()..sort((a, b) => a.compareTo(b));
    }
    bangumiDetails.subscribed = document
            .querySelector(".subscribed-badge")
            ?.attributes
            ?.getOrNull("style")
            ?.isNullOrBlank ??
        false;
    final more = document
            .querySelectorAll(
                "#sk-container > div.pull-left.leftbar-container > p.bangumi-info")
            ?.map((e) => e.text.split("：")) ??
        [];
    final Map<String, String> map = {};
    more.forEach((element) {
      map[element[0].trim()] = element[1].trim();
    });
    bangumiDetails.more = map;
    String temp;
    List<Element> elements = document.querySelectorAll(
        "#sk-container > div.pull-left.leftbar-container > div.leftbar-nav > a");
    elements.forEach((element) {
      temp = element.text;
      if (temp == "下载种子") {
        bangumiDetails.torrent = MikanUrl.BASE_URL + element.attributes["href"];
      } else if (temp == "磁力链接") {
        bangumiDetails.magnet = element.attributes['href'];
      }
    });
    final Element element = document.querySelector(
        "#sk-container > div.central-container > div.episode-desc");
    element.children.forEach((ele) {
      if (ele.attributes['style'].isNotBlank) {
        ele.remove();
      }
    });
    bangumiDetails.intro = element.innerHtml.trim();
    return bangumiDetails;
  }
}
