
import 'package:flutter/widgets.dart';
import 'package:preview/preview.dart';
import 'external/preview.dart';  
void main() {
  runApp(_PreviewApp());
}

class _PreviewApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PreviewPage(
      path: 'external/preview.dart',
      providers: () => [
        DevicePreviewProvider(), 
        DevicePreviewPreview2(), 
        
      ],
    );
  }
}
  