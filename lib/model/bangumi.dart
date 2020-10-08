import 'dart:ui';

class Bangumi {
  // 番剧的id
  String id;

  // 更新时间
  String updateAt;

  // 更新的数量
  int num;

  // 标题
  String name;

  // 封面
  String cover;

  // 是否已订阅
  bool subscribed;

  bool grey;

  Size _coverSize;

  Size get coverSize => _coverSize;

  set coverSize(Size value) {
    _coverSize = value;
  }

  Bangumi({
    this.id,
    this.updateAt,
    this.num,
    this.name,
    this.cover,
    this.subscribed,
    this.grey,
  });
}
