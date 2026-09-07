Absolutely. For interviews, the best approach is to use **one simple pattern per problem**, then remember the time/space complexity rather than memorizing large amounts of code.

 Below, I’ll use **Java 7, Java 8, and Java 17** versions wherever the language features differ. The core logic remains the same.

 # Array / Collection Interview Problems

 ## Quick Cheat Sheet

 | # | Problem | Best approach | Time | Extra Space |
| --- | --- | --- | --- | --- |
| 1 | Remove duplicates | `LinkedHashSet` / `Set` | O(n) | O(n) |
| 2 | Second highest | One-pass variables | O(n) | O(1) |
| 3 | Max & Min | One-pass variables | O(n) | O(1) |
| 4 | Sort without built-in sort | Bubble Sort | O(n²) | O(1) |
| 5 | Sorting complexity | Bubble Sort | O(n²) | O(1) |
| 6 | Find duplicates | `Set` | O(n) | O(n) |
| 7 | Find missing number | Sum / XOR | O(n) | O(1) |
| 8 | Frequency | `Map` | O(n) | O(n) |

 > **Interview memory trick:**\
>  **Set → duplicates**\
>  **Map → frequency**\
>  **Two variables → max/min/second max**\
>  **Sum/XOR → missing number**\
>  **Nested loops → sorting/comparison → O(n²)**

---

 # 1\. Remove Duplicates from a List

 ### Example

```
Input:
[10, 20, 10, 30, 20, 40]

              |
              v
        +-------------+
        |    Set      |
        |             |
        | 10          |
        | 20          |
        | 30          |
        | 40          |
        +-------------+
              |
              v
Output:
[10, 20, 30, 40]
```

 ## Java 7

 Use `LinkedHashSet` when you want to **remove duplicates while maintaining insertion order**.

```
import java.util.*;

public class RemoveDuplicates {
    public static void main(String[] args) {

        List<Integer> list = Arrays.asList(
            10, 20, 10, 30, 20, 40
        );

        Set<Integer> set = new LinkedHashSet<Integer>(list);

        System.out.println(set);
    }
}
```

 Output:

```
[10, 20, 30, 40]
```

 ## Java 8

```
import java.util.*;
import java.util.stream.*;

public class RemoveDuplicates {
    public static void main(String[] args) {

        List<Integer> list = Arrays.asList(
            10, 20, 10, 30, 20, 40
        );

        List<Integer> result = list.stream()
                                   .distinct()
                                   .collect(Collectors.toList());

        System.out.println(result);
    }
}
```

 ## Java 17

```
import java.util.*;

public class RemoveDuplicates {
    public static void main(String[] args) {

        var list = List.of(10, 20, 10, 30, 20, 40);

        var result = list.stream()
                         .distinct()
                         .toList();

        System.out.println(result);
    }
}
```

 ### Complexity

```
Time  : O(n)
Space : O(n)
```

 ### Remember

 **Duplicate → Set**

---

 # 2\. Find the Second-Highest Number

 Example:

```
Input:
[10, 50, 30, 20, 40]

highest
   |
   v
  50

secondHighest
      |
      v
     40
```

 Instead of sorting, maintain two variables:

```
        current number
              |
              v
       +--------------+
       |              |
       v              v
    > highest?     > second?
       |              |
       v              v
   highest=number  second=number
```

 ## Java 7

```
public class SecondHighest {
    public static void main(String[] args) {

        int[] arr = {10, 50, 30, 20, 40};

        int highest = Integer.MIN_VALUE;
        int secondHighest = Integer.MIN_VALUE;

        for (int num : arr) {

            if (num > highest) {
                secondHighest = highest;
                highest = num;
            }
            else if (num > secondHighest && num != highest) {
                secondHighest = num;
            }
        }

        System.out.println("Second Highest: " + secondHighest);
    }
}
```

 ## Java 8

```
import java.util.*;

public class SecondHighest {
    public static void main(String[] args) {

        int[] arr = {10, 50, 30, 20, 40};

        int secondHighest = Arrays.stream(arr)
                .distinct()
                .boxed()
                .sorted(Comparator.reverseOrder())
                .skip(1)
                .findFirst()
                .orElseThrow(() ->
                    new RuntimeException("No second highest"));

        System.out.println(secondHighest);
    }
}
```

 ### Interview note

 The **Java 7 approach is better for an algorithm interview** because:

```
No sorting
     ↓
One loop
     ↓
O(n)
```

 ## Java 17

```
import java.util.*;

public class SecondHighest {
    public static void main(String[] args) {

        int[] arr = {10, 50, 30, 20, 40};

        int secondHighest = Arrays.stream(arr)
                .distinct()
                .boxed()
                .sorted(Comparator.reverseOrder())
                .skip(1)
                .findFirst()
                .orElseThrow();

        System.out.println(secondHighest);
    }
}
```

 ### Complexity

 **Java 7 one-pass solution:**

```
Time  : O(n)
Space : O(1)
```

 ### Remember

 **Second highest → keep `highest` \+ `secondHighest`**

---

 # 3\. Find Maximum and Minimum

 Example:

```
[10, 5, 30, 2, 40]

 10 → min=10, max=10
  5 → min=5
 30 → max=30
  2 → min=2
 40 → max=40

Result:
Min = 2
Max = 40
```

 ## Java 7

