abstract class Resources {}

class ResourcesLoading implements Resources {
  @override
  Type get runtimeType => ResourcesSuccess;
}

class ResourcesSuccess<T> implements Resources {
  ResourcesSuccess(this.value);

  final T value;

  @override
  Type get runtimeType => ResourcesSuccess;
}

class ResourcesError<T> implements Resources {
  ResourcesError(this.value);

  final T value;

  @override
  Type get runtimeType => ResourcesError;
}
