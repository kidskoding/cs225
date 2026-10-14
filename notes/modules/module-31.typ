#import "../diagrams.typ": array-cells, linked-list

= Bloom Filters

Hash tables were all about *speed*: we wanted `find` and `insert` in expected $O(1)$ time, and we were happy to spend $O(n)$ space to get it. But what if the problem isn't time? What if we just don't have enough *space*?

Some data sets are so big that even an index of them doesn't fit anywhere. Back in 2013, Google estimated its index at about 60 billion web pages, and the whole web at about 130 trillion pages. The Sequence Read Archive, which holds the genetic sequences people have collected, is around 60 petabytes ($10^15$ bytes). Sky surveys have grown from a few terabytes to hundreds of petabytes, and the Square Kilometre Array is expected to produce about 4.6 exabytes. We're not even asking where to store the data itself. We just want an index that can answer "is this thing in there?"

Space is also speed. Reading all of the cache takes less than a second, reading all of RAM takes hours to days, reading all of the disks takes months, and reading the whole network takes years. So the less space our index takes, the closer to the CPU it can live

Our first instinct might be compression, like the Huffman encoding we saw earlier. But compression only buys a *constant factor*: 10 times smaller turns 4.6 exabytes into 0.46 exabytes, which still takes years to read. And it can't do much better than that, because if we want to tell $n$ different things apart *exactly*, we need $n$ different representations, so storing them exactly always takes at least $n$ space

So we're going to give up on exact answers. That's the same move we made with probability: we accept a small chance of being wrong in exchange for something much better

== From a Hash Table to a Bit Vector

Recall separate chaining from the previous chapter: an array of pointers, where each pointer leads to a linked list of everything that hashed to that index. With the hash function $h(x) = x mod 7$, inserting 16, 8, 4, 13, 29, 11, and 22 gives the hash table on the left of @bloom-from-table

Now let's throw almost all of it away. We don't keep the keys, and we don't keep the lists. We only keep *whether anything ever hashed to each index*. That's a yes or no question, so instead of an 8-byte pointer, each index only needs a *single bit*: 1 if something hashed there, 0 if nothing did. That's the bit vector on the right of @bloom-from-table

#figure(
  grid(
    columns: 3,
    column-gutter: 2em,
    align: horizon,
    grid(
      columns: 2,
      column-gutter: 0.8em,
      row-gutter: 0.6em,
      align: (right + horizon, left + horizon),
      raw("0"), raw("nullptr"),
      raw("1"), linked-list(22, 29, 8, head: ""),
      raw("2"), linked-list(16, head: ""),
      raw("3"), raw("nullptr"),
      raw("4"), linked-list(11, 4, head: ""),
      raw("5"), raw("nullptr"),
      raw("6"), linked-list(13, head: ""),
    ),
    $->$,
    array-cells(0, 1, 1, 0, 1, 0, 1),
  ),
  caption: [Example: a separate chaining hash table with $h(x) = x mod 7$ after inserting 16, 8, 4, 13, 29, 11, and 22, and the bit vector we get by keeping only whether each index is used],
) <bloom-from-table>

This is the most primitive version of a *Bloom filter*. It's a bit vector, initialized to all 0s, and a hash function

- To insert a key, hash it and set that bit to 1
- To find a key, hash it and look at that bit

We have to do a little bit of fancy arithmetic to get at a single bit inside a chunk of memory, but we'll see how to do that later in this chapter

=== Insert

@bloom-insert inserts the same seven keys into a 7-bit filter with $h(x) = x mod 7$. Notice that most of the inserts don't change anything: 29 and 22 both hash to 1, which 8 already set, and 11 hashes to 4, which 4 already set. Setting a bit that's already 1 just leaves it 1

