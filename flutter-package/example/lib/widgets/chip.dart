import 'package:flutter/material.dart';
import 'package:preview/preview.dart';

class Chip extends StatelessWidget {
  final String title;
  final Color? color;
  final bool outline;

  const Chip({super.key, required this.title, this.color, this.outline = false});

  const Chip.outlined({super.key, required this.title, this.color}) : outline = true;
  @override
  Widget build(BuildContext context) {
    final color = this.color ?? Theme.of(context).colorScheme.secondary;
    final padding = EdgeInsets.symmetric(horizontal: 20, vertical: 4);
    final radius = BorderRadius.circular(4);
    if (outline) {
      return Container(
        decoration: BoxDecoration(border: Border.all(color: color), borderRadius: radius),
        padding: padding,
        child: Text(
          title,
          style: TextStyle(color: color),
        ),
      );
    } else {
      final textColor = color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
      return Container(
        decoration: BoxDecoration(color: color, borderRadius: radius),
        padding: padding,
        child: Text(
          title,
          style: TextStyle(color: textColor),
        ),
      );
    }
  }
}

class WidgetPreview extends PreviewProvider {
  @override
  List<Preview> get previews {
    return [
      Preview(
        child: Chip(title: 'TAG'),
      ),
      Preview(
        child: Chip(title: 'TAG'),
      ),
      Preview(
        child: Chip(
          color: Colors.red,
          title: 'TAG',
        ),
      ),
      Preview(
        child: Chip(
          color: Colors.black,
          title: 'TAG',
        ),
      ),
      Preview(
        child: Chip.outlined(
          color: Colors.green,
          title: 'TAG',
        ),
      ),
      Preview(
        child: Chip.outlined(
          color: Colors.red,
          title: 'TAG',
        ),
      ),
      Preview(
        child: Chip.outlined(
          title: 'TAG',
        ),
      ),
    ];
  }
}
