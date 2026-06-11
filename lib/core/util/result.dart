sealed class Result<T> {
  const Result();

  R fold<R>(
    R Function(String message) onFailure,
    R Function(T data) onSuccess,
  ) {
    final current = this;
    if (current is Success<T>) {
      return onSuccess(current.data);
    }
    return onFailure((current as Failure<T>).message);
  }
}

class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;
}

class Failure<T> extends Result<T> {
  const Failure(this.message);

  final String message;
}
