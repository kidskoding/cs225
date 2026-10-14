#import "../diagrams.typ": array-cells, linked-list

= Hashing, Hash Collisions, and Hash Tables

Hashing is the data structure you've all heard of before, but that we've been studiously, intentionally ignoring until now. It's also our first *probabilistic* data structure: instead of promising that every operation is fast, it promises that operations are fast *in expectation*

Let's start with the problem it solves. Say I have a library full of books and I want to store them in a dictionary (recall the dictionary ADT: `insert(key, value)`, `remove(key)`, and `find(key)`). So far we've seen three real dictionaries

#table(
  columns: 4,
  table.header([*Dictionary*], [*`find`*], [*`insert`*], [*`remove`*]),
  [Sorted array], [$O(log n)$], [$O(n)$\*], [$O(n)$],
  [BST], [$O(h)$, worst $O(n)$], [$O(h)$, worst $O(n)$], [$O(h)$, worst $O(n)$],
  [Balanced BST (AVL tree)], [$O(log n)$], [$O(log n)$], [$O(log n)$],
)

`find` in a sorted array is just binary search. `insert` is a binary search to find where the new key goes, and then $O(n)$ to shift everything over to make space. The `*` is a reminder that it's also amortized, since sometimes the array is full and we double it, which only costs a constant amount of extra work per insert

A BST runs in the height of the tree, since there's only one place a key can go and finding it means walking down from the root. Strictly that's $O(n)$, since a "tree" shaped like a linked list is still a BST, which is why we built AVL trees to force the height back down to $O(log n)$. So as long as we're doing any edits, the balanced BST is our best dictionary. It also has one bonus feature: an in-order traversal lists the keys in sorted order in $O(n)$, which is what made range searches (and KD trees) possible. Not every dictionary can do that, so keep it in mind

But $O(log n)$ isn't constant. For any one lookup, $log n$ is fast enough and I don't care. But what if my program's main loop is "look this up, look this up, look this up" millions of times? Then those $log n$s add up, and we'd like to do better

Here's the plan: instead of a guarantee that *every* operation is fast, we'll settle for operations that are *usually* fast. Just like amortization let us charge an expensive resize across many cheap inserts, if we do a huge number of operations whose *expected* runtime is constant, the law of large numbers makes it very likely that the total really is about (expected runtime) $times$ (number of operations)

== Hash Functions

What we want is a function that takes *any key that could possibly exist* and quickly turns it into an integer in some range: an index into an array. If we had that, finding a key would be easy: "where is it? It's at this index, we just have to run the function." That's exactly what a *hash function* is

$ h : K -> {0, 1, dots, m - 1} $

where $K$ is the *keyspace* (every possible key) and $m$ is the size of our array

We've actually already used one. Back when we wanted to remember which pixels of an image we'd visited, we turned pixel $(x, y)$ into the number `y * width + x`. That number is unique for every pixel and really fast to compute, so it's a hash function over a small, finite keyspace. When the array is at least as big as the keyspace like this, we can have a *perfect hash function*, where every key gets its own unique index (it's one-to-one). From a data structures point of view, the *ideal* hash function is both one-to-one and onto, so we can go both ways: given a key we can compute its index, and given an index we can compute which key lives there

The problem is that most keyspaces are enormous. Even plain integers on our machines have $2^64$ possible values, and I don't have the memory for an array with $2^64$ entries. The number of books that could ever exist is way bigger than the number of spots on my library's shelves, and my function has to work for any book that could ever exist, even though the library only stores a finite number of them. So in general, our hash function has to squeeze a huge keyspace into a much smaller array

=== What a Hash Function Must Do

A hash function has three requirements

+ *Deterministic*: if $k_1 = k_2$, then $h(k_1) = h(k_2)$. Hashing the same key twice must give the same index, or we could never find anything again. Notice it's this direction only: two *different* keys are allowed to land on the same index, and we just argued that with a huge keyspace they have to. Rolling dice is a great way to get a random integer, but it's a terrible hash function, since if I roll dice again for the same key I get a different number
+ *Efficient*: the whole point is to beat $O(log n)$, so the hash function should run in $O(1)$. If it takes $O(log n)$, just use a balanced BST and stop
+ *Defined with respect to $m$*: our array is a real object with a real size, so the output has to land in ${0, dots, m - 1}$, not just anywhere in the natural numbers

The last one is the easy one. If we have a function that produces any natural number, we just take the remainder: `% m`. So in practice, a hash function is built in two stages

+ A *hash*, which turns a key of whatever type into a (usually huge) integer
+ A *compression*, which squeezes that integer into the range of the table, almost always with `% m`

Compression can still break a hash that was fine on its own. If our hash only ever produced multiples of 8, say $8k$, then on a table of size 8 every single key would compress to index 0. Mod is what we'll use every single time, but it's worth remembering that a badly built hash can interact badly with it

The short answer to "how do I write a good hash function?" is: *don't come up with your own, you'll do it wrong*. For the rest of this chapter, we'll assume someone else hands us a good hash function, and focus on what to do with it

=== Example: Professors and Their Courses

Say we want to store professors as keys and the course they're teaching as values, in a table of size 8, using

$ h(k) = (k[0] - #raw("'A'")) mod 8 $

That is, we take the first character of the name and subtract `'A'`. Since characters are encoded in order in both ASCII and Unicode, `'A' - 'A'` is 0, `'B' - 'A'` is 1, and so on

#table(
  columns: 4,
  table.header([*Professor (key)*], [*Course (value)*], [*$k[0]$*], [*$h(k)$*]),
  [Angrave], [CS 341], [`'A'`], [0],
  [Beckman], [CS 101], [`'B'`], [1],
  [Challen], [CS 124], [`'C'`], [2],
  [Evans], [CS 225], [`'E'`], [4],
  [Alawini], [CS 411], [`'A'`], [0],
)

The first four go in beautifully, like in @hash-professors. It looks like an amazing hash function, until we try to add Alawini, who also starts with an `'A'`. Index 0 is already taken by Angrave, so we have a conflict

