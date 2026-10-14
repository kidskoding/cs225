#import "../diagrams.typ": array-cells

= MinHash Sketch Strategy

Cardinality is a useful measure of a set, but it's a fairly limited one. A question we often want to ask instead is *how similar are two sets?* If I have a huge collection of images and you have one too, and we're deciding whether to merge them, we want to know how much they overlap. If they're very similar, we wouldn't gain much by joining them, but if they're very different, we would. Or if we're studying a disease and have sequenced its genome, we might want to know which diseases we already understand have a similar genome, so we can use what we know about them

So we want to measure the similarity between sets that are potentially very large, and often between *lots* of sets that are potentially very large

== Measuring Similarity

Which pair of sets is more similar? If both pairs have sets of the same size, that's easy: the pair that shares more is more similar. But in @minhash-pairs, both pairs share exactly the same items (2, 3, and 4), so how much they share can't be the whole story

#figure(
  grid(
    columns: 2,
    column-gutter: 1em,
    row-gutter: 1em,
    align: (right + horizon, left + horizon),
    [Pair 1: $A$], array-cells(0, 1, 2, 3, 4, none, none, highlight: (2, 3, 4)),
    [$B$], array-cells(none, none, 2, 3, 4, 5, 6, highlight: (2, 3, 4)),
    [Pair 2: $A$], array-cells(0, 1, 2, 3, 4, none, none, none, none, none, none, highlight: (2, 3, 4)),
    [$B$], array-cells(none, none, 2, 3, 4, 5, 6, 7, 8, 9, 10, highlight: (2, 3, 4)),
  ),
  caption: [Example: two pairs of sets, with each item drawn in its own column. Both pairs share the same three items (highlighted), but in pair 2, $B$ also has lots of items that $A$ doesn't],
) <minhash-pairs>

Pair 1 is clearly more similar: in pair 2, $B$ has a whole bunch of stuff that $A$ doesn't. So when we measure similarity, we care about what the sets share, but *also* about what they don't share. The standard measure is the *Jaccard similarity* (or *Jaccard coefficient*): the size of the intersection divided by the size of the union

$ J(A, B) = (abs(A inter B)) / abs(A union B) $

For pair 1, that's $3 / 7 approx 0.43$, and for pair 2, it's $3 / 11 approx 0.27$, which matches our intuition. If the sets share nothing, the intersection is empty and $J = 0$. If they share everything, the intersection *is* the union and $J = 1$. So the Jaccard similarity is always a number between 0 and 1, with no units

Now say I have 600 trillion cat pictures and you have 476 trillion, and we want to know if we'd get more cat pictures by putting them together, or if they're really all the same cat pictures. We can't go through every picture and compare them exactly. We couldn't even count the unique pictures in *one* collection exactly (that's why we needed cardinality estimates in the first place), so computing the intersection and union exactly is hopeless

== Estimating Similarity From Sketches

It turns out we can build on top of our cardinality estimate. At some point, I streamed through my whole collection once (probably as I gathered it from the internet), and to count the unique pictures, I kept the $k$ smallest hash values I saw, which is exactly the cardinality sketch from the previous chapter. Since it holds the $k$ minimum hashes, we'll call it a *k-min sketch* of the set. It's tiny, maybe 100 bytes for 600 trillion cat pictures, so storing it costs nothing. If you did the same thing for your collection, then we each have a sketch, and we want to estimate our similarity using *only* the two sketches

=== A First Example

To keep things readable, let's write every item as its hash value, out of a range of 100. @minhash-sets shows two full sets, sorted by hash value. They share 5 items, and their union has 12, so their real similarity is $J = 5 / 12 approx 0.42$

#figure(
  grid(
    columns: 2,
    column-gutter: 1em,
    row-gutter: 1em,
    align: (right + horizon, left + horizon),
    [$A$], array-cells(4, 9, 17, 22, 47, 53, 61, 75, 88, highlight: (1, 2, 4, 6, 8)),
    [$B$], array-cells(9, 17, 25, 38, 47, 61, 70, 88, highlight: (0, 1, 4, 5, 7)),
  ),
  caption: [Example: two sets, with every item written as its hash value and sorted from smallest to largest. The 5 shared items are highlighted, and the union has 12 items, so $J(A, B) = 5 / 12$],
) <minhash-sets>

