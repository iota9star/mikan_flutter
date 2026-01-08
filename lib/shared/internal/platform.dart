import 'dart:io';

final isMobile = Platform.isIOS || Platform.isAndroid;
final isSupportFirebase = isMobile || Platform.isMacOS;
final isDesktop = Platform.isMacOS || Platform.isLinux || Platform.isWindows;
