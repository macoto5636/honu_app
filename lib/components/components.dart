import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//カメラのプレビューが入る半透明のあの四角いやつ
BoxDecoration previewBoxDecoration = BoxDecoration(
  borderRadius: BorderRadius.circular(5.0),
  gradient: RadialGradient(
      tileMode: TileMode.clamp,
      colors: [
        Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.4),
      ]
  ),
);