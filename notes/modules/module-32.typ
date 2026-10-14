#import "../diagrams.typ": array-cells

= Cardinality

Bloom filters let us store a set in far less space than anything else we've seen, at the cost of the occasional false positive. But there's a catch we ran into when we optimized one: to pick the filter size $m$ and the number of hash functions $k$, we need to know $n$, the number of *unique* items going in, before we ever start. A bloom filter can't grow, so if we guess too small it fills up with ones and tells us nothing, and if we guess too big we waste the space we were trying to save. So how do we figure out how many unique things are in a data set that's too big to store?

== Counting Unique Items

Let's start by asking what a bloom filter, exactly as we've studied it, can and can't do

#table(
  columns: 2,
  table.header([*Can a bloom filter...*], [*Answer*]),
  [Find the closest matching item to a query?], [No],
  [Check if a query exists in a data set?], [Yes],
  [Compare the similarity between two data sets?], [Kind of],
  [Count the number of unique items in a data set?], [Kind of],
)

- *Closest match: no.* A bloom filter never finds anything. It only says "probably here" or "definitely not here". Worse, a good hash function sends two very similar keys to completely unrelated places (we've been using `mod` because it's easy to compute by hand, but a real hash function scrambles its keys), so similar hashes tell us nothing about similar keys
- *Membership: yes.* That's exactly what it's built for: either the item is definitely not in the set, or it probably is
- *Similarity: kind of.* If two filters use the same $m$ and the same hash functions and have exactly the same bits set, they were very likely built from the same data, since every query would give the same answer. But that's not really a measure of *how* similar two sets are
- *Unique items: kind of.* With $k = 1$, counting the ones in the filter is close to the number of unique items, but every collision makes two items look like one, so the count comes up short

The last two aren't what a bloom filter does, but the same probabilistic idea (hash everything, then reason about where the hashes land) leads to data structures that do solve them efficiently. This chapter is about the last one, which is exactly what we needed to size our bloom filter

The size of a set is called its *cardinality*, and the key word is *unique*. If we stream every picture we can find on the internet, we don't want to know how many pictures went by (a single counter would do that); we want to know how many *different* cat photos there are, no matter how many times each one shows up. To count that exactly, we'd have to store every unique photo we've seen so far and check each new one against all of them. With something like 130 billion photos, we can't store them all, so we'll settle for a *cardinality estimate*: a good guess at the number of unique items, made in one pass over the data while storing almost nothing

== The Hat Problem

Before we bring hashing in, let's play a game with a hat. Take a deck of cards numbered 0 to 999. I put some of them in a hat, and you want to know how many. I let you pull out one card at random, and it's 95. That tells you almost nothing: there's at least one card in the hat, and one of them is 95

Now suppose I tell you something different: the card I handed you is the *minimum* card in the hat. That tells you a lot more. Cards 0 through 94 definitely aren't in the hat, and every other card is above 95. But if I chose which cards went in, I could have put in exactly 95 through 999, so the minimum alone still can't tell you how many there are

So let's make one more change: the cards in the hat are chosen *uniformly at random*. Now a minimum of 95 really means something. If the hat had 900 cards, every single one would have to avoid 0 through 94, and the chance of that is about $10^(-127)$, so it basically never happens. With 9 cards, the chance is about 41%. A big minimum means there aren't many cards in the hat, and a small minimum means there are a lot

How do we turn that into a number? If we scatter $n$ cards uniformly at random across the range 0 to 999, they cut it into $n + 1$ gaps (one before the first card, one between each pair, and one after the last). No gap is special, so on average each one is about $1000 / (n + 1)$ long, and that includes the very first gap, from 0 up to the minimum. @card-hat-gaps shows a hat with 9 cards: the gaps aren't all exactly 100, but they're all close, and the first one is 95

#figure(
  array-cells(0, 95, 212, 304, 377, 498, 611, 700, 815, 906, marks: (min: 1)),
  caption: [Example: 9 cards drawn at random from 0 to 999, in sorted order, after a 0 marking the start of the range. The 10 gaps (95, 117, 92, 73, 121, 113, 89, 115, 91, and 94 from 906 up to 1000) average out to $1000 / 10 = 100$],
) <card-hat-gaps>

So if the minimum is 95, our best guess is that the first gap is average, and we solve for $n$

