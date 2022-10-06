import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/delegate.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:mikan_flutter/widget/sliver_pinned_header.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

@FFRoute(
  name: "license",
  routeName: "/license",
)
@immutable
class LicenseList extends StatelessWidget {
  LicenseList({Key? key}) : super(key: key);
  final Future<_LicenseData> _licenses = LicenseRegistry.licenses
      .fold<_LicenseData>(
        _LicenseData(),
        (_LicenseData prev, LicenseEntry license) => prev..addLicense(license),
      )
      .then((_LicenseData licenseData) => licenseData..sortPackages());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnnotatedRegion(
      value: context.fitSystemUiOverlayStyle,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            const SliverPinnedTitleHeader(title: "开源协议"),
            FutureBuilder<_LicenseData>(
              future: _licenses,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Container(
                        height: 120.0,
                        width: 120.0,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                              "assets/mikan.png",
                            ),
                            colorFilter: ColorFilter.mode(
                              Colors.grey,
                              BlendMode.color,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                  case ConnectionState.active:
                    return SliverFillRemaining(
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: theme.secondary,
                          ),
                        ),
                      ),
                    );
                  case ConnectionState.done:
                    final data = snapshot.data!;
                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      sliver: SliverWaterfallFlow(
                        delegate: SliverChildBuilderDelegate(
                          (_, index) {
                            final String packageName = data.packages[index];
                            final List<int> bindings =
                                data.packageLicenseBindings[packageName]!;
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    Routes.licenseDetail.name,
                                    arguments: Routes.licenseDetail.d(
                                      packageName: packageName,
                                      licenseEntries: bindings
                                          .map((int i) => data.licenses[i])
                                          .toList(growable: false),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: theme.backgroundColor,
                                    borderRadius: borderRadius16,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        packageName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0,
                                          height: 1.25,
                                          fontFamily: "mono",
                                        ),
                                      ),
                                      sizedBoxH8,
                                      Text(
                                        "${bindings.length}条协议",
                                        style: const TextStyle(
                                          fontFamily: "mono",
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: data.packages.length,
                        ),
                        gridDelegate:
                            const SliverWaterfallFlowDelegateWithMinCrossAxisExtent(
                          crossAxisSpacing: 12.0,
                          mainAxisSpacing: 12.0,
                          minCrossAxisExtent: 240.0,
                        ),
                      ),
                    );
                }
              },
            ),
            SliverToBoxAdapter(
              child: Center(
                  child: Padding(
                padding: EdgeInsets.only(
                  top: 24.0,
                  bottom: 24.0 + Screen.navBarHeight,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      "assets/mikan.png",
                      width: 36.0,
                    ),
                    sizedBoxW12,
                    const Text(
                      "❤",
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.red,
                      ),
                    ),
                    sizedBoxW12,
                    const FlutterLogo(
                      size: 32.0,
                    ),
                  ],
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }
}

class _LicenseData {
  final List<LicenseEntry> licenses = <LicenseEntry>[];
  final Map<String, List<int>> packageLicenseBindings = <String, List<int>>{};
  final List<String> packages = <String>[];

  // Special treatment for the first package since it should be the package
  // for delivered application.
  String? firstPackage;

  void addLicense(LicenseEntry entry) {
    // Before the license can be added, we must first record the packages to
    // which it belongs.
    for (final String package in entry.packages) {
      _addPackage(package);
      // Bind this license to the package using the next index value. This
      // creates a contract that this license must be inserted at this same
      // index value.
      packageLicenseBindings[package]!.add(licenses.length);
    }
    licenses.add(entry); // Completion of the contract above.
  }

  /// Add a package and initialize package license binding. This is a no-op if
  /// the package has been seen before.
  void _addPackage(String package) {
    if (!packageLicenseBindings.containsKey(package)) {
      packageLicenseBindings[package] = <int>[];
      firstPackage ??= package;
      packages.add(package);
    }
  }

  /// Sort the packages using some comparison method, or by the default manner,
  /// which is to put the application package first, followed by every other
  /// package in case-insensitive alphabetical order.
  void sortPackages([int Function(String a, String b)? compare]) {
    packages.sort(compare ??
        (String a, String b) {
          // Based on how LicenseRegistry currently behaves, the first package
          // returned is the end user application license. This should be
          // presented first in the list. So here we make sure that first package
          // remains at the front regardless of alphabetical sorting.
          if (a == firstPackage) {
            return -1;
          }
          if (b == firstPackage) {
            return 1;
          }
          return a.toLowerCase().compareTo(b.toLowerCase());
        });
  }
}