#figure(
  grid(
    columns: 2,
    column-gutter: 1em,
    row-gutter: 1em,
    align: (right + horizon, left + horizon),
    [Start], array-cells(0, 0, 0, 0, 0, 0, 0),
    [Insert 16: $16 mod 7 = 2$], array-cells(0, 0, 1, 0, 0, 0, 0, highlight: (2,)),
    [Insert 8: $8 mod 7 = 1$], array-cells(0, 1, 1, 0, 0, 0, 0, highlight: (1,)),
    [Insert 4: $4 mod 7 = 4$], array-cells(0, 1, 1, 0, 1, 0, 0, highlight: (4,)),
    [Insert 13: $13 mod 7 = 6$], array-cells(0, 1, 1, 0, 1, 0, 1, highlight: (6,)),
    [Insert 29: $29 mod 7 = 1$, already 1], array-cells(0, 1, 1, 0, 1, 0, 1),
    [Insert 11: $11 mod 7 = 4$, already 1], array-cells(0, 1, 1, 0, 1, 0, 1),
    [Insert 22: $22 mod 7 = 1$, already 1], array-cells(0, 1, 1, 0, 1, 0, 1),
  ),
  caption: [Example: inserting 16, 8, 4, 13, 29, 11, and 22 into a 7-bit Bloom filter with $h(x) = x mod 7$. The highlighted cells are the bits that changed],
) <bloom-insert>

Seven `int`s take $7 dot 4 = 28$ bytes, and our filter takes 7 *bits*, less than a single byte. Who cares about 28 bytes, but the same idea lets a filter of a few megabytes stand in for an index of exabytes

=== Find

Finding is where things get interesting. In @bloom-find, we query three keys on the finished filter from @bloom-insert

- `find(16)`: $16 mod 7 = 2$, and bit 2 is 1, so we say *yes*. 16 really is in the set, so this is a *true positive*
- `find(20)`: $20 mod 7 = 6$, and bit 6 is 1, so we say *yes*. But 20 was never inserted! Bit 6 is 1 because of 13. This is a *false positive*
- `find(3)`: $3 mod 7 = 3$, and bit 3 is 0, so we say *no*. 3 is not in the set, and we're definitely right

#figure(
  array-cells(0, 1, 1, 0, 1, 0, 1, marks: ("h(16)": 2, "h(3)": 3, "h(20)": 6), highlight: (2, 3, 6)),
  caption: [Example: `find(16)` (a true positive), `find(20)` (a false positive), and `find(3)` (a true negative) on the filter from @bloom-insert],
) <bloom-find>

A 0 means *nothing* in the whole set ever hashed there, so a "no" is always correct. A 1 only means *something* hashed there, and we have no idea what. In @bloom-find, `find(2)` would also say yes, for the same reason as 20

That's the key thing to understand about `find` on a Bloom filter: a "yes" really means "*maybe*". From the point of view of someone using the filter, a true positive and a false positive look *identical*. Both are just a 1, and the filter has literally no data to tell them apart, since we threw out the keys. So the filter is 100% right when it says no, and right with some probability when it says yes

- If the bit is 0, the key is *definitely not* in the set
- If the bit is 1, the key *might* be in the set

Even a filter that says "maybe" to half of the keys that aren't in the set is useful. Every "no" is a search through exabytes that we never have to do, so we've cut the number of expensive searches in half, using a filter small enough to keep in memory all the time. The more bits we give the filter, the fewer collisions it has, and the less often it says maybe when the answer is no

== One-Sided Error

Any yes-or-no test, like a disease test, has four possible outcomes, depending on what it says and what's actually true

#table(
  columns: 3,
  table.header([], [*Actually in the set*], [*Actually not in the set*]),
  [*Filter says yes*], [True positive], [False positive],
  [*Filter says no*], [False negative (impossible)], [True negative],
)

Most real tests can get any of the four. A Bloom filter can *never* give a false negative: if a key was inserted, its bit was set to 1, and bits never go back to 0. This is *one-sided error*, just like the primality test we saw when we talked about probability

Here's a concrete use: a *malicious website detector* in a browser. Checking every URL with an authoritative server would double the network traffic. Instead, the browser occasionally downloads a small Bloom filter with every known malicious site inserted into it, and checks each URL against the filter first

