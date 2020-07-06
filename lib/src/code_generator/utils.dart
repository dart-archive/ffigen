class ConflictHandler {
  final Set<String> usedUpNames;
  ConflictHandler(this.usedUpNames);

  /// Returns a non conflicting name by appending `_<int>` to it.
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
}
