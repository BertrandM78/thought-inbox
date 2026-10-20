import 'package:flutter/material.dart';

import 'app.dart';
import 'state/thought_inbox_controller.dart';
import 'storage/thought_storage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ThoughtStorage storage;
  try {
    storage = FileThoughtStorage.defaultLocation();
  } on Object catch (error) {
    storage = UnavailableThoughtStorage(error);
  }
  final controller = ThoughtInboxController(storage: storage)..load();
  runApp(ThoughtInboxApp(controller: controller));
}