#figure(
  grid(
    columns: 1,
    row-gutter: 1.5em,
    align: center,
    array-cells("341", "101", "124", none, "225", none, none, none),
    array-cells("341", "101", "124", none, "225", none, none, none, marks: (Alawini: 0), highlight: (0,)),
  ),
  caption: [Example: storing courses in a table of size 8 with $h(k) = (k[0] - #raw("'A'")) mod 8$. Angrave, Beckman, Challen, and Evans each get their own index, but Alawini also hashes to 0, which Angrave already holds],
) <hash-professors>

Notice that doubling the table to 16 and switching to `mod 16` doesn't help at all: both names still start with `'A'`, so they'd still both go to 0. The real problem is that this hash only looks at one character, and the first letters of names aren't evenly spread out. It's like an early version of Java's string hash, which only looked at a handful of a string's characters. On the web, most strings were addresses that all start with the same `https://`, so huge numbers of them hashed to the same value. The hash depends entirely on what the user gives it, and users don't give us random data

=== Good and Bad Hash Functions

Let's try some hash functions for our library, where the key is a book, $m$ is the size of the table, and letters are numbered $A = 1$ through $Z = 26$

#table(
  columns: (auto, 1fr),
  table.header([*Hash function*], [*Verdict*]),
  [(first initial + last initial of the author) $mod m$], [Valid: deterministic and $O(1)$ (two lookups and one addition). Not great, since names aren't evenly distributed and every book by the same author lands in the same place, but it's something],
  [(`rand()` + number of pages) $mod m$], [Useless: not deterministic, since looking up the same book twice can give two different indices],
  [(number of times I've read the book) $mod m$], [Useless: that number can't be derived from the book itself (we'd need a dictionary of books just to build our dictionary of books), and it changes every time I reread one],
)

A few questions came up about these. Isn't the first one non-deterministic if one author wrote several books? No: all of their books get the same hash value, which isn't ideal, but the *same book* always gets the same answer, and that's all deterministic means. The output must be determined entirely by the input. What about two different authors who share initials? Also fine, for the same reason: since there are more possible books than slots in the table, *something* has to share a slot. And isn't `rand()` usually pseudorandom and seeded, so technically deterministic? Maybe, but the function as a whole doesn't give the same answer for the same book, which is what we care about. (There are even truly random sources, like Cloudflare's LavaRand, which films a wall of lava lamps.)

== Hash Collisions

So the first hash function is our best one. Let's try it

- *The Hobbit* by J.R.R. Tolkien: $J + T = 10 + 20 = 30$
- *Goosebumps* by R.L. Stine: $R + S = 18 + 19 = 37$
- *Aardvarks Anonymous* by Jim Truth: $J + T = 10 + 20 = 30$

Uh oh. *The Hobbit* and *Aardvarks Anonymous* both hash to 30, before we've even compressed anything. With $m = 16$, they both go to $30 mod 16 = 14$, like in @hash-books-collision. If a hash table were just "hash the key, go to that index, store it there", it would break right here, because index 14 is one box and we want to put two things in it

#figure(
  array-cells(..range(16).map(i => none), marks: ("Goosebumps": 5, "The Hobbit, Aardvarks Anonymous": 14), highlight: (14,)),
  caption: [Example: hashing books by the author's initials with $m = 16$. Goosebumps goes to $37 mod 16 = 5$, but Tolkien and Truth share the initials J and T, so their books collide at index 14],
) <hash-books-collision>

When two different keys hash to the same index, we have a *hash collision*. You've seen these all semester: when the autograder prints a text version of a PNG, it's printing a *hash* of the image. That hash ignores the order of the pixels, so any two PNGs with the same set of pixels hash to the same value, even when they look completely different. That's why "my hashes match but the test says the images don't!" comes up every semester. It isn't a bug: an arbitrarily large image squeezed down to a single 64-bit number has to lose information somewhere

In fact, collisions are unavoidable. If the table is at least as large as the keyspace, we can use a perfect hash function, but normally the keyspace is far bigger than any table we'd choose. By the *pigeonhole principle*, if we have $m$ slots (pigeonholes) and more than $m$ possible keys, at least one slot must get more than one key. And since our hash function has to be fixed (if it changed based on the data coming in, it wouldn't be deterministic), some collisions are baked in

So a *hash table* is built out of three things

+ A *hash function* (let somebody else come up with it)
+ A *data storage structure*, usually an array
+ A *method of handling collisions*

The biggest difference between different kinds of hash tables is the third one, and that's what the rest of this chapter is about

== Open vs. Closed Hashing

There are two families of collision handling, and they're named after where the data lives

- *Open hashing*: the array holds *pointers*, and the key-value pairs themselves live somewhere else in memory
- *Closed hashing*: the key-value pairs are stored *directly in the array*

Watch out for the confusing names: closed hashing is also called *open addressing* (the address is "open", since a key might end up at an index other than its hash), so open addressing is closed hashing. People are also a bit sloppy in practice, since a closed hashing table sometimes stores pointers to the data anyway. What really matters is the collision algorithm: if it conceptually stores each item *in* the table, we call it closed hashing

That sloppiness has a reason. A closed hashing table needs a way to say "there's nothing in this slot", so the stored type needs a value that can never be real data. A pointer gets that for free with `nullptr`, but for an arbitrary key-value type, the easiest way to guarantee it is often to store a pointer. The fastest closed hashing tables really do reserve some never-valid value of the data type instead

Open hashing is the most common, has the fewest constraints, and degrades gracefully when things go a bit wrong. Closed hashing is faster when all our ducks are in a row: the fastest hash tables in the world use closed hashing, but they get complicated. We'll start with the easier one

== Separate Chaining

The only kind of open hashing we'll talk about (and honestly, practically the only kind anyone uses, so the names are nearly synonyms) is *separate chaining*. Every slot of the array, called a *bucket*, holds the head of a *linked list* of key-value pairs, and every bucket starts out as `nullptr` (an empty list). To insert, we hash the key and `push_front` the pair onto that bucket's list. A collision is no problem at all: putting two items in a linked list is easy

Let's insert our running example keys $16, 8, 4, 13, 29, 11, 22$ (in that order) into a table of size $m = 7$, using

$ h(k) = k mod 7 $

+ $16 mod 7 = 2$, so bucket 2 becomes the list $[16]$
+ $8 mod 7 = 1$, so bucket 1 becomes $[8]$
+ $4 mod 7 = 4$ and $13 mod 7 = 6$, so they start buckets 4 and 6
+ $29 mod 7 = 1$: our first collision! We just put 29 at the front of bucket 1's list: $[29, 8]$
+ $11 mod 7 = 4$, so bucket 4 becomes $[11, 4]$
+ $22 mod 7 = 1$, so bucket 1 becomes $[22, 29, 8]$

@hash-chaining shows the final table. Each node really stores a key *and* its value as a pair (otherwise, once two keys share a bucket, how would we know which value belongs to which key?), but just like with BSTs, the drawings only show the keys

#figure(
  grid(
    columns: 1,
    row-gutter: 0.8em,
    align: left,
    [#raw("table[0]") #sym.arrow.r #raw("nullptr")],
    linked-list(22, 29, 8, head: "table[1]", highlight: (0, 1, 2)),
    linked-list(16, head: "table[2]"),
    [#raw("table[3]") #sym.arrow.r #raw("nullptr")],
    linked-list(11, 4, head: "table[4]"),
    [#raw("table[5]") #sym.arrow.r #raw("nullptr")],
    linked-list(13, head: "table[6]"),
  ),
  caption: [Example: separate chaining with $h(k) = k mod 7$ after inserting 16, 8, 4, 13, 29, 11, 22. Colliding keys are pushed onto the front of their bucket's list. `find(8)` and `find(15)` both walk the highlighted chain],
) <hash-chaining>

There's no order to a chain. It happens to be in reverse insertion order, but all we know is that every key in bucket 1 hashes to 1

=== Insert

Computing the hash is $O(1)$, and inserting at the front of a linked list is $O(1)$, so `insert` is $O(1)$ in the *worst case*. That's great! We could insert at the tail instead, but that either costs a walk down the list or a tail pointer, and buys us nothing. (This assumes we're told the key isn't already in the table. If we have to check for duplicates first, `insert` costs a `find`.)

=== Find

To find a key, we hash it, go to its bucket, and walk the chain comparing keys. In @hash-chaining, `find(8)` hashes to 1, then checks 22 (not 8), 29 (not 8), and 8, which is a match. `find(15)` also hashes to 1 and checks 22, 29, and 8, and then hits `nullptr`, so now we know 15 isn't in the table

So `find` runs in the length of the chain, and in the worst case (say, a hash function that returns 1 for every key) that's all $n$ keys, so $O(n)$. If the hash function is perfect, every chain has at most one key. The real answer depends on how long we *expect* the chains to be, and we'll work that out once we've seen the other collision strategies

=== Remove

`remove` is the same as `find`: walk the chain to the key, and then unlinking a node from a linked list is $O(1)$. @hash-chaining-remove shows `remove(29)`, which just points 22's `next` at 8. So `remove` also runs in the length of the chain: $O(n)$ in the worst case

#figure(
  grid(
    columns: 1,
    row-gutter: 0.8em,
    align: left,
    linked-list(22, 29, 8, head: "table[1]", highlight: (1,)),
    linked-list(22, 8, head: "table[1]"),
  ),
  caption: [Example: `remove(29)` from @hash-chaining walks bucket 1's chain to 29 and unlinks it],
) <hash-chaining-remove>

=== The Code

This basically codes itself with `std::list` and `std::pair`. Keys are assumed to be non-negative integers so that `key % m` works, and since this version never resizes, its expected runtimes are in terms of the load factor $alpha$, which we'll define soon

```cpp
// ChainedTable.h

#pragma once

#include <list>
#include <string>
#include <utility>
#include <vector>

class ChainedTable {
public:
    /** Inserts a key-value pair at the front of the key's chain
     * Runtime: O(1)
     */
    void insert(int key, const std::string& value);

    /** Returns a pointer to the key's value, or nullptr if it's missing
     * Runtime: O(1 + alpha) expected (under SUHA), O(n) worst case
     */
    std::string* find(int key);

    /** Removes the key and its value from the table, if it's there
     * Runtime: O(1 + alpha) expected (under SUHA), O(n) worst case
     */
    void remove(int key);

private:
    /** Compresses a key into a bucket index
     * Runtime: O(1)
     */
    size_t hash(int key) const { return key % table_.size(); }

    // every bucket starts as an empty list (a nullptr head)
    std::vector<std::list<std::pair<int, std::string>>> table_ =
        std::vector<std::list<std::pair<int, std::string>>>(7);
};
```

```cpp
// ChainedTable.cpp

#include "ChainedTable.h"

/** Inserts a key-value pair at the front of the key's chain
 * Runtime: O(1)
 */
void ChainedTable::insert(int key, const std::string& value) {
    // colliding keys just share the list, so no probing is needed
    table_[hash(key)].push_front({key, value});
}

/** Returns a pointer to the key's value, or nullptr if it's missing
 * Runtime: O(1 + alpha) expected (under SUHA), O(n) worst case
 */
std::string* ChainedTable::find(int key) {
    // only this bucket can hold the key, so walk its chain comparing keys
    for (auto& entry : table_[hash(key)]) {
        if (entry.first == key) { return &entry.second; }
    }
    return nullptr;
}

/** Removes the key and its value from the table, if it's there
 * Runtime: O(1 + alpha) expected (under SUHA), O(n) worst case
 */
void ChainedTable::remove(int key) {
    // a reference, so erasing changes the chain inside the table
    auto& chain = table_[hash(key)];
    for (auto it = chain.begin(); it != chain.end(); ++it) {
        if (it->first == key) {
            // unlinking a node from a linked list is O(1)
            chain.erase(it);
            return;
        }
    }
}
```

`find` returns a pointer to the value, or `nullptr` if the key isn't there

#table(
  columns: 3,
  table.header([*Operation*], [*Worst case*], [*In terms of chains*]),
  [`insert`], [$O(1)$], [$O(1)$],
  [`find`], [$O(n)$], [$O(text("length of the chain"))$],
  [`remove`], [$O(n)$], [$O(text("length of the chain"))$],
)

This feels a lot like when we first built a BST and realized the worst case was still $O(n)$. But it's not really $n$, it's the length of a chain. Intuitively, if the hash function acts like rolling an $m$-sided die for every key, then each bucket expects about $n / m$ of the $n$ keys, just like if I roll 100 six-sided dice, I expect $100 / 6 approx 16.7$ of them to land on any particular face. We'll make this precise later

== Closed Hashing

Linked lists are easy, but closed hashing is often faster for a reason we haven't talked about much in this course: the *cache*. (You'll see the details in CS 233 or CS 340, or ECE 391 and 411.) Modern computers really want data packed densely into contiguous memory, and following pointers to linked list nodes scattered all over memory is slow in comparison. Storing everything directly in one array doesn't improve the big O, but it improves the constant factors on a lot of operations, which is why anyone bothers with the more complicated scheme

But now each slot holds exactly one key-value pair. If a key hashes to a slot that's already taken, it has to go *somewhere else in the array*, so we need a rule for which other slots to try. Checking a slot is called a *probe*

=== Linear Probing

The simplest rule is *linear probing*: if the slot is full, try the next one, and keep going until we find an empty slot. If we fall off the end of the array, we wrap around to the start. Formally, the $i$th probe for key $k$ looks at

$ h(k, i) = (h(k) + i) mod m $

for $i = 0, 1, 2$, and so on. The `mod m` at the end is what wraps us around

Some people write linear probing as one big hash function like that, and others write it as a hash function plus a probing rule. They're the same thing, but it's easiest to think of the hash function and the probing separately, since we analyze them separately

Let's insert the same keys $16, 8, 4, 13, 29, 11, 22$ with the same $h(k) = k mod 7$, like in @hash-linear-inserts

+ 16, 8, 4, and 13 hash to 2, 1, 4, and 6, which are all empty, so they go right in
+ $29 mod 7 = 1$, but 8 is there. Try 2: 16 is there. Try 3: empty, so 29 goes in slot 3
+ $11 mod 7 = 4$, but 4 is there. Try 5: empty, so 11 goes in slot 5
+ $22 mod 7 = 1$, and slots 1 through 6 are all full, so we wrap around to slot 0 after *seven* probes

#figure(
  grid(
    columns: 2,
    column-gutter: 2em,
    row-gutter: 1.2em,
    align: (right + horizon, left + horizon),
    [`insert(16)`: probe 2], array-cells(none, none, 16, none, none, none, none, highlight: (2,)),
    [`insert(8)`: probe 1], array-cells(none, 8, 16, none, none, none, none, highlight: (1,)),
    [`insert(4)`: probe 4], array-cells(none, 8, 16, none, 4, none, none, highlight: (4,)),
    [`insert(13)`: probe 6], array-cells(none, 8, 16, none, 4, none, 13, highlight: (6,)),
    [`insert(29)`: probe 1, 2, 3], array-cells(none, 8, 16, 29, 4, none, 13, highlight: (1, 2, 3)),
    [`insert(11)`: probe 4, 5], array-cells(none, 8, 16, 29, 4, 11, 13, highlight: (4, 5)),
    [`insert(22)`: probe 1, 2, 3, 4, 5, 6, 0], array-cells(22, 8, 16, 29, 4, 11, 13, highlight: (0, 1, 2, 3, 4, 5, 6)),
  ),
  caption: [Example: linear probing with $h(k) = k mod 7$. Each row shows the table after one insert, with every slot that insert probed highlighted. 22 probes the whole table before wrapping around to slot 0],
) <hash-linear-inserts>

Insert is easy to picture, as long as we can tell when a slot is empty

=== Find

To find a key, we start at its hash and probe forward until we either find it or reach an *empty* slot. Let's use the table from right after `insert(29)` in @hash-linear-inserts

- `find(29)`: start at 1. 8 is there, which isn't 29, but *something* is there, so 29 could have been pushed further down. Try 2: 16, keep going. Try 3: found it
- `find(22)`: start at 1 and probe 8, 16, 29, and 4, which are all not 22. Slot 5 is empty, so we stop: 22 isn't in the table, like in @hash-linear-find

#figure(
  array-cells(none, 8, 16, 29, 4, none, 13, marks: ("h(22) = 1": 1), highlight: (1, 2, 3, 4, 5)),
  caption: [Example: an unsuccessful `find(22)` on the table after inserting 16, 8, 4, 13, 29. It probes from slot 1 until it hits the empty slot 5],
) <hash-linear-find>

