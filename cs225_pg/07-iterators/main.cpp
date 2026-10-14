// main.cpp

#include <iostream>
#include <string>
#include <vector>

/** An animal in the zoo, with what it eats and whether it is big */
struct Animal {
    std::string name, food;
    bool big;
    Animal(std::string name = "blob", std::string food = "you", bool big = true)
        : name(name), food(food), big(big) { }
};

/** Iterators: walking a `std::vector` of animals with an iterator and a range-based for loop
 * Runtime: O(n)
 */
int main() {
    std::cout << "\n== Iterators ==\n";

    Animal g("giraffe", "leaves", true), p("penguin", "fish", false), b("bear");
    std::vector<Animal> zoo;
    zoo.push_back(g);
    zoo.push_back(p);
    zoo.push_back(b);

    for(std::vector<Animal>::iterator it = zoo.begin(); it != zoo.end(); it++) {
        std::cout << it->name << " " << it->food << "\n";
    }
    for(const Animal& animal : zoo) {
        std::cout << "range-for: " << animal.name << " eats " << animal.food << "\n";
    }
    return 0;
}
