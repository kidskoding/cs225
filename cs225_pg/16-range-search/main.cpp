// main.cpp

#include <iostream>
#include <map>
#include <string>

/** BBST range search: every key in [10, 42] with `lower_bound` and `upper_bound`
 * Runtime: O(log n + k)
 */
int main() {
    std::cout << "\n== BBST Range Search ==\n";

    std::map<int, std::string> m = {
        {6, "f"}, {11, "k"}, {19, "s"}, {25, "y"}, {33, "g"}, {42, "p"}, {44, "r"}
    };

    // every key in [10, 42]
    std::cout << "keys in [10, 42]:";
    for(auto it = m.lower_bound(10); it != m.upper_bound(42); ++it) {
        std::cout << " " << it->first;
    }
    std::cout << "\n";
    return 0;
}
