import 'package:flutter_bloc/flutter_bloc.dart';

/// Base cubit that prevents emitting states after the cubit is closed
abstract class BaseCubit<T> extends Cubit<T> {
  BaseCubit(super.initialState);

  /// Safely emit a state only if the cubit is not closed
  @override
  void emit(T state) {
    if (!isClosed) {
      super.emit(state);
    }
  }

  /// Safely emit a state with a callback that returns the new state
  void safeEmit(T Function(T currentState) stateBuilder) {
    if (!isClosed) {
      final newState = stateBuilder(state);
      super.emit(newState);
    }
  }

  /// Execute an async operation and safely emit states
  Future<void> safeAsyncOperation<TResult>({
    required Future<TResult> Function() operation,
    required T Function(T currentState) onSuccess,
    required T Function(T currentState, dynamic error) onError,
    T Function(T currentState)? onProgress,
  }) async {
    if (isClosed) return;

    // Emit progress state if provided
    if (onProgress != null) {
      safeEmit(onProgress);
    }

    try {
      await operation();

      if (!isClosed) {
        safeEmit(onSuccess);
      }
    } catch (error) {
      if (!isClosed) {
        safeEmit((currentState) => onError(currentState, error));
      }
    }
  }
}
