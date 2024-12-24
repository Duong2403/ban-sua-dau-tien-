@JS()
library js_interop;

import 'package:js/js.dart';
import 'package:js/js_util.dart';

@JS('Promise')
class PromiseJsImpl<T> {
  external PromiseJsImpl(
      void Function(void Function(T) resolve, void Function(Object) reject)
          executor);
  external PromiseJsImpl then(Function onFulfilled, [Function onRejected]);
}

@JS('Object')
class JsObject {
  external factory JsObject();
}

Future<T> handleThenable<T>(dynamic jsPromise) {
  return promiseToFuture<T>(jsPromise);
}

@JS('JSON.stringify')
external String stringify(dynamic obj);

@JS('JSON.parse')
external dynamic parse(String str);

dynamic dartify(dynamic jsObject) {
  if (jsObject == null) return null;
  return parse(stringify(jsObject));
}

dynamic jsify(dynamic dartObject) {
  if (dartObject == null) return null;
  return parse(stringify(dartObject));
}
