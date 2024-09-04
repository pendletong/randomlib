export function now() {
  return Date.now() * 1000;
}

export function to_n_bits(bi, n) {
  return bi & (2n**BigInt(n)-1n);
}

export function shift_left(bi, n) {
  return bi << BigInt(n)
}

export function shift_right(bi, n) {
  return bi >> BigInt(n)
}