### Public vs Private

Each member of a class in C++ has a specific **access level** that determines how that member can be accessed

A member can be one of three types: **public**, **private**, or **protected**
- `private` - Members declared as private can only be accessed from **within the same class**
- `protected` - Members declared as protected can only be accessed by derived classes (subclasses)
- `public` - Members declared as public can be accessed **anywhere** (inside the class, from other classes, or even outside the class)

| Access Specifier | Access within Class | Access in Derived Class | Access Outside Class |
| ---------------- | ------------------- | ----------------------- | -------------------- |
| `public`         | Yes                 | Yes                     | Yes                  |
| `protected`      | Yes                 | Yes                     | Yes                  |
| `private`        | Yes                 | No                      | No                   |

#### Classes vs Structs

> Members of a `struct` are `public` by default
> Members of a `class` are `private` by default

That is the simple difference between a `class` and a `struct` 

The keywords `public` `protected` and `private` can explicitly define access levels of functions and variables for both a struct or class. 

However, it is **best practice** for a struct to not use any access specifiers (all members will anyway default to `public`) and for a class to make member variables `private` (or `protected`) and methods `public`

A `struct` is typically used when 
- There is a simple collection of data that doesn't benefit from restricting access
- Aggregate initialization is sufficient (no need for object)
- Structs should be aggregates by convention, where direct initialization of members are allowed through an initializer list `{ }` and there are no **constructors**, no **private/protected access members**, no **virtual functions**, and no **base classes**

Otherwise, just use classes

#### Member Functions

**Member functions** are functions that belong to a class type. This means that they can be called on an instance of that class type (e.g. `e.getData()` , where `getData()` is a member function of object type `e`)
- This means they are declared in the class definition!

> C# and Java refer to these as methods, since they are object oriented languages at the core. They aren't referred to as methods in C++, but the idea still remains the same

Functions that don't belong to a class are **non-member functions** or simply **free functions**. 

With free functions, the object must be explicitly passed into the function, while with member functions, the object is implicitly passed and accessed through that object with the dot operator (`.`)

Member functions can sometimes create more clarity on what is doing the action!

### Constructors

**Constructors** are special functions automatically called after a non-aggeregate class type is created
- If an accessible matching constructor is found, then memory for the object is allocated and the constructor function is called. Otherwise, a compilation error is generated

They can also be **overloaded**, like functions

By convention, constructors **initialize member variables** (via a member initialization list) and perform **other setup functions** (error checking intialization values, opening a file or database, etc.)

Constructors must **have the same name as the class** and have **no return type** (not even `void`)

Class members are initialized in a constructor as follows via an intializer list, which initializes the member variable to the parameter variable

```
class Foo {
	int m_x;
	int m_y;
	
public:
	Foo(int x, int y) : m_x{ x }, m_y{ y } { }
};
```

This is the proper way to intialize member variables. 

The code below does the same thing, but its technically not initializing, but rather assigning. This means that `m_x` and `m_y` may go uninitialized

```
class Foo {
	int m_x;
	int m_y;
	
public;
	Foo(int x, int y) {
		m_x = x;
		m_y = y;
	}
};
```

A **default constructor** is one that accepts no arguments, meaning that it has been defined with no parameters. Suppose, class `Foo` exists where the only constructor that exists is the default constructor

```
class Foo {
public:
	Foo() { }
};
```

When creating an object, like `Foo f;` or `Foo f2{};` the **default constructor** is called, which doesn't do anything in this example

If no constructor is given, then the compiler will generate a public default constructor that does nothing, equivalent to the example above. This is known as an **implicit default constructor**

Instead of explicitly stating a default constructor, like `Foo() { }`, we can use the default keyword to have the compiler explicitly generate a default constructor for us. This is shown in the example below

```
class Foo {
public:
	Foo() = default
};
```

With a user defined constructor, member variables are not automatically initialized (you need to do it yourself). However, with compiler provided constructors (either `= default` or implicitly provided), the compiler will zero initialize member variables before running the constructor

Therefore, only create a default constructor when it makes sense for objects of a class type to be created using all default values

### Namespaces

**Namespaces** group together related code (variables, functions, classes, etc.) under a name to avoid naming conflicts. 

