import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';

void getTitle() {
  final shouldSkip = kIsWeb
      ? false
      : ![
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

  final String getTitleTest = '''
        <!DOCTYPE html><html>
        <head><title>Some title</title>
        </head>
        <body>
        </body>
        </html>
      ''';
  final String getTitleTestBase64 =
      base64Encode(const Utf8Encoder().convert(getTitleTest));

  var url = !kIsWeb
      ? Uri.parse('data:text/html;charset=utf-8;base64,$getTitleTestBase64')
      : TEST_WEB_PLATFORM_URL_1;
  var expectedValue = !kIsWeb ? 'Some title' : 'page';

  testWidgets('getTitle', (WidgetTester tester) async {
    final Completer<void> pageStarted = Completer<void>();
    final Completer<void> pageLoaded = Completer<void>();
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          initialUrlRequest: URLRequest(url: url),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStart: (controller, url) {
            pageStarted.complete();
          },
          onLoadStop: (controller, url) {
            pageLoaded.complete();
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
    await pageStarted.future;
    await pageLoaded.future;

    final String? title = await controller.getTitle();
    expect(title, expectedValue);
  }, skip: shouldSkip);
}
