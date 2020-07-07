class ConflictHandler {
  final Set<String> usedUpNames;
  ConflictHandler(this.usedUpNames);

  /// Returns a non conflicting name by appending `_<int>` to it.
  ///
  /// If [name] isn't conflicting, it is returned as is.
  String getNonConflictingName(String name, [bool addToUsedUpNames = true]) {
    String cr_name = name;
    int i = 1;
    while (usedUpNames.contains(cr_name)) {
      cr_name = '${name}_$i';
      i++;
    }
    if (addToUsedUpNames) {
      usedUpNames.add(cr_name);
    }
    return cr_name;
  }

  /// Adds a name to usedUpNames.
  ///
  /// Note: [getNonConflictingName] also adds the name by default.
  void addToUsedUpNames(String name) {
    usedUpNames.add(name);
  }

  /// Returns true if a name has been used before.
  bool isNameConflicting(String name) {
    return usedUpNames.contains(name);
  }
}
