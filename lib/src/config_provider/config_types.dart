// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Contains all the neccesary classes required by config.

import 'package:meta/meta.dart';
import 'package:quiver/pattern.dart' as quiver;

class CommentType {
  CommentStyle style;
  CommentLength length;
  CommentType(this.style, this.length);

  /// Sets default style as [CommentStyle.doxygen], default length as
  /// [CommentLength.full].
  CommentType.def()
      : style = CommentStyle.doxygen,
        length = CommentLength.full;

  /// Disables any comments.
  CommentType.none()
      : style = CommentStyle.doxygen,
        length = CommentLength.none;
}

enum CommentStyle { doxygen, any }
enum CommentLength { none, brief, full }

/// Represents a single specification in configurations.
///
/// [E] is the return type of the extractedResult.
class Specification<E> {
  final bool Function(String name, dynamic value) validator;
  final E Function(dynamic map) extractor;
  final E Function() defaultValue;

  final Requirement requirement;
  final void Function(dynamic result) extractedResult;

  Specification({
    @required this.extractedResult,
    @required this.validator,
    @required this.extractor,
    this.defaultValue,
    this.requirement = Requirement.no,
  });
}

enum Requirement { yes, prefer, no }

// Holds headers and filters for header.
class Headers {
  /// Path to headers.
  ///
  /// This contains all the headers, after extraction from Globs.
  List<String> entryPoints = [];

  /// Include filter for headers.
  HeaderIncludeFilter includeFilter = GlobHeaderFilter();

  Headers({this.entryPoints, this.includeFilter});
}

abstract class HeaderIncludeFilter {
  bool shouldInclude(String headerSourceFile);
}

class GlobHeaderFilter extends HeaderIncludeFilter {
  List<quiver.Glob> includeGlobs = [];

  GlobHeaderFilter({
    this.includeGlobs,
  });

  @override
  bool shouldInclude(String header) {
    // Return true if header was included.
    for (final globPattern in includeGlobs) {
      if (quiver.matchesFull(globPattern, header)) {
        return true;
      }
    }

    // If any includedInclusionHeaders is provided, return false.
    if (includeGlobs.isNotEmpty) {
      return false;
    } else {
      return true;
    }
  }
}

/// A generic declaration config, used for Functions, Structs and Enums.
class Declaration {
  final Includer _includer;
  final Renamer _renamer;

  Declaration({
    Includer includer,
    Renamer renamer,
  })  : _includer = includer ?? Includer(),
        _renamer = renamer ?? Renamer();

  /// Applies renaming and returns the result.
  String renameUsingConfig(String name) => _renamer.renameUsingConfig(name);

  /// Checks if a name is allowed by a filter.
  bool shouldInclude(String name) => _includer.shouldInclude(name);
}

/// Matches `$<single_digit_int>`, value can be accessed in group 1 of match.
final replaceGroupRegexp = RegExp(r'\$([0-9])');

class RenamePattern {
  final RegExp regExp;
  final String replacementPattern;

  RenamePattern(this.regExp, this.replacementPattern);

  /// Returns true if [str] has a full match with [regExp].
  bool matches(String str) => quiver.matchesFull(regExp, str);

  /// Renames [str] according to [replacementPattern].
  String rename(String str) {
    if (quiver.matchesFull(regExp, str)) {
      final regExpMatch = regExp.firstMatch(str);
      final groups = regExpMatch.groups(
          List.generate(regExpMatch.groupCount, (index) => index) +
              [regExpMatch.groupCount]);

      final result =
          replacementPattern.replaceAllMapped(replaceGroupRegexp, (match) {
        final groupInt = int.parse(match.group(1));
        return groups[groupInt];
      });
      return result;
    } else {
      /// We return [str] if pattern doesn't have a full match.
      return str;
    }
  }

  @override
  String toString() {
    return 'Regexp: $regExp, ReplacementPattern: $replacementPattern';
  }
}

class Includer {
  // matchers
  final List<RegExp> _includeMatchers;
  final Set<String> _includeFull;
  final List<RegExp> _excludeMatchers;
  final Set<String> _excludeFull;

  Includer({
    List<RegExp> includeMatchers,
    Set<String> includeFull,
    List<RegExp> excludeMatchers,
    Set<String> excludeFull,
  })  : _includeMatchers = includeMatchers ?? [],
        _includeFull = includeFull ?? {},
        _excludeMatchers = excludeMatchers ?? [],
        _excludeFull = excludeFull ?? {};

  bool shouldInclude(String name) {
    if (_excludeFull.contains(name)) {
      return false;
    }

    for (final em in _excludeMatchers) {
      if (quiver.matchesFull(em, name)) {
        return false;
      }
    }

    if (_includeFull.contains(name)) {
      return true;
    }

    for (final im in _includeMatchers) {
      if (quiver.matchesFull(im, name)) {
        return true;
      }
    }

    // If user has provided 'include' field in the filter, then default
    // matching is false.
    if (_includeMatchers.isNotEmpty || _includeFull.isNotEmpty) {
      return false;
    } else {
      return true;
    }
  }
}

class Renamer {
  final Map<String, String> _renameFull;
  final List<RenamePattern> _renameMatchers;

  Renamer({
    List<RenamePattern> renamePatterns,
    Map<String, String> renameFull,
  })  : _renameMatchers = renamePatterns ?? [],
        _renameFull = renameFull ?? {};

  String renameUsingConfig(String name) {
    // Apply full rename (if any).
    if (_renameFull.containsKey(name)) {
      return _renameFull[name];
    }

    // Apply rename regexp (if matches).
    for (final renamer in _renameMatchers) {
      if (renamer.matches(name)) {
        return renamer.rename(name);
      }
    }

    // No renaming is provided for this declaration, return unchanged.
    return name;
  }
}
