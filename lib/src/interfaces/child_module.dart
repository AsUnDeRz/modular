import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/src/routers/router.dart';

abstract class ChildModule {
  List<Bind> get binds;
  List<Router> get routers;

  final List<String> paths = List<String>();

  final Map<String, dynamic> _injectBinds = {};

  getBind<T>([Map<String, dynamic> params]) {
    String typeName = T.toString();
    T _bind;
    if (_injectBinds.containsKey(typeName)) {
      _bind = _injectBinds[typeName];
      return _bind;
    }

    Bind b = binds.firstWhere((b) => b.inject is T Function(Inject),
        orElse: () => null);
    if (b == null) {
      return null;
    }
    _bind = b.inject(Inject(
      params: params,
      //     tag: this.runtimeType.toString(),
    ));
    if (b.singleton) {
      _injectBinds[typeName] = _bind;
    }
    return _bind;
  }

  bool remove<T>() {
    String typeName = T.toString();
    if (_injectBinds.containsKey(typeName)) {
      var inject = _injectBinds[typeName];
      _callDispose(inject);
      _injectBinds.remove(typeName);
      return true;
    } else {
      return false;
    }
  }

  _callDispose(dynamic bind) {
    if (bind is Disposable || bind is ChangeNotifier) {
      bind.dispose();
      return;
    } else if (bind is Sink) {
      bind.close();
      return;
    }

    try {
      bind?.dispose();
    } catch (e) {}
  }

  cleanInjects() {
    for (String key in _injectBinds.keys) {
      var _bind = _injectBinds[key];
      _callDispose(_bind);
    }
    _injectBinds.clear();
  }
}