But all we actually stored is the $k = 4$ smallest values of each set, shown in @minhash-sketches. If we combine the two sketches and take the 4 smallest values overall, we get 4, 9, 17, and 22, which are the 4 smallest hash values in all of $A union B$. Two of those four (9 and 17) are in both sketches, so we estimate that the sets are $2 / 4 = 1 / 2$ similar. The real answer was $5 / 12$, so we did okay

#figure(
  grid(
    columns: 2,
    column-gutter: 1em,
    row-gutter: 1em,
    align: (right + horizon, left + horizon),
    [Sketch of $A$], array-cells(4, 9, 17, 22, highlight: (1, 2)),
    [Sketch of $B$], array-cells(9, 17, 25, 38, highlight: (0, 1)),
    [Sketch of $A union B$], array-cells(4, 9, 17, 22, highlight: (1, 2)),
  ),
  caption: [Example: the $k = 4$ sketches of the sets from @minhash-sets. The 4 smallest values of the union include two shared values (highlighted), so we estimate $J approx 2 / 4$],
) <minhash-sketches>

Notice we never needed the full sets to tell whether 22 is in $B$. If a value is one of the $k$ smallest in $A union B$ and it belongs to $B$, then at most $k - 1$ values of $B$ can be smaller than it, so it has to be one of the $k$ smallest in $B$ too. Since 22 isn't in $B$'s sketch, it isn't in $B$ at all

=== Why This Works

Let's start with just the single smallest hash value in $A union B$. Since we assume SUHA, every item in $A union B$ is equally likely to be the one with the smallest hash. The smallest hash in $A$ equals the smallest hash in $B$ exactly when that item is in *both* sets, and since it's equally likely to be any item of the union, the chance it lands in the intersection is the fraction of the union that's shared

$ P(min h(A) = min h(B)) = (abs(A inter B)) / abs(A union B) = J(A, B) $

This is where the name *MinHash* comes from. But one sample is a coin flip: it always says either 0 or 1. In @minhash-sets, the smallest value in the union is 4, which is only in $A$, so with $k = 1$ we would have guessed that the sets share nothing. Keeping the $k$ smallest values of the union gives us $k$ samples instead of one, and the fraction of them that are shared is our estimate of $J$, just like keeping more values made our cardinality estimate better

== Building a k-Min Sketch

Let's slow down and work through this more carefully, starting with how we compute the sketch in the first place. As we stream through the data, we keep the smallest hash values we've seen so far in a sorted array of size $k$

+ Hash the next item
+ If its hash is already in the sketch, we've seen this item before, so skip it (we only care about *unique* items)
+ If the sketch has fewer than $k$ values, insert the hash in sorted order
+ Otherwise, if the hash is smaller than the largest value in the sketch, insert it in sorted order and drop the largest value
+ Otherwise, ignore it: it can't be one of the $k$ smallest

We store the hash values themselves, not the items, so the sketch is $k$ numbers no matter how big the set is. @minhash-build streams the data 16, 8, 18, 13, 15 into a $k = 3$ sketch, using the toy hash function $h(x) = x mod 7$

#figure(
  grid(
    columns: 2,
    column-gutter: 1em,
    row-gutter: 1em,
    align: (right + horizon, left + horizon),
    [Start], array-cells(none, none, none),
    [$h(16) = 2$], array-cells(2, none, none, highlight: (0,)),
    [$h(8) = 1$], array-cells(1, 2, none, highlight: (0, 1)),
    [$h(18) = 4$], array-cells(1, 2, 4, highlight: (2,)),
    [$h(13) = 6$: larger than 4, ignore], array-cells(1, 2, 4),
    [$h(15) = 1$: already stored, skip], array-cells(1, 2, 4),
  ),
  caption: [Example: building a $k = 3$ sketch of 16, 8, 18, 13, 15 with $h(x) = x mod 7$. The highlighted cells are the ones that changed],
) <minhash-build>

