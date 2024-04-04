all: latex mdbook presentation typst

latex:
    just -f latex/justfile

mdbook:
    just -f mdbook/justfile

presentation:
    just -f presentation/justfile

typst:
    just -f typst/justfile

clean: clean-latex clean-mdbook clean-presentation clean-typst

clean-latex:
    just -f latex/justfile clean

clean-mdbook:
    just -f mdbook/justfile clean

clean-presentation:
    just -f presentation/justfile clean

clean-typst:
    just -f typst/justfile clean