```
public class MaxMin {
    public static void main(String[] args) {

        int[] arr = {10, 5, 30, 2, 40};

        int min = arr[0];
        int max = arr[0];

        for (int num : arr) {

            if (num < min) {
                min = num;
            }

            if (num > max) {
                max = num;
            }
        }

        System.out.println("Minimum: " + min);
        System.out.println("Maximum: " + max);
    }
}
```

 ## Java 8

```
import java.util.*;

public class MaxMin {
    public static void main(String[] args) {

        int[] arr = {10, 5, 30, 2, 40};

        int min = Arrays.stream(arr).min().orElseThrow();
        int max = Arrays.stream(arr).max().orElseThrow();

        System.out.println("Minimum: " + min);
        System.out.println("Maximum: " + max);
    }
}
```

 ## Java 17

```
import java.util.*;

public class MaxMin {
    public static void main(String[] args) {

        var arr = new int[]{10, 5, 30, 2, 40};

        var min = Arrays.stream(arr).min().orElseThrow();
        var max = Arrays.stream(arr).max().orElseThrow();

        System.out.println("Minimum: " + min);
        System.out.println("Maximum: " + max);
    }
}
```

 ### Complexity

```
Time  : O(n)
Space : O(1)
```

 ### Remember

 **Min/Max → one loop + two variables**

---

 # 4\. Sort Integers Without Built-in Sorting

 For interviews, **Bubble Sort** is easiest to remember.

 Example:

```
[5, 3, 4, 1]

Pass 1:
5 3 4 1
↓
3 5 4 1
    ↓
3 4 5 1
      ↓
3 4 1 5

Pass 2:
3 4 1 5
↓
3 1 4 5

Pass 3:
1 3 4 5
```

 ### Core idea

```
Compare adjacent elements
          ↓
   wrong order?
      /       \
    YES        NO
     ↓          ↓
   swap       continue
```

 ## Java 7

```
public class BubbleSort {
    public static void main(String[] args) {

        int[] arr = {5, 3, 4, 1};

        for (int i = 0; i < arr.length - 1; i++) {

            for (int j = 0; j < arr.length - 1 - i; j++) {

                if (arr[j] > arr[j + 1]) {

                    int temp = arr[j];
                    arr[j] = arr[j + 1];
                    arr[j + 1] = temp;
                }
            }
        }

        for (int num : arr) {
            System.out.print(num + " ");
        }
    }
}
```

 ## Java 8

 The algorithm itself doesn't need Java 8 features:

```
import java.util.stream.IntStream;

public class BubbleSort {
    public static void main(String[] args) {

        int[] arr = {5, 3, 4, 1};

        for (int i = 0; i < arr.length - 1; i++) {
            for (int j = 0; j < arr.length - 1 - i; j++) {

                if (arr[j] > arr[j + 1]) {
                    int temp = arr[j];
                    arr[j] = arr[j + 1];
                    arr[j + 1] = temp;
                }
            }
        }

        IntStream.of(arr).forEach(n -> System.out.print(n + " "));
    }
}
```

 ## Java 17

```
import java.util.*;

public class BubbleSort {
    public static void main(String[] args) {

        var arr = new int[]{5, 3, 4, 1};

        for (var i = 0; i < arr.length - 1; i++) {
            for (var j = 0; j < arr.length - 1 - i; j++) {

                if (arr[j] > arr[j + 1]) {
                    var temp = arr[j];
                    arr[j] = arr[j + 1];
                    arr[j + 1] = temp;
                }
            }
        }

        System.out.println(Arrays.toString(arr));
    }
}
```

 ### Complexity

```
Worst Case:
5 4 3 2 1

Comparisons:
(n-1) + (n-2) + ... + 1

= n(n-1)/2

Time = O(n²)
Space = O(1)
```

 ### Remember

 **Bubble Sort = two loops + adjacent swap**

---

 # 5\. Calculate Time Complexity of Sorting

 For the Bubble Sort above:

```
for (int i = 0; i < n - 1; i++) {

    for (int j = 0; j < n - 1 - i; j++) {

        if (arr[j] > arr[j + 1]) {
            // swap
        }
    }
}
```

 Diagram:

```
             n
             |
       +-----+-----+
       |           |
       v           v
    outer        inner
     loop         loop
      n           n
       \           /
        \         /
         \       /
          O(n²)
```

 More precisely:

```
(n - 1)
+
(n - 2)
+
(n - 3)
+
...
+
1

= n(n-1)/2
```

 Drop constants and lower-order terms:

```
n(n-1)/2
     ↓
(n² - n)/2
     ↓
O(n²)
```

 ### Complexity

 | Case | Time |
| --- | --- |
| Best case\* | O(n²) |
| Average | O(n²) |
| Worst | O(n²) |
| Space | O(1) |

 \*If you add a `swapped` flag, the best case becomes **O(n)**.

 ### Optimized Bubble Sort

```
boolean swapped;

for (int i = 0; i < arr.length - 1; i++) {

    swapped = false;

    for (int j = 0; j < arr.length - 1 - i; j++) {

        if (arr[j] > arr[j + 1]) {

            int temp = arr[j];
            arr[j] = arr[j + 1];
            arr[j + 1] = temp;

            swapped = true;
        }
    }

    if (!swapped) {
        break;
    }
}
```

 Now:

```
Best     : O(n)
Average  : O(n²)
Worst    : O(n²)
Space    : O(1)
```

---

 # 6\. Find Duplicate Elements in an Array

 Example:

```
Input:
[10, 20, 10, 30, 20, 40]

             |
             v
       +-------------+
       |     Set     |
       +-------------+
        10 → new
        20 → new
        10 → DUPLICATE
        30 → new
        20 → DUPLICATE
        40 → new

Output:
10, 20
```

 ## Java 7

```
import java.util.*;

public class FindDuplicates {
    public static void main(String[] args) {

        int[] arr = {10, 20, 10, 30, 20, 40};

        Set<Integer> seen = new HashSet<Integer>();
        Set<Integer> duplicates = new LinkedHashSet<Integer>();

        for (int num : arr) {

            if (!seen.add(num)) {
                duplicates.add(num);
            }
        }

        System.out.println(duplicates);
    }
}
```

 ### Important

 This line is very useful in interviews:

```
if (!seen.add(num))
```

 Why?

```
set.add(num)

true  → element was new
false → element already existed
```

 ## Java 8

```
import java.util.*;
import java.util.function.Function;
import java.util.stream.Collectors;

public class FindDuplicates {
    public static void main(String[] args) {

        int[] arr = {10, 20, 10, 30, 20, 40};

        Set<Integer> duplicates =
            Arrays.stream(arr)
                  .boxed()
                  .collect(Collectors.groupingBy(
                      Function.identity(),
                      LinkedHashMap::new,
                      Collectors.counting()
                  ))
                  .entrySet()
                  .stream()
                  .filter(e -> e.getValue() > 1)
                  .map(Map.Entry::getKey)
                  .collect(Collectors.toCollection(
                      LinkedHashSet::new
                  ));

        System.out.println(duplicates);
    }
}
```

 For an interview, however, **use the Java 7-style Set solution**. It's much easier to explain.

 ## Java 17

```
import java.util.*;

public class FindDuplicates {
    public static void main(String[] args) {

        var arr = new int[]{10, 20, 10, 30, 20, 40};

        var seen = new HashSet<Integer>();
        var duplicates = new LinkedHashSet<Integer>();

        for (var num : arr) {
            if (!seen.add(num)) {
                duplicates.add(num);
            }
        }

        System.out.println(duplicates);
    }
}
```

 ### Complexity

```
Time  : O(n) average
Space : O(n)
```

 ### Remember

 **Find duplicates → `Set`**

---

 # 7\. Find Missing Number from an Array

 Assume numbers are from:

```
1 to n
```

 Example:

```
Expected:

1  2  3  4  5

Actual:

1  2  4  5

Missing = 3
```

 ## Approach: Sum

 Expected sum:

```
1 + 2 + 3 + ... + n

n * (n + 1)
----------------
       2
```

 Then:

```
Missing = Expected Sum - Actual Sum
```

 Diagram:

```
        n(n+1)/2
             |
             v
      Expected Sum
             |
             |
             v
      - Actual Sum
             |
             v
       Missing Number
```

 ## Java 7

```
public class MissingNumber {
    public static void main(String[] args) {

        int[] arr = {1, 2, 4, 5};

        int n = 5;

        int expectedSum = n * (n + 1) / 2;

        int actualSum = 0;

        for (int num : arr) {
            actualSum += num;
        }

        int missing = expectedSum - actualSum;

        System.out.println("Missing: " + missing);
    }
}
```

 ## Java 8

```
import java.util.Arrays;

public class MissingNumber {
    public static void main(String[] args) {

        int[] arr = {1, 2, 4, 5};

        int n = 5;

        int expectedSum = n * (n + 1) / 2;

        int actualSum = Arrays.stream(arr).sum();

        System.out.println(expectedSum - actualSum);
    }
}
```

 ## Java 17

```
import java.util.Arrays;

public class MissingNumber {
    public static void main(String[] args) {

        var arr = new int[]{1, 2, 4, 5};
        var n = 5;

        var expected = n * (n + 1) / 2;
        var actual = Arrays.stream(arr).sum();

        System.out.println("Missing: " + (expected - actual));
    }
}
```

 ### Complexity

```
Time  : O(n)
Space : O(1)
```

 ### Important interview caveat

 This approach assumes:

 - numbers are from `1` to `n`
- exactly one number is missing
- no unexpected duplicates

 ### Remember

 **Missing number → Expected Sum − Actual Sum**

---

 # 8\. Find Frequency of Each Element

 Example:

```
Input:
[10, 20, 10, 30, 20, 10]

Map:

10 → 3
20 → 2
30 → 1
```

 Diagram:

```
             Array
               |
               v
       +---------------+
       |      Map      |
       +---------------+
       | 10 → 3        |
       | 20 → 2        |
       | 30 → 1        |
       +---------------+
```

 ## Java 7

