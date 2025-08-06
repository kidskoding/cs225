// Lambda demo

#include <algorithm>
#include <vector>

bool lessThan5(int x) {
    return x < 5;
}

int countIf(std::vector<int>& data) {
    return std::count_if(data.begin(), data.end(), lessThan5);
}

