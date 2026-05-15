import 'package:flutter/material.dart';

class TextScaleState {
  static final ValueNotifier<double> scaleNotifier = ValueNotifier<double>(1.0);

  static void setScale(double newScale) {
    scaleNotifier.value = newScale;
  }
  
  static void increase() {
    if (scaleNotifier.value < 1.4) {
      scaleNotifier.value += 0.1;
    }
  }

  static void decrease() {
    if (scaleNotifier.value > 0.8) {
      scaleNotifier.value -= 0.1;
    }
  }
}
