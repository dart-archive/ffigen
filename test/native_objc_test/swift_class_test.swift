import Foundation

@objc public class MySwiftClass: NSObject {
  var val = 123;
  @objc public func getValue() -> Int {
    return val;
  }
  @objc public func setValue(x: Int) {
    val = x;
  }
}
