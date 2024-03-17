import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_editor/control_slider.dart';
import 'package:image_editor/image_painter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ui.FragmentProgram? program;
  ui.Image? image;
  OverlayEntry? overlayEntry;
  GlobalKey globalKey = GlobalKey();
  double noise = 0;
  double brightness = 0;
  double constrast = 0;
  double saturation = 1;
  double vignetteRadius = 1;
  Color? selectedColor;
  double selectedColorIntensity = 0;

  void createHighlightOverlay() {
    // Remove the existing OverlayEntry.
    removeHighlightOverlay();

    assert(overlayEntry == null);

    RenderBox? renderBox =
        globalKey.currentContext!.findRenderObject() as RenderBox?;
    Offset offset = renderBox!.localToGlobal(Offset.zero);

    overlayEntry = OverlayEntry(
      // Create a new OverlayEntry.
      builder: (BuildContext context) {
        // Align is used to position the highlight overlay
        // relative to the NavigationBar destination.
        return StatefulBuilder(builder: (context, overlaySetState) {
          return Positioned(
            left: offset.dx - 200,
            top: offset.dy,
            child: Material(
              color: Colors.black.withOpacity(0.4),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 200,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Colors.red,
                          Colors.yellow,
                          Colors.green,
                          Colors.blue,
                          Colors.purple,
                          Colors.indigo,
                        ]
                            .map(
                              (e) => GestureDetector(
                                onTap: () {
                                  if (selectedColor == e) {
                                    selectedColor = null;
                                  } else {
                                    selectedColor = e;
                                  }
                                  overlaySetState(() {});
                                  setState(() {});
                                },
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: e,
                                    border: Border.all(
                                      color: selectedColor == e
                                          ? Colors.white
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      if (selectedColor != null)
                        ControlsSlider(
                          title: "",
                          value: selectedColorIntensity,
                          onChanged: (value) {
                            selectedColorIntensity = value;
                            setState(() {});
                            overlaySetState(() {});
                          },
                        ),
                      ControlsSlider(
                        title: "Noise",
                        value: noise,
                        onChanged: (value) {
                          noise = value;
                          setState(() {});
                          overlaySetState(() {});
                        },
                      ),
                      ControlsSlider(
                        title: "Vignette",
                        value: vignetteRadius,
                        onChanged: (value) {
                          vignetteRadius = value;
                          setState(() {});
                          overlaySetState(() {});
                        },
                      ),
                      ControlsSlider(
                        title: "Brightness",
                        value: brightness,
                        min: -0.5,
                        max: 0.5,
                        onChanged: (value) {
                          brightness = value;
                          setState(() {});
                          overlaySetState(() {});
                        },
                      ),
                      ControlsSlider(
                        title: "Contrast",
                        value: constrast,
                        onChanged: (value) {
                          constrast = value;
                          setState(() {});
                          overlaySetState(() {});
                        },
                      ),
                      ControlsSlider(
                        title: "Saturation",
                        value: saturation,
                        onChanged: (value) {
                          saturation = value;
                          setState(() {});
                          overlaySetState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      },
    );

    // Add the OverlayEntry to the Overlay.
    Overlay.of(context, debugRequiredFor: widget).insert(overlayEntry!);
  }

  // Remove the OverlayEntry.
  void removeHighlightOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  @override
  void initState() {
    _loadAllAssets();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => removeHighlightOverlay(),
      child: Scaffold(
        body: program == null && image == null
            ? const SizedBox()
            : Row(
                children: [
                  CustomPaint(
                    size:
                        Size.fromWidth(MediaQuery.of(context).size.width - 30),
                    painter: ImagePainter(
                      shader: program!.fragmentShader(),
                      image: image!,
                      noise: noise,
                      brightness: brightness,
                      constrast: constrast,
                      vignetteRadius: vignetteRadius,
                      saturation: saturation,
                      seletedColor: selectedColor,
                      selectedColorIntensity: selectedColorIntensity,
                    ),
                  ),
                  GestureDetector(
                      onTap: () {
                        createHighlightOverlay();
                      },
                      child: Icon(
                        Icons.tune,
                        key: globalKey,
                      )),
                ],
              ),
      ),
    );
  }

  Future<ui.Image> loadUiImage(String imageAssetPath) async {
    final ByteData assetImageByteData = await rootBundle.load(imageAssetPath);
    final codec = await ui.instantiateImageCodec(
      assetImageByteData.buffer.asUint8List(),
    );
    final image = (await codec.getNextFrame()).image;
    return image;
  }

  Future<void> _loadAllAssets() async {
    program = await ui.FragmentProgram.fromAsset('shaders/image_edit.frag');
    image = await loadUiImage('assets/images/nature.jpg');
    setState(() {});
  }
}