```
import java.util.*;

public class Frequency {
    public static void main(String[] args) {

        int[] arr = {10, 20, 10, 30, 20, 10};

        Map<Integer, Integer> frequency =
            new LinkedHashMap<Integer, Integer>();

        for (int num : arr) {

            if (frequency.containsKey(num)) {
                frequency.put(num, frequency.get(num) + 1);
            }
            else {
                frequency.put(num, 1);
            }
        }

        System.out.println(frequency);
    }
}
```

 A shorter Java 7 version:

```
for (int num : arr) {
    frequency.put(num, frequency.containsKey(num)
        ? frequency.get(num) + 1
        : 1);
}
```

 ## Java 8

 This is where `getOrDefault()` becomes very useful:

```
import java.util.*;

public class Frequency {
    public static void main(String[] args) {

        int[] arr = {10, 20, 10, 30, 20, 10};

        Map<Integer, Integer> frequency = new LinkedHashMap<>();

        for (int num : arr) {
            frequency.put(
                num,
                frequency.getOrDefault(num, 0) + 1
            );
        }

        System.out.println(frequency);
    }
}
```

 Or using streams:

```
import java.util.*;
import java.util.function.Function;
import java.util.stream.Collectors;

public class Frequency {
    public static void main(String[] args) {

        int[] arr = {10, 20, 10, 30, 20, 10};

        Map<Integer, Long> frequency =
            Arrays.stream(arr)
                  .boxed()
                  .collect(Collectors.groupingBy(
                      Function.identity(),
                      LinkedHashMap::new,
                      Collectors.counting()
                  ));

        System.out.println(frequency);
    }
}
```

 ## Java 17

```
import java.util.*;

public class Frequency {
    public static void main(String[] args) {

        var arr = new int[]{10, 20, 10, 30, 20, 10};

        var frequency = new LinkedHashMap<Integer, Integer>();

        for (var num : arr) {
            frequency.put(
                num,
                frequency.getOrDefault(num, 0) + 1
            );
        }

        System.out.println(frequency);
    }
}
```

 ### Complexity

```
Time  : O(n) average
Space : O(n)
```

 ### Remember

 **Frequency → Map + `getOrDefault()`**

---

 # Java 7 vs 8 vs 17 — What Should You Actually Remember?

 You don't need to memorize three completely different solutions.

 The **algorithm is the same**. The syntax evolves.

 ### Java 7

```
Map<Integer, Integer> map =
    new HashMap<Integer, Integer>();
```

 ### Java 8

```
Map<Integer, Integer> map = new HashMap<>();
```

 And you get:

```
getOrDefault()
streams
lambda
method references
```

 ### Java 17

 You can additionally use:

```
var
```

 and modern collection APIs such as:

```
List.of(...)
Set.of(...)
Map.of(...)
stream().toList()
```

 But in an interview, **don't use newer syntax just to show off**. If the interviewer asks for the algorithm, simple code is usually better.

---

 # ⭐ Interview Memory Map

 This is the most important part to memorize:

```
                 ARRAY PROBLEMS
                       |
        +--------------+--------------+
        |              |              |
        v              v              v
      DUPLICATE       COUNT          EXTREME
        |              |              |
        v              v              v
       SET            MAP          MIN / MAX
        |              |              |
       O(n)           O(n)           O(n)
```

 And:

```
Second Highest
      |
      v
highest + secondHighest
      |
     O(n)
```

```
Missing Number
      |
      v
Expected Sum - Actual Sum
      |
     O(n)
```

```
Sorting
    |
    v
Two loops
    |
    v
Bubble Sort
    |
   O(n²)
```

---

 # ⭐ 8 Problems — One-Line Interview Answers

 If the interviewer asks, **"How would you solve it?"**, answer like this:

 1. **Remove duplicates**\
    → "I'll use a `Set`, because a Set doesn't allow duplicate elements."
2. **Second highest**\
    → "I'll maintain `highest` and `secondHighest` and solve it in one pass."
3. **Maximum/minimum**\
    → "I'll maintain `min` and `max` while traversing the array once."
4. **Sort without built-in sort**\
    → "I'll use Bubble Sort by comparing adjacent elements and swapping them."
5. **Time complexity**\
    → "Bubble Sort uses nested loops, so the worst-case time complexity is O(n²) and space is O(1)."
6. **Find duplicates**\
    → "I'll maintain a Set of visited elements. If `add()` returns false, the element is a duplicate."
7. **Missing number**\
    → "I'll calculate the expected sum from 1 to n and subtract the actual array sum."
8. **Frequency**\
    → "I'll use a Map where the key is the element and the value is its count."

---

 # ⭐ Complexity Patterns to Memorize

```
One loop
   ↓
O(n)
```

```
Two nested loops
   ↓
O(n²)
```

```
HashSet / HashMap lookup
   ↓
O(1) average
```

```
n elements + HashSet/HashMap
   ↓
O(n) space
```

```
Only a few variables
   ↓
O(1) space
```

 ### Final interview cheat sheet

 | Problem | Keyword to remember | Time | Space |
| --- | --- | --- | --- |
| Remove duplicates | **Set** | O(n) | O(n) |
| Second highest | **2 variables** | O(n) | O(1) |
| Min & Max | **2 variables** | O(n) | O(1) |
| Sort | **2 loops + swap** | O(n²) | O(1) |
| Sorting complexity | **Nested loops** | O(n²) | O(1) |
| Find duplicates | **Set.add()** | O(n) | O(n) |
| Missing number | **Sum difference** | O(n) | O(1) |
| Frequency | **Map + count** | O(n) | O(n) |