Why is it safe to stop at an empty slot? If 22 were in the table, then when it was inserted it would have probed this same sequence of slots and taken the first empty one it found. So every key sits in a *contiguous* run of full slots starting at its hash, and an empty slot means it isn't there. On a completely full table, there's no empty slot to stop at, so we also stop after checking all $m$ slots

=== Remove and Tombstones

Now let's go back to the full table from @hash-linear-inserts, `remove(16)`, and then `find(29)`. If removing 16 just empties slot 2, then `find(29)` starts at 1, sees 8, moves to 2, finds it empty, and declares that 29 isn't in the table. But it is! It's sitting in slot 3

We can't fix this by searching the whole table every time, because then `find` is $O(m)$, which is terrible. Instead, we need to tell the difference between *"there's nothing here"* and *"there has never been anything here"*. If a slot has never held anything, we can stop. If a slot used to hold something, we have to keep going, since the key we want could have been pushed past it before it was removed

So when we remove a key, we don't empty its slot, we mark it with a *tombstone* that means "something was here, but it's gone". `find` treats a tombstone as full (keep probing), and `insert` treats it as empty (we're allowed to reuse it). @hash-tombstone compares the two. It's the same trick we saw for removing from graph formats, where we marked an entry as missing instead of reshuffling a whole vector