- If the filter says *safe* (no), the site is definitely not on the list, and we never had to ask anyone
- If the filter says *malicious* (maybe), we ask the real service whether the site is actually malicious

The one outcome we can't afford is calling a malicious site safe, and that's exactly the outcome a Bloom filter can never give. Calling a safe site malicious only costs us one extra request

Another way to see it: a Bloom filter is a filter in the literal sense. If we pass all our data through it, *everything* in the set makes it through, along with a few things that aren't. The filter never loses anything we're looking for, it just doesn't remove everything we aren't. And because it never loses anything, we can pass what's left through a *second*, different filter to remove even more of the wrong things

== Repeated Trials

How do we make the filter more accurate? One idea is to store a *count* at each index instead of a single bit. That gives us a hint, but it uses more space and gets complicated, so let's put it aside

Instead, recall the primality test: one random trial could wrongly say "prime", but we could make a mistake extremely unlikely by running *more* random trials, since we only have to be wrong once to catch it. A hash function is also fundamentally a random selection (that's the whole point of SUHA), so we can do the same thing here. Note that hashing the same key with the same function again isn't a new trial: it gives the same answer every time. We need *different* hash functions

=== $k$ Separate Filters

The most straightforward way is to build $k$ completely separate Bloom filters, each with its own hash function $h_1, ..., h_k$. To insert a key, we insert it into every filter. To find a key, we check every filter, and say yes only if *all* of them say yes. If any of them says no, the key is definitely not in the set

For a false positive, *every* filter has to be wrong. If the filters are independent and each one is wrong half the time, then

- one filter gives a false positive rate of $1/2$
- two filters give $1/2 dot 1/2 = 1/4$
- three filters give $1/8$

and in general, if one filter has false positive rate $p$, then $k$ filters have a false positive rate of $p^k$

For an example, we'll switch to 10-bit filters and three hash functions

$ h_1(x) = x mod 10 #h(2em) h_2(x) = 2x mod 10 #h(2em) h_3(x) = (3x + 5) mod 10 $

@bloom-k-tables inserts 6, 8, and 4 into three separate filters. For instance, 6 sets bit $h_1(6) = 6$ in the first filter, bit $h_2(6) = 12 mod 10 = 2$ in the second, and bit $h_3(6) = 23 mod 10 = 3$ in the third. Querying 9 checks bit 9 of the first filter, which is 0, so we can say no right away

#figure(
  grid(
    columns: 2,
    column-gutter: 1em,
    row-gutter: 1em,
    align: (right + horizon, left + horizon),
    [$h_1$ filter], array-cells(0, 0, 0, 0, 1, 0, 1, 0, 1, 0, marks: ("h1(9)": 9), highlight: (9,)),
    [$h_2$ filter], array-cells(0, 0, 1, 0, 0, 0, 1, 0, 1, 0, marks: ("h2(9)": 8), highlight: (8,)),
    [$h_3$ filter], array-cells(0, 0, 0, 1, 0, 0, 0, 1, 0, 1, marks: ("h3(9)": 2), highlight: (2,)),
  ),
  caption: [Example: 6, 8, and 4 inserted into three separate 10-bit filters. `find(9)` checks one bit in each filter, and the 0 in the $h_1$ filter means 9 is not in the set],
) <bloom-k-tables>

Notice that we can stop as soon as we see a 0: once one filter says no, the rest can't change the answer. That's a nice optimization for time, but it doesn't help with space, and space is the problem. We started with a hash table and threw out everything except one bit per index, and now we're storing *$k$ bits* per index. If $k$ gets anywhere close to the size of a key, we've built something almost as big as the data we were trying to avoid storing

=== One Shared Bit Vector

So let's throw something out again. Instead of $k$ filters, we keep *one* bit vector of $m$ bits, and all $k$ hash functions set and check bits in that same vector. This is what people actually mean by a *Bloom filter*

