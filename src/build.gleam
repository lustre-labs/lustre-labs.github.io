// IMPORTS ---------------------------------------------------------------------

import app/layout
import gleam/bool
import gleam/list
import gleam/map
import lustre/ssg
import shellout

// CONSTANTS -------------------------------------------------------------------

const outdir = "./docs"

const lustre_api = [
  #("attribute", "../content/api/lustre/attribute.md"),
  #("effect", "../content/api/lustre/effect.md"),
  #("element", "../content/api/lustre/element.md"),
  #("event", "../content/api/lustre/event.md"),
]

const element_api = [
  #("html", "../content/api/lustre/element/html.md"),
  #("svg", "../content/api/lustre/element/svg.md"),
]

const docs = [
  #("components", "../content/docs/components.md"),
  #("managing-state", "../content/docs/managing-state.md"),
  #("quickstart", "../content/docs/quickstart.md"),
  #("server-side-rendering", "../content/docs/server-side-rendering.md"),
  #("side-effects", "../content/docs/side-effects.md"),
]

const guides = [
  #("mist", "../content/guides/mist.md"),
  #("wisp", "../content/guides/wisp.md"),
]

// MAIN ------------------------------------------------------------------------

pub fn main() {
  let argv = shellout.arguments()
  let page = layout.page(_, False)
  let api = layout.page(_, True)

  ssg.new(outdir)
  |> ssg.add_static_route("/", layout.homepage("../content/docs/quickstart.md"))
  |> ssg.add_static_route("/api/lustre", page("../content/api/lustre.md"))
  |> ssg.add_dynamic_route("/api/lustre", map.from_list(lustre_api), api)
  |> ssg.add_dynamic_route(
    "/api/lustre/element",
    map.from_list(element_api),
    api,
  )
  |> ssg.add_dynamic_route("/docs", map.from_list(docs), page)
  |> ssg.add_dynamic_route("/guides", map.from_list(guides), page)
  |> ssg.build

  bool.guard(!list.contains(argv, "--build-assets"), Nil, build_assets)
  bool.guard(!list.contains(argv, "--serve"), Nil, serve)
}

// BUILD -----------------------------------------------------------------------

fn build_assets() {
  let assert Ok(_) = build_tailwind()
  let assert Ok(_) = build_javascript()

  Nil
}

fn build_tailwind() {
  let input = "./src/styles.css"
  let output = outdir <> "/styles.css"

  shellout.command("npx", ["tailwindcss", "-i", input, "-o", output], ".", [])
}

fn build_javascript() {
  let input = "./src/app.mjs"
  let output = outdir <> "/app.js"

  shellout.command(
    "npx",
    ["esbuild", input, "--bundle", "--outfile=" <> output],
    ".",
    [],
  )
}

// SERVE -----------------------------------------------------------------------

fn serve() {
  let assert Ok(_) = shellout.command("npx", ["http-server", outdir], ".", [])

  Nil
}
