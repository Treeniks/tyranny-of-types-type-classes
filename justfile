all: latex mdbook

latex:
    just -f latex/justfile

mdbook:
    mdbook build mdbook

clean: clean-latex clean-mdbook

clean-latex:
    just -f latex/justfile clean

clean-mdbook:
    mdbook clean mdbook