To insert a key $x$

+ Compute $h_1(x), h_2(x), ..., h_k (x)$
+ Set every one of those bits to 1 (if a bit is already 1, it stays 1)

To find a key $x$

+ Compute $h_1(x), h_2(x), ..., h_k (x)$
+ If *any* of those bits is 0, the key is definitely not in the set, so return false (we can stop at the first 0)
+ If *all* of them are 1, the key might be in the set, so return true

@bloom-shared-insert inserts 6, 8, and 4 into one 10-bit vector using the same three hash functions. Each insert sets up to three bits, and 8 only sets two new ones, since $h_2(8) = 6$ was already set by $h_1(6)$

#figure(
  grid(
    columns: 2,
    column-gutter: 1em,
    row-gutter: 1.5em,
    align: (right + horizon, left + horizon),
    [Start], array-cells(0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    [Insert 6], array-cells(0, 0, 1, 1, 0, 0, 1, 0, 0, 0, marks: ("h1(6)": 6, "h2(6)": 2, "h3(6)": 3), highlight: (2, 3, 6)),
    [Insert 8], array-cells(0, 0, 1, 1, 0, 0, 1, 0, 1, 1, marks: ("h1(8)": 8, "h2(8)": 6, "h3(8)": 9), highlight: (8, 9)),
    [Insert 4], array-cells(0, 0, 1, 1, 1, 0, 1, 1, 1, 1, marks: ("h1(4)": 4, "h2(4)": 8, "h3(4)": 7), highlight: (4, 7)),
  ),
  caption: [Example: inserting 6, 8, and 4 into one 10-bit Bloom filter with $k = 3$ hash functions. The highlighted cells are the bits that changed],
) <bloom-shared-insert>

This still never gives a false negative: if a key was inserted, *all* of its bits were set to 1, so all of them will still be 1 when we look it up. @bloom-shared-find runs four queries on the finished filter, where only bits 0, 1, and 5 are still 0

- `find(6)`: bits 6, 2, and 3 are all 1, so *yes*, a true positive
- `find(1)`: $h_1(1) = 1$, and bit 1 is 0, so *no* right away
- `find(16)`: bits 6, 2, and 3 are all 1, so *yes*, but 16 was never inserted, so this is a false positive
- `find(9)`: bits 9, 8, and 2 are all 1, so *yes*, another false positive

#figure(
  grid(
    columns: 2,
    column-gutter: 1em,
    row-gutter: 1.5em,
    align: (right + horizon, left + horizon),
    [`find(6)`: yes], array-cells(0, 0, 1, 1, 1, 0, 1, 1, 1, 1, marks: ("h1(6)": 6, "h2(6)": 2, "h3(6)": 3), highlight: (2, 3, 6)),
    [`find(1)`: no], array-cells(0, 0, 1, 1, 1, 0, 1, 1, 1, 1, marks: ("h1(1)": 1), highlight: (1,)),
    [`find(16)`: yes (false positive)], array-cells(0, 0, 1, 1, 1, 0, 1, 1, 1, 1, marks: ("h1(16)": 6, "h2(16)": 2, "h3(16)": 3), highlight: (2, 3, 6)),
    [`find(9)`: yes (false positive)], array-cells(0, 0, 1, 1, 1, 0, 1, 1, 1, 1, marks: ("h1(9)": 9, "h2(9)": 8, "h3(9)": 2), highlight: (2, 8, 9)),
  ),
  caption: [Example: four queries on the filter from @bloom-shared-insert. 6 is a true positive, 1 is a true negative, and 16 and 9 are false positives],
) <bloom-shared-find>

Two things are worth noticing here. First, 16 checks *exactly* the same bits as 6. That's because all three of our toy hash functions only depend on the last digit of the key, so they aren't independent at all, and no number of them could ever tell 6 and 16 apart. Real hash functions need to be independent for repeated trials to help

