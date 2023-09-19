import { attribute } from "../lustre/lustre/attribute.mjs";
import { element, text } from "../lustre/lustre/element.mjs";
import { List, Empty, NonEmpty } from "./gleam.mjs";
import { fromMarkdown } from "mdast-util-from-markdown";
import * as Markdown from "./app/markdown.mjs";

const empty = new Empty();
const singleton = (val) => new NonEmpty(val, empty);
const fold_into_list = (arr, f) =>
  arr.reduceRight((acc, val) => new NonEmpty(f(val), acc), empty);

function compute_hash(str) {
  let hash = 0;
  for (let i = 0, len = str.length; i < len; i++) {
    let chr = str.charCodeAt(i);
    hash = (hash << 5) - hash + chr;
    hash |= 0; // Convert to 32bit integer
  }
  return `${~hash}`;
}

export function parse_md(md, is_api = false) {
  const ast = fromMarkdown(md);
  const summary = [];
  const content = fold_into_list(
    ast.children,
    function to_lustre_element(node) {
      switch (node.type) {
        case "code":
          return Markdown.code(node.value, compute_hash(node.value), node.lang);

        case "emphasis":
          return Markdown.emphasis(
            fold_into_list(node.children, to_lustre_element)
          );

        case "heading": {
          const [title, rest] = node.children[0].value.split("|");
          const tags = List.fromArray(rest ? rest.trim().split(" ") : []);
          const id =
            /^[A-Z]/.test(title.trim()) && node.depth === 3 && is_api
              ? `${title
                  .toLowerCase()
                  .trim()
                  .replace(/\s/g, "-")
                  .replace(/[^a-zA-Z0-9-_]/g, "")}-type`
              : `${title
                  .toLowerCase()
                  .trim()
                  .replace(/\s/g, "-")
                  .replace(/[^a-zA-Z0-9-_]/g, "")}`;

          if (node.depth > 1) {
            summary.unshift(
              element(
                "a",
                List.fromArray([
                  attribute("href", `#${id}`),
                  attribute(
                    "class",
                    `text-sm text-gray-400 no-underline hover:text-gray-700 hover:underline ${
                      node.depth === 2 ? `mt-4 first:mt-0` : `ml-2`
                    }`
                  ),
                ]),
                singleton(text(title.trim()))
              )
            );
          }

          return Markdown.heading(node.depth, title.trim(), tags, id);
        }

        case "inlineCode":
          return Markdown.inline_code(node.value);

        case "link":
          return Markdown.link(
            node.url,
            fold_into_list(node.children, to_lustre_element)
          );

        case "list":
          return Markdown.list(
            !!node.ordered,
            fold_into_list(node.children, to_lustre_element)
          );

        case "listItem":
          return Markdown.list_item(
            fold_into_list(node.children, to_lustre_element)
          );

        case "paragraph":
          return Markdown.paragraph(
            fold_into_list(node.children, to_lustre_element)
          );

        case "strong":
          return Markdown.strong(
            fold_into_list(node.children, to_lustre_element)
          );

        case "text":
          return Markdown.text(node.value);

        default:
          return Markdown.text("");
      }
    }
  );

  return [content, List.fromArray(summary)];
}
