abstract class Resources {}

class Loading implements Resources {
  @override
  Type get runtimeType => Success;
}

class Success<T> implements Resources {
  Success(this.value);
  final T value;

  @override
  Type get runtimeType => Success;
}

class Error<T extends Exception> implements Resources {
  Error(this.value);
  final T value;

  @override
  Type get runtimeType => Error;
}
