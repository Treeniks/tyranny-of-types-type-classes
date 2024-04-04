= OCaml

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

// TODO this ```ocaml elem list list``` may cause problems at end of the line
OCaml modules also have an associated _signature_. The signature includes information about the function names and types, the names of the defined types and what those types are defined to. The latter part is optional to have the ability to hide implementation details from the user of the module. OCaml can infer the signature of our ```ocaml DenseMatrix``` module, but let's say we want to hide the fact that our matrix uses an ```ocaml elem list list```, so we'll define the signature ourselves:
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
This also allows us to create a separate ```ocaml SparseMatrix``` module with the same signature:
```ocaml
module SparseMatrix : Matrix =
  struct
    type elem = int
    type t = (* ... *)
    let add a b = (* ... *)
  end
```
Thus, from the perspective of interfaces, module signatures can be seen as type classes and modules as instances~@modular-type-classes.

The main difference to type classes (and by extension the reason why OCaml modules are not ad-hoc polymorphic) is that the ```ocaml add``` function will be namespaced inside each module we defined. If we wanted to use the ```ocaml DenseMatrix```'s add function, we would have to specify it as ```ocaml DenseMatrix.add```. There is no logic behind automatically choosing the correct ```ocaml add``` function for a given context, which is what ad-hoc polymorphism and overloading is about. Instead, the caller must specify an exact function they want to call. In contrast to this, for Haskell, the implemented functions in a type class were available independently from specific instances, i.e. in OCaml's terms, the module signature's defined functions could be used without specifying the exact module.

== Functors

=== Extending our matrices for more element types

#figure(
    [
        ```ocaml
        module DenseIntMatrix : (Matrix with type elem = int) =
          struct
            type elem = int
            type t = elem list list
            let add a b = (* ... *)
          end

        module SparseFloatMatrix : (Matrix with type elem = float) =
          struct
            type elem = float
            type t = (* ... *)
            let add a b = (* ... *)
          end
        ```
    ],
    caption: [OCaml matrix example with dense and sparse matrix],
    placement: top,
) <ocaml-all-matrix>

Let's take one step back and slightly alter our ```ocaml Matrix``` module signature.
```ocaml
module type Matrix =
  sig
    type elem
    type t
    val add : t -> t -> t
  end
```
In particular, we are not defining the type of ```ocaml elem``` anymore. This allows us to implement multiple matrices for different types.

@ocaml-all-matrix shows two of many possible matrix modules. ```ocaml Matrix with type elem = int``` simply means to replace ```ocaml type elem``` with ```ocaml type elem = int``` inside the ```ocaml Matrix``` module signature, effectively exporting the type of ```ocaml elem```. This allows an outside user of ```ocaml DenseIntMatrix``` to know that ```ocaml elem``` is an ```ocaml int```. This can be important if, let's say, we added a ```ocaml get``` function that returns an ```ocaml elem``` to get certain elements out of the matrix. If we didn't specify that ```ocaml elem``` was of type ```ocaml int```, the user of our module would then not know that ```ocaml get``` returns ```ocaml int```s, but rather some unknown and thus unusable type ```ocaml elem```.

Because we left out the implementations of these functions, it might not be immediately obvious, but the actual implementation of a dense matrix with ```ocaml float``` values and a dense matrix with ```ocaml int``` values will most likely look _very_ similar. The same is true for the sparse matrix. This is not exactly something we want, and this is where functors come in handy.

=== Defining addition as a module

Functors, as the name would suggest, are something similar to functions. In a sense, they can be seen as compile-time functions that take modules as arguments, and return other modules. They can also be seen as a sort of macro for module definitions.

A functor in our case could define the implementation of an entire ```ocaml DenseMatrix``` for any type ```ocaml elem``` that implements an addition. Thus we must first define what "implements an addition" means, which we do by defining a module signature:
```ocaml
module type Addable =
  sig
    type t
    val add : t -> t -> t
  end
```
Because our ```ocaml Matrix``` module signature defines this same ```ocaml add``` function, we can also define the ```ocaml Matrix``` signature by including ```ocaml Addable```:
```ocaml
module type Matrix =
  sig
    type elem
    type t
    include Addable with type t := t
  end
```
The ```ocaml include``` keyword in OCaml copies all definitions of another module/signature into the current module/signature, making our matrices addable in this case. The reason why we don't use ```ocaml Addable```'s ```ocaml type t``` but instead our own is because we might want to add signatures for other operations (like multiplication) later on which should all share the same ```ocaml t```.

=== Functors in action

#figure(
    [
        ```ocaml
        module DenseMatrix (D : Addable) : (Matrix with type elem = D.t) =
          struct
            type elem = D.t
            type t = elem list list
            let add a b = (* implementation of Matrix addition using D.add *)
          end
        ```
    ],
    caption: [OCaml functor matrix example]
) <ocaml-matrix-functor>

@ocaml-matrix-functor shows how we can define a ```ocaml DenseMatrix``` functor, that takes in an ```ocaml Addable``` module as an argument called ```ocaml D```, and gives back a ```ocaml Matrix``` module by implementing a dense matrix with elements of type ```ocaml D.t```. We can do the same for sparse matrices, but we will skip this here.

So far we can't use the ```ocaml DenseMatrix``` functor, as we have yet to create a module with the ```ocaml Addable``` signature, so let's do so for ```ocaml int```s:
```ocaml
module IntAddable : (Addable with type t = int) =
  struct
    type t = int
    let add a b = a + b
  end
```
Now we can create a ```ocaml DenseIntMatrix``` module by calling the ```ocaml DenseMatrix``` functor on our ```ocaml IntAddable``` module:
```ocaml
module DenseIntMatrix = DenseMatrix IntAddable
```
A ```ocaml DenseMatrix``` for floating point values can easily be created as well, simply by creating a ```ocaml FloatAddable``` module and calling the ```ocaml DenseMatrix``` functor on it.
