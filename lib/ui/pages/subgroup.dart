import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
@FFArgumentImport()
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../internal/extension.dart';
import '../../model/season_gallery.dart';
@FFArgumentImport()
import '../../model/subgroup.dart';
import '../../providers/op_model.dart';
import '../../providers/subgroup_model.dart';
import '../../topvars.dart';
import '../../widget/sliver_pinned_header.dart';
import '../fragments/bangumi_sliver_grid.dart';

@FFRoute(name: '/subgroup')
@immutable
class SubgroupPage extends StatelessWidget {
  const SubgroupPage({super.key, required this.subgroup});

  final Subgroup subgroup;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return AnnotatedRegion(
      value: context.fitSystemUiOverlayStyle,
      child: ChangeNotifierProvider(
        create: (_) => SubgroupModel(subgroup),
        child: Builder(
          builder: (context) {
            final subgroupModel =
                Provider.of<SubgroupModel>(context, listen: false);
            return Scaffold(
              body: Selector<SubgroupModel, List<SeasonGallery>>(
                selector: (_, model) => model.galleries,
                shouldRebuild: (pre, next) => pre.ne(next),
                builder: (context, galleries, __) {
                  return EasyRefresh(
                    refreshOnStart: true,
                    onRefresh: subgroupModel.refresh,
                    header: defaultHeader,
                    child: CustomScrollView(
                      slivers: [
                        SliverPinnedAppBar(title: subgroup.name),
                        if (galleries.isNotEmpty)
                          ...List.generate(galleries.length, (index) {
                            final gallery = galleries[index];
                            return _buildList(context, theme, gallery);
                          }),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    ThemeData theme,
    SeasonGallery gallery,
  ) {
    return MultiSliver(
      pushPinnedChildren: true,
      children: <Widget>[
        _buildYearSeasonSection(theme, gallery.title),
        BangumiSliverGridFragment(
          flag: gallery.title,
          bangumis: gallery.bangumis,
          handleSubscribe: (bangumi, flag) {
            context.read<OpModel>().subscribeBangumi(
              bangumi.id,
              bangumi.subscribed,
              onSuccess: () {
                bangumi.subscribed = !bangumi.subscribed;
                context.read<OpModel>().subscribeChanged(flag);
              },
              onError: (msg) {
                '订阅失败：$msg'.toast();
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildYearSeasonSection(ThemeData theme, String section) {
    return SliverPinnedHeader(
      child: Transform.translate(
        offset: offsetY_1,
        child: Container(
          padding: edgeH24,
          height: 48.0,
          color: theme.colorScheme.background,
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            section,
            style: theme.textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}
