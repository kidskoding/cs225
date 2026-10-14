// ProbingTable.cpp

#include "ProbingTable.h"

/** Returns a pointer to the key's value, or nullptr if it's missing
 * Runtime: O(1) expected (under SUHA), O(n) worst case
 */
std::string* ProbingTable::find(int key) {
    // stop after m probes, so a full table can't loop forever
    for(size_t i = 0; i < table_.size(); i++) {
        Slot& slot = table_[probe(key, i)];
        // a never-used slot ends the run, so the key isn't in the table
        if(slot.state == State::Empty) { return nullptr; }
        // a tombstone or another key: ours could be further down
        if(slot.state == State::Full && slot.key == key) { return &slot.value; }
    }
    return nullptr;
}

/** Removes the key from the table by leaving a tombstone in its slot
 * Runtime: O(1) expected (under SUHA), O(n) worst case
 */
void ProbingTable::remove(int key) {
    for(size_t i = 0; i < table_.size(); i++) {
        Slot& slot = table_[probe(key, i)];
        if(slot.state == State::Empty) { return; }
        if(slot.state == State::Full && slot.key == key) {
            // not Empty, so later finds keep probing past it
            slot.state = State::Tombstone;
            size_--;
            return;
        }
    }
}

/** Inserts a key-value pair into the first open slot it probes (assumes the key isn't already there)
 * Runtime: O(1) amortized expected (under SUHA), O(n) worst case
 */
void ProbingTable::insert(int key, const std::string& value) {
    // resize first, so there's always an open slot to land in
    if(size_ + 1 > maxLoad_ * table_.size()) { resize(); }

    for(size_t i = 0; i < table_.size(); i++) {
        Slot& slot = table_[probe(key, i)];
        // both Empty slots and tombstones can be reused
        if(slot.state != State::Full) {
            slot = {State::Full, key, value};
            size_++;
            return;
        }
    }
}

/** Doubles the table and rehashes every key into it
 * Runtime: O(n)
 */
void ProbingTable::resize() {
    // take the old slots out, leaving table_ free to be replaced
    std::vector<Slot> old = std::move(table_);
    table_ = std::vector<Slot>(grownSize(old.size()));
    size_ = 0;
    for(const Slot& slot : old) {
        // rehash into the new size, dropping tombstones
        if(slot.state == State::Full) { insert(slot.key, slot.value); }
    }
}

/** Returns the slot to check on the ith probe for a key (double hashing)
 * Runtime: O(1)
 */
size_t DoubleHashTable::probe(int key, size_t i) const {
    // h2(k) = 5 - (k mod 5) is always between 1 and 5, so it's never 0
    size_t step = 5 - key % 5;
    // start at h1(k) = k mod m and jump by the step on every probe
    return (key % table_.size() + i * step) % table_.size();
}

/** Returns the smallest prime that is at least double `m`
 * Runtime: O(m)
 */
size_t DoubleHashTable::grownSize(size_t m) const {
    // a prime size makes every step size from 1 to 5 relatively prime to it
    for(size_t candidate = 2 * m;; candidate++) {
        bool prime = candidate > 1;
        for(size_t f = 2; f * f <= candidate && prime; f++) {
            if(candidate % f == 0) { prime = false; }
        }
        if(prime) { return candidate; }
    }
}
