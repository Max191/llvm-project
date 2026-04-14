// RUN: mlir-opt -pass-pipeline='builtin.module(func.func(test-staged-analyses))' %s | FileCheck %s

// CHECK-LABEL: func.func @linear()
func.func @linear() {
  // CHECK: "test.foo"() {bar_add = 3 : ui64, bar_state = 3 : i64, foo_state = 0 : i64, tag = "annotate"} : () -> ()
  "test.foo"() {tag = "annotate", bar_add = 3 : ui64} : () -> ()
  // CHECK: "test.foo"() {bar_add = 4 : ui64, bar_state = 5 : i64, foo = 1 : ui64, foo_state = 1 : i64, tag = "annotate"} : () -> ()
  "test.foo"() {tag = "annotate", foo = 1 : ui64, bar_add = 4 : ui64} : () -> ()
  // CHECK: "test.foo"() {bar_state = 0 : i64, foo = 1 : ui64, foo_state = 0 : i64, tag = "annotate"} : () -> ()
  "test.foo"() {tag = "annotate", foo = 1 : ui64} : () -> ()
  return
}

// CHECK-LABEL: func.func @branch()
func.func @branch() {
  // CHECK: "test.branch"()[^bb{{[0-9]+}}, ^bb{{[0-9]+}}] {bar_add = 10 : ui64, bar_state = 11 : i64, foo = 1 : ui64, foo_state = 1 : i64, tag = "annotate"} : () -> ()
  "test.branch"() [^bb0, ^bb1] {tag = "annotate", foo = 1 : ui64, bar_add = 10 : ui64} : () -> ()

^bb0:
  // CHECK: "test.branch"()[^bb{{[0-9]+}}] {bar_add = 100 : ui64, bar_state = 103 : i64, foo = 2 : ui64, foo_state = 3 : i64, tag = "annotate"} : () -> ()
  "test.branch"() [^bb2] {tag = "annotate", foo = 2 : ui64, bar_add = 100 : ui64} : () -> ()

^bb1:
  // CHECK: "test.branch"()[^bb{{[0-9]+}}] {bar_add = 1000 : ui64, bar_state = 1005 : i64, foo = 4 : ui64, foo_state = 5 : i64, tag = "annotate"} : () -> ()
  "test.branch"() [^bb2] {tag = "annotate", foo = 4 : ui64, bar_add = 1000 : ui64} : () -> ()

^bb2:
  // CHECK: "test.foo"() {bar_add = 7 : ui64, bar_state = 13 : i64, foo_state = 6 : i64, tag = "annotate"} : () -> ()
  "test.foo"() {tag = "annotate", bar_add = 7 : ui64} : () -> ()
  return
}
