// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Contains all the neccesary classes required by config.
import 'dart:io';

import 'package:ffigen/src/code_generator.dart';
import 'package:quiver/pattern.dart' as quiver;

import 'path_finder.dart';

enum Language { c, objc }

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

enum CompoundDependencies { full, opaque }

/// Holds config for how Structs Packing will be overriden.
class StructPackingOverride {
  final Map<RegExp, int?> _matcherMap;

  StructPackingOverride({Map<RegExp, int?>? matcherMap})
      : _matcherMap = matcherMap ?? {};

  /// Returns true if the user has overriden the pack value.
  bool isOverriden(String name) {
    for (final key in _matcherMap.keys) {
      if (quiver.matchesFull(key, name)) {
        return true;
      }
    }
    return false;
  }

  /// Returns pack value for [name]. Ensure that value [isOverriden] before
  /// using the returned value.
  int? getOverridenPackValue(String name) {
    for (final opv in _matcherMap.entries) {
      if (quiver.matchesFull(opv.key, name)) {
        return opv.value;
      }
    }
    return null;
  }
}

// Holds headers and filters for header.
class Headers {
  /// Path to headers.
  ///
  /// This contains all the headers, after extraction from Globs.
  final List<String> entryPoints;

  /// Include filter for headers.
  final HeaderIncludeFilter includeFilter;

  Headers({List<String>? entryPoints, HeaderIncludeFilter? includeFilter})
      : entryPoints = entryPoints ?? [],
        includeFilter = includeFilter ?? GlobHeaderFilter();
}

abstract class HeaderIncludeFilter {
  bool shouldInclude(String headerSourceFile);
}

class GlobHeaderFilter extends HeaderIncludeFilter {
  List<quiver.Glob>? includeGlobs = [];

  GlobHeaderFilter({
    this.includeGlobs,
  });

  @override
  bool shouldInclude(String headerSourceFile) {
    // Return true if header was included.
    for (final globPattern in includeGlobs!) {
      if (quiver.matchesFull(globPattern, headerSourceFile)) {
        return true;
      }
    }

    // If any includedInclusionHeaders is provided, return false.
    if (includeGlobs!.isNotEmpty) {
      return false;
    } else {
      return true;
    }
  }
}

/// A generic declaration config, used for Functions, Structs, Enums, Macros,
/// unnamed Enums and Globals.
class Declaration {
  final Includer _includer;
  final Renamer _renamer;
  final MemberRenamer _memberRenamer;
  final Includer _symbolAddressIncluder;

  Declaration({
    Includer? includer,
    Renamer? renamer,
    MemberRenamer? memberRenamer,
    Includer? symbolAddressIncluder,
  })  : _includer = includer ?? Includer(),
        _renamer = renamer ?? Renamer(),
        _memberRenamer = memberRenamer ?? MemberRenamer(),
        _symbolAddressIncluder =
            symbolAddressIncluder ?? Includer.excludeByDefault();

  /// Applies renaming and returns the result.
  String renameUsingConfig(String name) => _renamer.rename(name);

  /// Applies member renaming and returns the result.
  String renameMemberUsingConfig(String declaration, String member) =>
      _memberRenamer.rename(declaration, member);

  /// Checks if a name is allowed by a filter.
  bool shouldInclude(String name, bool excludeAllByDefault) =>
      _includer.shouldInclude(name, excludeAllByDefault);

  /// Checks if the symbol address should be included for this name.
  bool shouldIncludeSymbolAddress(String name) =>
      _symbolAddressIncluder.shouldInclude(name);
}

/// Matches `$<single_digit_int>`, value can be accessed in group 1 of match.
final replaceGroupRegexp = RegExp(r'\$([0-9])');

/// Match/rename using [regExp].
class RegExpRenamer {
  final RegExp regExp;
  final String replacementPattern;

  RegExpRenamer(this.regExp, this.replacementPattern);

  /// Returns true if [str] has a full match with [regExp].
  bool matches(String str) => quiver.matchesFull(regExp, str);

  /// Renames [str] according to [replacementPattern].
  ///
  /// Returns [str] if [regExp] doesn't have a full match.
  String rename(String str) {
    if (matches(str)) {
      // Get match.
      final regExpMatch = regExp.firstMatch(str)!;

      /// Get group values.
      /// E.g for `str`: `clang_dispose` and `regExp`: `clang_(.*)`
      /// groups will be `0`: `clang_disponse`, `1`: `dispose`.
      final groups = regExpMatch.groups(
          List.generate(regExpMatch.groupCount, (index) => index) +
              [regExpMatch.groupCount]);

      /// Replace all `$<int>` symbols with respective groups (if any).
      final result =
          replacementPattern.replaceAllMapped(replaceGroupRegexp, (match) {
        final groupInt = int.parse(match.group(1)!);
        return groups[groupInt]!;
      });
      return result;
    } else {
      return str;
    }
  }

  @override
  String toString() {
    return 'Regexp: $regExp, ReplacementPattern: $replacementPattern';
  }
}

/// Handles `include/exclude` logic for a declaration.
class Includer {
  final List<RegExp> _includeMatchers;
  final Set<String> _includeFull;
  final List<RegExp> _excludeMatchers;
  final Set<String> _excludeFull;

