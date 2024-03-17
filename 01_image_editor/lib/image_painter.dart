import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ImagePainter extends CustomPainter {
  final ui.FragmentShader shader;
  final ui.Image image;
  final double noise;
  final double brightness;
  final double constrast;
  final double vignetteRadius;
  final double saturation;
  final Color? seletedColor;
  final double selectedColorIntensity;

  ImagePainter({
    super.repaint,
    required this.shader,
    required this.image,
    required this.noise,
    required this.brightness,
    required this.constrast,
    required this.vignetteRadius,
    required this.saturation,
    required this.seletedColor,
    required this.selectedColorIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, noise);
    shader.setFloat(3, brightness);
    shader.setFloat(4, constrast);
    shader.setFloat(5, vignetteRadius);
    shader.setFloat(6, saturation);
    shader.setFloat(7, (seletedColor?.red ?? 0) / 255);
    shader.setFloat(8, (seletedColor?.green ?? 0) / 255);
    shader.setFloat(9, (seletedColor?.blue ?? 0) / 255);
    shader.setFloat(10, selectedColorIntensity);

    shader.setImageSampler(0, image);

    paint.shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
