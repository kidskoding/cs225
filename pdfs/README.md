# Generated PDFs

This directory contains PDF versions of the course notes generated from the markdown files.

## Available PDFs

- `module-03.pdf` - Module 3: List ADT and Linked List Implementation

## Generation Process

The PDFs are generated using Pandoc with WeasyPrint as the PDF engine:

```bash
pandoc notes/module-03.md -o pdfs/module-03.pdf --pdf-engine=weasyprint --metadata title="Module 3 - List ADT and Linked List Implementation"
```

### Requirements

To generate PDFs, you need:
- `pandoc` - Document converter
- `weasyprint` - PDF engine (can be installed via `pip3 install weasyprint`)

### Notes

- WeasyPrint handles complex markdown better than pdflatex for nested lists and code blocks
- The generated PDFs maintain proper formatting for code blocks, diagrams (mermaid), and mathematical expressions