extension Filter<T> on Stream<List<T>> {
  // we're extending any stream that has a filter of T
  Stream<List<T>> filter(bool Function(T) where) =>
      map((items) => items.where(where).toList());
}

// A stream containing a list of things
// Now we have a stream containing a list of things that are contingent to a test