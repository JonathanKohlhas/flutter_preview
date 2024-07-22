import 'package:device_frame/device_frame.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'frame_painter.dart' as frame_painter;

export 'package:device_frame/device_frame.dart' show DeviceFrameStyle;

const previewAppBuilder = kDebugMode ? Frame._appBuilder : null;

class FrameData {
  final DeviceFrameStyle? style;
  final Size? size;
  final double? pixelRatio;
  final EdgeInsets landscapeSafeArea;
  final EdgeInsets portraitSafeArea;
  final TargetPlatform platform;
  final Orientation? orientation;

  final bool isKeyboardVisible;
  final Duration keyboardTransitionDuration;
  final EdgeInsets bodyPadding;

  final BorderRadius edgeRadius;
  final BorderRadius screenRadius;

  const FrameData({
    this.size,
    this.pixelRatio,
    this.landscapeSafeArea = const EdgeInsets.all(0),
    this.portraitSafeArea = const EdgeInsets.all(0),
    this.bodyPadding = const EdgeInsets.all(38),
    this.edgeRadius = const BorderRadius.all(Radius.circular(20)),
    this.screenRadius = const BorderRadius.all(Radius.circular(8)),
    required this.platform,
    this.orientation,
    this.isKeyboardVisible = false,
    this.keyboardTransitionDuration = const Duration(milliseconds: 500),
    this.style,
  });

  FrameData copyWith({
    DeviceFrameStyle? style,
    TargetPlatform? platform,
    Size? size,
    double? pixelRatio,
    EdgeInsets? landscapeSafeArea,
    EdgeInsets? portraitSafeArea,
    Orientation? orientation,
    bool? isKeyboardVisible,
    Duration? keyboardTransitionDuration,
    EdgeInsets? bodyPadding,
    BorderRadius? edgeRadius,
    BorderRadius? screenRadius,
  }) {
    return FrameData(
      platform: platform ?? this.platform,
      bodyPadding: bodyPadding ?? this.bodyPadding,
      edgeRadius: edgeRadius ?? this.edgeRadius,
      screenRadius: screenRadius ?? this.screenRadius,
      size: size ?? this.size,
      pixelRatio: pixelRatio ?? this.pixelRatio,
      landscapeSafeArea: landscapeSafeArea ?? this.landscapeSafeArea,
      portraitSafeArea: portraitSafeArea ?? this.portraitSafeArea,
      style: style ?? this.style,
      orientation: orientation ?? this.orientation,
      isKeyboardVisible: isKeyboardVisible ?? this.isKeyboardVisible,
      keyboardTransitionDuration:
          keyboardTransitionDuration ?? this.keyboardTransitionDuration,
    );
  }
}

class Frame extends StatelessWidget {
  final FrameData frame;
  final Widget child;

  const Frame({Key? key, required this.frame, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = frame.orientation!.toMediaQuery(
        size: frame.size!,
        pixelRatio: frame.pixelRatio!,
        portrait: frame.portraitSafeArea,
        landscape: frame.landscapeSafeArea);
    return MediaQueryFrameProvider(
      mediaQuery: mediaQuery,
      child: frame_painter.MobileDeviceFrame(
        platform: frame.platform,
        style: frame.style!,
        orientation: frame.orientation!,
        mediaQueryData: mediaQuery,
        isKeyboardVisible: frame.isKeyboardVisible,
        keyboardTransitionDuration: frame.keyboardTransitionDuration,
        child: ClipRRect(child: child, borderRadius: frame.screenRadius),
        body: frame.bodyPadding,
        edgeRadius: frame.edgeRadius,
        screenRadius: frame.screenRadius,
      ),
    );
  }

  static Widget _appBuilder(
    BuildContext context,
    Widget widget,
  ) {
    final mediaQuery = context
        .dependOnInheritedWidgetOfExactType<MediaQueryFrameProvider>()
        ?.mediaQuery;
    if (mediaQuery == null) return widget;
    return MediaQuery(
      data: mediaQuery,
      child: widget,
    );
  }
}

class MediaQueryFrameProvider extends InheritedWidget {
  final MediaQueryData mediaQuery;

  MediaQueryFrameProvider({
    Key? key,
    required this.mediaQuery,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(MediaQueryFrameProvider oldWidget) =>
      mediaQuery != oldWidget.mediaQuery;
}

extension OrientationExtensions on Orientation {
  MediaQueryData toMediaQuery({
    required Size size,
    required double pixelRatio,
    EdgeInsets landscape = EdgeInsets.zero,
    EdgeInsets portrait = EdgeInsets.zero,
  }) {
    return this == Orientation.landscape
        ? MediaQueryData(
            size: Size(size.height, size.width),
            padding: landscape,
            devicePixelRatio: pixelRatio,
          )
        : MediaQueryData(
            size: Size(size.width, size.height),
            padding: portrait,
            devicePixelRatio: pixelRatio,
          );
  }
}
