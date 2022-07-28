@objc class FooClass {
  var val = 123;
  @objc func getValue() -> Int {
    return val;
  }
  @objc func setValue(x: Int) {
    val = x;
  }
}
