import gleam/io
import gleam/list
import randomlib

pub fn main() {
  io.print("Hello from randomlib!")
  io.debug(randomlib.with_seed(919_191))
  list.range(0, 9)
  |> list.fold(#(-1, randomlib.with_seed(919_191)), fn(acc, e) {
    let #(_last, rnd) = acc
    randomlib.next_bits(rnd, 8)
    |> io.debug
  })
  io.debug("Next")
  io.debug(randomlib.next(randomlib.Random(252_758_543_459_965), 8))
  io.debug(randomlib.next(randomlib.Random(252_758_543_459_965), 48))
  io.debug(randomlib.next(randomlib.Random(252_758_543_459_965), 96))
  io.debug(randomlib.next(randomlib.Random(252_758_543_459_965), 100))
  io.debug(randomlib.next(randomlib.Random(252_758_543_459_965), 192))
  // list.range(0, 99)
  // |> list.fold(#(False, new()), fn(acc, _e) {
  //   let #(_, rnd) = acc

  //   next_bool(rnd) |> io.debug
  // })
  // |> io.debug
}
