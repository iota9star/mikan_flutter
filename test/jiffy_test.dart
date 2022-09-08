import 'package:flutter_test/flutter_test.dart';
import 'package:jiffy/jiffy.dart';

main() {
  group("test jiffy", () {
    test("format", ()async {
      await Jiffy.locale("zh_cn");
      var jiffy = Jiffy([2022,6,19]);
      print(jiffy.yQQQ);
      print(jiffy.yQQQQ);
      print(jiffy.yMMMMEEEEd);
      print(jiffy.yMMMMEEEEdjm);
      print(jiffy.yMEd);
      print(jiffy.yMMMd);
      print(jiffy.yMMMdjm);
      print(jiffy.yMMMEdjm);
    });
  });
}
