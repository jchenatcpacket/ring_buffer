type 'a state = {
  ring_buffer: 'a option array;
  mutable write_p: int;
  mutable read_p: int;
  mutable count: int;
  capacity: int;
}

let create capacity = {
  ring_buffer = Array.make capacity None;
  write_p = 0;
  read_p = 0;
  count = 0;
  capacity;
}

let write state something =
  state.ring_buffer.(state.write_p) <- Some something;
  state.write_p <- (state.write_p + 1) mod state.capacity;
  state.count <- state.count + 1

let read state =
  if state.count = 0 then
    Error "buffer is empty"
  else
    let value = state.ring_buffer.(state.read_p) in
    state.ring_buffer.(state.read_p) <- None;
    state.read_p <- (state.read_p + 1) mod state.capacity;
    state.count <- state.count - 1;
    Ok value
