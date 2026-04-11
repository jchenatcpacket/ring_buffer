# Dev Log

## 1. Fixed Ring Buffer Implementation

The original code in `bin/main.ml` had several bugs:

- `'a option Array` — should be lowercase `array`
- Record value used type declaration syntax (`mutable`, `:`) instead of value syntax (`=`)
- Missing `capacity` field in record value
- Bare `Error` — needed `Error "message"` for a valid `result` type
- `read` discarded the value instead of returning it
- No modulo wrap-around on pointers (not actually a ring)

All fixed. Replaced the hardcoded `state` value with a `create` constructor function.

## 2. Updated README

Changed description to: "A vibe coded implementation of a ring buffer data structure in OCaml."

## 3. Updated .gitignore

Added `bin/ocamllsp`, `lib/ocaml-lsp-server/`, and `doc/ocaml-lsp-server/` to ignore OCaml LSP server files.

## 4. Wrote Tests

Moved `RingBuffer` module from `bin/main.ml` into `lib/ring_buffer.ml` so both the executable and tests can share it.

Tests written (21 assertions, all passing):

- Read from empty buffer returns `Error`
- Basic write/read round-trip
- FIFO ordering across multiple writes
- Read after draining returns `Error`
- Pointer wrap-around at capacity boundary
- Read clears the slot back to `None`
- 10 write/read cycles on a capacity-2 buffer
- Edge case: capacity of 1

Tests uncovered a bug: the original `read_p = write_p` empty check can't distinguish full from empty. Added a `count` field to fix this.
