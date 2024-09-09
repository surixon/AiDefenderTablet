import 'package:flutter/cupertino.dart';

class LoadingProvider with ChangeNotifier {
  double _progress=0.0;

  double get progress => _progress;

  setProgress(double value) {
    _progress = value;
    notifyListeners();
  }

  bool _loading = false;
  bool get loading => _loading;
  setLoad(bool status) {
    _loading = status;
    notifyListeners();
  }
}