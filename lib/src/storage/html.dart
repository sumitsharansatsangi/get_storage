import 'dart:async';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import '../value.dart';

class StorageImpl {
  StorageImpl(this.fileName, [this.path]);
  html.Storage get localStorage => html.window.localStorage;

  final String? path;
  final String fileName;

  ValueStorage<Map<String, dynamic>> subject =
      ValueStorage<Map<String, dynamic>>(<String, dynamic>{});

  void clear() {
    localStorage.remove(fileName);
    if (subject.value != null) {
      subject.value!.clear();

      subject
        ..value!.clear()
        ..changeValue("", null);
    }
  }

  Future<bool> _exists() async {
    return localStorage.containsKey(fileName);
  }

  Future<void> flush() async {
    if (subject.value != null) return await _writeToStorage(subject.value!);
  }

  T? read<T>(String key) {
    if (subject.value != null)
      return subject.value![key] as T?;
    else
      return null;
  }

  T? getKeys<T>() {
    if (subject.value != null)
      return subject.value!.keys as T;
    else
      return null;
  }

  T? getValues<T>() {
    if (subject.value != null)
      return subject.value!.values as T;
    else
      return null;
  }

  Future<void> init([Map<String, dynamic>? initialData]) async {
    subject.value = initialData ?? <String, dynamic>{};
    if (await _exists()) {
      await _readFromStorage();
    } else {
      if (subject.value != null) await _writeToStorage(subject.value!);
    }
    return;
  }

  void remove(String key) {
    if (subject.value != null)
      subject
        ..value!.remove(key)
        ..changeValue(key, null);
    //  return _writeToStorage(subject.value);
  }

  void write(String key, dynamic value) {
    if (subject.value != null)
      subject
        ..value![key] = value
        ..changeValue(key, value);
    //return _writeToStorage(subject.value);
  }

  // void writeInMemory(String key, dynamic value) {

  // }

  Future<void> _writeToStorage(Map<String, dynamic> data) async {
    localStorage.update(fileName, (val) => json.encode(subject.value),
        ifAbsent: () => json.encode(subject.value));
  }

  Future<void> _readFromStorage() async {
    final dataFromLocal = localStorage.entries.firstWhereOrNull(
      (value) {
        return value.key == fileName;
      },
    );
    if (dataFromLocal != null) {
      subject.value = json.decode(dataFromLocal.value) as Map<String, dynamic>;
    } else {
      await _writeToStorage(<String, dynamic>{});
    }
  }
}

extension FirstWhereExt<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
