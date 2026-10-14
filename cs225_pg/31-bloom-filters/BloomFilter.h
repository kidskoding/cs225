// BloomFilter.h

#pragma once
#include <cstddef>
#include <cstdint>
#include <functional>
#include <string>
#include <vector>

/** Returns whether bit `b` of `bits` is 1
 * Runtime: O(1)
 */
inline bool isSet(uint64_t bits, unsigned b) {
    uint64_t mask = uint64_t(1) << b;
    return (bits & mask) != 0;
}

/** Returns `bits` with bit `b` set to 1
 * Runtime: O(1)
 */
inline uint64_t setBit(uint64_t bits, unsigned b) {
    uint64_t mask = uint64_t(1) << b;
    return bits | mask;
}

/** A Bloom filter: one bit vector of m bits shared by k hash functions.
 * `contains` never gives a false negative, but can give a false positive
 */
class BloomFilter {
  public:
    using HashFunction = std::function<size_t(int)>;

    /** Creates an empty filter of `m` bits that uses the given hash functions
     * Runtime: O(m)
     */
    BloomFilter(size_t m, std::vector<HashFunction> hashes)
        : m_(m), bits_((m + 63) / 64, 0), hashes_(hashes) { }

    /** Sets the bit each hash function picks for `key`
     * Runtime: O(k)
     */
    void insert(int key) {
        for(const HashFunction& h : hashes_) {
            size_t i = h(key) % m_;
            // bit `i` lives in word `i / 64`, at position `i % 64` within it
            bits_[i / 64] |= uint64_t(1) << (i % 64);
        }
    }

    /** Returns whether `key` might be in the filter (no false negatives)
     * Runtime: O(k)
     */
    bool contains(int key) const {
        for(const HashFunction& h : hashes_) {
            size_t i = h(key) % m_;
            // one 0 means the key was never inserted
            if((bits_[i / 64] & (uint64_t(1) << (i % 64))) == 0) {
                return false;
            }
        }
        return true;
    }

    /** Turns this filter into the union of itself and `other`
     * (both filters need the same size and the exact same hash functions)
     * Runtime: O(m)
     */
    void unionWith(const BloomFilter& other);

    /** Returns the filter's bits as a string of 0s and 1s, bit 0 first
     * Runtime: O(m)
     */
    std::string bits() const;

  private:
    /** the number of bits in the filter */
    size_t m_;

    /** the m bits, packed 64 to a word */
    std::vector<uint64_t> bits_;

    /** the k hash functions */
    std::vector<HashFunction> hashes_;
};
