
# Module 10 - Tree Searching and Dictionaries

A **traversal** is an algorithm that goes through every single node in a tree and visits it ($O(n)$ time)

A **search** is an algorithm that finds a node in a tree of value $v$ if it exists (worst case is when $v \notin T$, where $T$ represents any tree; this involves running the full traversal, so it is in $O(n)$ time)

Previously, we discussed two types of search **Breath First** and **Depth First** (**BFS** and **DFS**)

**BFS** is the same as level order traversal, where its overhead (or space complexity) is the maximum number of nodes in a queue (can also be seen as the width of a tree)

**DFS** involves any of the three traversals that descend into the tree's children: pre order traversal, in order traversal, and post order traversal. Its overhead is the maximum depth in the tree (or simply height)

BFS is more **reliable** than DFS. This is because it will eventually find a solution to a valid search if one exists, even if the tree is infinite in depth. Since BFS explores nodes level by level, this guarantees that all nodes at depth $d$ are visited before any node at depth $d + 1$. So if the solution lies at a shallow depth, BFS will find it eventually. 

In contrast, DFS can get **"stuck"** going down an infinite branch of a tree, especially if the solution lies on a different, shallower path. Therefore, DFS might never return a proper solution, even if it does exist.

BFS will always find a solution if one exists, even in infinite-depth trees, but it may require an infinite amount of memory. This is because BFS stores all nodes at a given depth (one full level of the tree) in a queue before moving on to the next level. If the tree is very wide, this means the queue can grow extremely large, consuming a lot of memory. 

In contrast, DFS typically uses less memory, since it only needs to store the current path from the root to a leaf, which depends on the depth of the tree, not its width.

Therefore, in any practical application, memory is going to be the forefront problem. Since DFS uses less memory, that will often be the best approach. But, if there are infinite trees, DFS wouldn't work. There is a solution that solves this problem and it is known as **iterative deepening**

**Iterative Deepening** runs DFS with a **maximum depth limit** of $k$, meaning it will not explore any nodes beyond depth $k$ (starting at $k = 0$). When DFS reaches that depth, it stops descending and backtracks up the tree. This approach is useful because the maximum memory used when doing DFS is proportional to $k$ (simply the overhead cost - $O(k)$). If no solution is found at depth $k$, the algorithm restarts DFS with a new depth limit $k+1$, and this process repeats until a solution is found.

This effectively simulates BFS for DFS and will always find the solution because it explores each node at every level by using bounded memory (as deep as depth $k$ with overhead cost of $O(k)$). 

These are the two basic searching strategies, but they aren't that effective, since they can be slow in both time and memory. But what if there was a data structure that put searching at its forefront, which is essentially what a **map** or **dictionary** does

## Dictionaries

Dictionaries store **key-value** pairs, just like a regular dictionary, which stores words to definitions. If I had a word, I can use a dictionary to look up its definition! This could be done most optimally using binary search, where I start from the middle and then slowly go left or right based on whether the word I’m looking for comes before or after the middle word alphabetically.

This is just one example of a dictionary though, we can use it to look up students using their unique ID numbers (UIUC UIN) or by looking at a Flight number (**key**) for its departure time/arrival time (**value**).

In fact, an array really is just a dictionary, because we use an index (**key**) to lookup the value of an element that is present in the array (**value**)

### Dictionary Interface (ADT)

- `insert(key, value)` - insert a key and value into the dictionary
- `remove(key)` - remove a key value mapping from the dictionary via passing in the key
- `std::optional<value> find(key)` - return the value associated with the key (C++ has an `std::optional` type that you could use to return nothing if no value is found for the key!)

And then theres the obvious things like a constructor, destructor, and an iterator, but at the end of the day, this is what we want with a dictionary. 

And with this, we solve our problems with searching in Computer Science. A lot of other data structures, like Hash Tables and Tries, will rely on dictionaries to provide fast and efficient key-based access, which is essential for everything from caching to autocomplete and spell checking

The code below is a sample header file for our dictionary

```
// Dictionary.h

#include <unordered_map>

template <class K, class V>
class Dictionary {
public:
    using Iterator = typename std::unordered_map<K, V>::iterator;
    using ConstIterator = typename std::unordered_map<K, V>::const_iterator;

    void insert(const K key, const V value);
    V remove(const K& key);
    ConstIterator find(const K& key) const;
    Iterator begin();
    Iterator end();
    
private:

};
```

Our custom dictionary implements an iterator by leveraging C++’s standard library iterator from the underlying data structure of `std::unordered_map` . This allows us to avoid writing a custom iterator from scratch, while still providing full iterator functionality like `begin()`, `end()`, and `find()`.



<!--stackedit_data:
eyJoaXN0b3J5IjpbODQ5NDkxNDI0LC0xMjc5NjAyNzIwLC0xND
I2OTI4NDc2LC0xNTUxMzA2Mzk0LC05MTE2OTUxODgsLTE1MDkz
NTI2N119
-->