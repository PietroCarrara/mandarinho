import 'package:mutex/mutex.dart';

class LatestTaskRunner {
  final _m = ReadWriteMutex();
  int _currentExecutionId = 0;

  Future<TaskResult<T>> run<T>(Future<T> Function() task) async {
    final executionId = await _m.protectWrite(() async {
      final exId = _currentExecutionId;
      _currentExecutionId++;
      return exId;
    });

    try {
      final T data = await task();
      final bool isLatest = await _m.protectRead(() async {
        return executionId == _currentExecutionId;
      });

      return TaskResult(data: data, isLatest: isLatest);
    } catch (e) {
      final bool isLatest = await _m.protectRead(() async {
        return executionId == _currentExecutionId;
      });
      throw TaskException(exception: e, isLatest: isLatest);
    }
  }
}

class TaskResult<T> {
  final T data;
  final bool isLatest;

  const TaskResult({required this.data, required this.isLatest});
}

class TaskException implements Exception {
  final Object exception;
  final bool isLatest;

  TaskException({required this.exception, required this.isLatest});
}
