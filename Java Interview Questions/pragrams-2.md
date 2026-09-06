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