#figure(
  grid(
    columns: 2,
    column-gutter: 2em,
    row-gutter: 1.2em,
    align: (right + horizon, left + horizon),
    [Emptied: `find(29)` wrongly stops at 2], array-cells(22, 8, none, 29, 4, 11, 13, highlight: (1, 2)),
    [Tombstone: `find(29)` keeps going], array-cells(22, 8, $dagger$, 29, 4, 11, 13, highlight: (1, 2, 3)),
  ),
  caption: [Example: `remove(16)` then `find(29)` on the full table from @hash-linear-inserts. Emptying slot 2 cuts 29 off from its hash, while a tombstone ($dagger$) tells `find` to keep probing],
) <hash-tombstone>

So every slot is really in one of *three* states. We can store an extra bit or two per slot, or reserve two special values of the key type (one for "never used" and one for "deleted"), and real implementations do both

```cpp
// ProbingTable.h

#pragma once

#include <string>
#include <utility>
#include <vector>

// never used, holding a pair, or holding a pair that was removed
enum class State { Empty, Full, Tombstone };

struct Slot {
    State state = State::Empty;
    int key = 0;
    std::string value;
};

class ProbingTable {
public:
    /** Inserts a key-value pair into the first open slot it probes
     * Runtime: O(1) amortized expected (under SUHA), O(n) worst case
     */
    void insert(int key, const std::string& value);

    /** Returns a pointer to the key's value, or nullptr if it's missing
     * Runtime: O(1) expected (under SUHA), O(n) worst case
     */
    std::string* find(int key);

    /** Removes the key from the table by leaving a tombstone in its slot
     * Runtime: O(1) expected (under SUHA), O(n) worst case
     */
    void remove(int key);

private:
    /** Returns the slot to check on the ith probe for a key (linear probing)
     * Runtime: O(1)
     */
    size_t probe(int key, size_t i) const { return (key + i) % table_.size(); }

    /** Doubles the table and rehashes every key into it
     * Runtime: O(n)
     */
    void resize();

    std::vector<Slot> table_ = std::vector<Slot>(7);

    // the number of Full slots (tombstones don't count)
    size_t size_ = 0;

    // the load factor that triggers a resize
    double maxLoad_ = 0.7;
};
```

