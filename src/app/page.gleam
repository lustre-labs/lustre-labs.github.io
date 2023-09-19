// IMPORTS ---------------------------------------------------------------------

import app/layout
import gleam/list
import lustre/element.{Element}
import lustre/ssg.{Config, HasStaticRoutes}

// TYPES -----------------------------------------------------------------------

pub type Page {
  Page(
    title: String,
    content_path: String,
    route: String,
    render: fn(Page) -> Element(Nil),
  )
}

// CONSTRUCTORS ----------------------------------------------------------------

pub fn add_routes(config: Config(a, b)) -> Config(HasStaticRoutes, b) {
  config
  |> ssg.add_static_route("/", layout.homepage("./content/docs/quickstart.md"))
  |> list.fold(api, _, add_route)
  |> list.fold(docs, _, add_route)
  |> list.fold(guides, _, add_route)
}

fn add_route(config: Config(a, b), page: Page) -> Config(HasStaticRoutes, b) {
  ssg.add_static_route(config, page.route, page.render(page))
}

// UTILS -----------------------------------------------------------------------

fn view_page(page: Page) -> Element(Nil) {
  layout.page(page.content_path, page.title, transform_type_headings: False)
}

fn view_api_page(page: Page) -> Element(Nil) {
  layout.page(page.content_path, page.title, transform_type_headings: True)
}

// CONSTANTS -------------------------------------------------------------------

const api = [
  Page("lustre", "./content/api/lustre.md", "/api/lustre", view_api_page),
  Page(
    "lustre/attribute",
    "./content/api/lustre/attribute.md",
    "/api/lustre/attribute",
    view_api_page,
  ),
  Page(
    "lustre/effect",
    "./content/api/lustre/effect.md",
    "/api/lustre/effect",
    view_api_page,
  ),
  Page(
    "lustre/element",
    "./content/api/lustre/element.md",
    "/api/lustre/element",
    view_api_page,
  ),
  Page(
    "lustre/element/html",
    "./content/api/lustre/element/html.md",
    "/api/lustre/element/html",
    view_api_page,
  ),
  Page(
    "lustre/element/svg",
    "./content/api/lustre/element/svg.md",
    "/api/lustre/element/svg",
    view_api_page,
  ),
  Page(
    "lustre/event",
    "./content/api/lustre/event.md",
    "/api/lustre/event",
    view_api_page,
  ),
]

const docs = [
  Page(
    "Quickstart",
    "./content/docs/quickstart.md",
    "/docs/quickstart",
    view_page,
  ),
  Page(
    "Managing state",
    "./content/docs/managing-state.md",
    "/docs/managing-state",
    view_page,
  ),
  Page(
    "Side effects",
    "./content/docs/side-effects.md",
    "/docs/side-effects",
    view_page,
  ),
  Page(
    "Components",
    "./content/docs/components.md",
    "/docs/components",
    view_page,
  ),
  Page(
    "Server-side rendering",
    "./content/docs/server-side-rendering.md",
    "/docs/server-side-rendering",
    view_page,
  ),
]

const guides = [
  Page("Using with Mist", "./content/guides/mist.md", "/guides/mist", view_page),
  Page("Using with Wisp", "./content/guides/wisp.md", "/guides/wisp", view_page),
]