When 1 arrives, it's the new smallest value, so it goes at index 0 and 2 shifts over. In the worst case, a new value goes at the front and we shift all $k$ values, so each item takes $O(k)$ time, which is a constant if $k$ is fixed

Our toy hash function is terrible on purpose: 8 and 15 are different items with the same hash, so 15 gets skipped even though it's new. With a real hash function (say, 64 bits) that we treat as SUHA, a repeated hash value really does mean a repeated item, and skipping it is exactly how we ignore duplicates

== The Union Sketch

We run that process over both of our huge data sets and end up with one sketch each. @minhash-merge shows $k = 8$ sketches for two sets $A$ and $B$, with hash values out of a range of 100. These sixteen numbers are all we have left of our cat picture collections

We could build the sketch of $A union B$ by feeding $A$'s values and then $B$'s values through the same process, but that does a lot of shifting (all of $B$'s small values have to squeeze in front of $A$'s). Since both sketches are already sorted, it's easier to *merge* them, just like the merge step of merge sort

+ Look at the front of each sketch and take the smaller value
+ If both fronts are equal, it's the same item in both sets, so write it down once and move past it in both sketches
+ Stop once we've written $k$ values

#figure(
  grid(
    columns: 2,
    column-gutter: 1em,
    row-gutter: 1em,
    align: (right + horizon, left + horizon),
    [Sketch of $A$], array-cells(3, 7, 8, 11, 15, 17, 22, 23),
    [Sketch of $B$], array-cells(2, 3, 6, 7, 9, 11, 17, 23),
    [Sketch of $A union B$], array-cells(2, 3, 6, 7, 8, 9, 11, 15),
  ),
  caption: [Example: merging two $k = 8$ sketches. Taking the smallest remaining front value each time gives 2, 3, 6, 7, 8, 9, 11, 15, the 8 smallest hash values in $A union B$],
) <minhash-merge>

If we kept merging past $k$, we'd get 17, 22, and 23 too, but we only need 8. The result is *exactly* the sketch we would have gotten by streaming through all of $A union B$: each of the $k$ smallest values of the union is in $A$ or in $B$, so by the same argument as before, it's among the $k$ smallest of whichever set it came from. So from just the two sketches, we get a full-accuracy sketch of the union

Now we can estimate the size of the union exactly like we did for any other set. Recall from the previous chapter that the $k$-th smallest hash value $M_k$ (as a fraction of the hash range) has expected value $k / (n + 1)$. The 8th smallest value is 15 out of 100, so

$ 15 / 100 = 8 / (n + 1) quad => quad n = 800 / 15 - 1 approx 52.3 $

So our estimate is that there are about 52.3 unique items in $A union B$

== The Intersection

We'd like to do the same thing for the intersection, so let's walk through both sketches and only write down the values that appear in both. 2 is in $B$ but not $A$, 3 is in both, 6 is only in one, 7 is in both, and so on, which leaves the five values in @minhash-intersect

#figure(
  grid(
    columns: 2,
    column-gutter: 1em,
    row-gutter: 1em,
    align: (right + horizon, left + horizon),
    [Sketch of $A$], array-cells(3, 7, 8, 11, 15, 17, 22, 23, highlight: (0, 1, 3, 5, 7)),
    [Sketch of $B$], array-cells(2, 3, 6, 7, 9, 11, 17, 23, highlight: (1, 3, 5, 7)),
    [Sketch of $A inter B$], array-cells(3, 7, 11, 17, 23),
  ),
  caption: [Example: the values in both sketches (highlighted) from @minhash-merge. Only 5 of them survive, so the intersection gets a smaller $k = 5$ sketch],
) <minhash-intersect>

And that's all we can compute. Those five values really are the five smallest hashes in $A inter B$ (any shared item with a hash of 23 or less is in both sketches), but there's no sixth: a shared item with a bigger hash never made it into either sketch, and we have no more data. To get an equally accurate sketch of the intersection, we'd need bigger sketches. The only way the intersection keeps all $k$ values is if the two sketches are identical. So we have a couple of options

=== Option 1: Use the Smaller Sketch

