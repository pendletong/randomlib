import birdie
import gleam/bool
@target(erlang)
import gleam/erlang/process
import gleam/float
import gleam/int
import gleam/iterator
import gleam/list.{Continue, Stop}
import gleam/string
import gleeunit
import gleeunit/should
@target(javascript)
import plinth/javascript/global
import randomlib.{type Random}

pub fn main() {
  gleeunit.main()
}

pub fn new_test() {
  let init = randomlib.new()
  pause(5, fn() {
    let init2 = randomlib.new()

    init |> should.not_equal(init2)
  })
}

pub fn next_bool_test() {
  do_distinct_test(randomlib.new(), False, randomlib.next_bool)

  let rnd = randomlib.with_seed(89_305_027)
  let #(_rnd, l) =
    list.range(1, 30)
    |> list.fold(#(rnd, []), fn(acc, _v) {
      let #(rnd, l) = acc
      let #(next_val, rnd) = randomlib.next_bool(rnd)
      #(rnd, [bool.to_string(next_val), ..l])
    })
  let output = string.join(l, "\n")

  output
  |> birdie.snap(title: "bool test")
}

pub fn next_byte_test() {
  do_distinct_test(randomlib.new(), 0, randomlib.next_byte)

  let rnd = randomlib.with_seed(89_305_027)
  let #(_rnd, l) =
    list.range(1, 30)
    |> list.fold(#(rnd, []), fn(acc, _v) {
      let #(rnd, l) = acc
      let #(next_val, rnd) = randomlib.next_byte(rnd)
      #(rnd, [int.to_string(next_val), ..l])
    })
  let output = string.join(l, "\n")

  output
  |> birdie.snap(title: "byte test")
}

pub fn next_float_test() {
  do_distinct_test(randomlib.new(), 0.0, randomlib.next_float)

  let rnd = randomlib.with_seed(89_305_027)
  let #(_rnd, l) =
    list.range(1, 30)
    |> list.fold(#(rnd, []), fn(acc, _v) {
      let #(rnd, l) = acc
      let #(next_val, rnd) = randomlib.next_float(rnd)
      #(rnd, [float.to_string(next_val), ..l])
    })
  let output = string.join(l, "\n")

  output
  |> birdie.snap(title: "float test")
}

pub fn byte_iterator_test() {
  // check that an iterator starting at the same seed produces the same
  // list of bytes
  let rnd = randomlib.new()
  let l1 = randomlib.byte_iterator(rnd) |> iterator.take(10) |> iterator.to_list
  let l2 = randomlib.byte_iterator(rnd) |> iterator.take(10) |> iterator.to_list

  l1 |> should.equal(l2)

  do_distinct_test(randomlib.new(), [], fn(rnd) {
    #(
      randomlib.byte_iterator(rnd) |> iterator.take(10) |> iterator.to_list,
      rnd,
    )
  })

  let rnd = randomlib.with_seed(89_305_027)
  let l =
    randomlib.byte_iterator(rnd)
    |> iterator.take(10)
    |> iterator.to_list
    |> list.map(int.to_string)
  let output = string.join(l, "\n")

  output
  |> birdie.snap(title: "iterator test")
}

pub fn next_bytes_test() {
  let rnd = randomlib.with_seed(89_305_027)
  let #(_rnd, l) =
    list.range(1, 30)
    |> list.fold(#(rnd, []), fn(acc, _v) {
      let #(rnd, l) = acc
      let #(next_val, rnd) = randomlib.next_bytes(rnd, 5)
      #(rnd, [string.join(next_val |> list.map(int.to_string), ":"), ..l])
    })
  let output = string.join(l, "\n")

  output
  |> birdie.snap(title: "bytes test")
}

/// The tests in java ensure that the random functions don't just
/// produce 10000 values all the same
fn do_distinct_test(
  rnd: Random,
  init_value: value,
  get_rnd: fn(Random) -> #(value, Random),
) -> Nil {
  let i = iterator.range(1, 10_000)

  let #(n, _, _) =
    iterator.fold_until(i, #(0, init_value, rnd), fn(acc, v) {
      let #(_, current, rnd) = acc
      let #(next, rnd) = get_rnd(rnd)
      case next == current {
        True -> Continue(#(v, next, rnd))
        False -> Stop(#(v, next, rnd))
      }
    })

  n |> should.not_equal(10_000)
}

@target(erlang)
fn pause(ms: Int, cb: fn() -> Nil) -> Nil {
  process.sleep(ms)
  cb()
}

@target(javascript)
fn pause(ms: Int, cb: fn() -> Nil) -> Nil {
  global.set_timeout(ms, cb)
  Nil
}
