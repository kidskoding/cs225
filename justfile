# Build the textbook and open it
default: build open

# Compile notes/main.typ into cs225.pdf
build:
    typst compile notes/main.typ cs225.pdf

# Rebuild cs225.pdf on every save
watch:
    typst watch notes/main.typ cs225.pdf

# Open cs225.pdf in the default PDF viewer
open:
    xdg-open cs225.pdf >/dev/null 2>&1 &