$ 95 approx (1000) / (n + 1) quad => quad n + 1 approx (1000) / 95 approx 10.5 quad => quad n approx 9.5 $

Our estimate is 9.5 unique cards. It's not an integer, but it's an estimate, not a count. The same reasoning ranks any number of hats by their minimums: the smaller the minimum, the more cards we expect

#table(
  columns: 2,
  table.header([*Minimum card*], [*Estimate $1000 / "min" - 1$*]),
  [10], [99],
  [95], [9.5],
  [200], [4],
  [500], [1],
)

== From Cards to Hashes

Real data isn't a hat of uniformly random numbers. Photos, genomes, and URLs are anything but uniform, and if we just looked at the smallest photo, we'd learn nothing. This is where hashing comes in. Under *SUHA*, a hash function sends every key to a uniformly random value in its range, independently of every other key. So hashing an item is the same as putting a card with a random number into the hat, and the minimum hash value we've seen plays the role of the minimum card

Hashing also handles the "unique" part for free. If the same item shows up twice, it hashes to the same value twice, which can't change the minimum. So the minimum hash depends only on the *set* of unique items, no matter how many duplicates are mixed in

To make the math clean, we turn every hash into a number between 0 and 1 by dividing it by the size of the hash range. A hash function produces an integer in some fixed range (a 64-bit hash, for example, is always below $2^64$), so we divide by the size of that range and get a real number in $[0, 1)$, where 0 means the smallest possible hash and values close to 1 mean the largest. That should start to look a lot like a probability

=== The Expected Minimum

Let $X_1, X_2, ..., X_n$ be the hashes of $n$ unique items, each uniform in $[0, 1)$, and let $M$ be their minimum. We claim

$ E[M] = 1 / (n + 1) $

To see why, imagine hashing one more unique item, $X_(n + 1)$, and ask: what's the chance it lands below $M$, becoming the new minimum? We can answer that two ways

+ If the minimum is some value $m$, then $X_(n + 1)$ is uniform, so it lands below $m$ with probability exactly $m$ and above with probability $1 - m$. Averaging over every possible minimum, the chance is $E[M]$
+ Landing below $M$ means $X_(n + 1)$ is the smallest of all $n + 1$ values. All $n + 1$ are uniform and independent, so each one is equally likely to be the smallest, and the chance is $1 / (n + 1)$

Both answers describe the same event, so $E[M] = 1 / (n + 1)$. This is the hat problem again, just with the range scaled down from 1000 to 1: $n$ values cut $[0, 1)$ into $n + 1$ gaps that average $1 / (n + 1)$ each

=== The Estimator

Flipping that around gives us our estimate. If $M approx 1 / (n + 1)$, then

$ n approx 1 / M - 1 $

So to estimate the number of unique items in a stream

+ Start with the minimum at 1, the top of the range
+ For every item in the stream, hash it, divide by the size of the hash range, and keep the result if it's smaller than the current minimum
+ At the end, estimate $1 / M - 1$ unique items

```cpp
// MinSketch.h

class MinSketch {
  public:
    /** Hashes `item` into [0, 1] and keeps it if it is the new minimum
     * Runtime: O(1)
     */
    void insert(const std::string & item) {
        // divide by the size of the hash range to land in [0, 1]
        double h = hash_(item) / maxHash_;
        min_ = std::min(min_, h);
    }

    /** Estimates the number of unique items as 1 / min - 1
     * Runtime: O(1)
     */
    double estimate() const {
        return 1 / min_ - 1;
    }

  private:
    double min_ = 1;
    std::hash<std::string> hash_;
    static constexpr double maxHash_ = std::numeric_limits<size_t>::max();
};
```

Notice that we still look at every single item, so this is still a full pass over the data. The win is *space*: instead of storing every unique item to compare against, we store one `double`. Each `insert` is $O(1)$, and the whole sketch is $O(1)$ space no matter how big the stream is. An empty stream even gives a sensible answer, since $1 / 1 - 1 = 0$

Let's try it. To keep the numbers small, say our hash function produces values 0 to 999, so we divide by 1000. @card-attempts shows three different streams. In the first one, the same item appears twice (both hash to 920), so the stream has 4 unique items, while the other two have 5