```cpp
// ProbingTable.cpp

#include "ProbingTable.h"

/** Returns a pointer to the key's value, or nullptr if it's missing
 * Runtime: O(1) expected (under SUHA), O(n) worst case
 */
std::string* ProbingTable::find(int key) {
    // stop after m probes, so a full table can't loop forever
    for (size_t i = 0; i < table_.size(); i++) {
        Slot& slot = table_[probe(key, i)];
        // a never-used slot ends the run, so the key isn't in the table
        if (slot.state == State::Empty) { return nullptr; }
        // a tombstone or another key: ours could be further down
        if (slot.state == State::Full && slot.key == key) { return &slot.value; }
    }
    return nullptr;
}

/** Removes the key from the table by leaving a tombstone in its slot
 * Runtime: O(1) expected (under SUHA), O(n) worst case
 */
void ProbingTable::remove(int key) {
    for (size_t i = 0; i < table_.size(); i++) {
        Slot& slot = table_[probe(key, i)];
        if (slot.state == State::Empty) { return; }
        if (slot.state == State::Full && slot.key == key) {
            // not Empty, so later finds keep probing past it
            slot.state = State::Tombstone;
            size_--;
            return;
        }
    }
}

/** Inserts a key-value pair into the first open slot it probes
 * Runtime: O(1) amortized expected (under SUHA), O(n) worst case
 */
void ProbingTable::insert(int key, const std::string& value) {
    // resize first, so there's always an open slot to land in
    if (size_ + 1 > maxLoad_ * table_.size()) { resize(); }
    for (size_t i = 0; i < table_.size(); i++) {
        Slot& slot = table_[probe(key, i)];
        // both Empty slots and tombstones can be reused
        if (slot.state != State::Full) {
            slot = {State::Full, key, value};
            size_++;
            return;
        }
    }
}
```

Like the chaining version, `insert` assumes the key isn't already in the table. The `resize` call is there because a closed hashing table can fill up, which we'll deal with soon

How fast is this? An unsuccessful `find` probes from the key's hash to the end of the run of full slots it lands in, so in the worst case it walks the *longest run of full slots, plus one* for the empty slot that stops it. Everything depends on how long those runs get

=== Clustering

And that's the problem with linear probing: runs of full slots (*clusters*) love to grow. Say we have a table of size 10 with $h(k) = k mod 10$, and insert 1, 11, and 21 (which all hash to 1) and then 3 and 13 (which hash to 3). We're only using half of the table, but all five keys are in one clump from slot 1 to slot 5, like in @hash-cluster

#figure(
  array-cells(none, 1, 11, 21, 3, 13, none, none, none, none, marks: ("h(k) = 0": 0, "h(k) = 1 to 6": 6), highlight: (1, 2, 3, 4, 5)),
  caption: [Example: linear probing with $h(k) = k mod 10$ after inserting 1, 11, 21, 3, 13. Any new key that hashes to 0 through 6 lands next to the cluster and grows it],
) <hash-cluster>

If our hash function acts like a fair 10-sided die, what's the chance the *next* insert makes this cluster bigger? Any key hashing to 1 through 5 probes to the end and lands in slot 6, a key hashing to 6 lands in 6 directly, and a key hashing to 0 lands in 0, right in front of the cluster. That's 7 out of 10 hash values, so there's a *70%* chance of growing the cluster, even though the table is only half full! And each time it grows, the chance of growing it again goes up

Even starting from a single key, any later key that collides with it extends it, and every collision makes the clump bigger and easier to hit. A cluster never really goes away either: even after removing keys from it, `find` still has to probe through the tombstones. Analyzing this formally takes more probability than we're going to do here, but it's clear that big clusters get bigger. This is called *primary clustering*

The fix: instead of always trying the very next slot, let's *pick better*

== Double Hashing

Every closed hashing scheme has collisions, and the only thing it can do is choose another slot to try. The trick is to choose it in a way that doesn't feed clusters, while staying cheap: whatever work we do to pick the next slot gets charged to every insert

*Double hashing* uses *two* hash functions: $h_1$ picks the starting slot, and $h_2$ picks the *step size*, how far to jump on each probe

$ h(k, i) = (h_1 (k) + i dot h_2 (k)) mod m $

For our running example, we'll use

$ h_1 (k) = k mod 7 quad quad h_2 (k) = 5 - (k mod 5) $

Notice $h_2 (k)$ is always between 1 and 5, so it's never 0 (a step size of 0 would just probe the same slot forever). Two keys that collide at the same starting slot will usually have different step sizes, so they spread out instead of piling up next to each other. Also notice that $h_2$ isn't compressed by `mod 7` until it's combined with $h_1$

