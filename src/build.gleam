// IMPORTS ---------------------------------------------------------------------

import app/page
import gleam/bool
import gleam/function
import gleam/io
import gleam/list
import gleam/result.{try}
import gleam/string
import lustre/element
import lustre/ssg.{type BuildError, SimplifileError}
import simplifile.{type FileError}

// MAIN ------------------------------------------------------------------------

pub fn main() {
  let site =
    ssg.new("./docs")
    |> ssg.add_static_dir("./static")
    |> ssg.add_static_route("/404", element.text("Not found"))

  let lustre_ui_styles = "./build/packages/lustre_ui/priv/styles.css"

  use css <- try_simplifile(simplifile.read(lustre_ui_styles))
  use _ <- try_simplifile(simplifile.write("./static/lustre-ui.css", css))

  use content <- try_simplifile(simplifile.get_files("./src/content"))
  use site <- try({
    use site, path <- list.try_fold(content, site)
    use <- bool.guard(!string.ends_with(path, ".djot"), Ok(site))
    use file <- try_simplifile(simplifile.read(path))
    let #(metadata, content) = page.render(file)

    Ok(ssg.add_static_route(site, metadata.route, content))
  })

  site
  |> ssg.build
}

// UTILS -----------------------------------------------------------------------

fn try_simplifile(
  r: Result(a, FileError),
  k: fn(a) -> Result(b, BuildError),
) -> Result(b, BuildError) {
  r
  |> result.map_error(function.compose(io.debug, SimplifileError))
  |> result.then(k)
}
