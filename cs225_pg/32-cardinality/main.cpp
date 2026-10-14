// main.cpp

#include "CardinalitySketch.h"
#include "MinSketch.h"

#include <cstddef>
#include <iomanip>
#include <iostream>
#include <string>
#include <vector>

/** Cardinality: the min sketch on the three example streams, the k-min sketch on stream 2,
 * and a real stream of strings
 * Runtime: O(n log k)
 */
int main() {
    std::cout << "\n== Cardinality ==\n";

    const std::vector<std::vector<int>> streams = {
        {920, 328, 700, 920, 930}, {492, 253, 810, 327, 660}, {580, 134, 450, 970, 290}
    };
    std::cout << std::fixed << std::setprecision(2);
    for(size_t s = 0; s < streams.size(); s++) {
        MinSketch sketch;
        for(int h : streams[s]) {
            sketch.insertHash(h / 1000.0);
        }
        std::cout << "stream " << s + 1 << " min sketch estimate: " << sketch.estimate() << "\n";
    }
    for(size_t k = 1; k <= 3; k++) {
        CardinalitySketch sketch(k);
        for(int h : streams[1]) {
            sketch.insertHash(h / 1000.0);
        }
        std::cout << "stream 2, k = " << k << " estimate: " << sketch.estimate() << "\n";
    }

    // 1000 unique strings, each appearing twice
    CardinalitySketch sketch(100);
    MinSketch single;
    for(int round = 0; round < 2; round++) {
        for(int i = 0; i < 1000; i++) {
            sketch.insert("item" + std::to_string(i));
            single.insert("item" + std::to_string(i));
        }
    }
    std::cout << "1000 unique strings (each twice): k = 100 estimates " << sketch.estimate()
              << ", k = 1 estimates " << single.estimate() << "\n";
    return 0;
}
