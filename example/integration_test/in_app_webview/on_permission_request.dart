import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';

void onPermissionRequest() {
  final shouldSkip = kIsWeb
      ? true
      : ![
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

  var expectedValue = [];
  expectedValue = [PermissionResourceType.CAMERA];

  testWidgets('onPermissionRequest', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();
    final Completer<List<PermissionResourceType>> onPermissionRequestCompleter =
        Completer<List<PermissionResourceType>>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: TEST_PERMISSION_SITE),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            pageLoaded.complete();
          },
          onPermissionRequest:
              (controller, PermissionRequest permissionRequest) async {
            onPermissionRequestCompleter.complete(permissionRequest.resources);
            return PermissionResponse(
                resources: permissionRequest.resources,
                action: PermissionResponseAction.GRANT);
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;
    await controller.evaluateJavascript(
        source: "document.querySelector('#camera').click();");
    await tester.pump();
    final List<PermissionResourceType> resources =
        await onPermissionRequestCompleter.future;

    expect(listEquals(resources, expectedValue), true);
  }, skip: shouldSkip);
}
