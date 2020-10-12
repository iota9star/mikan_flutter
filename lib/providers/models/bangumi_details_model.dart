import 'package:mikan_flutter/core/repo.dart';
import 'package:mikan_flutter/ext/extension.dart';
import 'package:mikan_flutter/model/bangumi_home.dart';
import 'package:mikan_flutter/model/subgroup_bangumi.dart';
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

  final RefreshController _refreshController = RefreshController();

  PanelController get panelController => _panelController;

  RefreshController get refreshController => _refreshController;

  BangumiHomeModel(this.id) {
    this._loadBangumiDetails();
  }

  SubgroupBangumi _subgroupBangumi;

  SubgroupBangumi get subgroupBangumi => _subgroupBangumi;

  set selectedSubgroupId(String value) {
    _subgroupBangumi = _bangumiHome.subgroupBangumis.firstWhere(
        (element) => element.subgroupId == value,
        orElse: () => null);
    if (_refreshController.headerStatus != RefreshStatus.completed) {
      _refreshController.loadComplete();
    }
    _refreshController.resetNoData();
    notifyListeners();
    _panelController.animatePanelToPosition(
      1.0,
      duration: Duration(
        milliseconds: 240,
      ),
    );
  }

  loadSubgroupList() {
    if (this._subgroupBangumi.records.length < 10) {
      return _refreshController.loadNoData();
    }
    Repo.bangumiMore(
      this.id,
      this._subgroupBangumi.subgroupId,
      this._subgroupBangumi.records.length + 20,
    ).then((resp) {
      if (resp.success) {
        if (this._subgroupBangumi.records.length == resp.data.length) {
          _refreshController.loadNoData();
        }
        this._subgroupBangumi.records = resp.data;
      } else {
        _refreshController.loadFailed();
        resp.msg.toast();
      }
    }).whenComplete(() {
      if (_refreshController.headerStatus != RefreshStatus.completed) {
        _refreshController.loadComplete();
      }
      this.notifyListeners();
    });
  }

  _loadBangumiDetails() {
    this._loading = true;
    Repo.bangumi(this.id).then((resp) {
      if (resp.success) {
        _bangumiHome = resp.data;
      } else {
        resp.msg.toast();
      }
    }).whenComplete(() {
      this._loading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}
