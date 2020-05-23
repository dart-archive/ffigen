/// Contains functions to print details for user
/// and global options for determining what should be printed to console

enum VerboseLevel {
  extra,
  normal,
  none,
}

VerboseLevel _verboseLevel = VerboseLevel.extra;

/// Set verbose level extra, normal or none
void setPrintOptions({VerboseLevel verboseLevel}) {
  if (verboseLevel != null) {
    _verboseLevel = verboseLevel;
  }
}

void printExtraVerbose(Object object) {
  if (_verboseLevel == VerboseLevel.extra) {
    print(object);
  }
}

void printVerbose(Object object) {
  if (_verboseLevel != VerboseLevel.none) {
    print(object);
  }
}

/// Prints info for user (will always print to screen)
void printInfo(Object object) {
  print(object);
}

/// Prints error for user (will always print to screen)
void printError(Object object) {
  print(object);
}

/// Print method to be used in development (is always printed)
void printDebug(Object object) {
  print(object);
}
