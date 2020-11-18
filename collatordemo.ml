open !Core_kernel
open Bap_main
open Bap.Std

module Cmd = Extension.Command
module Typ = Extension.Type

module Loader = struct

  let loader = "llvm"

  let load (filename : string) : Project.t =
    let input = Project.Input.file ~loader ~filename in
    let proj = Project.create input ~package:filename in
    match proj with
    | Ok p -> p
    | Error e -> failwith @@ Error.to_string_hum e

  let get_sub (prog : Program.t) (name : string) : Sub.t =
    let subs = Term.enum sub_t prog in
    Seq.find_exn ~f:(fun s -> String.equal (Sub.name s) name) subs

end

module Mult = struct

  let package = "collatordemo"
  let name = "collator-demo"

  (* A do-nothing state for now... *)
  type state = unit
  let initial_state = () 

  let seq_of (exes : string list) : project seq =
    let projects = List.map exes ~f:Loader.load in
    Seq.of_list projects

  let prepare (p : Project.t) : state =
    let prog = Project.program p in
    let main = Loader.get_sub prog "main" in
    Format.printf "=== PROGRAM 1 ==========\n%!";
    Format.printf "%a\n%!" Sub.pp main; 
    initial_state

  let collate (version : int) (state : state) (p : Project.t) : state =
    let prog = Project.program p in
    let main = Loader.get_sub prog "main" in
    Format.printf "=== PROGRAM %d ==========\n%!" (version + 2);
    Format.printf "%a\n%!" Sub.pp main; 
    state

  let summary state : unit = print_endline "- Done"

  let process (projects : project Sequence.t) : unit =
    Project.Collator.register ~package ~prepare ~collate ~summary name;
    let collator = Project.Collator.find ~package name in
    match collator with
    | Some coll -> Project.Collator.apply coll projects
    | None -> failwith "No such collator"

end

module Cli = struct

  let name = "collatordemo"
  let doc = "Demo: load multiple binaries into BAP"

  let exe_1 = Cmd.argument Typ.file ~doc:"Path to exe 1"
  let exe_2 = Cmd.argument Typ.file ~doc:"Path to exe 2"

  let grammar = Cmd.(args $ exe_1 $ exe_2)

  let run (exe_1 : string) (exe_2 : string) (_ : ctxt) : (unit, error) result =
    let projects = Mult.seq_of [exe_1; exe_2] in
    Mult.process projects;
    Ok ()

end

let () = Cmd.declare Cli.name Cli.grammar Cli.run ~doc:Cli.doc
