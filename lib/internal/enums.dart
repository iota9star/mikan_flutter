class WeekSection {
  final String name;
  final String shortName;

  const WeekSection._(this.name, this.shortName);

  static final WeekSection mon = const WeekSection._("星期一", "月");
  static final WeekSection tue = const WeekSection._("星期二", "火");
  static final WeekSection wed = const WeekSection._("星期三", "水");
  static final WeekSection thu = const WeekSection._("星期四", "木");
  static final WeekSection fri = const WeekSection._("星期五", "金");
  static final WeekSection sat = const WeekSection._("星期六", "土");
  static final WeekSection sun = const WeekSection._("星期日", "日");
  static final WeekSection mv = const WeekSection._("剧场版", "剧");
  static final WeekSection ova = const WeekSection._("OVA", "O");
  static final List<WeekSection> values = [
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
