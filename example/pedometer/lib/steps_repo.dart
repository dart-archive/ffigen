// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:isolate';

import 'package:intl/intl.dart';

import 'pedometer_bindings_generated.dart' as pd;

typedef PedometerHandler = pd.ObjCBlock_ffiVoid_CMPedometerData_NSError;
late PedometerHandler handler;

/// Class to hold the information needed for the chart
class Steps {
  String startHour;
  int steps;
  Steps(this.startHour, this.steps);
}

class StepsRepo {
  static const _formatString = "yyyy-MM-dd HH:mm:ss";
  static const _dylibPath =
      '/System/Library/Frameworks/CoreMotion.framework/CoreMotion';

  // Bindings for the CMPedometer class
  final lib = pd.PedometerBindings(ffi.DynamicLibrary.open(_dylibPath));

  late final pd.CMPedometer client;
  late final pd.NSDateFormatter formatter;
  late final pd.NSDateFormatter hourFormatter;

  static StepsRepo? _instance;
  static StepsRepo get instance => _instance ??= StepsRepo();

  StepsRepo() {
    // Create a new CMPedometer instance.
    client = pd.CMPedometer.new1(lib);

    // Setting the formatter for date strings.
    formatter =
        pd.NSDateFormatter.castFrom(pd.NSDateFormatter.alloc(lib).init());
    formatter.dateFormat = pd.NSString(lib, "$_formatString zzz");
    hourFormatter =
        pd.NSDateFormatter.castFrom(pd.NSDateFormatter.alloc(lib).init());
    hourFormatter.dateFormat = pd.NSString(lib, "HH");
  }

  pd.NSDate dateConverter(DateTime dartDate) {
    // Format dart date to string.
    final formattedDate = DateFormat(_formatString).format(dartDate);
    // Get current timezone. If eastern african change to AST to follow with NSDate.
    final tz = dartDate.timeZoneName == "EAT" ? "AST" : dartDate.timeZoneName;

    // Create a new NSString with the formatted date and timezone.
    final nString = pd.NSString(lib, "$formattedDate $tz");
    // Convert the NSString to NSDate.
    return formatter.dateFromString_(nString);
  }

  @override
  Future<List<Steps>> getSteps() async {
    if (!pd.CMPedometer.isStepCountingAvailable(lib)) {
      print("Step counting is not available.");
      return [];
    }

    final futures = <Future<pd.CMPedometerData>>[];
    final now = DateTime.now();

    for (int h = 0; h <= now.hour; h++) {
      final completer = Completer<pd.CMPedometerData>();
      futures.add(completer.future);

      handler = PedometerHandler.listener(lib, (ffi.Pointer<pd.ObjCObject> pedometerData, ffi.Pointer<pd.ObjCObject> error) {
        if(error == ffi.nullptr){
          completer.complete(pd.CMPedometerData.castFromPointer(
              lib, pedometerData, retain: true, release: true));
        } else{
          print("Error: $error");
        }
      });

      final start = dateConverter(DateTime(now.year, now.month, now.day, h));
      final end = dateConverter(DateTime(now.year, now.month, now.day, h + 1));
      client.queryPedometerDataFromDate_toDate_withHandler_(
          start, end, handler.pointer);
    }

    final data = await Future.wait(futures);
    return data.map((pd.CMPedometerData pedometerData) {
      final stepCount = pedometerData.numberOfSteps?.intValue ?? 0;
      final startHour =
          hourFormatter.stringFromDate_(pedometerData.startDate!).toString();
      return Steps(startHour, stepCount);
    }).toList();
  }
}
