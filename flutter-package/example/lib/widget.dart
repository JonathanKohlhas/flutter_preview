import 'package:flutter/material.dart';
import 'package:preview/preview.dart';

class Example extends StatefulWidget {
  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
    );
  }
}

class ExamplePreview extends PreviewProvider {
  @override
  List<Preview> get previews => [
        Preview(
          theme: ThemeData(),
          width: 40,
          height: 40,
          child: Example(),
        ),
        Preview(
          width: 40,
          height: 40,
          child: Example(),
        ),
        Preview(
          width: 40,
          height: 40,
          child: Example(),
        ),
        Preview(
          width: 40,
          height: 40,
          child: Example(),
        )
      ];
}
