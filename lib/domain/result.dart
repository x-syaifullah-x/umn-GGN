abstract class Result {}

class ResultSuccess<T> implements Result {
  ResultSuccess(this.value);

  final T value;

  @override
  Type get runtimeType => ResultSuccess;
}

class ResultError<T> implements Result {
  ResultError(this.value);

  final T value;

  @override
  Type get runtimeType => ResultError;
}
