import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter WebRTC Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _localRenderer = RTCVideoRenderer();
  late MediaStream _localStream;
  bool _isFrontCamera = true;
  String _selectedCameraOption = 'Turn off camera';

  @override
  void dispose() {
    _localStream.dispose();
    _localRenderer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initRenderers();
    _getUserMedia();
  }

  initRenderers() async {
    await _localRenderer.initialize();
  }

  _getUserMedia() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': false,
      'video': {
        'facingMode': _isFrontCamera ? 'user' : 'environment',
      },
    };

    _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);

    _localRenderer.srcObject = _localStream;
  }

  void _toggleCamera() {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
      if (_isFrontCamera) {
        _selectedCameraOption = 'Front camera';
      } else {
        _selectedCameraOption = 'Back camera';
      }
    });
    _getUserMedia();
  }

  List<String> _buildCameraOptions() {
    List<String> options = ['Turn off camera'];
    if (MediaDevices.isMobileDevice) {
      if (MediaDevices.hasFrontCamera) {
        options.add('Front camera');
      }
      if (MediaDevices.hasBackCamera) {
        options.add('Back camera');
      }
    } else {
      options.add('Camera');
    }
    return options;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebRTC Demo'),
      ),
      body: Center(
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child:
                  _selectedCameraOption != 'Turn off camera' ? RTCVideoView(_localRenderer, mirror: true) : Container(),
            ),
            Positioned(
              top: -10,
              left: 20,
              child: DropdownButton<String>(
                value: _selectedCameraOption,
                onChanged: (String? newValue) {
                  if (newValue == 'Front camera') {
                    setState(() {
                      _isFrontCamera = true;
                    });
                  } else if (newValue == 'Back camera') {
                    setState(() {
                      _isFrontCamera = false;
                    });
                  } else {
                    setState(() {
                      _isFrontCamera = false;
                    });
                  }
                  setState(() {
                    _selectedCameraOption = newValue!;
                  });
                  _getUserMedia();
                },
                items: _buildCameraOptions().map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: _toggleCamera,
                child: Icon(Icons.switch_camera),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MediaDevices {
  static bool get isMobileDevice {
    return true;
  }

  static bool get hasFrontCamera {
    return true;
  }

  static bool get hasBackCamera {
    return true;
  }
}
