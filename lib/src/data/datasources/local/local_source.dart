import 'dart:async';

abstract class LocalSource {
  LocalSource() {
    _init();
  }

  final Completer<void> _initCompleter = Completer<void>();

  /// State if [openBoxes] was successfully executed.
  Future<bool> get areBoxesOpen async {
    await _initCompleter.future;
    return true;
  }

  /// Register adapters.
  void registerAdapters();

  /// Open boxes.
  Future<void> openBoxes();

  /// Setup adapters and boxes.
  Future<void> _init() async {
    registerAdapters();
    await openBoxes();
    _initCompleter.complete();
  }
}