We could just say, this is all we've got, and treat the intersection as a $k = 5$ sketch. Its 5th smallest value is 23, so

$ 23 / 100 = 5 / (n + 1) quad => quad n = 500 / 23 - 1 approx 20.7 $

which gives $J approx 20.7 / 52.3 approx 0.40$. That works, but the intersection estimate is less accurate than the union estimate, since it's built from fewer values

=== Option 2: Go Through the Union

If we know the size of $A$, the size of $B$, and the size of $A union B$, we can compute the size of the intersection directly. Adding $abs(A)$ and $abs(B)$ counts every shared item twice, and counts everything else once, so

$ abs(A inter B) = abs(A) + abs(B) - abs(A union B) $

In pair 1 of @minhash-pairs, that's $5 + 5 - 7 = 3$. The nice thing is that all three sizes on the right come from full $k = 8$ sketches. Both $A$'s and $B$'s 8th smallest values are 23, so

$ abs(A) approx abs(B) approx 800 / 23 - 1 approx 33.8 $
$ abs(A inter B) approx 33.8 + 33.8 - 52.3 = 15.2 $
$ J(A, B) approx 15.2 / 52.3 approx 0.29 $

So from a k-min sketch of each set, we can compute two potentially valuable things: the *cardinality* of each set, and the *Jaccard similarity* between any two of them. And if $k$ is around 100, working with just $k$ values per set takes almost no time compared to comparing the full sets

Notice the three estimates we've seen for this example (0.40, 0.29, and the $3 / 8 = 0.375$ we'd get from the shared fraction of the union's sketch, as in @minhash-sketches) don't agree. That's not a mistake: $k = 8$ is a tiny sketch, and every one of these is only an estimate

== How Accurate Is It?

Just like with cardinality, the answer depends on $k$. The statistical analysis is well outside this course, so let's run an experiment instead. Take two sets of 1000 items that share 500, so $J = 500 / 1500 = 1 / 3$, and estimate $J$ from their sketches 500 times, with a different hash function each time

#table(
  columns: 3,
  table.header([*$k$*], [*Average error: shared fraction*], [*Average error: through the union*]),
  [10], [0.12], [0.20],
  [50], [0.05], [0.10],
  [100], [0.035], [0.066],
  [500], [0.013], [0.029],
)

Both estimates get better as $k$ grows, and just like with cardinality, the improvement slows down: going from 10 to 100 helps a lot more than going from 100 to 500. Going through the union has a weakness worth knowing about: it *subtracts* estimates, and subtracting doesn't cancel their errors, it adds them. With $k = 10$, it estimated a *negative* intersection in 35 of the 500 trials

== MinHash in Practice

Here's a real use of this. Researchers estimated the size and similarity of all the reference microbial genomes, where each genome is treated as the set of its *k-mers* (short, fixed-length pieces of its DNA sequence). There are tens of thousands of genomes, and comparing every pair of them directly would be an enormous amount of work. But once someone generated the sketches, estimating the similarity of every pair, which is really the valuable part (which organisms are related to which), could be done on a desktop

Storing a small sketch for each of tens of thousands of genomes is easy, while working with hundreds of thousands of k-mers for each of them starts to get really hard. Even as computers keep getting faster, this kind of estimation is an important tool for doing real science

== Sets of Very Different Sizes

Can we always use this technique? Let's look at a case where it doesn't go very well: one set is very small, and the other is very large. In @minhash-skew, the small set $S$ and the large set $L$ actually share 59, 82, and 101 (hash values out of 1000 now), three of $S$'s four smallest values

#figure(
  grid(
    columns: 2,
    column-gutter: 1em,
    row-gutter: 1em,
    align: (right + horizon, left + horizon),
    [Sketch of $S$], array-cells(31, 59, 82, 101, highlight: (1, 2, 3)),
    [8 smallest of $L$], array-cells(5, 12, 20, 27, 44, 59, 82, 101, highlight: (5, 6, 7), marks: ("k = 4 sketch ends": 3)),
    [Sketch of $S union L$], array-cells(5, 12, 20, 27),
  ),
  caption: [Example: a small set $S$ and a large set $L$ with $k = 4$. The shared values (highlighted) are only the 6th through 8th smallest in $L$, so $L$'s sketch never sees them, and the union's sketch is entirely $L$'s values],
) <minhash-skew>

