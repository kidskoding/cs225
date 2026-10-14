// Dictionary.hpp

#pragma once
#include "Dictionary.h"

/** Inserts a key-value pair into the dictionary
 * Runtime: expected O(1)
 */
template <class K, class V>
void Dictionary<K, V>::insert(const K key, const V value) {
    data[key] = value;
}

/** Removes the mapping for `key` and returns its value
 * (throws `std::out_of_range` if `key` is missing)
 * Runtime: expected O(1)
 */
template <class K, class V>
V Dictionary<K, V>::remove(const K& key) {
    // `at` throws if the key is missing, so there is always a value to return
    V value = data.at(key);
    data.erase(key);
    return value;
}

/** Returns an iterator to the pair with `key`, or `end()` if it is missing
 * Runtime: expected O(1)
 */
template <class K, class V>
typename Dictionary<K, V>::Iterator Dictionary<K, V>::find(const K& key) {
    return data.find(key);
}

/** Returns an iterator to the first key-value pair
 * Runtime: O(1)
 */
template <class K, class V>
typename Dictionary<K, V>::Iterator Dictionary<K, V>::begin() {
    return data.begin();
}

/** Returns an iterator one past the last key-value pair
 * Runtime: O(1)
 */
template <class K, class V>
typename Dictionary<K, V>::Iterator Dictionary<K, V>::end() {
    return data.end();
}
