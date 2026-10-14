// ProbingTable.h

#pragma once
#include <cstddef>
#include <string>
#include <utility>
#include <vector>

/** never used, holding a pair, or holding a pair that was removed */
enum class State { Empty, Full, Tombstone };

/** One slot of a closed hashing table */
struct Slot {
    State state = State::Empty;
    int key = 0;
    std::string value;
};

/** A closed hashing (open addressing) table with linear probing and tombstones.
 * Keys are non-negative integers, and the table doubles and rehashes once it passes `maxLoad`
 */
class ProbingTable {
public:
    /** Creates a table with `m` empty slots that resizes once more than `maxLoad` of them are full
     * Runtime: O(m)
     */
    ProbingTable(size_t m = 7, double maxLoad = 0.7) : table_(m), maxLoad_(maxLoad) { }

    virtual ~ProbingTable() = default;

    /** Inserts a key-value pair into the first open slot it probes (assumes the key isn't already there)
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

    /** Doubles the table and rehashes every key into it
     * Runtime: O(n)
     */
    void resize();

    /** Returns every slot of the table
     * Runtime: O(1)
     */
    const std::vector<Slot>& slots() const { return table_; }

protected:
    /** Returns the slot to check on the ith probe for a key (linear probing)
     * Runtime: O(1)
     */
    virtual size_t probe(int key, size_t i) const { return (key + i) % table_.size(); }

    /** Returns the size to grow a table of `m` slots to
     * Runtime: O(1)
     */
    virtual size_t grownSize(size_t m) const { return 2 * m; }

    /** the slots of the table */
    std::vector<Slot> table_;

    /** the number of Full slots (tombstones don't count) */
    size_t size_ = 0;

    /** the load factor that triggers a resize */
    double maxLoad_;
};

/** A closed hashing table with double hashing: h(k, i) = (h1(k) + i * h2(k)) mod m,
 * where h1(k) = k mod m and h2(k) = 5 - (k mod 5). Its size grows to the next prime
 * at least double the old size, so every step size is relatively prime to it
 */
class DoubleHashTable : public ProbingTable {
public:
    /** Creates a table with `m` empty slots (`m` should be a prime bigger than 5)
     * that resizes once more than `maxLoad` of them are full
     * Runtime: O(m)
     */
    DoubleHashTable(size_t m = 7, double maxLoad = 0.7) : ProbingTable(m, maxLoad) { }

protected:
    /** Returns the slot to check on the ith probe for a key (double hashing)
     * Runtime: O(1)
     */
    size_t probe(int key, size_t i) const override;

    /** Returns the smallest prime that is at least double `m`
     * Runtime: O(m)
     */
    size_t grownSize(size_t m) const override;
};
