// BloomFilter.cpp

#include "BloomFilter.h"

/** Turns this filter into the union of itself and `other`
 * (both filters need the same size and the exact same hash functions)
 * Runtime: O(m)
 */
void BloomFilter::unionWith(const BloomFilter& other) {
    // a bit is 1 in the union exactly when it is 1 in either filter
    for(size_t w = 0; w < bits_.size(); w++) {
        bits_[w] |= other.bits_[w];
    }
}

/** Returns the filter's bits as a string of 0s and 1s, bit 0 first
 * Runtime: O(m)
 */
std::string BloomFilter::bits() const {
    std::string out;
    for(size_t i = 0; i < m_; i++) {
        out += isSet(bits_[i / 64], i % 64) ? '1' : '0';
    }
    return out;
}
