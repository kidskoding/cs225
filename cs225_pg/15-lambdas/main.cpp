// main.cpp

#include "lambdas.h"

#include <algorithm>
#include <iostream>
#include <queue>
#include <string>
#include <vector>

/** Prints `label`, then every value in `values` separated by spaces
 * Runtime: O(n)
 */
template <typename T>
void printValues(const std::string& label, const std::vector<T>& values) {
    std::cout << label << ":";
    for(const T& value : values) {
        std::cout << " " << value;
    }
    std::cout << "\n";
}

/** Returns `true` if `x` is less than 5, as a plain function to pass to `count_if`
 * Runtime: O(1)
 */
bool lessThan5(int x) {
    return x < 5;
}

/** Lambdas and functions as data: count_if, a priority queue ordered by a lambda, captures,
 * and a function pointer
 * Runtime: O(n log n)
 */
int main() {
    std::cout << "\n== Lambdas ==\n";

    std::vector<int> data = {1, 7, 3, 9, 4, 5};
    std::cout << "count_if with a function: " << std::count_if(data.begin(), data.end(), lessThan5) << "\n";
    std::cout << "countIf (count_if with a lambda): " << countIf(data) << "\n";

    auto greater = [](int a, int b) { return a > b; };
    std::priority_queue<int, std::vector<int>, decltype(greater)> pq(greater);
    for(int x : data) {
        pq.push(x);
    }
    std::vector<int> popped;
    while(!pq.empty()) {
        popped.push_back(pq.top());
        pq.pop();
    }
    printValues("priority_queue with the greater lambda pops", popped);

    int threshold = 5;
    auto isBig = [threshold](int x) { return x > threshold; }; // captures threshold
    std::cout << "isBig(7) with threshold 5: " << std::boolalpha << isBig(7) << std::noboolalpha << "\n";

    auto myMax = [](int x, int y) { return x > y ? x : y; };
    int (*maxPointer)(int, int) = myMax; // a captureless lambda converts to a function pointer
    std::cout << "maxPointer(4, 7): " << maxPointer(4, 7) << "\n";
    return 0;
}
