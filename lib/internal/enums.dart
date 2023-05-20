enum WeekSection {
  mon('星期一', '月'),
  tue('星期二', '火'),
  wed('星期三', '水'),
  thu('星期四', '木'),
  fri('星期五', '金'),
  sat('星期六', '土'),
  sun('星期日', '日'),
  mv('剧场版', '剧'),
  ova('OVA', 'O'),
  ;

  const WeekSection(this.name, this.shortName);

  final String name;
  final String shortName;

  static WeekSection? getByName(String name) {
    return values.firstWhere((element) => element.name == name);
  }
}
