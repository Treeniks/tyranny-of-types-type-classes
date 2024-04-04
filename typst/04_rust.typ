= Rust

Rust is known to be a language that combines different features of different programming languages into one language, with the goal of only keeping whatever works best and eliminating whatever doesn't. When it comes to polymorphism, Rust combines the concept of type classes with generics, the latter of which is usually seen in object oriented languages like Java, C\# and C++.

== Generics: Rust's Parametric Polymorphism

Generics, in their simplest form, are a form of parametric polymorphism. As such, the length function on slices can be defined with a generic which we will name ```rust T```. #footnote[Because Rust only implements many ideas from functional languages, but is in itself a C-like imperative language, the terminology used for similar things will be slightly different, so will the syntax. In this case, we use a slice in place of a list. A slice in Rust is a reference to a specific area inside an array (or similar), or to the entire array itself. The type ```rust usize``` is one of Rust's unsigned integer types. Also, pay no mind to ampersands inside the Rust code, as it is not of importance for this topic.]
```rust
fn len<T>(slice: &[T]) -> usize {
    // calculate and return length
}
```
We will leave out the implementation of the length function here, because it requires knowledge of the underlying layout of slices. The function is given by Rust's STL~@rust-len.

We will also slightly alter the declaration of this function. As it stands, ```rust len``` is declared as a standalone function, but in the real Rust STL it is actually defined as a member function on the slice primitive. To implement member functions on types, Rust uses the ```rust impl``` keyword. Note that we also must declare the generic ```rust T``` with the ```rust impl``` keyword, as the type we are implementing on itself uses the generic:
```rust
impl<T> [T] {
    fn len(&self) -> usize {
        // calculate and return length
    }
}
```
```rust self``` is a keyword used in Rust to allow a call with the dot operator, e.g. so one can write ```rust my_slice.len()``` instead of ```rust len(my_slice)```. It implicitly is of the type the ```rust impl``` block is defined on.

== Traits: Rust's Type Classes

In their simplest form, traits are the exact same concept as type classes, they simply define a named set of operations. This is because Rust's traits are heavily inspired by type classes~@rust-reference[Chapter~20.2]. The main difference between the two being a slight change in nomenclature. Whereas in Haskell we explicitly gave the type we are later instancing on a name, i.e. the ```haskell a``` in ```haskell class Eq a```, in Rust this type is implicitly called ```rust Self```. ```rust Self``` is not the same as ```rust self```, ```rust self``` is a value and ```rust Self``` is ```rust self```'s type.

To see how traits work, we will implement the same equality type class from @haskell-type-classes: #footnote[Rust's STL also defines an ```rust Eq``` trait, however this is actually a marker trait without any function declarations. Instead, what we are doing here is more similar to the STL's ```rust PartialEq``` trait (although that one also has a default implementation for not equals).]
```rust
trait Eq { fn eq(&self, other: &Self) -> bool; }
```
What we called a type class instance in Haskell we call a trait implementation in Rust, because doing so extends the previously used ```rust impl``` keyword:
```rust
impl Eq for usize {
    fn eq(&self, other: &Self) -> bool {
        // ...
    }
}
```
We can of course also implement the trait on other types, such as Rust's floating point primitive ```rust f32```:
```rust
impl Eq for f32 {
    fn eq(&self, other: &Self) -> bool {
        // ...
    }
}
```

Like Haskell, Rust is also statically typed, and therefore calling ```rust eq``` on either ```rust usize``` or ```rust f32``` types will automatically pick the correct function at compile time, and calling it on any other type will give us a compile time error.

=== Trait bounds: Rust's type constraints

