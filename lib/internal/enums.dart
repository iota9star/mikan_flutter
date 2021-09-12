class WeekSection {
  final String name;
  final String shortName;

  const WeekSection._(this.name, this.shortName);

  static const WeekSection mon = WeekSection._("星期一", "月");
  static const WeekSection tue = WeekSection._("星期二", "火");
  static const WeekSection wed = WeekSection._("星期三", "水");
  static const WeekSection thu = WeekSection._("星期四", "木");
  static const WeekSection fri = WeekSection._("星期五", "金");
  static const WeekSection sat = WeekSection._("星期六", "土");
  static const WeekSection sun = WeekSection._("星期日", "日");
  static const WeekSection mv = WeekSection._("剧场版", "剧");
  static const WeekSection ova = WeekSection._("OVA", "O");
  static const List<WeekSection> values = [
    mon,
    tue,
    wed,
    thu,
    fri,
    sat,
    sun,
    mv,
    ova,
  ];

  static WeekSection? getByName(final String name) {
    return values.firstWhere((element) => element.name == name);
  }
}
