import bigi.{type BigInt}
import gleam/float
import gleam/int

pub type Random {
  Random(seed: Int)
}

const unique_seed = 8_682_522_807_148_012

const multiplier = 25_214_903_917

const bitmask_48 = 281_474_976_710_655

pub fn new() {
  Random(initial_scramble(init_seed()))
}

pub fn with_seed(seed: Int) {
  Random(initial_scramble(seed))
}

fn init_seed() -> Int {
  let assert Ok(cong_gen) = bigi.from_string("1181783497276652981")
  let assert Ok(init_seed) =
    bigi.to_int(ffi_to_n_bits(
      bigi.multiply(bigi.from_int(unique_seed), cong_gen),
      48,
    ))
  int.bitwise_exclusive_or(init_seed, ffi_now())
}

fn initial_scramble(seed: Int) -> Int {
  int.bitwise_and(int.bitwise_exclusive_or(seed, multiplier), bitmask_48)
}

pub fn next_bits(rnd: Random, bits: Int) -> #(Int, Random) {
  let assert Ok(next_seed) =
    bigi.to_int(ffi_to_n_bits(
      bigi.add(
        ffi_to_n_bits(
          bigi.multiply(bigi.from_int(rnd.seed), bigi.from_int(multiplier)),
          64,
        ),
        bigi.from_int(11),
      ),
      48,
    ))
  let next_num = int.bitwise_shift_right(next_seed, 48 - bits)
  #(next_num, Random(next_seed))
}

pub fn do_next(bits: Int, res: #(BigInt, Random)) -> #(BigInt, Random) {
  let #(bi, rnd) = res
  case bits > 48 {
    True -> {
      let #(next, rnd) = next_bits(rnd, 48)
      do_next(bits - 48, #(
        bigi.add(ffi_shift_left(bi, 48), bigi.from_int(next)),
        rnd,
      ))
    }
    False -> {
      case bits {
        0 -> res
        bits -> {
          let #(next, rnd) = next_bits(rnd, bits)
          #(bigi.add(ffi_shift_left(bi, 48), bigi.from_int(next)), rnd)
        }
      }
    }
  }
}

pub fn next(rnd: Random, bits: Int) -> #(BigInt, Random) {
  do_next(bits, #(bigi.zero(), rnd))
}

pub fn next_bool(rnd: Random) -> #(Bool, Random) {
  let #(val, rnd) = next_bits(rnd, 1)
  #(val == 0, rnd)
}

@external(erlang, "randomlib_ffi", "now")
@external(javascript, "./randomlib_ffi.mjs", "now")
fn ffi_now() -> Int

@external(javascript, "./randomlib_ffi.mjs", "to_n_bits")
fn ffi_to_n_bits(bi: BigInt, n: Int) -> BigInt {
  let assert Ok(i) = bigi.to_int(bi)
  let assert Ok(pow) = int.power(2, int.to_float(n))
  bigi.from_int(int.bitwise_and(i, float.truncate(pow) - 1))
}

@external(javascript, "./randomlib_ffi.mjs", "shift_left")
fn ffi_shift_left(bi: BigInt, n: Int) -> BigInt {
  let assert Ok(i) = bigi.to_int(bi)

  bigi.from_int(int.bitwise_shift_left(i, n))
}