Trait bounds allow us to tell the Rust compiler that a generic function only makes sense, if those generic types implement a specific trait. This is the exact same as Haskell's type constraints discussed in @constraints. We will also use the same ```haskell Cost``` example and thus first define a ```rust Cost``` trait:
```rust
trait Cost { fn cost(&self) -> usize; }
```
Then we will implement the trait for some custom data type, which will be an enum with two variants with the exact same semantics as the custom data type we used for the Haskell example:
```rust
enum Custom { Cheap, Expensive }
impl Cost for Custom {
    fn cost(&self) -> usize {
        match self {
            Custom::Cheap => 0,
            Custom::Expensive => 1,
        }
    }
}
```
And now we again define a ```rust cheapest``` function, however this time we define it on slices instead of lists:
```rust
fn cheapest<T>(elements: &[T]) -> &T where T: Cost {
    // the exact implementation is not relevant
    elements.iter()
        .min_by(|x, y| x.cost().cmp(&y.cost()))
        .unwrap()
}
```
Inside the ```rust cheapest``` function, we use the ```rust cost``` method on elements of the slice. To do so, we must tell the compiler that elements of the slice implement such function, which is done by giving the ```rust cheapest``` function a ```rust where``` clause. Inside a ```rust where``` clause, we can define as many trait bounds as we want which are of the form ```rust type: bound```. In this case, we are adding a bound ```rust Cost``` for the generic ```rust T``` inside the ```rust where``` clause, meaning that the function ```rust cheapest``` shall only exist for ```rust T```s that have a ```rust Cost``` implementation.

=== Creating implementations from other implementations

As with Haskell, we can create implementations for generic types, where the generics are constrained, i.e. have trait bounds. For this, we will again implement ```rust Cost``` for slices where the slices' elements implement ```rust Cost```:
```rust
impl<T> Cost for [T] where T: Cost {
    fn cost(&self) -> usize {
        self.iter().map(|x| x.cost()).sum()
    }
}
```
// Rust only allows us to do so if _either_ the type we're implementing on _or_ the trait is not foreign, i.e. local to the current crate (which is Rust's version of a package)~\cite{rust-book}. This is done to prevent certain situations that could cause ambiguities when selecting a method.
// TODO the above is not really necessary is it?

=== Generic traits: Rust's multi-parameter type classes

So far we faced a similar problem we did in Haskell: If we wanted to define an ```rust Add``` trait with an ```rust add``` function, that function would have to take the same types for both parameters. This limitation can be removed in Rust by using generics inside the trait's definition:
```rust
trait Add<T> { fn add(self, rhs: T) -> Self; }
```
Unlike in Haskell, we did not have to enable a language extension first, as Rust supports this out of the box.

As in @haskell-add, the output is set to be of the same type as the left hand side, which we could fix by adding a second generic:
```rust
trait Add<T, U> { fn add(self, rhs: T) -> U; }
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
If we were to call ```rust 1_usize.add(3.2_f32)```, we would have to specify _which_ ```rust add``` function we want to call: #footnote[This uses Rust's Fully Qualified Syntax for Disambiguation~@rust-book[Chapter~19.2] and it looks rather complex. However, by simply binding the result to a variable, it would be enough to give said variable a type: ```rust let k: f32 = 1_usize.add(3.2_f32);```.]
```rust <usize as Add<f32, f32>>::add(1_usize, 3.2_f32)```

=== Associated types <rust-associated-types>

Once again, Rust also defines the notion of associated types, which also work very similar to Haskell. Just as in Haskell, an associated type is another type parameter that is fixed for a specific configuration of types inserted in the generics. And as before, we will use an associated type to define the output type of an addition.

First we must edit the ```rust Add``` trait's definition. We will add an associated type called ```rust Output``` and we will also change the name of the generic ```rust T``` to ```rust Rhs``` and default it to ```rust Self```: #footnote[This is actually how the real world ```rust Add``` trait in Rust's STL is defined, with the exception of access modifiers.]
```rust
trait Add<Rhs = Self> {
    type Output;
    fn add(self, rhs: Rhs) -> Self::Output;
}
```
The type ```rust Output``` is now fixed for a given ```rust Self``` and ```rust Rhs``` type. Notice how we didn't call the associated type ```rust AddOutput``` like we did in the Haskell example. The reason being that, in Rust, the associated type is in the namespace of the surrounding trait. That is why, to use the associated type as the output type of the ```rust add``` function, we need to qualify it as ```rust Self::Output``` which implicitly translates to ```rust <Self as Add<Rhs>>::Output``` inside this trait. That way, we can reuse the ```rust Output``` name for all operations.

Implementing the ```rust Add``` trait now means one also has to define the ```rust Output``` associated type, which we will set to be a float like we did with Haskell:
```rust
impl Add<f32> for usize {
    type Output = f32;
    fn add(self, rhs: f32) -> Self::Output {/*...*/}
}
```
If we were to add another implementation with ```rust type Output = usize```, the Rust compiler would detect the ambiguity and throw an error.

=== A matrix example

Rust generics can also be used for structs, which are Rust's custom data types. To mirror the matrix example from @haskell-matrix, let us assume we have a generic matrix struct ```rust Matrix<T>``` where the matrix's elements are of type ```rust T```.

First, we will define the addition over matrices with the same ```rust T```:
```rust
impl<T> Add for Matrix<T> where T: Add<Output = T> {
    type Output = Matrix<T>;
    fn add(self, rhs: Matrix<T>) -> Self::Output {
        // ...
    }
}
```
Note that we do not have to specify the type of the right hand side, as it defaults to ```rust Self```, which is ```rust Matrix<T>``` in this case. Note also that we had to bound ```rust T``` to be addable with itself where the result is again a ```rust T```. The ```rust where``` clause can thus be read as "implement only for types ```rust T``` that are addable with itself and where such an addition returns a ```rust T```".

We extend this implementation for additions where the element type of the right hand side matrix (which we will call ```rust U```) is different to the element type of the left hand side matrix (```rust T```). We also make the Output type of the addition of a ```rust T``` and ```rust U``` variable, by giving the output type the name ```rust O```:
```rust
impl<T, U, O> Add<Matrix<U>> for Matrix<T>
where
    T: Add<U, Output = O>,
{
    type Output = Matrix<O>;
    fn add(self, rhs: Matrix<U>) -> Self::Output {
        // ...
    }
}
```
This is essentially the exact same as Haskell's matrix example.

// ===== removed to fit within the page limit
=== Making the matrix's size known at compile time

As one last extension to our matrix example, we can make use of Rust's system for _const generics_. These offer a limited form of dependent types in Rust, limited in the sense that the values for each generic must be known at compile time and cannot be changed at runtime.

What this allows us to do is define matrix multiplication only for matrices of correct sizes. To demonstrate, let us first look at how the appropriate matrix struct would be defined:
```rust
struct Matrix<T, const M: usize, const N: usize> {
    // ...
}
```
We can view this as a definition of matrices of type $upright(T)^(upright(M) times upright(N))$.

To see how one would implement a matrix multiplication, we will first have to define a ```rust Mul``` trait, which will look very similar to the ```rust Add``` trait:
```rust
trait Mul<Rhs = Self> {
    type Output;