Second, look at 9. In @bloom-k-tables, the separate filters said no to 9, because bit 9 of the $h_1$ filter was 0. In the shared vector, bit 9 is 1, but it was set by $h_3(8)$, not by any $h_1$. That's the price of sharing: when $h_2$ looks at a bit, it might see a 1 that was put there by $h_1$ of a *different* key. So the number of 1s in the filter isn't just the number of keys we inserted, and a shared filter fills up faster than $k$ separate ones. Our simple $p^k$ analysis doesn't work anymore

We can also take this to the extreme. A "Bloom filter" whose only hash function sends every key to bit 0 is technically correct: it never gives a false negative. But as soon as anything is inserted, it says yes to everything, which is a 100% false positive rate. Being correct is easy; what we care about is *how often* we're wrong

== Analysis

=== Running Time and Space

Both `insert` and `find` compute $k$ hash functions and touch $k$ bits, so they're $O(k)$. But $k$ is fixed when we create the filter and never changes for that filter, so it's also fair to call them $O(1)$, the same way $O(100000)$ is still $O(1)$. $O(k)$ is just the more precise answer

The filter stores a bit vector of $m$ bits and the $k$ hash functions, so its space is $O(m)$, or $O(m + k)$ if we count the functions as data too, since we need to know them to use the filter. Interestingly, that doesn't depend on $n$ at all: no matter how much we insert, the filter never gets bigger. But that's a little bit of a lie, since a filter that's too small for its $n$ fills up with 1s and becomes useless. To pick $m$, we need to know how often we're wrong

The size has to be fixed at creation for another reason too. A hash table can resize by rehashing, because it still has all of its keys. A Bloom filter threw its keys away, so there's nothing to rehash: to make it bigger, or to change $k$, we'd have to rebuild it from the original data

For the same reason, a Bloom filter has *no remove*. To remove a key, we'd want to set its bits back to 0, but every one of those bits might also belong to other keys. In @bloom-shared-insert, removing 8 by clearing bits 8, 6, and 9 would also clear bit 6 for 6 and bit 8 for 4, and suddenly `find(6)` says no: a false negative, which is the one thing a Bloom filter promises never to do. (Storing a count instead of a bit, the idea we put aside earlier, is how variations of the Bloom filter support removing)

=== False Positive Rate

Let's work out the probability of a false positive for a filter of $m$ bits, with $k$ SUHA hash functions, after inserting $n$ keys. With $k$ separate filters, the answer was just $p^k$. With one shared vector, it's tempting to guess that one key sets $k / m$ of the bits, but that's wrong, since some of the $k$ hash functions might hit the same bit

