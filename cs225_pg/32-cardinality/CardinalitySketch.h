// CardinalitySketch.h

#pragma once
#include <cstddef>
#include <functional>
#include <iterator>
#include <limits>
#include <set>
#include <string>

/** Estimates the number of unique items in a stream from the k smallest hashes it has seen */
class CardinalitySketch {
  public:
    /** Creates an empty sketch that keeps the `k` smallest hashes
     * Runtime: O(1)
     */
    CardinalitySketch(size_t k) : k_(k) { }

    /** Hashes `item` into [0, 1] and keeps it if it is among the k smallest
     * Runtime: O(log k)
     */
    void insert(const std::string & item) {
        // divide by the size of the hash range to land in [0, 1]
        insertHash(hash_(item) / maxHash_);
    }

    /** Keeps an already scaled hash `h` (in [0, 1]) if it is among the k smallest
     * Runtime: O(log k)
     */
    void insertHash(double h) {
        // a set ignores a value it already has, which takes care of repeated items
        smallest_.insert(h);

        // keep only the k smallest hashes by dropping the largest one
        if(smallest_.size() > k_) {
            smallest_.erase(std::prev(smallest_.end()));
        }
    }

    /** Estimates the number of unique items as k / (kth smallest hash) - 1
     * Runtime: O(1)
     */
    double estimate() const {
        // fewer than k unique items so far, so we know the exact count
        if(smallest_.size() < k_) {
            return smallest_.size();
        }
        double kthSmallest = *smallest_.rbegin();
        return k_ / kthSmallest - 1;
    }

  private:
    /** how many of the smallest hashes to keep */
    size_t k_;

    /** the k smallest scaled hashes seen so far, in sorted order */
    std::set<double> smallest_;

    /** the hash function every item goes through */
    std::hash<std::string> hash_;

    /** the size of the hash range, used to scale a hash into [0, 1]
     * (2^64 - 1 rounds up to 2^64 as a double, which is exactly the number of possible hashes)
     */
    static constexpr double maxHash_ = static_cast<double>(std::numeric_limits<size_t>::max());
};
