let () =
  let buf = Ring_buffer.create 4 in
  Ring_buffer.write buf 10;
  Ring_buffer.write buf 20;
  Ring_buffer.write buf 30;
  (match Ring_buffer.read buf with
   | Ok (Some v) -> Printf.printf "read: %d\n" v
   | Ok None -> print_endline "read: None"
   | Error msg -> print_endline msg);
  (match Ring_buffer.read buf with
   | Ok (Some v) -> Printf.printf "read: %d\n" v
   | Ok None -> print_endline "read: None"
   | Error msg -> print_endline msg);
  print_endline "Hello, World!"