**Best interview strategy:** first explain the **simple approach**, then write the code, then state **time + space complexity**. For Java 8/17, mention the modern alternative only after you've explained the core algorithm.


---
---

Absolutely. I’ll structure these as **interview-ready notes**: first the idea, then code for **Java 7, Java 8, and Java 17 where it makes sense**, followed by a small trace and a memory trick.

> **Important interview point:** The algorithm for Fibonacci, Prime, and Perfect Number does not fundamentally change between Java 7, 8, and 17. What changes is mainly the **syntax/style**. Java 8+ gives you lambdas/streams, while Java 17 lets you use newer language features, but the simple loop-based solutions are often the best choice in interviews.

---

# 1. Fibonacci Series

## What is Fibonacci?

The Fibonacci series is:

```text
0  1  1  2  3  5  8  13  21  34 ...
```

The rule is:

```text
next = previous + current
```

Diagrammatically:

```text
        0     1
         \   /
           1
          / \
         1   2
             / \
            2   3
                / \
               3   5
                   / \
                  5   8
```

Or simply remember:

```text
a = 0
b = 1

next = a + b
a = b
b = next
```

### Easy interview formula

```text
0 → 1 → 1 → 2 → 3 → 5 → 8

     Add previous two numbers ↑
```

---

# 2. Fibonacci using Java 7

Java 7 does not have lambdas or streams, so use a normal `for` loop.

### Code

```java
public class FibonacciJava7 {

    public static void main(String[] args) {

        int n = 10;

        int a = 0;
        int b = 1;

        for (int i = 0; i < n; i++) {

            System.out.print(a + " ");

            int next = a + b;
            a = b;
            b = next;
        }
    }
}
```

### Output

```text
0 1 1 2 3 5 8 13 21 34
```

---

## Trace

Suppose:

```java
n = 5;
```

Initial:

```text
a = 0
b = 1
```

### Iteration 1

Print `a`:

```text
0
```

Calculate:

```text
next = a + b
      = 0 + 1
      = 1
```

Then:

```text
a = b     → 1
b = next  → 1
```

State:

```text
a = 1
b = 1
```

---

### Iteration 2

Print:

```text
1
```

Calculate:

```text
next = 1 + 1 = 2
```

Update:

```text
a = 1
b = 2
```

---

### Iteration 3

Print:

```text
1
```

Calculate:

```text
next = 1 + 2 = 3
```

Update:

```text
a = 2
b = 3
```

---

### Iteration 4

Print:

```text
2
```

Calculate:

```text
next = 2 + 3 = 5
```

Update:

```text
a = 3
b = 5
```

---

### Iteration 5

Print:

```text
3
```

Calculate:

```text
next = 3 + 5 = 8
```

So:

```text
Output = 0 1 1 2 3
```

### Remember it like this

```text
a     b     next
↓     ↓      ↓
0  +  1  =   1
      ↓     ↓
      a     b

1  +  1  =   2
      ↓     ↓
      1     2

1  +  2  =   3
      ↓     ↓
      2     3
```

**Memory trick:**

> **Print → Add → Shift**

```text
Print a
   ↓
next = a + b
   ↓
a = b
   ↓
b = next
```

---

# 3. Fibonacci using Java 8

Java 8 gives us Streams, so we can write a functional-style solution.

One interview-friendly Java 8 solution is:

```java
import java.util.stream.Stream;

public class FibonacciJava8 {

    public static void main(String[] args) {

        int n = 10;

        Stream.iterate(
                new int[]{0, 1},
                a -> new int[]{a[1], a[0] + a[1]}
        )
        .limit(n)
        .forEach(a -> System.out.print(a[0] + " "));
    }
}
```

Output:

```text
0 1 1 2 3 5 8 13 21 34
```

### How does this work?

We start with:

```text
[0, 1]
```

Then:

```text
[0, 1]
   ↓
[1, 1]
   ↓
[1, 2]
   ↓
[2, 3]
   ↓
[3, 5]
   ↓
[5, 8]
```

The transformation is:

```java
a -> new int[]{a[1], a[0] + a[1]}
```

Meaning:

```text
old = [a, b]

new = [b, a+b]
```

For example:

```text
[0, 1]
 ↓
[1, 0+1]
 ↓
[1, 1]

[1, 1]
 ↓
[1, 1+1]
 ↓
[1, 2]

[1, 2]
 ↓
[2, 1+2]
 ↓
[2, 3]
```

### Interview note

If the interviewer asks:

> "Can you implement Fibonacci in Java 8?"

You can give the normal loop solution first and then say:

> "Since Java 8 supports streams, this can also be expressed using `Stream.iterate()`."

That is usually a better interview approach than immediately using a complicated stream.

---

# 4. Fibonacci using Java 17

For Java 17, the simple loop is still the most readable:

```java
public class FibonacciJava17 {

    public static void main(String[] args) {

        int n = 10;

        int a = 0;
        int b = 1;

        for (int i = 0; i < n; i++) {

            System.out.print(a + " ");

            int next = a + b;
            a = b;
            b = next;
        }
    }
}
```