- The built in `cout` function for console output belongs to the standard `std` namespace, which is why we namespace it with `std::cout`
	- This avoids naming conflicts in case we decided to make our own `cout` function (this actually was a thing back in old C++, where `cout` didnt belong to the `std` namespace)
	- There is a way to get around this with `using namespace std`, but if we end up defining our own `cout` function, this causes a **namespacing collision** and our code won't compile!

## References and Pointers

A **reference** is an alias of an existing object. It refers to the same object in memory with a different **name**. References are notated with an `&`

```
int x = 10;
int& xRef = x;
xRef = 20;

// After x will also become 20 because they refer to the same memory
```

After running the code above, `x` will also become 20 because `x` and `xRef` refer to the same address in memory

**Note that this is called an lvalue reference in modern C++**

A **pointer** is a variable that **stores the memory address** of another variable, thereby "pointing" to that variable's address in memory
- `*` is the syntax used after a type to declare a pointer type and it is used in conjunction with `&` (the address of operator) to get a variable's address in memory!
- `*` (dereferencing operator) is also used to dereference a pointer to access the value that it points to
- Pointers can be **null** (meaning they point to nothing!)
	- Dereferencing these points can lead to undefined behavior (segmentation fault!)
	- `nullptr` keyword can be used to check if a pointer is null! This also avoids dangling pointers! 
		- `NULL` and `0` can also reference null pointers. `NULL` comes from `C`, while `0` is an address that typically represents a null pointer. However `0` and `NULL` should be avoided in modern C++ in favor of `nullptr`

```
int x = 7;
int* xPtr = &x;
std::cout << *xPtr << std::endl;
```

The code snipped above still prints `7` to the console because it is dereferencing the pointer's value!

Since a pointer points to the memory address of another variable, it is important to initialize a proper memory address to it. Leaving a pointer **uninitalized** can cause problems!

A pointer is **very similar** to a reference. However, a **reference** is an alias that always refers to one fixed variable, while a **pointer** stores the **memory address** of any variable (or nothing/null). Try to use **references** over pointers because pointers can be dangerous

**Dangling Pointers and References** are those that happen when they refer to memory that’s no longer valid (usually because the object was destroyed or went out of scope)
- **Dangling pointer:** A pointer points to memory that has been freed or deleted
- **Dangling reference:** A reference refers to an object that no longer exists (e.g., a local variable that went out of scope)

These can be **dangerous** because they can lead to **undefined behavior**, **crashes**, or **data corruption**

## Dynamic Memory Allocation

**Dynamic Memory Allocation** assigns memory space during a program's execution rather than compile time. This memory that the program uses is generally divided into the **stack** and the **heap**.
### `new` and `delete`

C++ supports static and automatic memory allocation. **Automatic allocation** creates variables that live only while the function runs (on the stack), while **static allocation** creates variables that stay alive for the whole program (in static memory). The period in which a variable stays alive is known as its **lifetime**

Lifetime based on allocation type
- **Automatic objects**: lifetime ends when they go **out of scope** (e.g., when a function/block ends)
- **Static objects**: lifetime ends when the **program terminates**

With these two methods, the size of the variable/array must be known at compile time, and memory allocation and deallocation happen automatically (when a variable is instantiated/destroyed)

However, there may be situations where declaring a fixed size memory may lead to a waste of unused memory or there are more allocated objects of memory than what was assigned. 

To fix this problem, memory can be manually managed dynamically, which is known as **dynamic memory allocation**. This is done using two keywords `new` and `delete`

`new` - **Dynamically allocate memory at runtime on the heap for an object/array**. Also calls the **constructor** to initialize the object and returns a typed pointer to the allocated memory
- This is very similar to `malloc` in C (They actually do the same thing!). However, `malloc` is by default a void pointer (`void*`) and needs to be casted to the appropriate pointer type. Therefore in modern C++, `new` is highly recommended.

`delete` - **Frees memory allocated by** `new`. Also calls the **destructor** to clean up the object. Must match the type of allocation (`delete` for single objects and `delete[]` for arrays)
- Ensure that the pointer points to a valid object (has a valid address of memory!). Otherwise, unpredictable behavior can happen!
- Similar to `free` in C, but since there are no destructors, `free` wont call the destructor if there is any
- **Ends the lifetime of the object the pointer points to!**

