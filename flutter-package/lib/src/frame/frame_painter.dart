import 'dart:math' as math;

import 'package:device_frame/device_frame.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A generic widget that renders a simulated mobile device frame.
///
/// It can simulate a [notch] too.
class MobileDeviceFrame extends StatelessWidget {
  final Widget child;

  final DeviceFrameStyle? style;

  final EdgeInsets body;

  final double borderSize;

  final BorderRadius edgeRadius;

  final BorderRadius screenRadius;

  final Orientation orientation;

  final MediaQueryData mediaQueryData;

  final TargetPlatform platform;

  final bool isKeyboardVisible;

  final Duration keyboardTransitionDuration;

  MobileDeviceFrame(
      {required this.platform,
      required this.child,
      required this.orientation,
      required this.mediaQueryData,
      this.isKeyboardVisible = false,
      // this.keyboard = const VirtualKeyboard(),
      this.keyboardTransitionDuration = const Duration(milliseconds: 500),
      this.style,
      this.borderSize = 4,
      this.body = const EdgeInsets.all(38),
      this.edgeRadius = const BorderRadius.all(Radius.circular(20)),
      this.screenRadius = const BorderRadius.all(Radius.circular(8)),
      EdgeInsets edgeInsets = EdgeInsets.zero});

  MediaQueryData _createMediaQuery(BuildContext context) {
    var result = this.mediaQueryData;
    var keyboardMediaQuery = VirtualKeyboard.mediaQuery(result);

    if (isKeyboardVisible) {
      result = result.copyWith(
        viewInsets: EdgeInsets.only(
          bottom: keyboardMediaQuery.viewInsets.bottom +
              keyboardMediaQuery.padding.bottom,
        ),
      );
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final style = this.style ?? DeviceFrameTheme.of(context);
    var padding = body;

    if (orientation == Orientation.landscape) {
      padding = EdgeInsets.only(
        left: padding.bottom,
        top: padding.right,
        right: padding.top,
        bottom: padding.left,
      );
    }

    final childMediaQuery = _createMediaQuery(context);

    final childWithKeyboard = VirtualKeyboard(
        child: child,
        isEnabled: isKeyboardVisible,
        transitionDuration: keyboardTransitionDuration);

    final childWithMetadata = MediaQuery(
      data: childMediaQuery,
      child: Theme(
        data: Theme.of(context).copyWith(
          platform: platform,
        ),
        child: SizedBox(
          width: mediaQueryData.size.width,
          height: mediaQueryData.size.height,
          child: childWithKeyboard,
        ),
      ),
    );

    return FittedBox(
      child: Padding(
        padding: padding,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: edgeRadius,
                ),
              ),
            ),
            Padding(
              padding: padding,
              child: childWithMetadata,
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _DeviceFramePainter(
                    device: this,
                    style: style,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<EdgeInsets>('body', body));
    properties.add(DiagnosticsProperty<DeviceFrameStyle>('style', style));
    properties.add(DiagnosticsProperty<double>('borderSize', borderSize));
    properties
        .add(DiagnosticsProperty<Orientation>('orientation', orientation));
    properties.add(DiagnosticsProperty<BorderRadius>('edgeRadius', edgeRadius));
    properties
        .add(DiagnosticsProperty<BorderRadius>('screenRadius', screenRadius));
  }
}

//
// Modified to work with web
// Anything that uses Path.combined is either not executed on web, or
// replaced with blendMode
//
class _DeviceFramePainter extends CustomPainter {
  final MobileDeviceFrame device;
  final DeviceFrameStyle style;

  const _DeviceFramePainter({
    required this.device,
    required this.style,
  });

  Path _createBodyPath(Size size) {
    return Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          Offset.zero & size,
          topLeft: device.edgeRadius.topLeft,
          topRight: device.edgeRadius.topRight,
          bottomLeft: device.edgeRadius.bottomLeft,
          bottomRight: device.edgeRadius.bottomRight,
        ),
      );
  }

  Path _createScreenPath(Size size) {
    return Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          Offset(device.body.left, device.body.top) &
              Size(size.width - device.body.left - device.body.right,
                  size.height - device.body.top - device.body.bottom),
          topLeft: device.screenRadius.topLeft,
          topRight: device.screenRadius.topRight,
          bottomLeft: device.screenRadius.bottomLeft,
          bottomRight: device.screenRadius.bottomRight,
        ),
      );
  }

  @override
  void paint(Canvas canvas, Size size) {
    Size size;

    if (device.orientation == Orientation.landscape) {
      size = Size(
        device.mediaQueryData.size.height +
            device.body.left +
            device.body.right,
        device.mediaQueryData.size.width + device.body.top + device.body.bottom,
      );

      final transform = Matrix4.rotationZ(math.pi * 0.5) *
          Matrix4.translationValues(0.0, -size.height, 0.0);
      canvas.transform(transform.storage);
    } else {
      size = Size(
        device.mediaQueryData.size.width + device.body.left + device.body.right,
        device.mediaQueryData.size.height +
            device.body.top +
            device.body.bottom,
      );
    }

    final body = _createBodyPath(size);
    var screen = _createScreenPath(size);

    final bodyWithoutScreen =
        kIsWeb ? body : Path.combine(PathOperation.difference, body, screen);

    canvas.drawPath(
        bodyWithoutScreen,
        Paint()
          ..style = PaintingStyle.fill
          ..color = style.keyboardStyle.backgroundColor);
    if (kIsWeb) {
      canvas.drawPath(
          screen,
          Paint()
            ..style = PaintingStyle.fill
            ..blendMode = BlendMode.dstOut);
    }

    canvas.drawPath(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = device.borderSize
        ..color = style.keyboardStyle.button1ForegroundColor,
    );

    final bodyBounds = body.getBounds();
  }

  @override
  bool shouldRepaint(_DeviceFramePainter oldDelegate) =>
      device.orientation != oldDelegate.device.orientation ||
      device.borderSize != oldDelegate.device.borderSize ||
      device.edgeRadius != oldDelegate.device.edgeRadius ||
      device.mediaQueryData != oldDelegate.device.mediaQueryData ||
      device.body != oldDelegate.device.body ||
      style != oldDelegate.style;

  @override
  bool shouldRebuildSemantics(_DeviceFramePainter oldDelegate) => false;
}
