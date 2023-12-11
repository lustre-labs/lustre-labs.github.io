// IMPORTS ---------------------------------------------------------------------

import app/djot.{
  type Container, type Document, type Inline, Codeblock, Document, Heading, Link,
  Paragraph, Reference, Text, Url,
}
import gleam/bool
import gleam/dict.{type Dict}
import gleam/function
import gleam/list
import gleam/option.{type Option}
import gleam/regex
import gleam/result
import gleam/string
import lustre/attribute.{attribute}
import lustre/element.{type Element}
import lustre/element/html.{html}
import lustre/ui
import lustre/ui/aside
import lustre/ui/box
import lustre/ui/stack
import lustre/ui/icon
import tom

pub fn render(content: String) -> #(Metadata, Element(Nil)) {
  let assert Ok(#(toml, djot)) = string.split_once(content, "---")

  let assert Ok(toml) = tom.parse(toml)
  let assert Ok(title) = tom.get_string(toml, ["title"])
  let assert Ok(route) = tom.get_string(toml, ["route"])
  let assert Ok(description) = tom.get_string(toml, ["description"])

  let Document(content, _) = djot.parse(djot)
  let summary =
    list.filter_map(content, fn(block) {
      case block {
        Heading(attributes, level, inline) -> Ok(#(attributes, level, inline))
        _ -> Error(Nil)
      }
    })
  let chunks = {
    use chunks, block <- list.fold_right(content, [])

    case block, chunks {
      Heading(_, _, _), [head, ..rest] -> [[block, ..head], ..rest]
      _, [[Heading(_, _, _), ..] as head, ..rest] -> [[block], head, ..rest]
      _, [head, ..rest] -> [[block, ..head], ..rest]
      _, [] -> [[block]]
    }
  }
  let content = list.map(chunks, render_djot)
  let metadata = Metadata(title, route, description)

  #(metadata, template(content, metadata, summary))
}

pub type Metadata {
  Metadata(title: String, route: String, description: String)
}

fn template(
  content: List(List(Element(Nil))),
  metadata: Metadata,
  summary: List(#(Dict(String, String), Int, List(Inline))),
) -> Element(Nil) {
  html([attribute("lang", "en")], [
    html.head([], [
      html.meta([attribute("charset", "UTF-8")]),
      html.meta([
        attribute("name", "viewport"),
        attribute("content", "width=device-width, initial-scale=1.0"),
      ]),
      html.title([], "Lustre - catchy tagline."),
      // OPEN GRAPH ------------------------------------------------------------
      html.meta([
        attribute("property", "og:type"),
        attribute("content", "article"),
      ]),
      html.meta([
        attribute("property", "og:title"),
        attribute("content", metadata.title),
      ]),
      html.meta([
        attribute("property", "og:url"),
        attribute("content", "https://lustre.build" <> metadata.route),
      ]),
      html.meta([
        attribute("property", "og:description"),
        attribute("content", metadata.description),
      ]),
      // STYLES ----------------------------------------------------------------
      html.link([
        attribute("rel", "stylesheet"),
        attribute("href", "/lustre-ui.css"),
      ]),
      html.link([
        attribute("rel", "stylesheet"),
        attribute("href", "/styles.css"),
      ]),
      html.link([
        attribute("rel", "stylesheet"),
        attribute(
          "href",
          "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github.min.css",
        ),
      ]),
      html.link([
        attribute("rel", "stylesheet"),
        attribute(
          "href",
          "https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,400&family=Inter:wght@300&display=swap",
        ),
      ]),
      // SCRIPTS ---------------------------------------------------------------
      html.script([attribute.type_("module"), attribute.src("/app.js")], ""),
    ]),
    html.body([], [
      ui.aside(
        [aside.content_last()],
        ui.aside(
          [aside.min_width(80)],
          box.of(html.main, [], [
            ui.stack(
              [stack.loose()],
              list.map(content, stack.of(html.section, [], _)),
            ),
          ]),
          box.of(ui.stack, [stack.tight()], render_summary(summary)),
        ),
        ui.box([attribute.class("dropdown")], [
          ui.stack([stack.loose()], [
            aside.of(
              html.h2,
              [aside.align_centre()],
              html.p([], [element.text("Lustre.")]),
              html.label([attribute.class("toggle")], [
                html.input([attribute.type_("checkbox")]),
                icon.hamburger_menu([attribute.class("open")]),
                icon.cross([attribute.class("close")]),
              ]),
            ),
            stack.of(html.nav, [stack.tight()], [
              html.h3([], [element.text("Reference")]),
              html.a([attribute.href("/api/lustre")], [element.text("lustre")]),
              html.a([attribute.href("/api/lustre/attribute")], [
                element.text("lustre/attribute"),
              ]),
              html.a([attribute.href("/api/lustre/effect")], [
                element.text("lustre/effect"),
              ]),
              html.a([attribute.href("/api/lustre/element")], [
                element.text("lustre/element"),
              ]),
              html.a([attribute.href("/api/lustre/element/html")], [
                element.text("lustre/element/html"),
              ]),
              html.a([attribute.href("/api/lustre/element/svg")], [
                element.text("lustre/element/svg"),
              ]),
              html.a([attribute.href("/api/lustre/event")], [
                element.text("lustre/event"),
              ]),
            ]),
            stack.of(html.nav, [stack.tight()], [
              html.h3([], [element.text("Tutorial")]),
              html.a([attribute.href("/docs/quickstart")], [
                element.text("Quickstart"),
              ]),
              html.a([attribute.href("/docs/managing-state")], [
                element.text("Managing state"),
              ]),
              html.a([attribute.href("/docs/side-effects")], [
                element.text("Side effects"),
              ]),
              html.a([attribute.href("/docs/server-side-rendering")], [
                element.text("Server-side rendering"),
              ]),
              html.a([attribute.href("/docs/components")], [
                element.text("Components"),
              ]),
            ]),
            stack.of(html.nav, [stack.tight()], [
              html.h3([], [element.text("Guides")]),
              html.a([attribute.href("/guides/wisp")], [
                element.text("Integrating with Wisp"),
              ]),
            ]),
          ]),
        ]),
      ),
    ]),
  ])
}

fn render_summary(
  headings: List(#(Dict(String, String), Int, List(Inline))),
) -> List(Element(Nil)) {
  let level = fn(heading: #(a, Int, b)) { heading.1 }
  let chunks = list.chunk(headings, level)
  use headings <- list.map(chunks)

  ui.stack([stack.packed()], {
    use heading <- list.filter_map(headings)
    use <- bool.guard(heading.1 == 1, Error(Nil))
    let href = "#" <> section_id(heading.0, heading.1, heading.2)

    Ok(html.a([attribute("href", href)], list.map(heading.2, render_inline)))
  })
}

// DJOT RENDERERS --------------------------------------------------------------

fn render_djot(content: List(Container)) -> List(Element(Nil)) {
  use block <- list.map(content)

  case block {
    Paragraph(_, inline) -> render_paragraph(inline)
    Heading(attributes, level, inline) ->
      render_heading(attributes, level, inline)
    Codeblock(_, language, code) -> render_codeblock(language, code)
  }
}

fn render_paragraph(inline: List(Inline)) -> Element(Nil) {
  html.p([], list.map(inline, render_inline))
}

fn render_heading(
  attributes: Dict(String, String),
  level: Int,
  inline: List(Inline),
) -> Element(Nil) {
  let id = section_id(attributes, level, inline)
  let tags =
    dict.get(attributes, "target")
    |> result.map(string.split(_, " "))
    |> result.unwrap([])

  let tag = fn(label) { ui.tag([], [element.text(label)]) }
  let el = {
    case level {
      1 -> html.h1
      2 -> html.h2
      3 -> html.h3
      _ -> html.h4
    }
  }

  ui.aside(
    [attribute.id(id), aside.align_centre()],
    el([], list.map(inline, render_inline)),
    ui.cluster([attribute("aria-hidden", "true")], list.map(tags, tag)),
  )
}

fn render_codeblock(language: Option(String), code: String) -> Element(Nil) {
  let lang = option.unwrap(language, "none")

  box.of(html.pre, [], [
    html.code(
      [attribute("data-lang", lang), attribute.class("language-" <> lang)],
      [element.text(code)],
    ),
  ])
}

fn render_inline(inline: Inline) -> Element(Nil) {
  case inline {
    Text(content) -> element.text(content)
    Link(content, Url(href)) ->
      html.a([attribute("href", href)], list.map(content, render_inline))
    Link(content, Reference(_)) ->
      html.span([], list.map(content, render_inline))
  }
}

// UTILS -----------------------------------------------------------------------

fn when(cond: Bool, then: a, otherwise: a) -> a {
  case cond {
    True -> then
    False -> otherwise
  }
}

fn inline_as_string(inline: List(Inline)) -> String {
  use str, inline <- list.fold(inline, "")

  case inline {
    Text(content) -> str <> content
    Link(content, _) -> str <> inline_as_string(content)
  }
}

fn section_id(
  attributes: Dict(String, String),
  level: Int,
  inline: List(Inline),
) -> String {
  let assert Ok(is_type) = regex.from_string("^[A-Z]")
  let is_api = dict.has_key(attributes, "api")
  let inline_string = string.trim(inline_as_string(inline))

  inline_string
  |> string.replace(" ", "-")
  |> string.lowercase
  |> when(
    is_api && level == 3 && regex.check(is_type, inline_string),
    string.append(_, "-type"),
    function.identity,
  )
}
