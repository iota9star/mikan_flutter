import 'package:flutter/material.dart';
import 'package:mikan_flutter/core/repo.dart';
import 'package:mikan_flutter/ext/extension.dart';
import 'package:mikan_flutter/model/bangumi_home.dart';
import 'package:mikan_flutter/providers/models/base_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class BangumiHomeModel extends BaseModel {
  final String id;

  bool _loading = false;

  bool get loading => _loading;

  BangumiHome _bangumiHome;

  BangumiHome get bangumiHome => _bangumiHome;

  final PanelController _panelController = PanelController();
  TabController _tabController;
  List<RefreshController> _refreshControllers;

  TabController get tabController => _tabController;

  PanelController get panelController => _panelController;

  List<RefreshController> get refreshControllers => _refreshControllers;

  double _cropping = 1.0;

  double get cropping => _cropping;
  String _selectTabFlag;

  String get selectTabFlag => _selectTabFlag;

  set selectTabFlag(String value) {
    _selectTabFlag = value;
  }

  set cropping(double value) {
    _cropping = value;
    notifyListeners();
  }

  BangumiHomeModel(this.id, vsync) {
    this._load(vsync);
  }

  _load(final TickerProvider vsync) {
    this._loading = true;
    Repo.bangumi(this.id).then((resp) {
      if (resp.success) {
        _bangumiHome = resp.data;
        _tabController = TabController(
          length: _bangumiHome?.subgroupBangumis?.length ?? 0,
          vsync: vsync,
        );
        _refreshControllers = List.generate(
            _bangumiHome?.subgroupBangumis?.length ?? 0,
                (index) => RefreshController());
      } else {
        resp.msg.toast();
      }
    }).whenComplete(() {
      this._loading = false;
      notifyListeners();
    });
  }
}