  Includer({
    List<RegExp>? includeMatchers,
    Set<String>? includeFull,
    List<RegExp>? excludeMatchers,
    Set<String>? excludeFull,
  })  : _includeMatchers = includeMatchers ?? [],
        _includeFull = includeFull ?? {},
        _excludeMatchers = excludeMatchers ?? [],
        _excludeFull = excludeFull ?? {};

  Includer.excludeByDefault()
      : _includeMatchers = [],
        _includeFull = {},
        _excludeMatchers = [RegExp('.*', dotAll: true)],
        _excludeFull = {};

  /// Returns true if [name] is allowed.
  ///
  /// Exclude overrides include.
  bool shouldInclude(String name, [bool excludeAllByDefault = false]) {
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
      // Otherwise, fall back to the default behavior for empty filters.
      return !excludeAllByDefault;
    }
  }
}

/// Handles `full/regexp` renaming logic.
class Renamer {
  final Map<String, String> _renameFull;
  final List<RegExpRenamer> _renameMatchers;

  Renamer({
    List<RegExpRenamer>? renamePatterns,
    Map<String, String>? renameFull,
  })  : _renameMatchers = renamePatterns ?? [],
        _renameFull = renameFull ?? {};

  Renamer.noRename()
      : _renameMatchers = [],
        _renameFull = {};

  String rename(String name) {
    // Apply full rename (if any).
    if (_renameFull.containsKey(name)) {
      return _renameFull[name]!;
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

/// Match declaration name using [declarationRegExp].
class RegExpMemberRenamer {
  final RegExp declarationRegExp;
  final Renamer memberRenamer;

  RegExpMemberRenamer(this.declarationRegExp, this.memberRenamer);

  /// Returns true if [declaration] has a full match with [regExp].
  bool matchesDeclarationName(String declaration) =>
      quiver.matchesFull(declarationRegExp, declaration);

  @override
  String toString() {
    return 'DeclarationRegExp: $declarationRegExp, MemberRenamer: $memberRenamer';
  }
}

/// Handles `full/regexp` member renaming.
class MemberRenamer {
  final Map<String, Renamer> _memberRenameFull;
  final List<RegExpMemberRenamer> _memberRenameMatchers;

  final Map<String, Renamer> _cache = {};

  MemberRenamer({
    Map<String, Renamer>? memberRenameFull,
    List<RegExpMemberRenamer>? memberRenamePattern,
  })  : _memberRenameFull = memberRenameFull ?? {},
        _memberRenameMatchers = memberRenamePattern ?? [];

  String rename(String declaration, String member) {
    if (_cache.containsKey(declaration)) {
      return _cache[declaration]!.rename(member);
    }

    // Apply full rename (if any).
    if (_memberRenameFull.containsKey(declaration)) {
      // Add to cache.
      _cache[declaration] = _memberRenameFull[declaration]!;
      return _cache[declaration]!.rename(member);
    }

    // Apply rename regexp (if matches).
    for (final renamer in _memberRenameMatchers) {
      if (renamer.matchesDeclarationName(declaration)) {
        // Add to cache.
        _cache[declaration] = renamer.memberRenamer;
        return _cache[declaration]!.rename(member);
      }
    }

    // No renaming is provided for this declaration, return unchanged.
    return member;
  }
}

/// Handles config for automatically added compiler options.
class CompilerOptsAuto {
  final bool macIncludeStdLib;

  CompilerOptsAuto({bool? macIncludeStdLib})
      : macIncludeStdLib = macIncludeStdLib ?? true;

  /// Extracts compiler options based on OS and config.
  List<String> extractCompilerOpts() {
    if (Platform.isMacOS && macIncludeStdLib) {
      return getCStandardLibraryHeadersForMac();
    }

    return [];
  }
}

class _ObjCModulePrefixerEntry {
  final RegExp pattern;
  final String moduleName;

  _ObjCModulePrefixerEntry(this.pattern, this.moduleName);
}

/// Handles applying module prefixes to ObjC classes.
class ObjCModulePrefixer {
  final _prefixes = <_ObjCModulePrefixerEntry>[];

  ObjCModulePrefixer(Map<String, String> prefixes) {
    for (final entry in prefixes.entries) {
      _prefixes.add(_ObjCModulePrefixerEntry(RegExp(entry.key), entry.value));
    }
  }

  /// If any of the prefixing patterns match, applies that module prefix.
  /// Otherwise returns the class name unmodified.
  String applyPrefix(String className) {
    for (final entry in _prefixes) {
      if (quiver.matchesFull(entry.pattern, className)) {
        return '${entry.moduleName}.$className';
      }
    }
    return className;
  }
}

class FfiNativeConfig {
  final bool enabled;
  final String? asset;

  const FfiNativeConfig({required this.enabled, this.asset});
}

class SymbolFile {
  final String importPath;
  final String output;

  SymbolFile(this.importPath, this.output);
}

class OutputConfig {
  final String output;
  final SymbolFile? symbolFile;

  OutputConfig(this.output, this.symbolFile);
}

class RawVarArgFunction {
  String? postfix;
  final List<String> rawTypeStrings;

  RawVarArgFunction(this.postfix, this.rawTypeStrings);
}

class VarArgFunction {
  final String postfix;
  final List<Type> types;

  VarArgFunction(this.postfix, this.types);
}
