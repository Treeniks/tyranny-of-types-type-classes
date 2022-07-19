all: latex mdbook presentation

latex:
    just -f latex/justfile

mdbook:
    mdbook build mdbook

presentation:
    just -f presentation/justfile

clean: clean-latex clean-mdbook clean-presentation

clean-latex:
    just -f latex/justfile clean

clean-mdbook:
    mdbook clean mdbook

clean-presentation:
    just -f presentation/justfile clean
