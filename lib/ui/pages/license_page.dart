import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/topvars.dart';

@FFRoute(
  name: "license",
  routeName: "/license",
)
@immutable
class LicenseList extends StatelessWidget {
  const LicenseList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          StreamBuilder<LicenseEntry>(
            stream: LicenseRegistry.licenses,
            builder: (context, snapshot) {
              switch(snapshot.connectionState){

                case ConnectionState.none:
                  // TODO: Handle this case.
                  break;
                case ConnectionState.waiting:
                  // TODO: Handle this case.
                  break;
                case ConnectionState.active:
                  // TODO: Handle this case.
                  break;
                case ConnectionState.done:
                  // TODO: Handle this case.
                  break;
              }
              return emptySliverToBoxAdapter;
            },
          ),
        ],
      ),
    );
  }
}
