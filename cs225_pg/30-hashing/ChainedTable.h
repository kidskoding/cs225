// ChainedTable.h

#pragma once
#include <cstddef>
#include <list>
#include <string>
#include <utility>
#include <vector>

/** A hash table with separate chaining: every bucket is a linked list of key-value pairs.
 * Keys are non-negative integers hashed with `key % m`, and this version never resizes
 */
class ChainedTable {
public:
    /** Creates a table with `m` empty buckets
     * Runtime: O(m)
     */
    ChainedTable(size_t m = 7) : table_(m) { }

    /** Inserts a key-value pair at the front of the key's chain (assumes the key isn't already there)
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

    /** Returns every bucket, each one a chain of key-value pairs
     * Runtime: O(1)
     */
    const std::vector<std::list<std::pair<int, std::string>>>& buckets() const { return table_; }

private:
    /** Compresses a key into a bucket index
     * Runtime: O(1)
     */
    size_t hash(int key) const { return key % table_.size(); }

    /** every bucket starts as an empty list (a nullptr head) */
    std::vector<std::list<std::pair<int, std::string>>> table_;
};