Note that when you use `delete`, even though the object is freed from memory, its pointer now points to **invalid memory**. This is a **dangling pointer**. Therefore, it is best practice to set the pointer to `nullptr` (null) after using `delete`, as suggested in the code snippet below, which avoids the dangling pointer.

```
int* xPtr = new int(5);
delete xPtr;
xPtr = nullptr;
```

While static and automatic memory management free variables from memory its lifetime ends or out of scope respectively, memory must be explicitly freed with `delete` when dynamically allocated. 

> In other words, when creating memory calls with `new` they **must** be freed with `delete`. 

Otherwise, a **memory leak** happens. **Memory leaks** occur when a program allocates memory via `new`, but never frees it via `delete`.  This causes unused memory, which can eventually exhaust available memory if it happens repeatedly

### Destructors

A **destructor** is another special kind of class member function that runs when an object of that class is **destroyed**, using `delete`. While constructors initialize instances of a class, destructors help clean them up

When objects go out of scope via RAII, or a dynamically allocated object is explicitly deleted using `delete`, the class destructor (if it exists) is automatically called to do any necessary clean up of the object before it is freed from memory

Like constructors, destructors also have specific naming rules

1. Must have **same name** as the class (like a constructor)
2. Cannot have a **return type** (like a constructor)
3. Cannot take **any arguments**

Suppose `Foo` is a class with a default constructor (`Foo() = default`). The destructor for `Foo` is like one below

```
~Foo() {

}
```

### RAII

**Resource Acquisition Is Initialization**, or RAII, is a C++ programming design pattern that explains how to manage resources safely in a class through a constructor and a destructor. RAII is used heavily in the C++ STL (standard template library) for efficient resource management in objects. 

> [!RAII]
> You acquire a resource (memory, file, lock, etc.) via an object's **constructor** and you automatically release that resource via the object's **destructor** 

In other words, an object **acquires** a resource in its **constructor** and **releases** it in its **destructor**

These resources can include anything the class owns or manages
- A file handle
- A pointer to dynamic memory
- A mutex lock
- A network connection

RAII is a basic technique that explains best practices towards writing a class by **tying an object's resources to its lifetime** 
	- An object acquires a resource in its constructor, and releases it via its destructor when its lifetime ends

### Heap

The heap, also known as the **free store**, **tracks memory used for dynamic memory allocation**

Recall that `new` allocates memory and returns a pointer that points to that allocated memory. In contrast, `delete` frees the allocated memory towards the operating system to decide what to do with that memory next. 

This dynamic memory allocation behavior is all managed via the heap. This means that `new` will allocate memory onto the heap and `delete` will return the allocated memory from the heap, where the operating system can decide what to do with this memory later.

**Heap Advantages and Disadvantages**
- Allocating memory on the heap is slow
- Allocated memory stays allocated until the programmer deallocates the memory themselves or the application ends (OS cleans it up)
	- Even though an OS will clean up dynamically allocated memory at the end of the program, **memory leaks** are still bad practice and you should always `delete` dynamically allocated memory
			- This is a problem for bigger programs that handle lots of data, where they can possibly slow down, crash, or cause system instability
- Dynamically allocated memory must be accessed through a pointer. Therefore, dereferencing a pointer is slower than accessing a variable directly
- Because the heap is a big pool of memory, large arrays, structures, or classes can be allocated here

### Stack

The **stack**, formally referred to as the **call stack**, keeps track of all active functions (ones that have been called and not terminated) from the start of the program to the current point of execution. It also handles allocation of all function parameters and local variables

It stores
- **Local Variables** - function parameters and variables declared inside functions
- **Function call information** - where to return after a function finishes

When a function is called, a stack frame is created on top of the call stack that holds the function's local data. When the function ends, its stack frame is removed, and the memory is automatically reclaimed

**Key Details**
- The stack is **fast** because elements are accessed in a **LIFO** (Last In First Out) format. This means that both removal and insertion is $O(1)$
- Variables in the stack have automatic storage duration and only exist when the function is running
- Limited size (few MBs), so you can run out of stack space if you create too many local variables or deep recursion

All in all, the **stack** is memory for **local variables** that are automatically managed and exist only when a function is **running**. The **heap** is slower memory for **dynamically allocated variables** (`new`) that must be managed **manually** with `delete`