#figure(
  grid(
    columns: 2,
    column-gutter: 1em,
    row-gutter: 1em,
    align: (right + horizon, left + horizon),
    [Stream 1], array-cells(920, 328, 700, 920, 930, marks: (min: 1)),
    [Stream 2], array-cells(492, 253, 810, 327, 660, marks: (min: 1)),
    [Stream 3], array-cells(580, 134, 450, 970, 290, marks: (min: 1)),
  ),
  caption: [Example: the hashes (out of 1000) of three streams. Stream 1 has a repeated item (920 at indices 0 and 3) and 4 unique items, while streams 2 and 3 have 5 unique items each],
) <card-attempts>

#table(
  columns: 4,
  table.header([*Stream*], [*Minimum $M$*], [*Estimate $1 / M - 1$*], [*Actual unique items*]),
  [1], [0.328], [2.05], [4],
  [2], [0.253], [2.95], [5],
  [3], [0.134], [6.46], [5],
)

The repeated 920 in stream 1 didn't matter at all, which is exactly what we want. But honestly, these guesses aren't great: 2.05 for 4 items, 2.95 for 5, then 6.46 for 5. A single minimum is a single sample, and one lucky (or unlucky) hash throws the whole estimate off. A small minimum suggests lots of items and a big minimum suggests few, but one number is a pretty noisy way to tell those apart

== Keeping the $k$ Smallest

How do we do better? We want more samples. Right now the whole sketch is one number, and we can afford a lot more than that. So instead of keeping only the smallest hash, we keep the *$k$ smallest* hashes: the smallest, the second smallest, and so on up to the $k$-th smallest, which we call $M_k$

The same reasoning about gaps still works. The $n$ hashes cut $[0, 1)$ into $n + 1$ gaps of about $1 / (n + 1)$ each, and the $k$-th smallest hash sits at the end of the first $k$ gaps, so

$ E[M_k] = k / (n + 1) quad => quad n approx k / M_k - 1 $

With $k = 1$, this is exactly the estimator from before. The difference is that $M_k$ depends on $k$ gaps instead of just one, so a single unusually short or long gap gets averaged out with the others. @card-kmv-sorted shows stream 2 from @card-attempts in sorted order. With 5 items, the ideal spacing would be $1000 / 6 approx 167$, and the first gap alone (253) is a lot further off from that than the first three together (492, versus an ideal $3 times 167 = 500$)

#figure(
  array-cells(0, 253, 327, 492, 660, 810, marks: ("k = 1": 1, "k = 2": 2, "k = 3": 3)),
  caption: [Stream 2 from @card-attempts, sorted, after a 0 marking the start of the range. The $k$-th smallest hash sits at index $k$],
) <card-kmv-sorted>

#table(
  columns: 3,
  table.header([*$k$*], [*$M_k$*], [*Estimate $k / M_k - 1$*]),
  [1], [0.253], [$1 / 0.253 - 1 approx 2.95$],
  [2], [0.327], [$2 / 0.327 - 1 approx 5.12$],
  [3], [0.492], [$3 / 0.492 - 1 approx 5.10$],
)

Just going from $k = 1$ to $k = 2$ took us from 2.95 to 5.1, almost exactly the right answer, and $k = 3$ stays at 5.1. Using all of the values doesn't magically make the estimate perfect: $k$ is about getting enough samples, not about looking at everything

=== Building the Sketch

We maintain the $k$ smallest hashes as the stream goes by

+ Hash the item and divide by the size of the hash range
+ If that value is already in the sketch, it's a repeated item, so do nothing
+ Otherwise, add it. If the sketch now has $k + 1$ values, throw away the largest one
+ At the end, if the sketch has fewer than $k$ values, the stream had fewer than $k$ unique items and we know the count exactly. Otherwise, estimate $k / M_k - 1$, where $M_k$ is the largest value left in the sketch

@card-kmv-build builds the $k = 3$ sketch for stream 2. The first three hashes all fit, then 327 pushes out 810, and 660 is bigger than everything we're keeping, so it changes nothing

