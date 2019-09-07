type t = Buffer.t

let create ?(initial_size = 1024) () = Buffer.create initial_size

let write_byte = Buffer.add_char

let write_bytes = Buffer.add_string

let contents = Buffer.contents
