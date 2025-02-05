library preview;

import 'package:flutter/material.dart';
import 'package:preview/src/controls.dart';
import 'package:preview/src/frame/frame.dart';
import 'package:preview/src/persist.dart';
import 'package:preview/src/resizable.dart';
import 'package:preview/src/screenshot.dart';

import 'src/utils.dart';

export 'src/assets/image.dart';
export 'src/frame/frame.dart';
export 'src/frame/frames.dart';
export 'src/preview_page.dart';
export 'src/resizable.dart';
export 'src/screenshot.dart';

class Preview extends StatelessWidget {
  final Widget child;
  final double? height;
  final double? width;
  final BoxConstraints? constraints;
  final FrameData? frame;
  final ThemeData? theme;
  final UpdateMode mode;
  final ScreenshotSettings? screenshotSettings;

  Preview({
    super.key,
    required this.child,
    this.height,
    this.width,
    this.constraints,
    this.frame,
    this.theme,
    this.mode = UpdateMode.hotRestart,
    this.screenshotSettings,
  }) : assert(debugAssertPreviewModeRequired(Preview));

  String get name => child.runtimeType.toString();

  @override
  Widget build(BuildContext context) {
    Widget result =
        (frame != null ? Frame(frame: frame!, child: child) : child);

    return Container(
      constraints: constraints,
      height: height,
      width: width,
      child: Theme(
        data: theme ?? Theme.of(context),
        child: result,
      ),
    );
  }
}

mixin Previewer on StatelessWidget {
  Widget build(BuildContext context);

  String? get title => null;
}

abstract class PreviewProvider extends StatelessWidget with Previewer {
  List<Preview> get previews;

  PreviewProvider() : assert(debugAssertPreviewModeRequired(PreviewProvider));

  Widget build(BuildContext context) {
    return Scrollbar(
      child: Center(
        child: SingleChildScrollView(
            child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: previews
                .map<Widget>((Preview e) => _Preview(
                      child: e,
                      updateMode: e.mode,
                    ))
                .addInBetween(SizedBox(height: 20))
                .toList(),
          ),
        )),
      ),
    );
  }
}

abstract class ResizablePreviewProvider extends StatelessWidget with Previewer {
  Preview get preview;

  ResizablePreviewProvider()
      : assert(debugAssertPreviewModeRequired(ResizablePreviewProvider));

  @override
  Widget build(BuildContext context) {
    return _Preview(resizable: true, child: preview, updateMode: preview.mode);
  }
}

enum UpdateMode { hotReload, hotRestart }

class _Preview extends StatefulWidget {
  final Preview child;
  final bool resizable;

  final UpdateMode updateMode;

  const _Preview({
    super.key,
    required this.child,
    this.resizable = false,
    this.updateMode = UpdateMode.hotRestart,
  });

  @override
  _PreviewState createState() => _PreviewState();
}

class _PreviewState extends State<_Preview> {
  late PersistController controller;
  late ScreenshotController screenshotController;

  @override
  void initState() {
    controller = PersistController();
    screenshotController = ScreenshotController();
    ScreenshotSettings screenshotSettings =
        widget.child.screenshotSettings ?? ScreenshotSettings();

    if (screenshotSettings.filename == null) {
      screenshotSettings =
          screenshotSettings.copyWith(filename: widget.child.name + '.png');
    }
    screenshotController.settings = screenshotSettings;
    controller.isHotRestart = widget.updateMode == UpdateMode.hotRestart;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final preview = Persist(
      controller: controller,
      child: Screenshottable(
        child: widget.child,
        controller: screenshotController,
      ),
    );

    if (widget.resizable) {
      return OnHover(
          child: widget.child,
          builder: (context, hover, child) {
            final shouldDisplay = hover | !controller.isHotRestart;
            return ResizableWidget(
              child: preview,
              trailing: AnimatedOpacity(
                opacity: shouldDisplay ? 1 : 0,
                duration: Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: !shouldDisplay,
                  child: PreviewControls(
                    controller: controller,
                    screenshotController: screenshotController,
                  ),
                ),
              ),
            );
          });
    }

    return OnHover(
      child: widget.child,
      builder: (context, hover, child) {
        final shouldDisplay = hover | !controller.isHotRestart;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(width: 32),
            Flexible(
              child: preview,
            ),
            AnimatedOpacity(
              opacity: shouldDisplay ? 1 : 0,
              duration: Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: !shouldDisplay,
                child: PreviewControls(
                  controller: controller,
                  screenshotController: screenshotController,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void didUpdateWidget(_Preview oldWidget) {
    if (oldWidget.updateMode != widget.updateMode) {
      final mode = widget.updateMode ?? UpdateMode.hotRestart;
      controller.isHotRestart = mode == UpdateMode.hotRestart;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
