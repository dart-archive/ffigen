// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Contains all the neccesary classes required by config.

import 'package:meta/meta.dart';

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
  final String description;
  final bool Function(String name, dynamic value) validator;
  final E Function(dynamic map) extractor;
  final E Function() defaultValue;

  final Requirement requirement;
  final void Function(dynamic result) extractedResult;

  Specification({
    @required this.extractedResult,
    @required this.description,
    @required this.validator,
    @required this.extractor,
    this.defaultValue,
    this.requirement = Requirement.no,
  });
}

enum Requirement { yes, prefer, no }

class HeaderFilter {
  Set<String> includedInclusionHeaders;
  Set<String> excludedInclusionHeaders;

  HeaderFilter({
    this.includedInclusionHeaders = const {},
    this.excludedInclusionHeaders = const {},
  });
}

/// A generic declaration config.
class Declaration {
  // matchers
  List<RegExp> _includeMatchers = [];
  Set<String> _includeFull = {};
  List<RegExp> _excludeMatchers = [];
  Set<String> _excludeFull = {};
  String _globalPrefix = '';
  Map<String, String> _prefixReplacement = {};

  Declaration({
    List<String> includeMatchers,
    List<String> includeFull,
    List<String> excludeMatchers,
    List<String> excludeFull,
    String globalPrefix,
    Map<String, String> prefixReplacement,
  }) {
    if (includeMatchers != null) {
      _includeMatchers =
          includeMatchers.map((e) => RegExp(e, dotAll: true)).toList();
    }
    if (includeFull != null) {
      _includeFull = includeFull.map((e) => e).toSet();
    }
    if (excludeMatchers != null) {
      _excludeMatchers =
          excludeMatchers.map((e) => RegExp(e, dotAll: true)).toList();
    }
    if (excludeFull != null) {
      _excludeFull = excludeFull.map((e) => e).toSet();
    }
    if (globalPrefix != null) {
      _globalPrefix = globalPrefix;
    }
    if (prefixReplacement != null) {
      _prefixReplacement = prefixReplacement;
    }
  }

  /// Applies prefix and replacement and returns the result.
  ///
  /// Also logs warnings if declaration starts with '_'.
  String getPrefixedName(String name) {
    // Apply prefix replacement.
    for (final pattern in _prefixReplacement.keys) {
      if (name.startsWith(pattern)) {
        name = name.replaceFirst(pattern, _prefixReplacement[pattern]);
        break;
      }
    }

    // Apply global prefixes.
    name = '${_globalPrefix}$name';

    return name;
  }

  /// Checks if a name is allowed by a filter.
  bool shouldInclude(String name) {
    if (_excludeFull.contains(name)) {
      return false;
    }

    for (final em in _excludeMatchers) {
      if (em.firstMatch(name)?.end == name.length) {
        return false;
      }
    }

    if (_includeFull.contains(name)) {
      return true;
    }

    for (final im in _includeMatchers) {
      if (im.firstMatch(name)?.end == name.length) {
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