There is **no need to force a Java 17-specific feature** here.

### Interview principle

> Use the simplest correct solution unless the interviewer specifically asks for a Java 17 feature.

---

# 5. Check whether a number is Prime

## What is a prime number?

A prime number has exactly **two factors**:

```text
1 and itself
```

Examples:

```text
2 → 1, 2       PRIME
3 → 1, 3       PRIME
5 → 1, 5       PRIME
7 → 1, 7       PRIME
```

But:

```text
4 → 1, 2, 4
```

So `4` is not prime.

---

## The basic algorithm

For a number `n`:

```text
Check divisibility from 2 onwards.

If n % i == 0
       ↓
   NOT PRIME

If nothing divides it
       ↓
     PRIME
```

### Better optimization

We only need to check up to:

```text
sqrt(n)
```

Why?

If a number has a factor greater than `sqrt(n)`, it must have a corresponding factor smaller than `sqrt(n)`.

For beginner/interview code, remember:

```text
i * i <= n
```

instead of calculating `Math.sqrt(n)` every time.

---

# 6. Prime — Java 7

```java
public class PrimeJava7 {

    public static void main(String[] args) {

        int n = 29;
        boolean prime = true;

        if (n < 2) {
            prime = false;
        } else {

            for (int i = 2; i * i <= n; i++) {

                if (n % i == 0) {
                    prime = false;
                    break;
                }
            }
        }

        if (prime) {
            System.out.println(n + " is prime");
        } else {
            System.out.println(n + " is not prime");
        }
    }
}
```

Output:

```text
29 is prime
```

---

## Trace with `n = 29`

We check:

```text
i = 2
29 % 2 = 1
```

Not divisible.

Next:

```text
i = 3
29 % 3 = 2
```

Not divisible.

Next:

```text
i = 4
29 % 4 = 1
```

Not divisible.

Now:

```text
i * i <= n
4 * 4 <= 29
16 <= 29
```

Continue.

Next `i = 5`:

```text
5 * 5 <= 29
25 <= 29
```

Check:

```text
29 % 5 = 4
```

Not divisible.

Next:

```text
i = 6

6 * 6 <= 29
36 <= 29 → false
```

Stop.

Therefore:

```text
29 = PRIME
```

### Diagram

```text
29
│
├── % 2 → 1 ❌
├── % 3 → 2 ❌
├── % 4 → 1 ❌
└── % 5 → 4 ❌

No divisor found
       ↓
     PRIME
```

### Memory trick

> **Prime = no divisor from 2 to √n**

---

# 7. Prime — Java 8

We can use an `IntStream`:

```java
import java.util.stream.IntStream;

public class PrimeJava8 {

    public static void main(String[] args) {

        int n = 29;

        boolean prime = n >= 2 &&
                IntStream.rangeClosed(2, (int) Math.sqrt(n))
                         .noneMatch(i -> n % i == 0);

        System.out.println(
                prime ? n + " is prime" : n + " is not prime"
        );
    }
}
```

The important part:

```java
.noneMatch(i -> n % i == 0)
```

means:

> There is **no number** that divides `n` exactly.

For example:

```text
29

2 → 29 % 2 != 0
3 → 29 % 3 != 0
4 → 29 % 4 != 0
5 → 29 % 5 != 0

noneMatch = true
```

Therefore prime.

---

# 8. Prime — Java 17

The same algorithm works perfectly in Java 17:

```java
public class PrimeJava17 {

    public static boolean isPrime(int n) {

        if (n < 2) {
            return false;
        }

        for (int i = 2; i * i <= n; i++) {

            if (n % i == 0) {
                return false;
            }
        }

        return true;
    }

    public static void main(String[] args) {

        int n = 29;

        System.out.println(
                isPrime(n) ? "Prime" : "Not Prime"
        );
    }
}
```

This version is arguably the **best interview answer** because it's short and readable.

---

# 9. Check whether a number is a Perfect Number

## What is a perfect number?

A perfect number is a number whose **proper divisors add up to the number itself**.

Example:

```text
6
```

Its proper divisors are:

```text
1, 2, 3
```

And:

```text
1 + 2 + 3 = 6
```

Therefore:

```text
6 = PERFECT NUMBER
```

Another example:

```text
28
```

Divisors:

```text
1, 2, 4, 7, 14
```

Sum:

```text
1 + 2 + 4 + 7 + 14 = 28
```

Therefore:

```text
28 = PERFECT
```

---

# 10. Perfect Number — Java 7

```java
public class PerfectNumberJava7 {

    public static void main(String[] args) {

        int n = 28;
        int sum = 0;

        for (int i = 1; i <= n / 2; i++) {

            if (n % i == 0) {
                sum += i;
            }
        }

        if (sum == n) {
            System.out.println(n + " is a perfect number");
        } else {
            System.out.println(n + " is not a perfect number");
        }
    }
}
```

### Why `n / 2`?

No proper divisor of `n` can be greater than `n / 2`.

For:

```text
28
```

we only need:

```text
1 → 14
```

---

## Trace: `n = 28`

Start:

```text
sum = 0
```

Check every number from `1` to `14`.

```text
i = 1
28 % 1 = 0
sum = 0 + 1 = 1
```

