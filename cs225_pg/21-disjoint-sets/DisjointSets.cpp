// DisjointSets.cpp

#include "DisjointSets.h"

/** Creates a disjoint set straight from its uptree array (roots store negative numbers)
 * Runtime: O(n)
 */
DisjointSets::DisjointSets(const std::vector<int>& data) : data_(data) { }

/** Adds `num` new elements, each in a brand new set all by itself
 * Runtime: O(num)
 */
void DisjointSets::addElements(int num) {
    // every new element starts as its own root, which stores -1
    data_.insert(data_.end(), num, -1);
}

/** Returns the root of `k` and points every node on the path at it
 * Runtime: amortized O(α(m, n))
 */
int DisjointSets::find(int k) {
    // roots store a negative number (the size or height), so `k` is the root
    if(data_[k] < 0) { return k; }

    // point k straight at the root before returning it
    data_[k] = find(data_[k]);
    return data_[k];
}

/** Hangs the uptree rooted at `r1` underneath the root `r2`
 * (named `_union` because `union` is a C++ keyword)
 * Runtime: O(1)
 */
void DisjointSets::_union(int r1, int r2) {
    data_[r1] = r2;
}

/** Points the root of the smaller set at the root of the bigger one
 * Runtime: O(1)
 */
void DisjointSets::unionBySize(int r1, int r2) {
    // sizes are stored negated, so this is the merged set's size, negated
    int newSize = data_[r1] + data_[r2];

    // the more negative root is the bigger set
    if(data_[r1] < data_[r2]) {
        data_[r2] = r1;
        data_[r1] = newSize;
    } else {
        data_[r1] = r2;
        data_[r2] = newSize;
    }
}

/** Points the root of the shorter uptree at the root of the taller one
 * Runtime: O(1)
 */
void DisjointSets::unionByHeight(int r1, int r2) {
    // the more negative root is the taller tree
    if(data_[r1] < data_[r2]) {
        data_[r2] = r1;
    } else if(data_[r1] > data_[r2]) {
        data_[r1] = r2;
    } else {
        // same height: the new tree is one taller
        data_[r1] = r2;
        data_[r2]--;
    }
}

/** Points the root with the smaller rank at the root with the larger one
 * (the same code as `unionByHeight`, but stays correct with path compression)
 * Runtime: O(1)
 */
void DisjointSets::unionByRank(int r1, int r2) {
    // rank is stored as -(rank + 1), exactly like the height
    unionByHeight(r1, r2);
}

/** Returns the uptree array, where index k stores k's parent (or a negative number at a root)
 * Runtime: O(1)
 */
const std::vector<int>& DisjointSets::data() const {
    return data_;
}
