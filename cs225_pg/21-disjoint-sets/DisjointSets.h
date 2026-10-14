// DisjointSets.h

#pragma once
#include <vector>

/** A partition of the elements 0 to n - 1, stored as a forest of uptrees in one array.
 * `data_[k]` is the parent of `k`, or a negative number if `k` is a root
 * (-1 for plain uptrees, -size for union by size, -(height + 1) for union by height/rank)
 */
class DisjointSets {
public:
    /** Creates a disjoint set with no elements
     * Runtime: O(1)
     */
    DisjointSets() = default;

    /** Creates a disjoint set straight from its uptree array (roots store negative numbers)
     * Runtime: O(n)
     */
    DisjointSets(const std::vector<int>& data);

    /** Adds `num` new elements, each in a brand new set all by itself
     * Runtime: O(num)
     */
    void addElements(int num);

    /** Returns the root of `k` and points every node on the path at it
     * Runtime: amortized O(α(m, n))
     */
    int find(int k);

    /** Hangs the uptree rooted at `r1` underneath the root `r2`
     * (named `_union` because `union` is a C++ keyword)
     * Runtime: O(1)
     */
    void _union(int r1, int r2);

    /** Points the root of the smaller set at the root of the bigger one
     * Runtime: O(1)
     */
    void unionBySize(int r1, int r2);

    /** Points the root of the shorter uptree at the root of the taller one
     * Runtime: O(1)
     */
    void unionByHeight(int r1, int r2);

    /** Points the root with the smaller rank at the root with the larger one
     * (the same code as `unionByHeight`, but stays correct with path compression)
     * Runtime: O(1)
     */
    void unionByRank(int r1, int r2);

    /** Returns the uptree array, where index k stores k's parent (or a negative number at a root)
     * Runtime: O(1)
     */
    const std::vector<int>& data() const;

private:
    /** index k stores the parent of k, or a negative number if k is a root */
    std::vector<int> data_;
};