Computing the probability that a bit is 1 is hard. But a bit is either 0 or 1, so $P("bit is 1") = 1 - P("bit is 0")$, and the probability that a bit is *0* is much easier. (This is the same trick as with AVL trees, where we couldn't compute the height directly, but we could bound it by counting nodes)

+ By SUHA, one hash function hits a specific bit with probability $1/m$, so it *misses* that bit with probability $1 - 1/m$
+ Inserting one key uses $k$ independent hash functions, which is just like inserting $k$ keys with one function, so the bit is still 0 with probability $(1 - 1/m)^k$
+ Inserting $n$ keys uses $n k$ hash functions in total, so after all of them, the bit is still 0 with probability $(1 - 1/m)^(n k)$
+ So a bit is 1 with probability $1 - (1 - 1/m)^(n k)$

That's the chance that *one* check of a key that isn't in the set lands on a 1 when it should have found a 0. For `find` to give a false positive, *all $k$* of its checks have to land on 1s, so

$ P("false positive") = (1 - (1 - 1/m)^(n k))^k $

Let's see how each variable affects this

- A bigger $m$ makes $(1 - 1/m)^(n k)$ closer to 1, so fewer bits are 1, which is *better*: a bigger filter makes fewer mistakes
- A bigger $n$ puts more 1s in the filter, which is *worse*
- A bigger $k$ does both. The $k$ in the exponent inside means every key sets more bits, so the filter fills up faster, which is worse. The $k$ outside means we need *more* 1s to be wrong, which is better

=== The Optimal Number of Hash Functions

So for a given $m$ and $n$, what's the best $k$? It turns out to be

$ k^* = (m / n) ln 2 approx 0.7 dot m / n $

Getting there takes a bit of calculus, which you won't be asked to do, but here's the sketch. First, we rewrite the inside using $x = e^(ln x)$ and $ln(x^y) = y ln x$

$ (1 - 1/m)^(n k) = e^(n k ln(1 - 1/m)) $

Next, recall the series $ln(1 + x) = x - x^2 / 2 + x^3 / 3 - x^4 / 4 + ...$, with $x = -1/m$. Since $m$ is a number of bits, it's big (at least a thousand or so), so $1/m$ is tiny, the squared and higher terms are tinier, and $ln(1 - 1/m) approx -1/m$. Plugging that back in

$ P("false positive") approx (1 - e^(-(n k) / m))^k $

To find the $k$ that minimizes this, we can minimize its natural log instead, since $ln$ is increasing and has its minimum at the same place. Taking the derivative of $k ln(1 - e^(-(n k) / m))$ with respect to $k$ and setting it to 0 gives $e^(-(n k) / m) = 1/2$, which is $k = (m / n) ln 2$. At that point, exactly half of the bits are 1, and the false positive rate is about $(1/2)^k$

The table shows the approximate false positive rate for a filter with 10 bits per key ($m / n = 10$). It drops quickly, bottoms out around $k = 7$ (since $k^* = 10 ln 2 approx 6.93$), and then climbs again as the filter gets too full. If we measure it with real data instead, the curve isn't perfectly smooth, since we can only ever have a whole number of hash functions, but it has the same shape

#table(
  columns: 2,
  table.header([*$k$*], [*False positive rate for $m / n = 10$*]),
  [1], [9.52%],
  [2], [3.29%],
  [3], [1.74%],
  [4], [1.18%],
  [5], [0.94%],
  [6], [0.84%],
  [*7*], [*0.82%*],
  [8], [0.85%],
  [9], [0.91%],
  [10], [1.02%],
)

Notice that $m / n$ is the *inverse* of the load factor from hash tables: it's bits per key, not keys per slot. And notice how small these numbers are. Our early examples assumed a filter that's wrong half the time, but with 10 bits per key and 7 hash functions, a Bloom filter is wrong less than 1% of the time. That's still an error, but it's a very small one

We can solve the same equation for whichever variable we don't know

- *100 keys and 3 hash functions*: $m = (k n) / (ln 2) = 300 / (ln 2) approx 433$ bits
- *100 bits and 20 keys*: $k = (ln 2) dot 100 / 20 approx 3.47$, so 3 or 4 hash functions. There's no such thing as 3.47 hash functions, so we'd plug both 3 and 4 into the formula and see which is better
- *100 bits and 2 hash functions*: $n = (ln 2) dot 100 / 2 approx 34.7$ keys

== Using Bloom Filters

Here's an important catch: for the optimal error rate, $m = (k n) / (ln 2)$, which is still *linear in $n$*. We get a big constant factor improvement (a few bits per key instead of the whole key), but it's still $O(n)$ space. There are two ways to think about that

- We can combine it with other tricks, like first reducing the data in other ways, so the Bloom filter is a constant factor improvement on top of another one
- We can just pick a budget. "You get one megabyte, how accurate can you be?" A 100,000-bit filter might have a fairly high error rate for our data, but still filter out most of what we don't need

Either way, there's a lot of engineering here without hard answers. What you need to remember is that when we create a Bloom filter, we fix

- the number of hash functions, $k$
- the size of the filter, $m$
- and ideally, an estimate of the number of keys, $n$

That last one is new. Every other data structure we've seen lets us keep inserting forever, but a Bloom filter can't grow. If we insert fewer keys than we planned for, we've wasted space, which defeats the point. If we insert too many, the filter fills with 1s and stops telling us anything

