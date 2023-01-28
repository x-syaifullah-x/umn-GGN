abstract class Result {}

class ResultSuccess<T> implements Result {
  ResultSuccess(this.value);

  final T value;
}

class ResultError<T> implements Result {
  ResultError(this.value);

  final T value;
}
