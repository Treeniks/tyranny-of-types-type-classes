# OCaml

As already noted before, OCaml supports parametric polymorphism. However the language has no concept of ad-hoc polymorhism, i.e. there is no way to overload functions. Nontheless, OCaml inherits ML's powerful module system which still allows the language to express and convey complicated relations between types.

At first glance, a module system might not seem related to interface systems. However these concepts aren't all that different. Interfaces define a set of functions over one or, in some languages, multiple types. Modules are quite similar, they are a collection of types and functions. For example, to define a module for working with matrices of integers, in OCaml one could write this:
```ocaml
module DenseMatrix =
  struct
    type elem = int
    type t = elem list list

    let add a b = (* ... *)
  end
```
This matrix module could be further extended with other functions, but for our example this minimal version suffices.

OCaml modules also have an associated *signature*. The signature includes information about the function names and types, the names of the defined types and what those types are defined to. The latter part is optional to have the ability to hide implementation details from the user of the module. OCaml can infer the signature of our `DenseMatrix` module, but let's say we want to hide the fact that our matrix uses an `elem list list`, so we'll define the signature ourselves:
```ocaml
module type Matrix =
  sig
    type elem = int
    type t

    val add : t -> t -> t
  end

module DenseMatrix : Matrix =
  struct
    type elem = int
    type t = elem list list

    let add a b = (* ... *)
  end
```
This also allows us to create a separate `SparseMatrix` module with the same signature:
```ocaml
module SparseMatrix : Matrix =
  struct
    type elem = int
    type t = (* ... *)

    let add a b = (* ... *)
  end
```
Thus, from the perspective of interfaces, module signatures can be seen as type classes and modules as instances[^modular-type-classes].

The main difference to type classes (and by extension the reason why OCaml modules are not ad-hoc polymorphic) is that the `add` function will be namespaced inside each module we defined. If we wanted to use the `DenseMatrix`'s add function, we would have to specify it as `DenseMatrix.add`. There is no logic behind automatically choosing the correct `add` function for a given context, which is what ad-hoc polymorphism and overloading is about. Instead, the caller must specify an exact function they want to call. In contrast to this, for Haskell, the implemented functions in a type class were available independently from specific instances, i.e. in OCaml's terms, the module signature's defined functions could be used without specifying the exact module.

## Functors

### Extending our matrices for more element types

Let's take one step back and slightly alter our `Matrix` module signature.
```ocaml
module type Matrix =
  sig
    type elem
    type t

    val add : t -> t -> t
  end
```
In particular, we are not defining the type of `elem` anymore. This allows us to implement multiple matrices for different types:
```ocaml
module DenseIntMatrix : (Matrix with type elem = int) =
  struct
    type elem = int
    type t = elem list list

    let add a b = (* ... *)
  end

module SparseIntMatrix : (Matrix with type elem = int) =
  struct
    type elem = int
    type t = (* ... *)

    let add a b = (* ... *)
  end

module DenseFloatMatrix : (Matrix with type elem = float) =
  struct
    type elem = float
    type t = elem list list

    let add a b = ...
  end

module SparseFloatMatrix : (Matrix with type elem = float) =
  struct
    type elem = float
    type t = (* ... *)

    let add a b = (* ... *)
  end
```
`Matrix with type elem = int` simply means to replace `type elem` with `type elem = int` inside the `Matrix` module signature, effectively exporting the type of `elem`. This allows an outside user of `DenseIntMatrix` to know that `elem` is an `int`. This can be important if, let's say, we added a `get` function that returns an `elem` to get certain elements out of the matrix. If we didn't specify that `elem` was of type `int`, the user of our module would then not know that `get` returns `int`s, but rather some unknown and thus unusable type `elem`.

Because we left out the implementations of these functions, it might not be immediately obvious, but the actual implementation of a dense matrix with `float` values and a dense matrix with `int` values will most likely look *very* similar. The same is true for the sparse matrix. This is not exactly something we want, and this is where functors come in handy.

### Defining addition as a module

Functors, as the name would suggest, are something similar to functions. In a sense, they can be seen as compile-time functions that take modules as arguments, and return other modules. They can also be seen as a sort of macro for module definitions.

A functor in our case could define the implementation of an entire `DenseMatrix` for any type `elem` that implements an addition. Thus we must first define what "implements an addition" means, which we do by defining a module signature:
```ocaml
module type Addable =
  sig
    type t

    val add : t -> t -> t
  end
```
Because our `Matrix` module signature defines this same `add` function, we can also define the `Matrix` signature by including `Addable`:
```ocaml
module type Matrix =
  sig
    type elem
    type t

    include Addable with type t := t
  end
```
The `include` keyword in OCaml copies all definitions of another module/signature into the current module/signature, making our matrices addable in this case. The reason why we don't use `Addable`'s `type t` but instead our own is because we might want to add signatures for other operations (like multiplication) later on which should all share the same `t`.

### Functors in action

Now we can define a `DenseMatrix` functor, that takes in an `Addable` module as an argument called `D`, and gives back a `Matrix` module by implementing a dense matrix with elements of type `D.t`:
```ocaml
module DenseMatrix (D : Addable) : (Matrix with type elem = D.t) =
  struct
    type elem = D.t
    type t = elem list list

    let add a b = (* implementation of Matrix addition using D.add *)
  end
```
We can do the same for sparse matrices, but we will skip this here.

So far we can't use the `DenseMatrix` functor, as we have yet to create a module with the `Addable` signature, so let's do so for `int`s:
```ocaml
module IntAddable : (Addable with type t = int) =
  struct
    type t = int

    let add a b = a + b
  end
```
Now we can create a `DenseIntMatrix` module by calling the `DenseMatrix` functor on our `IntAddable` module:
```ocaml
module DenseIntMatrix = DenseMatrix IntAddable
```
We can now also easily create a `DenseMatrix` for floating point values, simply by creating an `Addable` module and calling the `DenseMatrix` functor on it:
```ocaml
module FloatAddable : (Addable with type t = float) =
  struct
    type t = float

    let add a b = a +. b
  end

module DenseFloatMatrix = DenseMatrix FloatAddable
```

[^modular-type-classes]: ["Modular type classes" by Derek Dreyer, Robert Harper and Manuel M.T. Chakravarty](https://doi.org/10.1145/1190215.1190229)
