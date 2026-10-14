// Lambda demo

#include <algorithm>
#include <vector>

int countIf(std::vector<int>& data) {
    auto lessThan5 = [](int x) { return x < 5; };
    return std::count_if(data.begin(), data.end(), lessThan5);
}

