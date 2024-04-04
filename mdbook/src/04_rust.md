# Rust

Rust is known to be a language that combines different features of different programming languages into one language, with the goal of only keeping whatever works best and eliminating whatever doesn't. When it comes to polymorphism, Rust combines the concept of type classes with generics, the latter of which is usually seen in object oriented languages like Java, C# and C++.

## Generics: Rust's Parametric Polymorphism

Generics, in their simplest form, are a form of parametric polymorphism. As such, the length function on slices can be defined with a generic which we will name `T`.

> Because Rust only implements many ideas from functional languages, but is in itself a C-like imperative language, the terminology used for similar things will be slightly different, so will the syntax. In this case, we use a slice in place of a list. A slice in Rust is a reference to a specific area inside an array (or similar), or to the entire array itself. The type `usize` is one of Rust's unsigned integer types. Also, pay no mind to ampersands inside the Rust code, as it is not of importance for this topic.

```rust
fn len<T>(slice: &[T]) -> usize {
    // calculate and return length
}
```
We will leave out the implementation of the length function here, because it requires knowledge of the underlying layout of slices. The function [is given by Rust's STL](https://doc.rust-lang.org/std/primitive.slice.html#method.len).

We will also slightly alter the declaration of this function. As it stands, `len` is declared as a standalone function, but in the real Rust STL it is actually defined as a member function on the slice primitive. To implement member functions on types, Rust uses the `impl` keyword. Note that we also must declare the generic `T` with the `impl` keyword, as the type we are implementing on itself uses the generic:
```rust
impl<T> [T] {
    fn len(&self) -> usize {
        // calculate and return length
    }
}
```
`self` is a keyword used in Rust to allow a call with the dot operator, e.g. so one can write `my_slice.len()` instead of `len(my_slice)`. It implicitly is of the type the `impl` block is defined on.

## Traits: Rust's Type Classes

In their simplest form, traits are the exact same concept as type classes, they simply define a named set of operations. This is because Rust's traits are heavily inspired by type classes[^rust-reference-20.2]. The main difference between the two being a slight change in nomenclature. Whereas in Haskell we explicitly gave the type we are later instancing on a name, i.e. the `a` in `class Eq a`, in Rust this type is implicitly called `Self`. `Self` is not the same as `self`, `self` is a value and `Self` is `self`'s type.

To see how traits work, we will implement the same equality type class from ["Haskell | Ad-hoc Polymorphism: Type Classes"](03_haskell.md#ad-hoc-polymorphism-type-classes):
```rust
trait Eq {
    fn eq(&self, other: &Self) -> bool;
}
```
> Rust's STL also defines an `Eq` trait, however this is actually a marker trait without any function declarations. Instead, what we are doing here is more similar to the STL's `PartialEq` trait (although that one also has a default implementation for not equals).

What we called a type class instance in Haskell we call a trait implementation in Rust, because doing so extends the previously used `impl` keyword:
```rust
impl Eq for usize {
    fn eq(&self, other: &Self) -> bool {
        // ...
    }
}
```
We can of course also implement the trait on other types, such as Rust's floating point primitive `f32`:
```rust
impl Eq for f32 {
    fn eq(&self, other: &Self) -> bool {
        // ...
    }
}
```

Like Haskell, Rust is also statically typed, and therefore calling `eq` on either `usize` or `f32` types will automatically pick the correct function at compile time, and calling it on any other type will give us a compile time error.

### Trait bounds: Rust's type constraints

Trait bounds allow us to tell the Rust compiler that a generic function only makes sense, if those generic types implement a specific trait. This is the exact same as Haskell's type constraints discussed in ["Haskell | Type constraints"](03_haskell.md#type-constraints). We will also use the same `Cost` example and thus first define a `Cost` trait:
```rust
trait Cost {
    fn cost(&self) -> usize;
}
```
Then we will implement the trait for some custom data type, which will be an enum with two variants with the exact same semantics as the custom data type we used for the Haskell example:
```rust
enum Custom {
    Cheap,
    Expensive,
}

impl Cost for Custom {
    fn cost(&self) -> usize {
        match self {
            Custom::Cheap => 0,
            Custom::Expensive => 1,
        }
    }
}
```
And now we again define a `cheapest` function, however this time we define it on slices instead of lists:
```rust
fn cheapest<T>(elements: &[T]) -> &T
where
    T: Cost,
{
    // the exact implementation is not relevant
    elements
        .iter()
        .min_by(|x, y| x.cost().cmp(&y.cost()))
        .unwrap()
}
```
Inside the `cheapest` function, we use the `cost` method on elements of the slice. To do so, we must tell the compiler that elements of the slice implement such function, which is done by giving the `cheapest` function a `where` clause. Inside a `where` clause, we can define as many trait bounds as we want which are of the form `type: bound`. In this case, we are adding a bound `Cost` for the generic `T` inside the `where` clause, meaning that the function `cheapest` shall only exist for `T`s that have a `Cost` implementation.

### Creating implementations from other implementations

As with Haskell, we can create implementations for generic types, where the generics are constrained, i.e. have trait bounds. For this, we will again implement `Cost` for slices where the slices' elements implement `Cost`:
```rust
impl<T> Cost for [T]
where
    T: Cost,
{
    fn cost(&self) -> usize {
        self.iter().map(|x| x.cost()).sum()
    }
}
```
<!-- Rust only allows us to do so if *either* the type we're implementing on *or* the trait is not foreign, i.e. local to the current crate (which is Rust's version of a package)[^rust-book]. This is done to prevent certain situations that could cause ambiguities when selecting a method. -->
<!-- TODO the above is not really necessary is it? -->

### Generic traits: Rust's multi-parameter type classes

So far we faced a similar problem we did in Haskell: If we wanted to define an `Add` trait with an `add` function, that function would have to take the same types for both parameters. This limitation can be removed in Rust by using generics inside the trait's definition:
```rust
trait Add<T> {
    fn add(self, rhs: T) -> Self;
}
```
Unlike in Haskell, we did not have to enable a language extension first, as Rust supports this out of the box.

As in ["Haskell | Multiple Parameters"](03_haskell.md#multiple-parameters), the output is set to be of the same type as the left hand side, which we could fix by adding a second generic:
```rust
trait Add<T, U> {
    fn add(self, rhs: T) -> U;
}
```
Which again poses the issue that an addition between two types does not have a well defined output type. We can implement addition between integers and floating point numbers with differing outputs:
```rust
impl Add<f32, usize> for usize {
    fn add(self, rhs: f32) -> usize {
        // ...
    }
}

impl Add<f32, f32> for usize {
    fn add(self, rhs: f32) -> f32 {
        // ...
    }
}
```
If we were to call `1_usize.add(3.2_f32)`, we would have to specify *which* `add` function we want to call:
```rust
<usize as Add<f32, f32>>::add(1_usize, 3.2_f32)
```

> This uses Rust's [Fully Qualified Syntax for Disambiguation](https://doc.rust-lang.org/stable/book/ch19-03-advanced-traits.html?highlight=fully%20qualified#fully-qualified-syntax-for-disambiguation-calling-methods-with-the-same-name) and it looks rather complex. However, by simply binding the result to a variable, it would be enough to give said variable a type: `let k: f32 = 1_usize.add(3.2_f32);`.

### Associated types

Once again, Rust also defines the notion of associated types, which also work very similar to Haskell. Just as in Haskell, an associated type is another type parameter that is fixed for a specific configuration of types inserted in the generics. And as before, we will use an associated type to define the output type of an addition.

First we must edit the `Add` trait's definition. We will add an associated type called `Output` and we will also change the name of the generic `T` to `Rhs` and default it to `Self`:
```rust
trait Add<Rhs = Self> {
    type Output;

    fn add(self, rhs: Rhs) -> Self::Output;
}
```
> This is actually how the real world `Add` trait in Rust's STL is defined, with the exception of access modifiers.

The type `Output` is now fixed for a given `Self` and `Rhs` type. Notice how we didn't call the associated type `AddOutput` like we did in the Haskell example. The reason being that, in Rust, the associated type is in the namespace of the surrounding trait. That is why, to use the associated type as the output type of the `add` function, we need to qualify it as `Self::Output` which implicitly translates to `<Self as Add<Rhs>>::Output` inside this trait. That way, we can reuse the `Output` name for all operations.

Implementing the `Add` trait now means one also has to define the `Output` associated type, which we will set to be a float like we did with Haskell:
```rust
impl Add<f32> for usize {
    type Output = f32;

    fn add(self, rhs: f32) -> Self::Output {
        // ...
    }
}
```
If we were to add another implementation with `type Output = usize`, the Rust compiler would detect the ambiguity and throw an error.

### A matrix example

Rust generics can also be used for structs, which are Rust's custom data types. To mirror the matrix example from ["Haskell | A matrix example"](03_haskell.md#a-matrix-example), let us assume we have a generic matrix struct `Matrix<T>` where the matrix's elements are of type `T`.

First, we will define the addition over matrices with the same `T`:
```rust
impl<T> Add for Matrix<T>
where
    T: Add<Output = T>,
{
    type Output = Matrix<T>;

    fn add(self, rhs: Matrix<T>) -> Self::Output {
        // ...
    }
}
```
Note that we do not have to specify the type of the right hand side, as it defaults to `Self`, which is `Matrix<T>` in this case. Note also that we had to bound `T` to be addable with itself where the result is again a `T`. The `where` clause can thus be read as "implement only for types `T` that are addable with itself and where such an addition returns a `T`".

We extend this implementation for additions where the element type of the right hand side matrix (which we will call `Trhs`) is different to the element type of the left hand side matrix (`Tlhs`). We also make the Output type of the addition of a `Tlhs` and `Trhs` variable, by giving the output type the name `Tout`:
```rust
impl<Tlhs, Trhs, Tout> Add<Matrix<Trhs>> for Matrix<Tlhs>
where
    Tlhs: Add<Trhs, Output = Tout>,
{
    type Output = Matrix<Tout>;

    fn add(self, rhs: Matrix<Trhs>) -> Self::Output {
        // ...
    }
}
```
This is essentially the exact same as Haskell's matrix example.

### Making the matrix's size known at compile time

As one last extension to our matrix example, we can make use of Rust's system for *const generics*. These offer a limited form of dependent types in Rust, limited in the sense that the values for each generic must be known at compile time and cannot be changed at runtime.

What this allows us to do is define matrix multiplication only for matrices of correct sizes. To demonstrate, let us first look at how the appropriate matrix struct would be defined:
```rust
struct Matrix<T, const M: usize, const N: usize> {
    // ...
}
```
We can view this as a definition of matrices of type $\texttt{T}^{\texttt{M} \times \texttt{N}}$.

To see how one would implement a matrix multiplication, we will first have to define a `Mul` trait, which will look very similar to the `Add` trait:
```rust
trait Mul<Rhs = Self> {
    type Output;

    fn mul(self, rhs: Rhs) -> Self::Output;
}
```

Reminder: Matrix multiplication is defined by the following function:
$$
\begin{aligned}
\texttt{Tlhs}^{\texttt{M} \times \texttt{N}} \times \texttt{Trhs}^{\texttt{N} \times \texttt{L}} \to \texttt{Tout}^{\texttt{M} \times \texttt{L}} : (A, B) \mapsto C \\
\text{where } \forall i, j: c_{i, j} = \sum_{k = 1}^{\texttt{N}} a_{i, k} \cdot b_{k, j}
\end{aligned}
$$

With this, we can construct a trait implementation for the `Matrix` struct:
```rust
impl<Tlhs, Trhs, Tout, const M: usize, const N: usize, const L: usize> Mul<Matrix<Trhs, N, L>>
    for Matrix<Tlhs, M, N>
where
    Tlhs: Mul<Trhs, Output = Tout>,
    Tout: Sum,
{
    type Output = Matrix<Tout, M, L>;

    fn mul(self, rhs: Matrix<Trhs, N, L>) -> Self::Output { /* ... */ }
}
```

> Technically we would also need to add `Copy` or `Clone` trait bounds for an implementation to work. However, for the sake of simplicity, we will leave those out.

At first we define all generics used, which are `Tlhs`, `Trhs`, `Tout` as well as all three const generics `M`, `N` and `L`.
Afterwards we can read the rest of the line as "implement multiplication between matrices of type $\texttt{Tlhs}^{\texttt{M} \times \texttt{N}}$ and $\texttt{Trhs}^{\texttt{N} \times \texttt{L}}$". The trait bound for `Tlhs` is as expected, however note how we also have to define that `Tout` needs to be sum-able in some way, with `Sum` being another trait defining such functionality.

What's impressive is that we define multiplication *only* on matrices that have the correct size, and as that size also must be known at compile time, that means that we can also check if the matrices' sizes are correct at compile time. We can also deduce the resulting size of such an operation, all at compile time. We did do so completely generically and it will work with matrices of *any* size.

[^rust-reference-20.2]: ["The Rust Reference"; Chapter 20.2](https://doc.rust-lang.org/reference/influences.html)

[^rust-book]: ["The Rust Programming Language" by Steve Klabnik and Carol Nichols](https://doc.rust-lang.org/stable/book/)