```text
i = 2
28 % 2 = 0
sum = 1 + 2 = 3
```

```text
i = 3
28 % 3 != 0
```

Nothing happens.

```text
i = 4
28 % 4 = 0
sum = 3 + 4 = 7
```

```text
i = 5 → no
i = 6 → no
```

```text
i = 7
28 % 7 = 0
sum = 7 + 7 = 14
```

```text
i = 8 → no
...
i = 14
28 % 14 = 0
sum = 14 + 14 = 28
```

Finally:

```text
sum = 28
n   = 28

sum == n
   ↓
PERFECT
```

### Diagram

```text
              28
               │
       Find proper divisors
               ↓
       ┌─────────────────┐
       │ 1  2  4  7  14 │
       └─────────────────┘
               │
               ↓
       1 + 2 + 4 + 7 + 14
               │
               ↓
              28
               │
               ↓
            PERFECT
```

### Memory trick

> **Perfect = sum of proper divisors equals number**

---

# 11. Perfect Number — Java 8

Using Java 8 streams:

```java
import java.util.stream.IntStream;

public class PerfectNumberJava8 {

    public static void main(String[] args) {

        int n = 28;

        int sum = IntStream.rangeClosed(1, n / 2)
                           .filter(i -> n % i == 0)
                           .sum();

        if (sum == n) {
            System.out.println(n + " is a perfect number");
        } else {
            System.out.println(n + " is not a perfect number");
        }
    }
}
```

Read this as:

```text
1 → n/2
   ↓
keep divisors
   ↓
add them
   ↓
compare with n
```

The stream:

```java
IntStream.rangeClosed(1, n / 2)
```

produces:

```text
1 2 3 4 ... 14
```

Then:

```java
.filter(i -> n % i == 0)
```

keeps:

```text
1 2 4 7 14
```

Then:

```java
.sum()
```

gives:

```text
28
```

---

# 12. Perfect Number — Java 17

Again, Java 17 doesn't require a different algorithm.

```java
public class PerfectNumberJava17 {

    public static boolean isPerfect(int n) {

        if (n <= 1) {
            return false;
        }

        int sum = 0;

        for (int i = 1; i <= n / 2; i++) {

            if (n % i == 0) {
                sum += i;
            }
        }

        return sum == n;
    }

    public static void main(String[] args) {

        int n = 28;

        System.out.println(
                isPerfect(n)
                        ? "Perfect number"
                        : "Not a perfect number"
        );
    }
}
```

---

# 13. Sum of all Perfect Numbers in a Range

Now suppose the question is:

> Find the sum of all perfect numbers between 1 and 1000.

Known perfect numbers in this range are:

```text
6
28
496
```

Therefore:

```text
6 + 28 + 496 = 530
```

---

## The algorithm

Think of it as **two loops**:

```text
Range
  │
  ↓
Check each number
  │
  ↓
Is it perfect?
  │
  ├── NO → next number
  │
  └── YES
       ↓
    Add to sum
```

Diagram:

```text
1 ─────────────────── 1000
│
├── 1   → perfect? NO
├── 2   → perfect? NO
├── 3   → perfect? NO
│
├── 6   → perfect? YES → sum = 6
│
├── ...
│
├── 28  → perfect? YES → sum = 34
│
├── ...
│
└── 496 → perfect? YES → sum = 530
```

---

# 14. Sum Perfect Numbers — Java 7

```java
public class SumPerfectJava7 {

    public static void main(String[] args) {

        int start = 1;
        int end = 1000;

        int total = 0;

        for (int n = start; n <= end; n++) {

            int sum = 0;

            for (int i = 1; i <= n / 2; i++) {

                if (n % i == 0) {
                    sum += i;
                }
            }

            if (sum == n) {
                System.out.println("Perfect: " + n);
                total += n;
            }
        }

        System.out.println("Total = " + total);
    }
}
```

Output:

```text
Perfect: 6
Perfect: 28
Perfect: 496
Total = 530
```

---

## Trace

For simplicity, imagine range `1 → 30`.

```text
n = 1
sum = 0
1 is not perfect

n = 2
sum = 1
1 != 2

n = 3
sum = 1
1 != 3

...

n = 6
divisors = 1, 2, 3
sum = 6
       ↓
perfect
       ↓
total = 6
```

Continue:

```text
n = 28

divisors:
1 + 2 + 4 + 7 + 14

sum = 28
     ↓
perfect
     ↓
total = 6 + 28
      = 34
```

So for `1 → 30`:

```text
Perfect numbers:
6, 28

Total:
6 + 28 = 34
```

For `1 → 1000`:

```text
6 + 28 + 496
      ↓
     530
```

---

# 15. Sum Perfect Numbers — Java 8

We can first create a reusable method:

```java
import java.util.stream.IntStream;

public class SumPerfectJava8 {

    public static boolean isPerfect(int n) {

        if (n <= 1) {
            return false;
        }

        int sum = IntStream.rangeClosed(1, n / 2)
                           .filter(i -> n % i == 0)
                           .sum();

        return sum == n;
    }

    public static void main(String[] args) {

        int start = 1;
        int end = 1000;

        int total = IntStream.rangeClosed(start, end)
                             .filter(SumPerfectJava8::isPerfect)
                             .sum();

        System.out.println("Total = " + total);
    }
}
```

