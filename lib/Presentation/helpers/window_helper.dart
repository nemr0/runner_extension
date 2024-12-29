
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, WidgetBuilder;
import 'package:macos_ui/macos_ui.dart';
import 'package:runner_extension/Presentation/shared_widgets/logo.dart';
import 'package:runner_extension/main.dart';
import 'package:window_manager/window_manager.dart';

class WindowHelper {
  WindowHelper._privateConstructor();

  static final WindowHelper _instance = WindowHelper._privateConstructor();

  static WindowHelper get instance => _instance;
  Size size = WindowSize.initial;

  Future<void> init() async {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = WindowOptions(
        size: WindowSize.initial,
        minimumSize: WindowSize.min,
        maximumSize: WindowSize.max,
        alwaysOnTop: true,
        fullScreen: false,
        center: false,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.hidden,
        windowButtonVisibility: true);
     windowManager.waitUntilReadyToShow(windowOptions, () async {
      windowManager.addListener(_WindowListener());
      windowManager.setVisibleOnAllWorkspaces(true);
       windowManager.setPosition(Offset(0, 0),animate: true);
      await windowManager.show();
      // await windowManager.focus();
      windowManager.setPreventClose(true);
    });
  }

  setSize(Size size) async => await windowManager.setSize(size, animate: true);

  Future<T?> showDialog<T>(WidgetBuilder builder) async {
      final currentSize = size;
      bool willChangeSize =
          currentSize.height < WindowSize.dialogShown.height ||
              currentSize.width < WindowSize.dialogShown.width;
      if (willChangeSize) {
        await setSize(WindowSize.dialogShown);
        await Future.delayed(Duration(milliseconds: 300));
      }
      final result = await showCupertinoModalPopup(
          context: navigationKey.currentContext!, builder: builder);

      if (willChangeSize) {
        await Future.delayed(Duration(milliseconds: 300));
        await setSize(currentSize);
      }
      return result;

  }
}

class _WindowListener extends WindowListener {
  @override
  onWindowResized() async {
    WindowHelper.instance.size = await windowManager.getSize();
  }

  @override
  void onWindowClose() {
    WindowHelper.instance.showDialog(
      (context) => MacosAlertDialog(
        appIcon: Logo(),
        title: Text("Exit"),
        message: Text('Are you sure you want to close this window?'),
        secondaryButton: PushButton(
          controlSize: ControlSize.large,
          child: Text('Yes'),
          onPressed: ()  {
            Navigator.of(context).pop();
             windowManager.destroy();
          },
        ),
        primaryButton:PushButton(
          controlSize: ControlSize.large,
          onPressed: () => Navigator.pop(context),
          secondary: true,
          child: Text('No'),
        ) ,
      ),
    );
    super.onWindowClose();
  }
}

class WindowSize {
  static const max = Size(600, 1000);
  static const mid = Size(600, 500);
  static const min = Size(400, 100);
  static const initial = Size(400, 100);
  static const dialogShown = Size(400, 500);
}