    fn mul(self, rhs: Rhs) -> Self::Output;
}
```

#figure(
    [
        ```rust
        impl<T, U, O, const M: usize, const N: usize, const L: usize> Mul<Matrix<U, N, L>>
            for Matrix<T, M, N>
        where
            T: Mul<U, Output = O>,
            O: Sum,
        {
            type Output = Matrix<O, M, L>;

            fn mul(self, rhs: Matrix<U, N, L>) -> Self::Output { /* ... */ }
        }
        ```
    ],
    caption: [Rust matrix example with const generics]
) <full-matrix>

Reminder: Matrix multiplication is defined by the following function:
$
upright(T)^(upright(M) times upright(N)) times upright(U)^(upright(N) times upright(L)) -> upright(O)^(upright(M) times upright(L)) : (A, B) |-> C \
"where" forall i, j: c_(i, j) = sum_(k = 1)^(upright(N)) a_(i, k) dot b_(k, j)
$
With this, @full-matrix shows how we can construct a trait implementation for the ```rust Matrix``` struct. #footnote[Technically we would also need to add ```rust Copy``` or ```rust Clone``` trait bounds for an implementation to work. However, for the sake of simplicity, we will leave those out.]

At first we define all generics used, which are ```rust T```, ```rust U```, ```rust O``` as well as all three const generics ```rust M```, ```rust N``` and ```rust L```.
Afterwards we can read the rest of the line as "implement multiplication between matrices of type $upright(T)^(upright(M) times upright(N))$ and $upright(U)^(upright(N) times upright(L))$". The trait bound for ```rust T``` is as expected, however note how we also have to define that ```rust O``` needs to be sum-able in some way, with ```rust Sum``` being another trait defining such functionality that we have not defined here.

What's impressive is that we define multiplication _only_ on matrices that have the correct size, and as that size also must be known at compile time, that means that we can also check if the matrices' sizes are correct at compile time. We can also deduce the resulting size of such an operation, all at compile time. We did so completely generically and it will work with matrices of _any_ size.
// =====
