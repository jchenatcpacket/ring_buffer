let test_count = ref 0
let fail_count = ref 0

let assert_equal name expected actual =
  incr test_count;
  if expected = actual then
    Printf.printf "PASS: %s\n" name
  else begin
    incr fail_count;
    Printf.printf "FAIL: %s\n" name
  end

let assert_true name condition =
  incr test_count;
  if condition then
    Printf.printf "PASS: %s\n" name
  else begin
    incr fail_count;
    Printf.printf "FAIL: %s\n" name
  end

let test_read_from_empty_buffer () =
  let buf = Ring_buffer.create 4 in
  match Ring_buffer.read buf with
  | Error _ -> assert_true "read from empty buffer returns Error" true
  | Ok _ -> assert_true "read from empty buffer returns Error" false

let test_write_then_read () =
  let buf = Ring_buffer.create 4 in
  Ring_buffer.write buf 42;
  match Ring_buffer.read buf with
  | Ok (Some 42) -> assert_true "write then read returns correct value" true
  | _ -> assert_true "write then read returns correct value" false

let test_fifo_order () =
  let buf = Ring_buffer.create 4 in
  Ring_buffer.write buf 1;
  Ring_buffer.write buf 2;
  Ring_buffer.write buf 3;
  let v1 = Ring_buffer.read buf in
  let v2 = Ring_buffer.read buf in
  let v3 = Ring_buffer.read buf in
  assert_equal "first read is 1" (Ok (Some 1)) v1;
  assert_equal "second read is 2" (Ok (Some 2)) v2;
  assert_equal "third read is 3" (Ok (Some 3)) v3

let test_read_after_drain () =
  let buf = Ring_buffer.create 4 in
  Ring_buffer.write buf 1;
  let _ = Ring_buffer.read buf in
  match Ring_buffer.read buf with
  | Error _ -> assert_true "read after drain returns Error" true
  | Ok _ -> assert_true "read after drain returns Error" false

let test_wrap_around () =
  let buf = Ring_buffer.create 3 in
  (* Fill and drain to advance pointers *)
  Ring_buffer.write buf 1;
  Ring_buffer.write buf 2;
  let _ = Ring_buffer.read buf in
  let _ = Ring_buffer.read buf in
  (* Now write_p=2, read_p=2. Write again to trigger wrap-around *)
  Ring_buffer.write buf 3;
  Ring_buffer.write buf 4;
  let v1 = Ring_buffer.read buf in
  let v2 = Ring_buffer.read buf in
  assert_equal "wrap-around read 1" (Ok (Some 3)) v1;
  assert_equal "wrap-around read 2" (Ok (Some 4)) v2

let test_read_clears_slot () =
  let buf = Ring_buffer.create 4 in
  Ring_buffer.write buf 99;
  let _ = Ring_buffer.read buf in
  (* The slot at index 0 should now be None *)
  assert_equal "slot cleared after read" None buf.ring_buffer.(0)

let test_multiple_wrap_arounds () =
  let buf = Ring_buffer.create 2 in
  for i = 0 to 9 do
    Ring_buffer.write buf i;
    let result = Ring_buffer.read buf in
    assert_equal (Printf.sprintf "multi wrap-around iteration %d" i) (Ok (Some i)) result
  done

let test_capacity_one () =
  let buf = Ring_buffer.create 1 in
  Ring_buffer.write buf 5;
  let v = Ring_buffer.read buf in
  assert_equal "capacity 1 write/read" (Ok (Some 5)) v;
  (match Ring_buffer.read buf with
   | Error _ -> assert_true "capacity 1 empty after read" true
   | Ok _ -> assert_true "capacity 1 empty after read" false)

let () =
  print_endline "=== Ring Buffer Tests ===";
  print_newline ();
  test_read_from_empty_buffer ();
  test_write_then_read ();
  test_fifo_order ();
  test_read_after_drain ();
  test_wrap_around ();
  test_read_clears_slot ();
  test_multiple_wrap_arounds ();
  test_capacity_one ();
  print_newline ();
  Printf.printf "Results: %d/%d passed\n" (!test_count - !fail_count) !test_count;
  if !fail_count > 0 then exit 1
