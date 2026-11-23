= Probability in Computer Science

Every runtime so far has been a *worst case*, or an amortized worst case. That's a strong promise: no matter what the user does, the operation is at most that slow. The next few data structures (hash tables, Bloom filters, and sketches) give up that promise. Instead of "every operation is fast", they promise "operations are fast *in expectation*", or "the answer is *probably* right". To talk about that, we need a little probability

== Where the Randomness Comes From

A probabilistic bound needs randomness from somewhere, and there are two places it can come from

- *Average case*: the randomness is in the *data*. We assume the inputs are random and average over them. The catch is that users don't hand us random data, and anyone who knows how our structure works can pick the worst inputs on purpose
- *Expected case*: the randomness is in the *algorithm*. The algorithm makes its own random choices (like picking a random hash function when it builds a table), so the bound holds for *every* input, since the user can't control the coin flips

These sound alike, but an average-case bound can be beaten by a bad input, and an expected-case bound can't

== The Tools

Rolling a fair $m$-sided die is the model to keep in mind. Every face comes up with probability $1 / m$, and two separate rolls don't affect each other

- *Independent events multiply*: if two events are independent, the chance of both is the product of their chances. So if each of $k$ independent trials goes wrong with probability $p$, all $k$ go wrong with probability $p^k$
- *The complement*: an event either happens or it doesn't, so $P(A) = 1 - P("not" A)$. When the chance of something happening is hard to compute directly, the chance of it *not* happening is often much easier
- *Expected value*: the average outcome we'd see if we repeated the random experiment many times
- *Linearity of expectation*: the expected value of a sum is the sum of the expected values. To find the expected size of a count, add up the probability of each thing being counted. For example, if I roll 100 six-sided dice, each one lands on a 4 with probability $1 / 6$, so I expect $100 / 6 approx 16.7$ fours

== Many Operations: The Law of Large Numbers

One operation with a constant *expected* runtime could still be slow. But if we do a huge number of them, the *law of large numbers* makes it very likely that the total is close to (expected runtime) $times$ (number of operations). This is the same move as amortization: there, one expensive resize was paid for by many cheap inserts, and here, a few unlucky slow operations are paid for by many fast ones

== Randomized Tests and One-Sided Error

Probability also lets us trade *correctness* for speed. The example from lecture is a *primality test*: pick a random value, run a quick check with it, and answer "prime" or "not prime"

- If the check says *not prime*, that answer is always right
- If the check says *prime*, a single random trial might be wrong

Any yes-or-no test has four possible outcomes

#table(
  columns: 3,
  table.header([], [*Actually yes*], [*Actually no*]),
  [*Test says yes*], [True positive], [False positive],
  [*Test says no*], [False negative], [True negative],
)

A test that can only be wrong in *one* direction has *one-sided error*. That's what makes it fixable: we run *more* independent random trials. A wrong "prime" has to fool every single trial, and one trial catching it is enough. If each trial is fooled with probability $p$, all $k$ are fooled with probability $p^k$, which gets tiny fast

Running the *same* trial again doesn't help, since it gives the same answer every time. The trials have to be *different* random choices

== Where This Shows Up

- *Hash tables*: the Simple Uniform Hashing Assumption treats every key's index like an independent roll of an $m$-sided die, and linearity of expectation gives the expected chain length
- *Bloom filters*: a Bloom filter has one-sided error (false positives, never false negatives), and it uses $k$ different hash functions as its repeated trials. Its false positive rate comes from the complement trick
- *Cardinality and MinHash sketches*: they estimate counts from the expected value of the smallest hash