#table(
  columns: 5,
  table.header([*Key*], [*$h_1 (k)$*], [*$h_2 (k)$*], [*Linear probes*], [*Double hashing probes*]),
  [16], [2], [4], [2], [2],
  [8], [1], [2], [1], [1],
  [4], [4], [1], [4], [4],
  [13], [6], [2], [6], [6],
  [29], [1], [1], [1, 2, 3], [1, 2, 3],
  [11], [4], [4], [4, 5], [4, 1, 5],
  [22], [1], [3], [1, 2, 3, 4, 5, 6, 0], [1, 4, 0],
)

29 happens to get a step size of 1, so it does the same thing as linear probing, but 22 jumps by 3 and finds a slot after 3 probes instead of 7, like in @hash-double-vs-linear. In total that's 13 probes instead of 16 for the same seven keys

#figure(
  grid(
    columns: 2,
    column-gutter: 2em,
    row-gutter: 1.2em,
    align: (right + horizon, left + horizon),
    [Linear probing: 1, 2, 3, 4, 5, 6, 0], array-cells(22, 8, 16, 29, 4, 11, 13, highlight: (0, 1, 2, 3, 4, 5, 6)),
    [Double hashing: 1, 4, 0], array-cells(22, 8, 16, 29, 4, 11, 13, highlight: (0, 1, 4)),
  ),
  caption: [Example: the probes for `insert(22)`, the last of our seven keys. Linear probing walks the whole cluster, while double hashing jumps by $h_2 (22) = 3$],
) <hash-double-vs-linear>

To use double hashing, the probing code only needs a different `probe` function in place of the linear one

```cpp
// ProbingTable.cpp

/** Returns the slot to check on the ith probe for a key (double hashing)
 * Runtime: O(1)
 */
size_t ProbingTable::probe(int key, size_t i) const {
    // h2(k) = 5 - (k mod 5) is always between 1 and 5, so it's never 0
    size_t step = 5 - key % 5;
    // start at h1(k) = k mod m and jump by the step on every probe
    return (key % table_.size() + i * step) % table_.size();
}
```

=== Step Sizes Must Be Relatively Prime to $m$

Double hashing introduces a new problem. What if our table had 8 slots instead of 7, using $h_1 (k) = k mod 8$ and the same $h_2$? Say slots 1, 3, 5, and 7 are full, and we insert 23. $h_1 (23) = 7$, which is full, and $h_2 (23) = 5 - 3 = 2$, so we probe 7, 1, 3, 5, 7, 1, ... forever, like in @hash-double-even. Half the table is empty, but a step of 2 from an odd slot only ever visits odd slots

#figure(
  array-cells(none, 1, none, 3, none, 5, none, 7, marks: ("h1(23) = 7": 7), highlight: (1, 3, 5, 7)),
  caption: [Example: double hashing into a table of size 8. With a step size of $h_2 (23) = 2$, the probes cycle through 7, 1, 3, 5 and never reach the empty even slots],
) <hash-double-even>

So $h_2 (k)$ must be *relatively prime* to $m$: the two can share no common divisor besides 1. They don't have to be prime themselves, they just act like primes with respect to each other. Then the probe sequence visits every slot before repeating, so if there's an empty slot, we'll find it

The easiest way to guarantee that is to make the table size *prime*, since every number from 1 to $m - 1$ is relatively prime to a prime $m$. That's why our table has 7 slots, and since $h_2$ is always between 1 and 5, every step size works. Finding big primes is inconvenient, though, so in practice implementations keep a list of primes that roughly double (up to around 100,000), and past that they double and subtract one, since odd numbers are relatively prime to more numbers than even ones. That isn't a guarantee, but once a table is that big, it's unlikely to matter

There are hundreds of other closed hashing schemes, almost all variations on this idea. One fun one is *cuckoo hashing*, where every key has two possible slots and a new key can kick an old one out to its other slot. Going further takes a lot more math than we have, but we'll stick with three strategies: separate chaining, linear probing, and double hashing

== Resizing and Rehashing

So far our tables have a fixed size, and that's a real problem for all three strategies. With closed hashing, once we've stored $m$ keys, the table is 100% full and we can't store anything else, whether we use linear probing or double hashing. Separate chaining never fills up, but it gets worse forever: even with a perfect hash function that spreads keys evenly, the chains have length $n / m$, and if $m$ never changes, that's just $O(n)$

To get the constant time we want, the table has to grow. We use the same strategy from very early in the course: when the table gets too full, allocate a new table about *double* the size (rounded up to a prime, if we're using double hashing) and move everything over

But we can't just copy the old array into the front of the new one. Suppose our full linear probing table from @hash-linear-inserts doubles to 14 slots, and we copy every slot straight over. Now the hash function is $k mod 14$, so `find(8)` looks in slot $8 mod 14 = 8$, which is empty, and decides 8 isn't in the table! The index a key belongs at depends on $m$, so every key has to be inserted again with the new hash function. This is called *rehashing*. Going through the old table in order

- $22 mod 14 = 8$, so 22 goes in slot 8
- $8 mod 14 = 8$, which 22 just took, so linear probing puts 8 in slot 9
- $16 mod 14 = 2$, $29 mod 14 = 1$, and 4, 11, and 13 hash to themselves

@hash-rehash shows all three tables. Since we're using linear probing here, the new size doesn't need to be prime

#figure(
  grid(
    columns: 1,
    row-gutter: 1.5em,
    align: center,
    array-cells(22, 8, 16, 29, 4, 11, 13),
    array-cells(22, 8, 16, 29, 4, 11, 13, none, none, none, none, none, none, none, marks: ("find(8)": 8), highlight: (8,)),
    array-cells(none, 29, 16, none, 4, none, none, none, 22, 8, none, 11, none, 13),
  ),
  caption: [Example: growing the full linear probing table from @hash-linear-inserts (top) to 14 slots. Copying the slots straight over (middle) breaks `find(8)`, which now looks in slot $8 mod 14 = 8$. Rehashing every key with $k mod 14$ (bottom) puts each key where `find` will look],
) <hash-rehash>