With $k = 4$, $L$'s sketch stops at 27, so we never see that the sets share anything. The union's sketch is made entirely of $L$'s values, and neither estimate notices the overlap. For $S$'s first four values to be recognized, we'd have needed $L$'s first *eight*. When the sets are similar in size, the data we lose past the end of the sketch is fairly small, but when one set is much bigger, the lost data becomes significant

Our estimates assume we see everything that overlaps, but here we don't, so the union looks different than it really is: it looks like less is shared. So even though $S$ shares almost everything with $L$ (while $L$ has lots of other items), our estimate of how much they share is going to be off. To see how bad this gets, take $abs(S) = 100$ and $abs(L) = 10000$, with 90 of $S$'s items inside $L$, so $J approx 0.009$. With $k = 100$, the shared-fraction estimate came out as exactly 0 in 118 of 300 trials, and was off by 87% of the true value on average

So this technique doesn't work well when the sizes of the two sets are very far apart. The error isn't bounded by some nice statistical guarantee: as the cardinalities of the two sets drift farther apart, the error in the similarity gets larger. For some problems, that's fine. Whole families of genomes are known to be about the same size, and the genome comparisons from the previous section actually group genomes by size and relation for exactly this reason

== k-Partitions

We won't completely defeat this problem, but we can do something easy to help. Instead of keeping the $k$ smallest values of the whole hash range, we *partition* the range into chunks and keep the smallest values in *each* chunk. With hash values between 0 and 1, three partitions would be $[0, 0.3)$, $[0.3, 0.6)$, and $[0.6, 1]$ (non-overlapping, so nothing gets counted twice). Now our samples are spread evenly across the whole hash range, instead of all coming from the very bottom of it

In practice, a hash value is just an integer stored in binary. We've been treating it as a number between 0 and 1, but that's only for the analysis, and working with integers is faster. So we pick partitions using the *most significant bits*: with two bits, the partitions are the values starting with `00`, `01`, `10`, and `11`. @minhash-partitions keeps the $k = 2$ smallest values in each partition of a set of 6-bit hash values

#figure(
  grid(
    columns: 3,
    column-gutter: 1.5em,
    row-gutter: 1em,
    align: (center + horizon, left + horizon, left + horizon),
    [*Top bits*], [*Hash values in binary*], [*Partition*],
    [00], [000101, 001001, 001110], array-cells(5, 9, 14, highlight: (0, 1)),
    [01], [011000], array-cells(24, highlight: (0,)),
    [10], [100011, 101010, 101101], array-cells(35, 42, 45, highlight: (0, 1)),
    [11], [111001], array-cells(57, highlight: (0,)),
  ),
  caption: [Example: partitioning 6-bit hash values by their two most significant bits and keeping the $k = 2$ smallest in each partition (highlighted). Partitions `01` and `11` only have one value, so they keep just that one],
) <minhash-partitions>

We keep two values in partition `00`, one in `01`, two in `10`, and one in `11`, so the sketch is an even subsample of the whole set. To compare two sets, we compare their sketches one partition at a time, exactly like before, and then combine the results

What if a partition is empty for one of the sets? That's okay: it just says the set has nothing in that range. An empty set is a perfectly valid set, so that partition has zero similarity, and it counts for $1 / 4$ (or $1 / 8$, $1 / 16$, and so on, depending on how many partitions we use) of the whole comparison. Since we assume SUHA, this shouldn't happen unless the partitions are very small compared to the number of items in the set

Partitioning softens the size problem, but it doesn't remove it. In the experiment from the previous section, 50 partitions of 2 values each did only a little better than a single $k = 100$ sketch (off by 78% on average instead of 87%), so the safest approach is still to compare sets of similar sizes

And all of this depends on having magic SUHA hash functions. That's the biggest fundamental flaw in this whole family of techniques: every estimate in this chapter is only as good as our hash function
