import highlight from "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/es/core.min.js";
import html from "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/es/languages/xml.min.js";
import javascript from "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/es/languages/javascript.min.js";
import shell from "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/es/languages/shell.min.js";

// SYNTAX HIGHLIGHTING ---------------------------------------------------------

highlight.registerLanguage("html", html);
highlight.registerLanguage("javascript", javascript);
highlight.registerLanguage("sh", shell);
highlight.registerLanguage("shell", shell);
highlight.registerLanguage("gleam", gleam);

highlight.highlightAll();

// DEEP LINKING CODE BLOCKS ----------------------------------------------------

const stdlib = "https://hexdocs.pm/gleam_stdlib/gleam";
const links = {
  App: `/api/lustre.html#app-type`,
  Attribute: `/api/lustre/attribute.html#attribute-type`,
  Bool: `${stdlib}/bool.html`,
  Decoder: `${stdlib}/dynamic.html#Decoder`,
  Dynamic: `${stdlib}/dynamic.html#Dynamic`,
  Effect: `/api/lustre/effect.html#effect-type`,
  Element: `/api/lustre/element.html#element-type`,
  Error: `/api/lustre.html#error-type`,
  Float: `${stdlib}/float.html`,
  Int: `${stdlib}/int.html`,
  List: `${stdlib}/list.html`,
  Map: `${stdlib}/map.html#Map`,
  Option: `${stdlib}/option.html#Option`,
  Result: `${stdlib}/result.html`,
  String: `${stdlib}/string.html`,
  StringBuilder: `${stdlib}/string_builder.html#StringBuilder`,
};

for (const el of document.querySelectorAll("code.hljs")) {
  for (const [t, url] of Object.entries(links)) {
    el.innerHTML = el.innerHTML.replace(
      new RegExp(`\\b${t}\\b`, "g"),
      `<a href="${url}">${t}</a>`
    );
  }
}

// GLEAM HIGHLIGHT.JS GRAMMAR --------------------------------------------------

function gleam(hljs) {
  const KEYWORDS =
    "as assert case const fn if import let panic use opaque pub todo type";
  const STRING = {
    className: "string",
    variants: [{ begin: /"/, end: /"/ }],
    contains: [hljs.BACKSLASH_ESCAPE],
    relevance: 0,
  };
  const NAME = {
    className: "variable",
    begin: "\\b[a-z][a-z0-9_]*\\b",
    relevance: 0,
  };
  const DISCARD_NAME = {
    className: "comment",
    begin: "\\b_[a-z][a-z0-9_]*\\b",
    relevance: 0,
  };
  const NUMBER = {
    className: "number",
    variants: [
      {
        // binary
        begin: "\\b0[bB](?:_?[01]+)+",
      },
      {
        // octal
        begin: "\\b0[oO](?:_?[0-7]+)+",
      },
      {
        // hex
        begin: "\\b0[xX](?:_?[0-9a-fA-F]+)+",
      },
      {
        // dec, float
        begin: "\\b\\d(?:_?\\d+)*(?:\\.(?:\\d(?:_?\\d+)*)*)?",
      },
    ],
    relevance: 0,
  };

  return {
    name: "Gleam",
    aliases: ["gleam"],
    contains: [
      hljs.C_LINE_COMMENT_MODE,
      STRING,
      {
        // bit string
        begin: "<<",
        end: ">>",
        contains: [
          {
            className: "keyword",
            beginKeywords:
              "binary bytes int float bit_string bits utf8 utf16 utf32 " +
              "utf8_codepoint utf16_codepoint utf32_codepoint signed unsigned " +
              "big little native unit size",
          },
          KEYWORDS,
          STRING,
          NAME,
          DISCARD_NAME,
          NUMBER,
        ],
        relevance: 10,
      },
      {
        className: "function",
        beginKeywords: "fn",
        end: "\\(",
        excludeEnd: true,
        contains: [
          {
            className: "title",
            begin: "[a-z][a-z0-9_]*\\w*",
            relevance: 0,
          },
        ],
      },
      {
        className: "attribute",
        begin: "@",
        end: "\\(",
        excludeEnd: true,
      },
      {
        className: "keyword",
        beginKeywords: KEYWORDS,
      },
      {
        // Type names and constructors
        className: "title",
        begin: "\\b[A-Z][A-Za-z0-9]*\\b",
        relevance: 0,
      },
      {
        className: "operator",
        begin: "[+\\-*/%!=<>&|.]+",
        relevance: 0,
      },
      NAME,
      DISCARD_NAME,
      NUMBER,
    ],
  };
}
