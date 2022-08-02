import Foundation

@objc class FooClass: NSObject {
  var val = 123;
  @objc func getValue() -> Int {
    return val;
  }
  @objc func setValue(x: Int) {
    val = x;
  }
}
