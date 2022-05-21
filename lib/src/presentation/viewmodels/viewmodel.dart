import 'package:flutter/material.dart';

abstract class Viewmodel with ChangeNotifier {
  /// Callback when error occurs in the viewmodel.
  ValueChanged<String>? onError;

  /// State if viewmodel is already disposed.
  bool get isDisposed => _isDisposed;
  bool _isDisposed = false;

  @override
  void notifyListeners() {
    if (_isDisposed) {
      return;
    }
    super.notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    onError = null;
    super.dispose();
  }
}
