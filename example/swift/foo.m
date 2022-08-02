#import <Foundation/Foundation.h>
#include <objc/runtime.h>
#import "foo.h"

int main() {
  @autoreleasepool {
    FooClass* foo = [FooClass new];
    NSLog(@"%ld", [foo getValue]);
    [foo setValueWithX: 456];
    NSLog(@"%ld", [foo getValue]);

    int numClasses = objc_getClassList(NULL, 0);
    NSLog(@"%d", numClasses);
    Class* classes = malloc(sizeof(Class) * numClasses);
    objc_getClassList(classes, numClasses);
    for (int i = 0; i < numClasses; ++i) {
      NSLog(@"%s", class_getName(classes[i]));
    }
    NSLog(@"%@", objc_getClass("foo.FooClass"));
  }
  return 0;
}
