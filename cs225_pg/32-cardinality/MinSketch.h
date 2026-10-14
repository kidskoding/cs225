// MinSketch.h

#pragma once
#include <algorithm>
#include <cstddef>
#include <functional>
#include <limits>
#include <string>

/** Estimates the number of unique items in a stream from the single smallest hash it has seen */
class MinSketch {
  public:
    /** Hashes `item` into [0, 1] and keeps it if it is the new minimum
     * Runtime: O(1)
     */
    void insert(const std::string & item) {
        // divide by the size of the hash range to land in [0, 1]
        insertHash(hash_(item) / maxHash_);
    }

    /** Keeps an already scaled hash `h` (in [0, 1]) if it is the new minimum
     * Runtime: O(1)
     */
    void insertHash(double h) {
        min_ = std::min(min_, h);
    }

    /** Estimates the number of unique items as 1 / min - 1
     * Runtime: O(1)
     */
    double estimate() const {
        return 1 / min_ - 1;
    }

  private:
    /** the smallest scaled hash seen so far (1, the top of the range, before any items) */
    double min_ = 1;

    /** the hash function every item goes through */
    std::hash<std::string> hash_;

    /** the size of the hash range, used to scale a hash into [0, 1]
     * (2^64 - 1 rounds up to 2^64 as a double, which is exactly the number of possible hashes)
     */
    static constexpr double maxHash_ = static_cast<double>(std::numeric_limits<size_t>::max());
};