One place most current web browsers use a Bloom filter is their *cache*. Most resources a browser loads are only ever visited *once*, so caching all of them wastes disk activity on things we'll never look at again. Instead, the browser keeps a Bloom filter of resources it has seen

- When it loads a resource, it checks the filter. If the bits are 0, it has definitely never seen this resource, so it just inserts it into the filter and doesn't cache it
- If the bits are already 1, it has *probably* seen it before, so this is the second visit, and it caches it

A false positive just means we cache something we've only seen once, which is what the browser did for *everything* before the Bloom filter. When this was turned on, disk activity dropped a lot with no real impact on performance, which also tells us how many resources really are only visited once. The filter can stay small, too, since it only needs to hold what we've seen since the browser started, and when it gets too full, we can just throw it out and start a new empty one: anything we visit constantly is already in the cache

== Working With Bits

Throughout this chapter, we've been talking about bits, but C++ doesn't give us an obvious way to work with a single bit. What it does have are the *bitwise operators*, which treat a number as a sequence of bits and work on every bit at once. With A = `10110` and B = `01110`

#table(
  columns: 3,
  table.header([*Operator*], [*Meaning*], [*Example*]),
  [`~B`], [Not: flips every bit], [`10001`],
  [`A & B`], [And: 1 only where both are 1], [`00110`],
  [`A | B`], [Or: 1 where either is 1], [`11110`],
  [`A >> 2`], [Right shift: moves every bit 2 places right, dropping the bits that fall off and filling with 0s], [`00101`],
  [`B << 2`], [Left shift: moves every bit 2 places left, filling with 0s], [`11000`],
)

Shifts are only well-defined when the value is *unsigned*. In our computers, a negative number has a 1 in its most significant bit, and right shifting a signed value usually fills with 1s instead of 0s to keep it negative, but the C++ standard doesn't promise that, so different compilers and hardware can do different things. That's why we use types like `uint64_t`: an unsigned 64-bit integer, which is the size of a register on our computers. Each of these operators works on all 64 bits in a *single instruction*, so with a vector of `uint64_t`, we handle 64 bits at a time instead of one

To check a single bit, we build a *mask*: a number with only that bit set. If we want bit $b$ (counting from 0 on the right), the mask is `1 << b`. And-ing the mask with our bits zeroes out everything except bit $b$, so the result is nonzero exactly when bit $b$ is 1. For example, to check the third bit (index 2), the mask is `1 << 2 = 00100`. Or-ing with the mask sets the bit instead

```cpp
/** Returns whether bit `b` of `bits` is 1
 * Runtime: O(1)
 */
bool isSet(uint64_t bits, unsigned b) {
    uint64_t mask = uint64_t(1) << b;
    return (bits & mask) != 0;
}

/** Returns `bits` with bit `b` set to 1
 * Runtime: O(1)
 */
uint64_t setBit(uint64_t bits, unsigned b) {
    uint64_t mask = uint64_t(1) << b;
    return bits | mask;
}
```

Notice we shift `uint64_t(1)`, not just `1`. A plain `1` is an `int`, which is usually only 32 bits, so shifting it 40 places wouldn't work. Code like this used to be written everywhere for performance, because compilers weren't good enough to do it for us. Nowadays, compilers do a lot of this on their own, and your time is usually worth more than the computer's, but for a structure that's *all* bits, it's exactly what we need

=== Implementation

Putting it together, bit $i$ of the filter lives in word `i / 64` of the vector, at position `i % 64` within that word

