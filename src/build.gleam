// IMPORTS ---------------------------------------------------------------------

import app/page
import gleam/bool
import gleam/list
import lustre/ssg
import shellout

// MAIN ------------------------------------------------------------------------

pub fn main() {
  let argv = shellout.arguments()

  ssg.new("./docs")
  |> page.add_routes
  |> ssg.add_static_dir("./static")
  |> ssg.use_index_routes
  |> ssg.build

  let assert Ok(_) = build_tailwind()
  let assert Ok(_) = build_javascript()

  bool.guard(!list.contains(argv, "--serve"), Nil, serve)
}

// BUILD -----------------------------------------------------------------------

fn build_tailwind() {
  let input = "./src/styles.css"
  let output = "./docs/styles.css"

  shellout.command("npx", ["tailwindcss", "-i", input, "-o", output], ".", [])
}

fn build_javascript() {
  let input = "./src/app.mjs"
  let output = "./docs/app.js"

  shellout.command(
    "npx",
    ["esbuild", input, "--bundle", "--outfile=" <> output],
    ".",
    [],
  )
}

// SERVE -----------------------------------------------------------------------

fn serve() {
  let assert Ok(_) = shellout.command("npx", ["http-server", "./docs"], ".", [])

  Nil
}
