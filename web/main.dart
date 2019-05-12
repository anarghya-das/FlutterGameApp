import 'package:flutter_web_ui/ui.dart' as ui;

import 'package:guess_number/main.dart' as app;

main() async {
  await ui.webOnlyInitializePlatform();
  app.main();
}