The code is easy, since we already wrote `insert`: walk through the old table and insert every key into the new one. Tombstones don't get copied, so rehashing also cleans them out

```cpp
// ProbingTable.cpp

/** Doubles the table and rehashes every key into it
 * Runtime: O(n)
 */
void ProbingTable::resize() {
    // take the old slots out, leaving table_ free to be replaced
    std::vector<Slot> old = std::move(table_);
    table_ = std::vector<Slot>(2 * old.size());
    size_ = 0;
    for (const Slot& slot : old) {
        // rehash into the new size, dropping tombstones
        if (slot.state == State::Full) { insert(slot.key, slot.value); }
    }
}
```

Rehashing is $O(n)$, but it has exactly the same analysis as the array doubling in @amortized-doubling: as long as we (roughly) double, every insert pays a constant amount toward the next resize, so `insert` stays amortized $O(1)$. Doubling and then rounding up to a prime only changes things by a small factor, which doesn't matter

While we're rehashing everything anyway, there's one more thing we should do: *pick a whole new hash function*, not just a new compression. Remember the one big worry about hash tables: if someone knows our hash function, they can deliberately insert a bunch of keys that all collide, and nothing we do helps. Since the old hash function doesn't matter anymore after a rehash, choosing a fresh one forces an attacker to figure out our function all over again every time we resize

== The Simple Uniform Hashing Assumption

Here's where we are: we *want* to say that hash table operations are $O(1)$ expected (and `insert` is $O(1)$ amortized expected). But an expected runtime needs randomness from somewhere. In many real hash table implementations, the only randomness is *the data itself*, which gives us an average case, and if someone knows what our table is built on, they can hand it garbage. That really has been done in practice

So to analyze hash tables, we make an assumption, the *simple uniform hashing assumption* (*SUHA*). For a table of size $m$, a simple uniform hash $h$ satisfies

$ forall k_1 != k_2, quad P(h(k_1) = h(k_2)) = 1 / m $

In words: any two different keys collide with probability $1 / m$, as if each key's index were an independent roll of a fair $m$-sided die. That really assumes two things: that keys are *independent* of each other, and that every index is *equally likely*

Under SUHA, the expected length of a chain is easy. Take any key $k$ in a separate chaining table with $n$ keys. Each of the other $n - 1$ keys lands in $k$'s bucket with probability $1 / m$, so by linearity of expectation, the expected number of keys sharing its chain is $(n - 1) / m$. Similarly, any particular bucket expects $n / m$ keys. This ratio is called the *load factor*

$ alpha = n / m $

which is just how full the table is. The longest chain in the whole table is somewhat longer than $alpha$, but `find` only walks the chain its own key lands in

So far that only gets us $O(n)$, since $alpha$ grows with $n$ if $m$ is fixed. But now we combine it with resizing: we pick a fixed maximum load factor, and *whenever $n / m$ reaches it, we resize*. We still resize by doubling, and the amortization still works out (the math is a little more involved since we resize when the table is a fixed fraction full instead of completely full). Since $alpha$ never exceeds a constant,

$ E[text("find")] = O(1 + alpha) = O(1) $

That's it: under SUHA, with a bounded load factor, hash tables really do give expected $O(1)$ operations, and you can push this further to show they're fast with high probability

=== Why SUHA Is Suspicious

The whole weakness of hash tables is the hash function. No *fixed* function can satisfy SUHA for every input: if I know your function, I can always pick a set of keys that all hash to the same index. In fact, for any fixed function, at least $(|K|) / m$ keys share some index, and I can just keep choosing those

Here's a hint that something is off. If we really assume the keys are independent and uniform, then the identity function `k % m` is a *perfect* hash function, and we've already seen how badly simple functions like that do on real data. The assumption is pushing the randomness onto the data

The way to make this honest is to put the randomness in the *hash function* instead of the data: every time we build or resize the table, choose a hash function uniformly at random from a whole family of functions that spread keys out uniformly. If the keyspace is infinite, there are infinitely many functions to choose from, and a program can't really choose uniformly from all of them. In practice, though, our inputs are finite (strings of at most 10,000 characters, say), so we can choose from a finite family, which is doable, if tricky to get right

A few places really do this. The routers that handle internet backbone traffic have to look up addresses incredibly fast, so they use hash tables that

- keep their load factor bounded by simply refusing to store more than a certain number of entries (once full, they start throwing old data out, since they mostly care about recent traffic)
- generate a random number the size of an address (64 or 128 bits), and hash each address by XORing it with that random number and then taking `mod m`
- pick a fresh random number every time they rehash

That works because every address is exactly the same size, and the XOR is done in custom hardware. Strings are a lot harder, since they vary in length, and XORing a 1,000-character string with a 1,000-character random number takes real time

A couple of questions came up about this. Can we predict when a hash function will go bad? For a specific hash function, if you can efficiently predict its collisions, it's a degenerate, terrible hash function to begin with. If it really is uniform, you can't do better than chance, *unless you know the function itself*, at which point you can always defeat it. And if we do everything right, won't it never go bad? No: a fixed function can always be attacked by someone who knows it, which is exactly why we keep the specific function (like the router's random number) secret and change it on every rehash. There's also a huge amount of research on hash functions for different goals: cryptographic hashes, hashes for fast tables like ours, and even hashes for *similarity*, where we want similar keys to collide, which is the exact opposite of what we want here

In practice, even a hash table with a kind of garbage hash function is usually fast. But sometimes it isn't, and that's what's going on when a website that mostly works suddenly starts acting horribly for no particular reason: it's hit a hash function that conflicts with the data it's being given. A business can dump the table and restart. A military or medical system can't. This is also why theoreticians treat algorithms that need a hash table as much worse than ones that don't (in CS 374, you'll often be told you aren't allowed to use one)

=== Choosing a Load Factor

