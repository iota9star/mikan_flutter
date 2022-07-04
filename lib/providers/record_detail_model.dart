import 'dart:ui';

import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/http.dart';
import 'package:mikan_flutter/internal/image_provider.dart';
import 'package:mikan_flutter/internal/repo.dart';
import 'package:mikan_flutter/model/record_details.dart';
import 'package:mikan_flutter/providers/base_model.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RecordDetailModel extends CancelableBaseModel {
  final String url;

  Size? coverSize;

  RecordDetail? _recordDetail;

  RecordDetail? get recordDetail => _recordDetail;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  RefreshController get refreshController => _refreshController;

  RecordDetailModel(this.url);

  Color? _coverMainColor;

  Color? get coverMainColor => _coverMainColor;

  _loadCoverMainColor() {
    final cover = _recordDetail?.cover;
    if (cover.isNullOrBlank == true ||
        cover!.endsWith("noimageavailble_icon.png")) return;
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
    final Resp resp = await (this + Repo.details(url));
    _refreshController.refreshCompleted();
    if (resp.success) {
      _recordDetail = resp.data;
      "加载成功".toast();
      if (_coverMainColor == null) _loadCoverMainColor();
    } else {
      "获取详情失败：${resp.msg}".toast();
    }
    notifyListeners();
  }

  subscribeChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}
