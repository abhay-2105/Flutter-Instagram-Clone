import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class PreviewCamera extends StatefulWidget {
  final void Function(
    File? imageFile,
  ) setImage;
  const PreviewCamera(this.setImage, {super.key});

  @override
  State<PreviewCamera> createState() => _PreviewCameraState();
}

class _PreviewCameraState extends State<PreviewCamera> {
  late CameraController _cameraController;
  late final firstCamera;
  File? _pickedImage;
  bool isClicked = false;

  Future<void> selectCamera() async {
    final cameras = await availableCameras();
    firstCamera = cameras.first;
    _cameraController = CameraController(firstCamera, ResolutionPreset.medium);
    await _cameraController.initialize();
  }

  @override
  void dispose() {
    super.dispose();
    _cameraController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: FutureBuilder(
            future: selectCamera(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    !isClicked
                        ? CameraPreview(_cameraController)
                        : Image.file(_pickedImage!),
                    Positioned(
                      bottom: 20,
                      child: IconButton(
                        onPressed: !isClicked
                            ? () async {
                                try {
                                  final image =
                                      await _cameraController.takePicture();
                                  _pickedImage = File(image.path);
                                  setState(() {
                                    isClicked = true;
                                  });
                                } catch (e) {
                                  print(e);
                                }
                              }
                            : () {
                                setState(() {
                                  isClicked = false;
                                  _pickedImage = null;
                                });
                              },
                        color: Colors.grey,
                        icon: Icon(
                          isClicked ? Icons.replay : Icons.motion_photos_on,
                          size: 50,
                        ),
                      ),
                    ),
                    if (isClicked)
                      Positioned(
                        bottom: 20,
                        left: 20,
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          color: Colors.red,
                          icon: const Icon(
                            Icons.close,
                            size: 50,
                          ),
                        ),
                      ),
                    if (isClicked)
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: IconButton(
                          onPressed: () {
                            widget.setImage(_pickedImage);
                            Navigator.of(context).pop();
                          },
                          color: Colors.green,
                          icon: const Icon(
                            Icons.done,
                            size: 50,
                          ),
                        ),
                      ),
                  ],
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            }),
      ),
    );
  }
}
