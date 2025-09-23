import 'package:get/get.dart';

class SettingsController extends GetxController {
  final RxDouble textScale = 1.0.obs;

  void inc() {
    final next = (textScale.value + 0.1).clamp(0.8, 2.0);
    textScale.value = next;
  }

  void dec() {
    final next = (textScale.value - 0.1).clamp(0.8, 2.0);
    textScale.value = next;
  }

  void reset() {
    textScale.value = 1.0;
  }
}