```cpp
// BloomFilter.h

class BloomFilter {
  public:
    using HashFunction = std::function<size_t(int)>;

    BloomFilter(size_t m, std::vector<HashFunction> hashes)
        : m_(m), bits_((m + 63) / 64, 0), hashes_(hashes) { }

    /** Sets the bit each hash function picks for `key`
     * Runtime: O(k)
     */
    void insert(int key) {
        for(const HashFunction& h : hashes_) {
            size_t i = h(key) % m_;
            // bit `i` lives in word `i / 64`, at position `i % 64` within it
            bits_[i / 64] |= uint64_t(1) << (i % 64);
        }
    }

    /** Returns whether `key` might be in the filter (no false negatives)
     * Runtime: O(k)
     */
    bool contains(int key) const {
        for(const HashFunction& h : hashes_) {
            size_t i = h(key) % m_;
            // one 0 means the key was never inserted
            if((bits_[i / 64] & (uint64_t(1) << (i % 64))) == 0) {
                return false;
            }
        }
        return true;
    }

    /** Turns this filter into the union of itself and `other`
     * Runtime: O(m)
     */
    void unionWith(const BloomFilter& other);

  private:
    // the number of bits in the filter
    size_t m_;

    // the m bits, packed 64 to a word
    std::vector<uint64_t> bits_;

    // the k hash functions
    std::vector<HashFunction> hashes_;
};
```

== Union and Intersection

Here's where working with bits really pays off. Suppose we have two Bloom filters with the same size $m$ and the *same* hash functions (not just the same number of them, the exact same functions). One holds the set $S_1$ and the other holds $S_2$. What do we get if we bitwise or them?

A bit is 1 in the result exactly when some key from $S_1$ or $S_2$ set it, which is exactly the filter we'd get by inserting every key of $S_1 union S_2$. So *bitwise or is union*, and it's exact. In @bloom-set-ops, $S_1 = \{6, 4\}$ and $S_2 = \{8, 4\}$, and their or is the same filter we built for $\{6, 8, 4\}$ in @bloom-shared-insert

That's a big deal for huge data sets. Every computer holding part of the data can build a Bloom filter for its own part, and then we or them all together to get the filter for everything, which gives us massive parallelism

```cpp
// BloomFilter.cpp

/** Turns this filter into the union of itself and `other`
 * Runtime: O(m)
 */
void BloomFilter::unionWith(const BloomFilter& other) {
    // a bit is 1 in the union exactly when it is 1 in either filter
    for(size_t w = 0; w < bits_.size(); w++) {
        bits_[w] |= other.bits_[w];
    }
}
```

What about bitwise and? If a key is in both sets, all of its bits are 1 in both filters, so they're still 1 in the result, and `find` will say yes. So it still never gives a false negative for $S_1 inter S_2$. But it's *not* the same as the filter for $S_1 inter S_2$. In @bloom-set-ops, $S_1 inter S_2 = \{4\}$, whose filter only has bits 4, 7, and 8 set. The and also has bit 6 set, because 6 set it in $S_1$ and 8 happened to set it in $S_2$, even though neither 6 nor 8 is in the intersection. So and-ing gives us something that still works as a filter, but with extra 1s, and a different error rate that our analysis doesn't cover

#figure(
  grid(
    columns: 2,
    column-gutter: 1em,
    row-gutter: 1em,
    align: (right + horizon, left + horizon),
    [$S_1 = \{6, 4\}$], array-cells(0, 0, 1, 1, 1, 0, 1, 1, 1, 0),
    [$S_2 = \{8, 4\}$], array-cells(0, 0, 0, 0, 1, 0, 1, 1, 1, 1),
    [$S_1$ or $S_2$], array-cells(0, 0, 1, 1, 1, 0, 1, 1, 1, 1),
    [$S_1$ and $S_2$], array-cells(0, 0, 0, 0, 1, 0, 1, 1, 1, 0, highlight: (6,)),
    [Filter of $\{4\}$], array-cells(0, 0, 0, 0, 1, 0, 0, 1, 1, 0),
  ),
  caption: [Example: the bitwise or and the bitwise and of two Bloom filters with the hash functions from @bloom-shared-insert. The or is exactly the filter of $S_1 union S_2$, but the and has an extra 1 (highlighted) that the filter of $S_1 inter S_2 = \{4\}$ doesn't have],
) <bloom-set-ops>
