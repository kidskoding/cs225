// lambdas.cpp

#include "lambdas.h"
#include <algorithm>

/** Counts the values in `data` that are less than 5
 * Runtime: O(n)
 */
int countIf(std::vector<int>& data) {
    auto lessThan5 = [](int x) { return x < 5; };
    return std::count_if(data.begin(), data.end(), lessThan5);
}
