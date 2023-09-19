// IMPORTS ---------------------------------------------------------------------

import gleam/list
import gleam/string
import lustre/attribute.{Attribute, attribute}
import lustre/element.{Element}
import lustre/element/html.{html}
import simplifile

// -----------------------------------------------------------------------------

pub fn homepage(content_path: String) -> Element(Nil) {
  let assert Ok(md) = simplifile.read(content_path)
  let #(content, summary) = parse_md(md, False)
  let content = section(content, summary)

  document(
    "Lustre",
    [],
    [
      html.div(
        [
          attribute.class("w-screen h-screen flex justify-center items-center"),
          attribute.style([
            #("background-color", "hsla(226,0%,100%,1)"),
            #(
              "background-image",
              " radial-gradient(at 62% 13%, hsla(170,76%,60%,1) 0px, transparent 65%),
                radial-gradient(at 67% 42%, hsla(234,89%,70%,1) 0px, transparent 65%),
                radial-gradient(at 10% 7%, hsla(213,93%,57%,1) 0px, transparent 65%),
                radial-gradient(at 32% 46%, hsla(291,93%,80%,1) 0px, transparent 65%)",
            ),
          ]),
        ],
        [
          html.hgroup(
            [],
            [
              html.h1([attribute.class("text-8xl")], [element.text("Lustre.")]),
              html.p(
                [attribute.class("pl-1")],
                [element.text("Web apps from space!")],
              ),
            ],
          ),
        ],
      ),
      content,
    ],
  )
}

pub fn page(
  content_path: String,
  title: String,
  transform_type_headings is_api: Bool,
) -> Element(Nil) {
  let assert Ok(md) = simplifile.read(content_path)
  let #(content, summary) = parse_md(md, is_api)
  let #(attrs, content) = body(content, summary)

  document(title, attrs, content)
}

// -----------------------------------------------------------------------------

fn document(
  title: String,
  attrs: List(Attribute(Nil)),
  content: List(Element(Nil)),
) -> Element(Nil) {
  html(
    [attribute("lang", "en"), attribute.class("overflow-x-hidden")],
    [
      html.head(
        [],
        [
          html.title([], title),
          html.meta([attribute("charset", "utf-8")]),
          html.meta([
            attribute("name", "viewport"),
            attribute("content", "width=device-width, initial-scale=1"),
          ]),
          html.link([attribute.href("/styles.css"), attribute.rel("stylesheet")]),
          html.script([attribute.src("/app.js"), attribute.type_("module")], ""),
        ],
      ),
      html.body(attrs, content),
    ],
  )
}

pub fn body(
  content: List(Element(Nil)),
  summary: List(Element(Nil)),
) -> #(List(Attribute(Nil)), List(Element(Nil))) {
  #(
    [attribute.class("prose prose-lustre max-w-none")],
    [
      html.div(
        [attribute.class("max-w-[96rem] mx-auto grid grid-cols-8")],
        [docs_left(), docs_content(content), docs_right(summary)],
      ),
    ],
  )
}

pub fn section(
  content: List(Element(Nil)),
  summary: List(Element(Nil)),
) -> Element(Nil) {
  html.div(
    [attribute.class("prose prose-lustre max-w-none")],
    [
      html.div(
        [attribute.class("max-w-[96rem] mx-auto grid grid-cols-8")],
        [docs_left(), docs_content(content), docs_right(summary)],
      ),
    ],
  )
}

fn docs_left() -> Element(msg) {
  html.aside(
    [
      attribute.style([#("align-self", "start")]),
      attribute.class(
        "relative sticky top-0 hidden px-4 pb-10 h-screen lg:block lg:col-span-2 xl:col-span-2",
      ),
    ],
    [
      html.div(
        [
          attribute.class(
            "absolute right-0 inset-y-0 w-[50vw] bg-gradient-to-b from-white to-gray-100 -z-10",
          ),
        ],
        [],
      ),
      html.div(
        [attribute.class("flex flex-col h-full overflow-y-scroll")],
        [
          html.h2(
            [attribute.class("mb-0")],
            [
              html.a(
                [
                  attribute.href("/"),
                  attribute.class("text-indigo-600 no-underline"),
                ],
                [element.text("Lustre")],
              ),
            ],
          ),
          html.p(
            [attribute.class("text-gray-400 font-bold")],
            [element.text("Web apps from space.")],
          ),
          ..docs_left_links()
        ],
      ),
    ],
  )
}

fn docs_left_links() -> List(Element(msg)) {
  let link = string.append("/", _)

  [
    docs_left_section(
      "Docs",
      [
        #("Quickstart", link("docs/quickstart.html")),
        #("Managing state", link("docs/managing-state.html")),
        #("Side effects", link("docs/side-effects.html")),
        #("Components", link("docs/components.html")),
        #("Server-side rendering", link("docs/server-side-rendering.html")),
      ],
    ),
    docs_left_section(
      "Guides",
      [
        #("Using with Mist", link("guides/mist.html")),
        #("Using with Wisp", link("guides/wisp.html")),
      ],
    ),
    docs_left_section(
      "Reference",
      [
        #("lustre", link("api/lustre.html")),
        #("lustre/attribute", link("api/lustre/attribute.html")),
        #("lustre/effect", link("api/lustre/effect.html")),
        #("lustre/element", link("api/lustre/element.html")),
        #("lustre/element/html", link("api/lustre/element/html.html")),
        #("lustre/element/svg", link("api/lustre/element/svg.html")),
        #("lustre/event", link("api/lustre/event.html")),
      ],
    ),
    docs_left_section(
      "External",
      [
        #("GitHub", "https://github.com/hayleigh-dot-dev/gleam-lustre"),
        #("Discord", "https://discord.gg/Fm8Pwmy"),
        #("Buy me a coffee?", "https://github.com/sponsors/hayleigh-dot-dev"),
      ],
    ),
  ]
}

fn docs_left_section(
  title: String,
  pages: List(#(String, String)),
) -> Element(msg) {
  html.nav(
    [],
    [
      html.h2([attribute.class("my-0 lg:mt-8 lg:mb-4")], [element.text(title)]),
      html.ul(
        [attribute.class("ml-2")],
        {
          use #(name, url) <- list.map(pages)
          html.li(
            [],
            [
              html.a(
                [attribute.href(url), attribute.class("font-serif")],
                [element.text(name)],
              ),
            ],
          )
        },
      ),
    ],
  )
}

fn docs_content(content: List(Element(msg))) -> Element(msg) {
  html.main(
    [
      attribute.class(
        "col-span-8 pt-4 px-4 pb-32 lg:px-8 lg:col-span-6 xl:col-span-5",
      ),
    ],
    content,
  )
}

fn docs_right(summary: List(Element(msg))) -> Element(msg) {
  html.aside(
    [
      attribute.style([#("align-self", "start")]),
      attribute.class(
        "sticky relative top-0 hidden p-4 py-10 h-screen xl:block xl:col-span-1",
      ),
    ],
    [
      html.div(
        [
          attribute.class(
            "absolute left-0 inset-y-0 w-[50vw] bg-gradient-to-b from-white to-gray-100 -z-10",
          ),
        ],
        [],
      ),
      html.div(
        [attribute.class("flex flex-col h-full overflow-y-scroll")],
        summary,
      ),
    ],
  )
}

// UTILS -----------------------------------------------------------------------

@external(javascript, "../build.ffi.mjs", "parse_md")
fn parse_md(
  content: String,
  is_api: Bool,
) -> #(List(Element(Nil)), List(Element(Nil)))
