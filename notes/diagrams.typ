#import "@preview/cetz:0.5.2"

#let marked = yellow.lighten(60%)

#let to-cetz(t) = if type(t) == array {
  let (root, ..kids) = t
  if kids.len() == 2 and kids.first() == none and kids.last() != none { kids.insert(0, none) }
  if kids.len() == 2 and kids.first() != none and kids.last() == none { kids.push(none) }
  (root, ..kids).map(to-cetz)
} else if t == none { (none,) } else { [#t] }

// Nested arrays `(root, left, right)`; `none` leaves an empty slot.
#let tree(t, highlight: ()) = cetz.canvas({
  import cetz.draw: *
  cetz.tree.tree(
    to-cetz(t),
    spread: 0.9,
    grow: 1.1,
    draw-node: node => if node.content != none {
      let is-marked = node.content in highlight.map(v => [#v])
      let label = box(width: 1em, align(center, node.content))
      content((), label, frame: "circle", padding: 0.1, fill: if is-marked { marked } else { white })
    },
    draw-edge: (parent, child) => if child.content != none {
      line(parent.group-name, child.group-name)
    },
  )
})

#let steps(..trees, highlight: ()) = {
  let cells = trees.pos().map(t => tree(t, highlight: highlight)).intersperse($->$)
  grid(columns: cells.len(), column-gutter: 2em, align: horizon, ..cells)
}

// Each node is a string of space-separated keys: `btree(("10 20", "3 5", "12 15", "25 30"))`.
#let btree(t) = cetz.canvas({
  import cetz.draw: *
  cetz.tree.tree(
    to-cetz(t),
    spread: 2.2,
    grow: 1.3,
    draw-node: node => {
      let keys = node.content.text.split(" ")
      let w = 0.6
      let x0 = -w * keys.len() / 2
      for (i, k) in keys.enumerate() {
        rect((x0 + w * i, -0.3), (x0 + w * (i + 1), 0.3), fill: white)
        content((x0 + w * (i + 0.5), 0), k)
      }
    },
    draw-edge: (parent, child) => line(
      (rel: (0, -0.3), to: parent.group-name),
      (rel: (0, 0.3), to: child.group-name),
    ),
  )
})

#let linked-list(..values, head: "head", highlight: ()) = cetz.canvas({
  import cetz.draw: *
  assert(values.named().len() == 0, message: "unknown linked-list option: " + values.named().keys().join(", "))
  let values = values.pos()
  let step = 1.9
  content((-0.4, 0), raw(head), anchor: "east", name: "head")
  line("head.east", (0, 0), mark: (end: ">", fill: black))
  for (i, v) in values.enumerate() {
    let x = step * i
    rect((x, -0.3), (x + 0.7, 0.3), fill: if i in highlight { marked } else { white }, name: "data")
    rect((x + 0.7, -0.3), (x + 1.05, 0.3), name: "next")
    content("data", [#v])
    circle("next", radius: 0.05, fill: black)
    let target = if i + 1 < values.len() { (x + step, 0) } else { (x + 1.6, 0) }
    line("next", target, mark: (end: ">", fill: black))
  }
  content((step * (values.len() - 1) + 1.65, 0), raw("nullptr"), anchor: "west")
})

#let array-cells(..values, marks: (:), highlight: ()) = cetz.canvas({
  import cetz.draw: *
  let w = 0.7
  for (i, v) in values.pos().enumerate() {
    let fill = if i in highlight { marked } else { white }
    rect((w * i, 0), (w * (i + 1), w), fill: fill, name: "cell")
    if v != none { content("cell", [#v]) }
    content((w * (i + 0.5), -0.3), text(size: 0.7em, fill: gray.darken(30%), str(i)))
  }
  let by-index = (:)
  for (label, i) in marks {
    by-index.insert(str(i), by-index.at(str(i), default: ()) + (label,))
  }
  for (n, (i, labels)) in by-index.pairs().sorted(key: p => int(p.first())).enumerate() {
    let x = w * (int(i) + 0.5)
    let top = w + 0.9 + 0.5 * calc.rem(n, 2)
    content((x, top), raw(labels.join(", ")), anchor: "south")
    line((x, top - 0.05), (x, w + 0.05), mark: (end: ">", fill: black))
  }
})

// Edges are `"a-b"` (undirected) or `"a->b"` (directed): `graph((a: (0, 0), b: (1, 0)), ("a-b",))`.
#let graph(nodes, edges, highlight: ()) = cetz.canvas({
  import cetz.draw: *
  for (name, pos) in nodes {
    let fill = if name in highlight { marked } else { white }
    circle(pos, radius: 0.3, fill: fill, name: name)
    content(name, name)
  }
  for edge in edges {
    let directed = edge.contains("->")
    let (a, b) = edge.split(if directed { "->" } else { "-" })
    let (pa, pb) = (nodes.at(a), nodes.at(b))
    let d = cetz.vector.scale(cetz.vector.norm(cetz.vector.sub(pb, pa)), 0.3)
    line(cetz.vector.add(pa, d), cetz.vector.sub(pb, d), mark: if directed { (end: ">", fill: black) } else { none })
  }
})

// Values starting with `->` point at another named cell: `memory(stack: (p: "->x"), heap: (x: 5))`.
#let memory(stack: (:), heap: (:)) = cetz.canvas({
  import cetz.draw: *
  let column(title, cells, x, side) = {
    content((x + 0.75, 0.6), strong(title))
    for (i, (name, value)) in cells.pairs().enumerate() {
      let y = -0.8 * i
      let (lx, anchor) = if side == "left" { (x - 0.15, "east") } else { (x + 1.65, "west") }
      content((lx, y), raw(name), anchor: anchor)
      rect((x, y - 0.3), (x + 1.5, y + 0.3), name: name)
      if not (type(value) == str and value.starts-with("->")) { content(name, [#value]) }
    }
  }
  column("Stack", stack, 0, "left")
  column("Heap", heap, 4.2, "right")
  for (name, value) in stack + heap {
    if type(value) == str and value.starts-with("->") {
      circle(name, radius: 0.05, fill: black)
      line(name, value.slice(2) + ".west", mark: (end: ">", fill: black))
    }
  }
})
