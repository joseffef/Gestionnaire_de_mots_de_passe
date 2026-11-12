import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClipboardService {
  ClipboardService({this.clearAfter = const Duration(seconds: 30)});

  final Duration clearAfter;
  Timer? _timer;

  /// Copie un secret, puis l'efface après le délai (seulement si le
  /// presse-papiers contient toujours ce même texte).
  Future<void> copySensitive(String text) async {
    _timer?.cancel();
    await Clipboard.setData(ClipboardData(text: text));
    _timer = Timer(clearAfter, () => _clearIfUnchanged(text));
  }

  Future<void> _clearIfUnchanged(String text) async {
    final current = await Clipboard.getData(Clipboard.kTextPlain);
    if (current?.text == text) {
      await Clipboard.setData(const ClipboardData(text: ''));
    }
  }

  void dispose() => _timer?.cancel();
}

final clipboardServiceProvider = Provider<ClipboardService>((ref) {
  final service = ClipboardService();
  ref.onDispose(service.dispose);
  return service;
});