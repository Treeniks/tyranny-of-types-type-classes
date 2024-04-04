# Comparing Haskell's Type Classes to Rust's Traits and OCaml's Modules

This Repository holds a paper I wrote in 2022 for a Bachelor-Seminar at TUM called "Tyranny of Types". The topic I was given was called "Type Classes" and I ended up writing a comparison of Haskell's Type Classes, Rust's Traits and OCaml's Modules. A web-version of the paper with small differences can be found [here](https://treeniks.github.io/tyranny-of-types-type-classes/).

## Abstract

> There are many ways to abstract functionality in programming languages. One important idea of abstraction is the notion of interfaces defining functionality for abstract types. Modern languages offer different approaches to such interfaces, some focus on data abstraction, while others focus on supporting ad-hoc polymorphism. We will see the differences between parametric and ad-hoc polymorphism. Furthermore we will look at three approaches to the concept of interfaces: Haskell type classes, the type class-inspired Rust traits and OCaml's ML-inherited module system, and find them to have many similarities.

## Info

For the actual submission, I was given a page limit because of which I had to leave out some sections. The sections are currently *not* left out, but you will find them marked with comments in the latex source. The submission-version of the paper can be found with the "deadline-paper" git tag.

I originally started writing the paper with Markdown and mdBook and then translated it over and did further edits in latex. I then re-translated those changes back into mdBook. Thus there is a `latex` and a `mdbook` folder in this repository. Both versions are almost identical, with some small tweaks and a little more code in the mdBook version.

I also had to hold a presentation about the topic, the slides for which can be found in the `presentation` folder. They are written in LaTeX with beamer and use TUM's design template. There are no notes or the likes and the slides themselves aren't very useful as the actual presentation was very freestyle.

## Build

To build the LaTeX paper or presentation, use [just](https://just.systems/):
```
cd latex # or presentation
just
```

To build the mdBook, you'll need to install [mdbook-katex](https://github.com/lzanini/mdbook-katex), then build the book:
```
cargo install mdbook-katex
cd mdbook
mdbook build
```
