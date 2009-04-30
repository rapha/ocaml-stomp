module type THREAD =
sig
  type 'a t
  val return : 'a -> 'a t
  val (>>=) : 'a t -> ('a -> 'b t) -> 'b t
  val bind : 'a t -> ('a -> 'b t) -> 'b t
  val catch : (unit -> 'a t) -> (exn -> 'a t) -> 'a t
  val fail : exn -> 'a t

  val iter_serial : ('a -> unit t) -> 'a list -> unit t

  type in_channel
  type out_channel
  val open_connection : Unix.sockaddr -> (in_channel * out_channel) t
  val output_char : out_channel -> char -> unit t
  val output_string : out_channel -> string -> unit t
  val flush : out_channel -> unit t
  val input_char : in_channel -> char t
  val input : in_channel -> string -> int -> int -> int t
  val input_line : in_channel -> string t
  val really_input : in_channel -> string -> int -> int -> unit t
  val close_in : in_channel -> unit t
  val close_out : out_channel -> unit t
end

module Posix_thread : THREAD
  with type 'a t = 'a
   and type in_channel = Pervasives.in_channel
   and type out_channel = Pervasives.out_channel
= struct
  type 'a t = 'a
  let return x = x
  let (>>=) v f =  f v
  let bind = (>>=)
  let fail = raise
  let iter_serial = List.iter

  type in_channel = Pervasives.in_channel
  type out_channel = Pervasives.out_channel
  let open_connection = Unix.open_connection
  let output_char = output_char
  let output_string = output_string
  let flush = flush
  let input_char = input_char
  let input = input
  let input_line = input_line
  let really_input = really_input
  let close_in = close_in
  let close_out = close_out
  let catch f rescue = try f () with e -> rescue e
end

module Green_thread : THREAD
  with type 'a t = 'a Lwt.t
   and type in_channel = Lwt_chan.in_channel
   and type out_channel = Lwt_chan.out_channel 
= struct
  include Lwt_util
  include Lwt_chan
  include Lwt
end
