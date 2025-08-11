
# Module 5 - Amortized Analysis

**Amortized Analysis** is a technique commonly used in Computer Science to analyze the **average running time** per operation
over a sequence of operations in an algorithm. Rather than focusing on the worst case cost for a single operation (this is simply **Big-O**), amortized analysis evaluates the overall cost when spreaded out evenly across all operations performed.

This is useful because even though some operations in an algorithm can cost a lot more than others, the average cost per operation is low when many operations are performed consecutively.

## Resizing by adding 2 elements every time

One way to implement our `addSpace()` function is to resize the buffer by increasing the `capacity` by 2 each time the array is full. This means that when more space is needed, `addSpace()` allocates a new array with a capacity of `capacity + 2`. Recall that after this, `addSpace()` then needs to copy all the data from the previous buffer to the new buffer and then update the buffer's internal pointers.

Since `addSpace()` needs to copy all the data from the previous buffer to the new buffer when updating its capacity by `capacity + 2`, this means that the algorithm has a runtime of $O(n)$, where $n$ represents the number of elements currently in the array. This is because each element must be copied one by one into the new buffer.

Let $r$ represent the number of resizes, where a resize occurs when the ArrayList is full (or simply every time two elements are added).

Then, the total runtime cost of this algorithm, where there are 2 copies made every 2 iterations, can be represented through the summation
$$
    \sum_{k = 1}^{r} = 2k
$$

Since $r$ represents the number of resize operations every two iterations, the summation is equivalent to $2 \times \frac{r(r + 1)}{2} = r(r + 1) = r^2 + r$. Therefore,
$$
    \sum_{k = 1}^{r} = r^2 + r
$$

However, $r$ is the number of resize operations every two iterations. When analyzing algorithmic runtime, it is important to express it in terms of $n$ rather than $r$ because an algorithm is expressed in terms of its input size, which is simply $n$.

If there were $5$ resizes that occurred every 2 elements, then the total number of elements, $n$, would be $10$, which can be mathematically expressed as $n = 2r$, or simply $r = \frac{n}{2}$ 

Substituting $n$ for $r$ becomes
$$
\begin{align*}
    &=(\frac{n}{2})^2 + \frac{n}{2} \\
    &=\frac{n^2 + 2n}{4} 
\end{align*}
$$

Therefore, the total time for $n$ inserts is $\frac{n^2 + 2n}{4}$.

The total amortized cost is then calculated by dividing by $n$, the total number of operations performed on an algorithm
$$
    \frac{\frac{n^2 + 2n}{4}}{n} = \frac{n^2 + 2n}{4n} = \frac{n(n + 2)}{4n} = \frac{n + 2}{4} = \frac{1}{4}n + \frac{1}{2}
$$

making the total amortized cost $O(n)$ (since constants are dropped)

## Resizing by doubling the elements every time

Now suppose, we resized the `ArrayList` by doubling the capacity everytime. Each time we resize, the time it takes to do so doubles from 1, 2, 4, 8, 16, etc. This is because each resize involves copying all the elements from the old array into a new array that is twice as large.

Let $r$ represent the number of resizes, where a resize occurs when the `ArrayList` is full (or simply every time two elements are added)

When the `ArrayList` is full, its capacity will resize by double the original capacity.

Recall that each time we resize, the time it takes to do so doubles from 1, 2, 4, 8, 16, etc. This is because each resize involves copying all the elements from the old array into a new array that is twice as large. Therefore, this results in $2^r$ copies per resize.

Therefore, the summation that represents the runtime of this algorithm is

$$
	\sum_{k = 0}^{r}2^k
$$

This summation is equivalent to the sequence $1 + 2 + 4 + \cdots + 2^{r - 1} = 2^{r} - 1$

However, in an amortized sense, we need to multiply this by the number of operations we are doing. We are doubling the capacity and inserting a new element into our buffer. This means we have to multiply this runtime cost by our insertions. The $+1$ at the end represents the initial operation and constant cost that isn't captured by the summation. Therefore,

