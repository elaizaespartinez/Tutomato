import 'package:flutter_riverpod/flutter_riverpod.dart';

extension AsyncValueData<T> on AsyncValue<T> {
  /// The data if there is any, otherwise null (loading or error).
  T? get dataOrNull => switch (this) {
        AsyncData<T>(:final value) => value,
        _ => null,
      };
}