#figure(
  grid(
    columns: 2,
    column-gutter: 1em,
    row-gutter: 1em,
    align: (right + horizon, left + horizon),
    [Insert 492], array-cells(492, none, none, highlight: (0,)),
    [Insert 253], array-cells(253, 492, none, highlight: (0, 1)),
    [Insert 810], array-cells(253, 492, 810, highlight: (2,)),
    [Insert 327: 810 is dropped], array-cells(253, 327, 492, highlight: (1, 2)),
    [Insert 660: too big], array-cells(253, 327, 492),
  ),
  caption: [Building the $k = 3$ sketch for stream 2 from @card-attempts, keeping the 3 smallest hashes in sorted order. The highlighted cells are the ones that changed. At the end, $M_3 = 0.492$],
) <card-kmv-build>

In C++, a `std::set` does almost all of the work for us: it keeps the values sorted, so the largest is at the end, and it ignores a value it already has, which takes care of repeated items

```cpp
// CardinalitySketch.h

class CardinalitySketch {
  public:
    CardinalitySketch(size_t k) : k_(k) { }

    /** Hashes `item` into [0, 1] and keeps it if it is among the k smallest
     * Runtime: O(log k)
     */
    void insert(const std::string & item) {
        // divide by the size of the hash range to land in [0, 1]
        double h = hash_(item) / maxHash_;
        smallest_.insert(h);

        // keep only the k smallest hashes by dropping the largest one
        if(smallest_.size() > k_) {
            smallest_.erase(std::prev(smallest_.end()));
        }
    }

    /** Estimates the number of unique items as k / (kth smallest hash) - 1
     * Runtime: O(1)
     */
    double estimate() const {
        // fewer than k unique items so far, so we know the exact count
        if(smallest_.size() < k_) {
            return smallest_.size();
        }
        double kthSmallest = *smallest_.rbegin();
        return k_ / kthSmallest - 1;
    }

  private:
    size_t k_;
    std::set<double> smallest_;
    std::hash<std::string> hash_;
    static constexpr double maxHash_ = std::numeric_limits<size_t>::max();
};
```

The set never holds more than $k + 1$ values, so each `insert` is $O(log k)$ and the sketch takes $O(k)$ space. This is our *cardinality sketch*. Even with $k = 100$, that's 100 `double`s, or 800 bytes, to estimate the number of unique items in a stream of billions

== Accuracy

How much does a bigger $k$ actually help? The full statistical analysis is well outside this course (even with magic SUHA hash functions it gets messy fast), but we can just try it. The table shows `CardinalitySketch` run over thousands of random streams, each with every item repeated twice, for two different numbers of unique items $n$. The typical error is the median of $abs("estimate" - n) \/ n$, and the last two columns give the error that 90% of the trials stayed under

#table(
  columns: 5,
  table.header([*$k$*], [*Typical error, \ $n = 1000$*], [*Typical error, \ $n = "100,000"$*], [*90% within, \ $n = 1000$*], [*90% within, \ $n = "100,000"$*]),
  [1], [67%], [65%], [830%], [670%],
  [10], [21%], [21%], [58%], [58%],
  [100], [6%], [7%], [16%], [17%],
)

A few things stand out

- *With $k = 1$, the estimate is close to useless.* Typically it's off by two thirds, and in one trial out of ten it's off by a factor of 7 or more. Most of those huge errors are overestimates: one hash that happens to land very close to 0 makes $1 / M$ enormous. If the hash range is small, like 10,000 values, a single unlucky stream can be estimated at nearly 10,000 items, as many as the hash range can even tell apart
- *$k = 10$ is already a lot better*, and *$k = 100$ is good*: typically within about 6%, and 9 times out of 10 within about 17%. In our streams of 1000 items, $k = 100$ is a tenth of the set, but in the streams of 100,000 items it's a thousandth, and it does just as well. We don't need $k$ to be any particular fraction of $n$
- *The returns diminish.* Making $k$ 10 times bigger made the typical error only about 3 times smaller (roughly $sqrt(10)$), so the jump from $k = 1$ to $k = 10$ is much bigger than the jump from $k = 10$ to $k = 100$
- *It's $k$ that matters, not $n$.* It's tempting to think a bigger stream would make the estimate better on its own, but with $k$ fixed, $n = "100,000"$ is no more accurate than $n = 1000$. Since $n$ is so much bigger than $k$, the error depends on how many gaps we average, which is $k$. To get a better estimate, we keep more hashes

So we choose $k$ for the accuracy we want, the same way we chose $m$ and the number of hash functions for a bloom filter. Every estimate here depends on the hash function behaving like SUHA, though: if real hashes aren't close to uniform, none of these numbers hold