Output:

```text
Total = 530
```

The important Java 8 line is:

```java
.filter(SumPerfectJava8::isPerfect)
```

Meaning:

> Keep only the numbers for which `isPerfect()` returns `true`.

Then:

```java
.sum()
```

adds them.

Conceptually:

```text
1 → 2 → 3 → 4 → ... → 1000
             │
             ↓
       isPerfect(n)?
             │
       ┌─────┴─────┐
      NO           YES
       │             │
    discard        keep
                     │
                     ↓
                   sum()
```

---

# 16. Sum Perfect Numbers — Java 17

The clean Java 17 version can still use the normal loop:

```java
public class SumPerfectJava17 {

    public static boolean isPerfect(int n) {

        if (n <= 1) {
            return false;
        }

        int sum = 0;

        for (int i = 1; i <= n / 2; i++) {

            if (n % i == 0) {
                sum += i;
            }
        }

        return sum == n;
    }

    public static void main(String[] args) {

        int start = 1;
        int end = 1000;

        int total = 0;

        for (int n = start; n <= end; n++) {

            if (isPerfect(n)) {
                total += n;
            }
        }

        System.out.println("Total = " + total);
    }
}
```

Output:

```text
Total = 530
```

---

# Quick Interview Cheat Sheet

These six questions are connected. Don't memorize six completely different programs.

## 1. Fibonacci

Remember:

```text
PRINT → ADD → SHIFT
```

```java
System.out.print(a);

int next = a + b;
a = b;
b = next;
```

Diagram:

```text
a     b
↓     ↓
0  +  1 = 1
↓     ↓
1  +  1 = 2
↓     ↓
1  +  2 = 3
```

---

## 2. Prime

Remember:

```text
n % i == 0 ?
```

If yes:

```text
NOT PRIME
```

Check only:

```text
2 → √n
```

Code pattern:

```java
for (int i = 2; i * i <= n; i++) {
    if (n % i == 0) {
        return false;
    }
}
return true;
```

---

## 3. Perfect Number

Remember:

```text
Find divisors
     ↓
Add divisors
     ↓
sum == number ?
```

Example:

```text
28
│
├── 1
├── 2
├── 4
├── 7
└── 14
     │
     ↓
1 + 2 + 4 + 7 + 14
     │
     ↓
    28
     │
     ↓
  PERFECT
```

---

## 4. Sum of Perfect Numbers in Range

Remember:

```text
for every number
       ↓
   isPerfect?
       ↓
      YES
       ↓
    total += n
```

---

# Java 7 vs Java 8 vs Java 17

| Problem                  | Java 7       | Java 8                     | Java 17                                    |
| ------------------------ | ------------ | -------------------------- | ------------------------------------------ |
| Fibonacci                | `for` loop   | Loop or `Stream.iterate()` | Loop                                       |
| Prime                    | `for` loop   | `IntStream` possible       | Loop                                       |
| Perfect                  | `for` loop   | `IntStream` possible       | Loop                                       |
| Perfect numbers in range | Nested loops | `IntStream`                | Loops                                      |
| Lambda                   | ❌            | ✅                          | ✅                                          |
| Stream API               | ❌            | ✅                          | ✅                                          |
| Best interview approach  | Simple loops | Know both                  | Simple loops + modern features when useful |

### One important interview lesson

Don't think:

> "Java 17 means I must use streams."

Instead think:

> **Algorithm first, Java version second.**

For these number problems, a simple loop is often the **clearest and safest interview answer**, even in Java 17.

---

# ⭐ The 4 patterns to memorize

If you're preparing for interviews, I'd memorize these four patterns rather than memorizing every program.

### Pattern 1 — Fibonacci

```java
int a = 0;
int b = 1;

for (...) {
    System.out.print(a);

    int next = a + b;
    a = b;
    b = next;
}
```

**Think:** `Print → Add → Shift`

---

### Pattern 2 — Prime

```java
if (n < 2) return false;

for (int i = 2; i * i <= n; i++) {
    if (n % i == 0) {
        return false;
    }
}

return true;
```

**Think:** `Find one divisor → immediately false`

---

### Pattern 3 — Perfect

```java
int sum = 0;

for (int i = 1; i <= n / 2; i++) {
    if (n % i == 0) {
        sum += i;
    }
}

return sum == n;
```

**Think:** `Find divisors → add → compare`

---

### Pattern 4 — Perfect numbers in range

```java
int total = 0;

for (int n = start; n <= end; n++) {

    if (isPerfect(n)) {
        total += n;
    }
}
```

**Think:** `Range → Check → Add`

---

## Final mental map

```text
                 NUMBER PROBLEMS
                       │
          ┌────────────┼────────────┐
          ↓            ↓            ↓
      Fibonacci       Prime      Perfect
          │            │            │
      a + b         n % i        divisors
          │            │            │
       shift       any divisor?   sum them
          │            │            │
       repeat        YES → NO      sum == n
                                    │
                                    ↓
                            Perfect Number
                                    │
                                    ↓
                         Apply to a RANGE
                                    │
                                    ↓
                              total += n
```

If you can remember this **mental map + four code patterns**, you can reconstruct the actual programs during an interview instead of trying to memorize them line by line.
