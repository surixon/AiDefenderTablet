import 'package:flutter/widgets.dart';
import '../enums/viewstate.dart';
import '../locator.dart';
import '../services/api_class.dart';

class BaseProvider extends ChangeNotifier {
  ViewState _state = ViewState.idle;

  ViewState get state => _state;

  Api api = locator<Api>();

  bool _isDisposed = false;

  void setState(ViewState viewState) {
    if (!_isDisposed) {
      _state = viewState;
      notifyListeners();
    }
  }

  void customNotify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
