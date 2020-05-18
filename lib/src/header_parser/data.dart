/// Holds all temp data needed by parser, all data is mutable
import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/config_provider.dart';

/// Holds configurations
Config config;

/// final bindings
List<Binding> bindings = <Binding>[];

/// Temporarily holds a function
Func func;