$$
\sum_{k = 0}^{r}2^k = 2(2^r - 1) + 1
$$

where $2^r = n$ and $r = log_2n$. Therefore,

$$
\sum_{k = 0}^{r}2^k = 2(2^{log_2 n} - 1) + 1 = 2(n - 1) + 1 = 2n - 1
$$

where $2n - 1$ represents the total copies with $n$ inserts, meaning that the amortized cost is represented by

$$
\frac{2n - 1}{n}
$$

which simplifies to $2 - \frac{1}{n}$. When analyzing this behavior's function, the 

$$
\lim_{n \rightarrow \infty}(2 - \frac{1}{n}) = 2
$$

which means that it approaches a constant value of $2$. Therefore, its amortized cost is $O(1)$

Since the amortized cost when doubling the capacity each resize is O(1), it makes more sense to implement the `addSpace()` function using this resizing method

Now to implement our `addSpace()` function into our data buffer, we need to do a series of steps following our resize approach

1. Reallocate the data buffer, typically done by doubling its capacity
2. Check if the original capacity is 0. If so, set the new capacity to 1. This is to ensure memory efficiency
3. Allocate a new data buffer equivalent to the new capacity (which was double the original capacity)
4. Calculate the number of elements currently in the `ArrayList` (recall that this can be done with our `size` and `data` pointers by doing `size` - `data`)
5. Copy all contents from the old data buffer into the new data buffer
6. Free all the contents from the old data buffer and update the pointer of the new data buffer
7. Update the capacity to the new capacity and update the size pointer to point to the correct position in the new buffer

The code for this algorithm that reflects these series of steps is shown below,

```
// ArrayList.hpp

#include "ArrayList.h"

/** Allocates additional space to the buffer in this `ArrayList`
 *  Runtime: O(n)
 */
template <typename T>
void ArrayList<T>::addSpace() {
    /* Reallocate the capacity of the buffer (similar to realloc in C)
     * Typically that of double the original capacity
     */
    int newCapacity = capacity * 2;

    // If the original capacity is 0, set it to 1 to be minimal and memory efficient
    if(newCapacity == 0) {
        newCapacity = 1;
    }

    // Allocate a new data buffer that is set to the updated capacity
    T* newData = new T[newCapacity];

    // Calculate the number of elements currently in the `ArrayList`
    int currentSize = size - data;

    // Copy all contents from the old data buffer into the new data buffer
    for(int i = 0; i < size; i++) {
        newData[i] = data[i];
    }

    // Free the contents from the old buffer from memory
    delete[] data;

    // Update the data pointer to point to the newly allocated buffer
    data = newData;

    // Set the current capacity to the new capacity
    capacity = newCapacity;

    // Update the size pointer to point to the correct position in the new buffer
    size = data + currentSize;
}
```

This will effectively add more space to our buffer (double that the original) when its capacity is full

## Amortized Costs of various operations on various `List` implementations

| Operation                     | **Singly Linked List** | **Array**            |
|-------------------------------|-----------------------|----------------------|
| Insert/Remove at front/back    | `O(1)`                  | `O(1)`* (amortized)    |
| Insert/Remove given a pointer  | `O(1)`                  | `O(n)`                 |
| Insert/Remove at a given index | `O(n)`                  | `O(n)`                 |
| Find a value in a list         | `O(n)`                  | `O(n)`                 |
| Find a value in a sorted list  | `O(n)`                  | `O(log n)`             |


The `*` represents **amortized** cost, which means the average cost per operation over a sequence of operations. Whether to use the amortized case depends on the application you are building. Amortized analysis isn’t ideal for explaining the cost of a single, individual operation, but rather useful for understanding the average cost spread across many operations.
<!--stackedit_data:
eyJoaXN0b3J5IjpbNDY3MjQ2MzI0LDY5NTA3MDA5Niw2OTUwNz
AwOTZdfQ==
-->