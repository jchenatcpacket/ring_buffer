let () = print_endline "Hello, World!"

module RingBuffer = struct
  type 'a option state = {
    ring_buffer: 'a option Array;
    mutable write_p: int;
    mutable read_p: int;
  }
  let state = {
    ring_buffer: Array.make 10 None;
    mutable write_p: 0;
    mutable read_p: 0;
  }

  let write state something =
    state.ring_buffer.(state.write_p) <- Some something;
    state.write_p <- state.write_p + 1;;
  let read state =
    match state.read_p < state.write_p with
    | false -> Error
    | _ -> let something = state.ring_buffer.(state.read_p) in something; state.read_p <- state.read_p + 1;;
end