# cs225-notes

notes for uiuc cs 225 (Data Structures and Algorithms), written in [Typst](https://typst.app).

- **Notes:** [`cs225.pdf`](cs225.pdf), built from [`notes/main.typ`](notes/main.typ)
- **API docs:** Doxygen docs for the implementations in [`cs225_pg/`](cs225_pg) (one folder per chapter), published [here](https://kidskoding.github.io/cs225-notes/)

## Building

```sh
typst compile notes/main.typ cs225.pdf
typst watch notes/main.typ cs225.pdf   # rebuild on save
```

CI rebuilds `cs225.pdf` and the API docs on every push to `master`.

## Layout

- `notes/main.typ`: book styling and chapter order
- `notes/diagrams.typ`: `tree`, `steps`, `btree`, `linked-list`, `array-cells`, `graph`, `memory`, and `plane` helpers (built on CeTZ)
- `notes/modules/`: one file per module
- `notes/midterm-reviews/`: midterm reviews (appendix)

