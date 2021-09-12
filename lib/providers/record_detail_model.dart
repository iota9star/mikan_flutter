import 'dart:ui';

import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/http.dart';
import 'package:mikan_flutter/internal/image_provider.dart';
import 'package:mikan_flutter/internal/repo.dart';
import 'package:mikan_flutter/model/record_details.dart';
import 'package:mikan_flutter/providers/base_model.dart';
import 'package:palette_generator/palette_generator.dart';

class RecordDetailModel extends CancelableBaseModel {
  final String url;
  bool _loading = false;

  Size? coverSize;

  bool get loading => _loading;

  RecordDetail? _recordDetail;

  RecordDetail? get recordDetail => _recordDetail;

  RecordDetailModel(this.url) {
    refresh();
  }

  Color? _coverMainColor;

  Color? get coverMainColor => _coverMainColor;

  _loadCoverMainColor() {
    if (_recordDetail?.cover.isNullOrBlank == true) return;
    PaletteGenerator.fromImageProvider(
      FastCacheImage(_recordDetail!.cover),
      maximumColorCount: 3,
      targets: [
        PaletteTarget.lightVibrant,
        PaletteTarget.vibrant,
      ],
    ).then((value) {
      _coverMainColor = value.lightVibrantColor?.color ??
          value.vibrantColor?.color ??
          value.colors.getOrNull(0);
      if (_coverMainColor != null) {
        notifyListeners();
      }
    });
  }

  refresh() async {
    if (_loading) return;
    _loading = true;
    final Resp resp = await (this + Repo.details(url));
    _loading = false;
    if (resp.success) {
      _recordDetail = resp.data;
      _loadCoverMainColor();
    } else {
      "获取详情失败：${resp.msg}".toast();
    }
    notifyListeners();
  }

  subscribeChanged() {
    notifyListeners();
  }
}
