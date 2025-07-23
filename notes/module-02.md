
# Module 2 - C++ Review

Contacting the CS 225 course - cs225admin@lists.cs.illinois.edu

##  Encapsulation

Encapsulation in C++ is primarily distinguished via two things: **header** and **code**. In C/C++, code is separated into two files, one which we call the **header** and one which we call the **code segment**
-  **header files** - Describes how the code is used, or how people should use this specific data structure
- has a `.h` or `.hpp` extension. Mostly `.h`, but `.hpp` is used for **templates**, which help write **generic** code that supports any data type
-  **code files** - Describes how the code works, or how the data structure is implemented!
- has a `.cpp` file extension

Object Oriented languages also provide with two main things, a **constructor**, which initializes the necessary data for us in a object and a **destructor** which gets rid of any necessary data for us in an object

##  Memory Management - Ownership

Someone or some code owns everything, which simply means that **one part of the program is responsible** for
- Creating an object in memory (**Constructor**)
- Keeping track of it
- Deleting (freeing) it when it's no longer needed (**Destructor**)

This essentially means that the programmer is responsible for managing memory, which can both be powerful and dangerous. Forgetting to free allocated memory can cause **memory leaks**, or program crashes. In contrast, **freeing** memory too early can cause **dangling pointers** and **undefined behavior (segfaults)**.

Ownership is tracked carefully using `new` and `delete`, or use smart pointers like `std::unique_ptr`, `std::shared_ptr`, `std::weak_ptr`

##  Rule of Zero/Three/Five

When your class manages resources (**dynamic memory**, file handles, etc.), you need to define how it is **copied**, **moved**, and **destroyed** in order to avoid issues like memory leaks or double deletes

The rule of zero/three/five are rules widely adopted in C++ related to memory/resource management and ownership, specifically about when and how you should define or avoid defining special member functions in a class

**Rule of Zero** - If your class doesn't manage resources directly, do not define the **big five**
- Destructor
- Copy Constructor
- Copy Assignment
- Move Constructor
- Move Assignment

**Rule of Three** - If you define one of a **destructor**, **copy constructor**, or **copy assignment operator**, **you should define ALL three of them!**

- This is because handling one implies your class is managing a resource that needs careful copying and cleanup

**Rule of Five** - Applies to modern C++, where if you plan on managing resources with move semantics, define **all 5** (this is the opposite of the **rule of zero**)

- Destructor
- Copy Constructor
- Copy Assignment
- Move Constructor
- Move Assignment

Use this rule when you need to **avoid deep copying** and allow your class to be efficiently moved
<!--stackedit_data:
eyJoaXN0b3J5IjpbLTkxNjY1Njc5M119
-->