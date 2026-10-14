// Point.h

#pragma once
#include <cstddef>
#include <functional>

/** A 2D point that can be a key in `std::unordered_set` and `std::unordered_map` */
struct Point {
    int x;
    int y;

    /** Returns whether two points have the same coordinates
     * (the table uses == to tell keys in the same bucket apart)
     * Runtime: O(1)
     */
    bool operator==(const Point& other) const {
        return x == other.x && y == other.y;
    }
};

namespace std {
/** The hash `std::unordered_set<Point>` uses, built from the built-in hash for `int` */
template <>
struct hash<Point> {
    /** Hashes a point by combining the built-in hashes of its coordinates
     * Runtime: O(1)
     */
    size_t operator()(const Point& p) const {
        // multiplying by 31 makes (1, 2) and (2, 1) hash differently
        return hash<int>()(p.x) * 31 + hash<int>()(p.y);
    }
};
}
