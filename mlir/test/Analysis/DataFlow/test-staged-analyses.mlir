// RUN: mlir-opt -pass-pipeline='builtin.module(func.func(test-staged-analyses))' %s | FileCheck %s

// CHECK-LABEL: func.func @linear()
func.func @linear() {
  // CHECK: "test.foo"() {foo = 1 : ui64, foo_state = 1 : i64, simultaneous_bar_state = true, staged_bar_state = true, tag = "annotate"} : () -> ()
  "test.foo"() {tag = "annotate", foo = 1 : ui64} : () -> ()
  // CHECK: "test.foo"() {foo = 2 : ui64, foo_state = 3 : i64, simultaneous_bar_state = true, staged_bar_state = true, tag = "annotate"} : () -> ()
  "test.foo"() {tag = "annotate", foo = 2 : ui64} : () -> ()
  // CHECK: "test.foo"() {foo_state = 3 : i64, simultaneous_bar_state = true, staged_bar_state = true, tag = "annotate"} : () -> ()
  "test.foo"() {tag = "annotate"} : () -> ()
  return
}

// CHECK-LABEL: func.func @requires_staged_bar()
func.func @requires_staged_bar() {
  // CHECK: "test.branch"()[^bb{{[0-9]+}}, ^bb{{[0-9]+}}] : () -> ()
  "test.branch"() [^bb0, ^bb2] : () -> ()

^bb0:
  // CHECK: "test.branch"()[^bb{{[0-9]+}}] {foo = 1 : ui64, foo_state = 1 : i64, simultaneous_bar_state = true, staged_bar_state = true, tag = "annotate"} : () -> ()
  "test.branch"() [^bb1] {tag = "annotate", foo = 1 : ui64} : () -> ()

^bb1:
  // CHECK: "test.foo"() {foo = 1 : ui64, foo_state = 3 : i64, simultaneous_bar_state = false, staged_bar_state = true, tag = "annotate"} : () -> ()
  "test.foo"() {tag = "annotate", foo = 1 : ui64} : () -> ()
  // CHECK: "test.foo"() {foo_state = 3 : i64, simultaneous_bar_state = false, staged_bar_state = true, tag = "annotate"} : () -> ()
  "test.foo"() {tag = "annotate"} : () -> ()
  return

^bb2:
  // CHECK: "test.branch"()[^bb{{[0-9]+}}] {foo = 2 : ui64, foo_state = 2 : i64, simultaneous_bar_state = true, staged_bar_state = true, tag = "annotate"} : () -> ()
  "test.branch"() [^bb1] {tag = "annotate", foo = 2 : ui64} : () -> ()
}