- **Stack data**: local variables inside functions, function parameters, pointer variables themselves (not what they point to)
	- Used for short-lived, simple variables
- **Heap data**: Any variable dynamically allocated via `new` or `malloc`
	- Use when a variable is needed to outlive the function or for large or dynamically-sized data

### Passing Arguments

There are three ways to pass arguments into a function
1. **By Value** - A copy of the argument is made; changes inside the function do **not** affect the original

```
void foo(int x) {
    x = 10;
}
```

In the example above, assigning `x = 10` only changes the local variable in the function. It does not affect the original `x` parameter being passed into the function. Instead, it creates a copy of `x` and changes that.

2. **By Reference** - The function receives an alias to the original argument; changes affect the caller’s variable

```
void foo(int& x) {
    x = 10;
}
```

In the example above, assigning `x = 10` changes the original `x` parameter to `10`

3. **By Pointer** - The function receives a pointer to the original variable, where you must dereference to modify

```
void foo(int* x) {
    *x = 10; 
}
```

In the example above, the function receives a pointer to the original parameter of `x`, which must be dereferenced with `*` to modify the original parameter

### Returning Values

Same three ways variables are passed into a function, are the same three ways variables are returned in a function

1. **By Value** - Returns a copy of the object

```
int foo() {
    int x = 5;
    return x;
}
```

In the example above, `x` is returned as a copy of the original `x` variable

2. **By Reference** - Returns a reference (alias) to an existing variable, but doesn't refer to a local variable that goes out of scope!

```
int& foo(int& x) {
    return x;
}
```

In the example above, `x` is simply returned as a reference to an existing variable. Be careful! Referencing a local variable that goes out of scope can lead to undefined behaviors!

3. **By Pointer** - Returns a pointer to an object (can be null). The caller can modify the object via the pointer

```
int* foo(int* x) {
    return x;
}
```

In the example above, `x` is simply returned as a pointer to an existing variable. Be careful! Like references, pointing to a local variable that goes out of scope can lead to undefined behaviors!

## Copy Semantics

**Copy Semantics** refers to how objects are copied when they are passed as arguments to functions, returned from functions, or assigned to other objects. Copy semantics dictate the rules for creating new objects that are copies of existing ones. Simply speaking, they **define** how objects are copied

A **copy constructor** is used to initialize an object with an existing object of the same type. After the copy constructor executes, the newly created object becomes a copy of the object passed in the initializer

- **Implicit Copy Constructor** - If a copy constructor is not provided for a class, the compiler will create a public **implicit copy constructor** for you

An explicit copy constructor can also be created, by taking in an referenced object type of that class

```
class Foo {
public:
	Foo(const Foo& foo) {
		
	}
};
```

where `Foo a; Foo b = a` implicitly calls the copy constructor on `b`. 

### Shallow and Deep Copies

**Shallow** and **deep** copies define how objects are copied!

A **shallow copy** occurs where an object's **pointers** are copied, but **not** **the data they point to**
- Both the object and the copied object share the same underlying data, which means that changing one pointer affects both objects
- If one object deletes or modifies the pointer, the other may be left with invalid data, causing crashes and segmentation faults resulting in undefined behavior or unexpected data, which may contain varied data than what was ideal

A **deep copy** is a completely independent copy of all data, including an object's pointers and the memory they point to
- Unlike a shallow copy, the object and the copied object **do not share the same data**
	- Instead, the copied object **allocates new memory** and copies the actual data, so they’re fully independent

### Copy Assignment Operator

The Copy Assignment Operator can be overloaded to define copy semantics **after** objects have been constructed. An example looks like such code below

However, multiple checks that are typically implemented include
- Self assignment check (`this != &other`)  to ensure that an object is not copying itself!
- Frees or cleans up resources that the current object owns
- Deep copies data from the source object
- Returns `*this`, a reference to the current object to allow assignment chaining (recall that `this` is an implicit pointer to the current object in a class)

```
Foo& operator=(const Foo& other) {
    return *this;
}
```

Typically, you need to overload it when
- Your class owns dynamically allocated memory or other resources.
- You want to **avoid shallow copies** that lead to double frees or dangling pointers
- You want to implement **deep copying** semantics

### Default and Delete on Copy constructors