So how full should we let the table get? Analyzing linear probing and double hashing fully gives these expected numbers of probes per search under SUHA (you don't need to memorize them, but you should know what the curves look like)

#table(
  columns: 8,
  table.header([*Strategy*], [*Search*], [*Expected probes*], [*$alpha = 0.5$*], [*$0.7$*], [*$0.8$*], [*$0.9$*], [*$0.95$*]),
  table.cell(rowspan: 2)[Separate chaining], [Found], [$1 + alpha / 2$], [1.25], [1.35], [1.4], [1.45], [1.48],
  [Not found], [$1 + alpha$], [1.5], [1.7], [1.8], [1.9], [1.95],
  table.cell(rowspan: 2)[Linear probing], [Found], [$1 / 2 (1 + 1 / (1 - alpha))$], [1.5], [2.2], [3], [5.5], [10.5],
  [Not found], [$1 / 2 (1 + 1 / (1 - alpha)^2)$], [2.5], [6.1], [13], [50.5], [200.5],
  table.cell(rowspan: 2)[Double hashing], [Found], [$1 / alpha ln (1 / (1 - alpha))$], [1.39], [1.72], [2.01], [2.56], [3.15],
  [Not found], [$1 / (1 - alpha)$], [2], [3.3], [5], [10], [20],
)

Up to around 50% full, everything is really good. Double hashing stays good until roughly 80% and then gets worse fast, and linear probing gets worse sooner, since clusters give it more long runs early. An unsuccessful search at 95% is already dozens to hundreds of probes. The elbows on these curves are *sharp*, so as long as we keep the table reasonably empty, things are fine

Separate chaining never blows up, since chains can grow past $alpha = 1$: its cost just grows linearly with $alpha$, so we can trade space for speed at almost any point we want. By probe count it actually wins at every load factor, but each step along a chain is a pointer jump somewhere else in memory, while probing walks through neighboring array cells, which the cache loves. That's why closed hashing (especially double hashing) is often faster in practice at a sensible load factor. And chaining's space savings are mostly an illusion: it uses the full array just like closed hashing *and* allocates a new node for every key, so the more collisions, the more extra space

So in practice, people resize somewhere between 60% and 90% full, and around 70% to 80% is common. Think about why: doubling a table that's only 50% full barely helps, but doubling one that's 90% full takes it down to 45%, which is a huge difference. If memory is really cheap, a load factor of 10% makes collisions almost nonexistent, and an infinitely large table would never collide at all. But a table that's only as big as the number of things we're storing is just as bad a trade-off in the other direction

== Which Hash Table?

If the records are *very large* (say, each value is a 10,000 by 10,000 image), separate chaining is clearly better, since closed hashing stores whole records in the array, and every empty slot wastes a record's worth of memory. For reasonably sized records, closed hashing, at least double hashing, tends to be better, mostly for structural reasons like the cache, and its expected probe counts are a little better too

In C++, `std::unordered_map` and `std::unordered_set` are hash tables that use separate chaining. That lets them hash many more kinds of things, since closed hashing needs two extra values per slot (never used and deleted) that we can identify efficiently. You can see the chaining in its interface: its default `max_load_factor()` is 1.0, which only makes sense if chains can hold more than one key. (`std::map`, on the other hand, is a red-black tree: a balanced BST.)

== Hash Tables vs. BSTs

A hash table is yet another implementation of the dictionary ADT. So why did we spend so much time on BSTs?

First, the key type has to be *hashable*. If you try to put your own type in a `std::unordered_set`, it'll refuse to compile, because it has no idea how to hash it. C++ comes with hash functions for the built-in types, so we can build one for our type out of those, along with `==` for checking whether two keys match

```cpp
// Point.h

#pragma once

#include <cstddef>
#include <functional>

struct Point {
    int x;
    int y;

    // the table uses == to tell keys in the same bucket apart
    bool operator==(const Point& other) const {
        return x == other.x && y == other.y;
    }
};

namespace std {
template <>
struct hash<Point> {
    /** Hashes a point by combining the built-in hashes of its coordinates
     * Runtime: O(1)
     */
    size_t operator()(const Point& p) const {
        // multiplying by 31 makes (1, 2) and (2, 1) hash differently
        return hash<int>()(p.x) * 31 + hash<int>()(p.y);
    }
};
}
```

With that, a `std::unordered_set<Point>` works just like a `std::unordered_set<int>`

Second, a hash table's runtimes are *amortized* (sometimes we have to rehash) and *probabilistic* (we don't have a guarantee, only an expectation). A balanced BST always runs in $O(log n)$: that's the real worst case, with no amortization and no "sometimes it's bad". If we need a hard deadline, we want the BST

Third, a hash table can't do *range* or *nearest* searches. It can tell us whether a key is in the table, but it can't tell us the key that's one bigger, so the only way to find the nearest key is to search the whole table. A BST does a `find` and then walks to the neighbors, and in multiple dimensions a KD tree does the same thing

#table(
  columns: 4,
  table.header([*Operation*], [*Hash table*], [*AVL tree*], [*Unsorted linked list*]),
  [`find`], [$O(1)$ expected, worst $O(n)$], [$O(log n)$], [$O(n)$],
  [`insert`], [$O(1)$\* expected], [$O(log n)$], [$O(1)$],
  [`remove`], [$O(1)$ expected, worst $O(n)$], [$O(log n)$], [$O(n)$],
  [Storage], [$O(n)$], [$O(n)$], [$O(n)$],
  [Range find], [No], [Yes], [No],
)

The hash table numbers assume SUHA, a bounded load factor, and amortized resizing (the `*`). Its storage is still $O(n)$, since the load factor is a constant ratio. An unsorted linked list only makes sense as a dictionary if `insert` is most of what we do, since it's just an insert at the front. We can also add B-trees next to AVL trees: they have the same $O(log n)$ guarantees, but are shorter and do more work per level, which is perfect when the data doesn't fit in memory and every seek to disk (or another machine) is slow. Every one of these is the right dictionary in some situation, depending on which operations we do most and which guarantees we need

Honestly, hash tables are one of the most frustrating data structures, because there isn't a simple rule for when they'll work. Most of the time they're great, and they've made slow, cumbersome projects fast. But sometimes they bite, and they've taken entire server infrastructures down for weeks. So use them when you can't think of something better (which happens a lot), but know that a hash table can't give you a real worst-case guarantee. They're also an active research area right now: since SUHA is basically always a lie, people are designing hash tables that need weaker guarantees from their hash functions, and they're making progress, though the analysis is well beyond this course
