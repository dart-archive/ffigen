/// Holds all temp data needed by parser, all data is mutable
import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/config_provider.dart';

/// Holds configurations
Config config;

/// final bindings
List<Binding> bindings = <Binding>[];

/// Temporarily holds a function
Func func;

/// Temporarily holds an Exception, to call later
///
/// When an exception occurs in visitor dart function called via a C,
/// It exits with a result code: 0 [CXChildVisit_Break].
/// This exception is called when that happens,
/// The stack trace is lost, but message is reprinted.
Exception exception = Exception('Untracked Exception');