Just like a regular constructor, we can have the compiler explicitly generate a `default` copy constructor, `Foo(const Foo& foo) = default`
- Note that this will perform a **shallow copy**

`= delete` on a copy constructor will prevent objects of a certain class from being copied

## Move Semantics

**Move semantics** allow the resources owned by one object to be **moved** or **transferred** to another object **without copying** the underlying data. They simply define how objects are moved!

Deep copies can be expensive, especially when objects manage dynamic memory or other expensive resources. Therefore, move semantics come in handy and avoid a deep copy when necessary
- Simply use move semantics when you want to avoid copying expensive resources and instead transfer ownership to another object!

They are defined like copy semantics, including a **move constructor** and **move semantics**

### rvalue references

An rvalue is a temporary object or value that **does not** have a persistent memory address. This is the opposite of an lvalue, which has a persistent memory address

`int x = 1`

In the code snippet above, `x` is an lvalue (left value) because it is stored in memory with a persistent memory address
- Recall that a pointer will store this memory address and an lvalue reference - sometimes simply called a reference - is a reference or alias to an existing value in memory

In contrast, `1` is an rvalue. It is a temporary value used to initialize `x`

**rvalue references** (right-value references) are references that bind to **rvalues**, temporary objects or literals that are about to expire. They enable **move semantics** by allowing the program to **take ownership** of resources from these temporary objects, avoiding expensive copies

Understanding these make understanding move semantics much more easier because ultimately what happens is the rvalue of one object is being moved to another object via a rvalue reference of the other object

### Move Constructor

A **move constructor** defines how objects should be moved once initialized

The code below defines a move constructor. Suppose class `Foo` contains two variables `data` and `size` and we want to move it to an rvalue reference called `other`
- `data` is a dynamically allocated int and `size` is an int
- An example of moving the data from `other` to the current object `this` is shown below by using an object's rvalue reference, `other`

```
Foo(Foo&& other) {
	// Move the data of the other object to this object
	this->data = other.data;
	this->size = other.size;

	// Set data pointer to null and size to 0
	other.data = nullptr;
	other.size = 0;
}
```

### Move Assignment Operator

The **move assignment operator** defines how objects should be moved after being initialized

The code below defines a move assignment operator, but typical operations that are implemented include
- **Self-assignment check** (`this != &other`) - ensures that an object is not moving into itself
- Free or clean up any resources that the current object owns (like deleting dynamically allocated memory)
- **Stealing resources from the source** - transfer the ownership of the resources from the `other` rvalue object to the current object by copying pointers or handles
- **Leave the source in a valid, but empty state** - Set the `other` object pointers or resource handles to `nullptr` or equivalent so that destructor won't free the resources again (double free - free what has already been freed)!
- Return `*this`, a reference to the current object!

```
Foo& operator=(Foo&& other) {
	return *this;
}
```

`std::move()` will trigger move semantics! For example, in the code below

```
Foo a;
Foo b = std::move(a);
```

`b` will call its move semantics into `a`, effectively moving `a`'s resources into `b`

Simply speaking, move semantics are triggered when an object is treated as an rvalue (like the example above), either because it’s a temporary (like `Foo a = Foo()`) or explicitly calling `std::move` (which converts an `lvalue` into an `rvalue`)

## Rule of Zero/Three/Five

When a class manages resources (**dynamic memory**, file handles, etc.), it **must** define how it is **copied**, **moved**, and **destroyed** in order to avoid issues like memory leaks or double deletes

The rule of zero/three/five are rules widely adopted in C++ related to memory/resource management and ownership, specifically about when and how you should define or avoid defining special member functions in a class

**Rule of Zero** - If your class doesn't manage resources directly, **DO NOT** define the **big five**
- Destructor
- Copy Constructor
- Copy Assignment
- Move Constructor
- Move Assignment

**Rule of Three** - If you define one of a **destructor**, **copy constructor**, or **copy assignment operator**, **you should define ALL three of them!**
- This is because handling one implies your class is managing a resource that needs careful copying and cleanup

**Rule of Five** - Applies to modern C++, where if you plan on managing resources with move semantics, define **all 5 of the following** (this is the opposite of the **rule of zero**)
- Destructor
- Copy Constructor
- Copy Assignment
- Move Constructor
- Move Assignment

Use this rule when you need to **avoid deep copying** and allow your class to be efficiently moved