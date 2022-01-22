import 'package:ai_barcode/ai_barcode.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AppBarcodeScannerWidget extends StatefulWidget {
  @override
  _AppBarcodeState createState() => _AppBarcodeState();
}

class _AppBarcodeState extends State<AppBarcodeScannerWidget> {
  @override
  Widget build(BuildContext context) {
    return _BarcodePermissionWidget();
  }
}

class _BarcodePermissionWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BarcodePermissionWidgetState();
  }
}

class _BarcodePermissionWidgetState extends State<_BarcodePermissionWidget> {
  bool _isGranted = true;

  bool _useCameraScan = true;

  String _inputValue = "";

  @override
  void initState() {
    super.initState();

    _requestPermission();
  }

  void _requestPermission() async {
    if (await Permission.camera.request().isGranted) {
      setState(() {
        _isGranted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: _isGranted
              ? _useCameraScan
                  ? _BarcodeScannerWidget()
                  : Text("No Camera")
              : Center(
                  child: OutlineButton(
                    onPressed: () {
                      _requestPermission();
                    },
                    child: Text("Label stuff"),
                  ),
                ),
        ),
        _useCameraScan
            ? OutlineButton(
                onPressed: () {
                  setState(() {
                    _useCameraScan = false;
                  });
                },
                child: Text("label 2"),
              )
            : Row(
                children: [
                  OutlineButton(
                    onPressed: () {
                      setState(() {
                        _useCameraScan = true;
                      });
                    },
                    child: Text("label 3"),
                  ),
                  OutlineButton(
                    onPressed: () {
                      print(_inputValue);
                    },
                    child: Text("label 4"),
                  ),
                ],
              ),
      ],
    );
  }
}

class _BarcodeInputWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BarcodeInputState();
  }
}

class _BarcodeInputState extends State<_BarcodeInputWidget> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final text = _controller.text.toLowerCase();
      _controller.value = _controller.value.copyWith(
        text: text,
        selection:
            TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(padding: EdgeInsets.all(8)),
        Row(
          children: <Widget>[
            Padding(padding: EdgeInsets.all(8)),
            Text(
              "label 5：",
            ),
            Expanded(
              child: TextFormField(
                controller: _controller,
                onChanged: (message) {
                  print(message);
                },
                decoration: InputDecoration(border: OutlineInputBorder()),
              ),
            ),
            Padding(padding: EdgeInsets.all(8)),
          ],
        ),
        Padding(padding: EdgeInsets.all(8)),
      ],
    );
  }
}

///ScannerWidget
class _BarcodeScannerWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AppBarcodeScannerWidgetState();
  }
}

class _AppBarcodeScannerWidgetState extends State<_BarcodeScannerWidget> {
  late ScannerController _scannerController;

  @override
  void initState() {
    super.initState();

    _scannerController = ScannerController(scannerResult: (result) {
      print(result);
    }, scannerViewCreated: () {
      TargetPlatform platform = Theme.of(context).platform;
      if (TargetPlatform.iOS == platform) {
        Future.delayed(Duration(seconds: 2), () {
          _scannerController.startCamera();
          _scannerController.startCameraPreview();
        });
      } else {
        _scannerController.startCamera();
        _scannerController.startCameraPreview();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    _scannerController.stopCameraPreview();
    _scannerController.stopCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: _getScanWidgetByPlatform(),
        )
      ],
    );
  }

  Widget _getScanWidgetByPlatform() {
    return PlatformAiBarcodeScannerWidget(
      platformScannerController: _scannerController,
    );
  }
}
