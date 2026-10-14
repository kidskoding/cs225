// Dictionary.h

#pragma once
#include <unordered_map>

/** The dictionary ADT (key-value pairs), backed by `std::unordered_map` to borrow its iterator */
template <class K, class V>
class Dictionary {
public:
    using Iterator = typename std::unordered_map<K, V>::iterator;

    /** Inserts a key-value pair into the dictionary
     * Runtime: expected O(1)
     */
    void insert(const K key, const V value);

    /** Removes the mapping for `key` and returns its value
     * (throws `std::out_of_range` if `key` is missing)
     * Runtime: expected O(1)
     */
    V remove(const K& key);

    /** Returns an iterator to the pair with `key`, or `end()` if it is missing
     * Runtime: expected O(1)
     */
    Iterator find(const K& key);

    /** Returns an iterator to the first key-value pair
     * Runtime: O(1)
     */
    Iterator begin();

    /** Returns an iterator one past the last key-value pair
     * Runtime: O(1)
     */
    Iterator end();

private:
    /** the underlying map that stores every key-value pair */
    std::unordered_map<K, V> data;
};
