// ChainedTable.cpp

#include "ChainedTable.h"

/** Inserts a key-value pair at the front of the key's chain (assumes the key isn't already there)
 * Runtime: O(1)
 */
void ChainedTable::insert(int key, const std::string& value) {
    // colliding keys just share the list, so no probing is needed
    table_[hash(key)].push_front({key, value});
}

/** Returns a pointer to the key's value, or nullptr if it's missing
 * Runtime: O(1 + alpha) expected (under SUHA), O(n) worst case
 */
std::string* ChainedTable::find(int key) {
    // only this bucket can hold the key, so walk its chain comparing keys
    for(auto& entry : table_[hash(key)]) {
        if(entry.first == key) { return &entry.second; }
    }
    return nullptr;
}

/** Removes the key and its value from the table, if it's there
 * Runtime: O(1 + alpha) expected (under SUHA), O(n) worst case
 */
void ChainedTable::remove(int key) {
    // a reference, so erasing changes the chain inside the table
    auto& chain = table_[hash(key)];
    for(auto it = chain.begin(); it != chain.end(); ++it) {
        if(it->first == key) {
            // unlinking a node from a linked list is O(1)
            chain.erase(it);
            return;
        }
    }
}
