Write a program to print second highest employee salary using java 8
	List<Integer> list = Arrays.asList(5,6,9,12,18,16);
	list.stream().sorted()
	.limit(2)
	.skip(1)

## **1. Write a program to reverse the charecter of the string and should not change the special charecter place?**
	String input = "abcd@efg#hi"; </br>
	Output string: ihgf@edc#ba </br>

```java
public class Test {

    public static void main(String[] args) {

        String input = "abcd@efg#hi";
        char[] chars = input.toCharArray();

        int left = 0;
        int right = chars.length - 1;

        while (left < right) {

            if (!Character.isLetter(chars[left])) {
                left++;

            } else if (!Character.isLetter(chars[right])) {
                right--;

            } else {
                char temp = chars[left];
                chars[left] = chars[right];
                chars[right] = temp;

                left++;
                right--;
            }
        }

        System.out.println(new String(chars));
    }
}
```

### ✅ Output

```
ihgf@edc#ba
```
</br>

Here’s a **stream-based version** that does the *same thing*:
👉 **reverse only letters, keep special characters in place**.

## ✅ Stream-based solution (Java 8+)

```java
import java.util.*;
import java.util.stream.*;

public class Test {

    public static void main(String[] args) {

        String input = "abcd@efg#hi";

        // Collect letters and reverse them
        List<Character> letters =
                input.chars()
                     .mapToObj(c -> (char) c)
                     .filter(Character::isLetter)
                     .collect(Collectors.toList());

        Collections.reverse(letters);

        // Build result using streams
        String result =
                input.chars()
                     .mapToObj(c -> (char) c)
                     .map(c -> Character.isLetter(c) ? letters.remove(0) : c)
                     .map(String::valueOf)
                     .collect(Collectors.joining());

        System.out.println(result);
    }
}
```

### ✅ Output
```
ihgf@edc#ba
```
---
	
## **2. Print the departmentwise highest salary? using groupingBy or using map**

Exactly! That’s the **core Java 8 version using streams**. I can give you a **complete, runnable Java 8 example** using that exact line. Here it is:

---

```java
import java.util.*;
import java.util.stream.Collectors;

class Employee {
    private String name;
    private String dept;

    public Employee(String name, String dept) {
        this.name = name;
        this.dept = dept;
    }

    public String getName() {
        return name;
    }

    public String getDept() {
        return dept;
    }

    @Override
    public String toString() {
        return name;
    }
}

public class GroupByDept {

    public static void main(String[] args) {

        // Sample employee list
        List<Employee> employees = Arrays.asList(
            new Employee("Alice", "HR"),
            new Employee("Bob", "Finance"),
            new Employee("Charlie", "HR"),
            new Employee("David", "Finance"),
            new Employee("Eve", "IT")
        );

        // Group employees by department using Java 8 Streams
        Map<String, List<Employee>> result =
            employees.stream()
                     .collect(Collectors.groupingBy(Employee::getDept));

        // Print the grouped result
        result.forEach((dept, emps) -> 
            System.out.println(dept + " => " + emps)
        );
    }
}
```

---

### ✅ Output

```
HR => [Alice, Charlie]
Finance => [Bob, David]
IT => [Eve]
```

---

This uses **exactly** the line you mentioned:

```java
employees.stream().collect(Collectors.groupingBy(Employee::getDept));
```

# Java 7 version (without Streams)

```java
import java.util.*;

class Employee {
    private String name;
    private String dept;

    public Employee(String name, String dept) {
        this.name = name;
        this.dept = dept;
    }

    public String getName() {
        return name;
    }

    public String getDept() {
        return dept;
    }

    @Override
    public String toString() {
        return name;
    }
}

public class GroupByDeptJava7 {
    public static void main(String[] args) {
        List<Employee> employees = Arrays.asList(
            new Employee("Alice", "HR"),
            new Employee("Bob", "Finance"),
            new Employee("Charlie", "HR"),
            new Employee("David", "Finance"),
            new Employee("Eve", "IT")
        );

        Map<String, List<Employee>> result = new HashMap<>();

        for (Employee e : employees) {
            String dept = e.getDept();
            if (!result.containsKey(dept)) {
                result.put(dept, new ArrayList<Employee>());
            }
            result.get(dept).add(e);
        }

        // Print result
        for (Map.Entry<String, List<Employee>> entry : result.entrySet()) {
            System.out.println(entry.getKey() + " => " + entry.getValue());
        }
    }
}
```

---

### Output for both:

```
HR => [Alice, Charlie]
Finance => [Bob, David]
IT => [Eve]
```

---



## **3. Explian the features of Java-8?** </br>

# 📘 JAVA 8 FEATURES – NOTES FORMAT

---

## 🔹 Introduction

* Java 8 is a **major release** that introduced **functional programming** concepts.
* Focus: **cleaner code, better performance, multi-core utilization**.
* Widely used in **enterprise & microservice applications**.

---

## 1️⃣ Lambda Expressions

* Anonymous function (no name, no return type, no access modifier).
* Used to implement **functional interfaces**.
* Reduces boilerplate code.

**Syntax:**

```java
(parameters) -> expression
```

**Example:**

```java
() -> System.out.println("Hello");
```

**Advantages:**

* Less code
* Better readability
* Enables functional programming

---

## 2️⃣ Functional Interfaces

* Interface with **exactly one abstract method**.
* Can have multiple **default** and **static** methods.
* Required for lambda expressions.

**Annotation:**

```java
@FunctionalInterface
```

**Common Functional Interfaces:**

* `Predicate<T>` → returns boolean
* `Function<T, R>` → transforms data
* `Consumer<T>` → consumes data
* `Supplier<T>` → supplies data

---

## 3️⃣ Default Methods in Interface

* Interface methods with implementation.
* Introduced for **backward compatibility**.

**Example:**

```java
default void show() {
    System.out.println("Default method");
}
```

---

## 4️⃣ Static Methods in Interface

* Utility methods inside interface.
* Cannot be overridden.

**Example:**

```java
static void print() {
    System.out.println("Static method");
}
```

---

## 5️⃣ Stream API ⭐ (Most Important)

* Used to process collections **functionally**.
* Supports **filtering, mapping, sorting, reducing**.

**Key Characteristics:**

* Lazy evaluation
* Internal iteration
* One-time use

**Example:**

```java
list.stream()
    .filter(n -> n > 10)
    .map(n -> n * 2)
    .forEach(System.out::println);
```

---

## 6️⃣ Intermediate & Terminal Operations

**Intermediate Operations:**

* Return stream
* Lazy
* Examples: `filter()`, `map()`, `sorted()`

**Terminal Operations:**

* Return result
* Trigger execution
* Examples: `forEach()`, `collect()`, `reduce()`

---

## 7️⃣ Method References

* Short-hand for lambda expressions.
* Improves readability.

**Syntax:**

```java
ClassName::methodName
```

**Example:**

```java
System.out::println
```

**Types:**

* Static method reference
* Instance method reference
* Constructor reference

---

## 8️⃣ Optional Class

* Container object to avoid `NullPointerException`.
* Used mainly as **return type**.

**Example:**

```java
Optional<String> name = Optional.ofNullable(str);
```

**Important Methods:**

* `isPresent()`
* `ifPresent()`
* `orElse()`
* `orElseGet()`
* `orElseThrow()`

⚠️ Not recommended as class field or parameter.

---

## 9️⃣ forEach() Method

* Used to iterate over collections.
* Terminal operation.

**Example:**

```java
list.forEach(System.out::println);
```

---

## 🔟 Parallel Streams

* Enables parallel processing using **ForkJoinPool**.
* Suitable for **large, CPU-bound tasks**.

**Example:**

```java
list.parallelStream().forEach(System.out::println);
```

⚠️ Avoid for:

* Small datasets
* IO operations
* Stateful logic

---

## 1️⃣1️⃣ Collectors API

* Used with `collect()` to convert stream results.

**Common Collectors:**

* `toList()`
* `toSet()`
* `groupingBy()`
* `partitioningBy()`
* `joining()`

**Example:**

```java
Collectors.groupingBy(Employee::getDept)
```

---

## 1️⃣2️⃣ New Date & Time API (`java.time`)

* Immutable and thread-safe.
* Replaces old `Date` and `Calendar`.

**Important Classes:**

* `LocalDate`
* `LocalTime`
* `LocalDateTime`
* `ZonedDateTime`
* `Period`, `Duration`

**Example:**

```java
LocalDate.now();
```

---

## 1️⃣3️⃣ CompletableFuture

* Supports **asynchronous, non-blocking programming**.
* Better than traditional `Future`.

**Example:**

```java
CompletableFuture
    .supplyAsync(() -> getData())
    .thenAccept(System.out::println);
```

---

## 1️⃣4️⃣ Nashorn JavaScript Engine

* Allows execution of JavaScript inside Java.
* Deprecated in later Java versions.

---

## 🔹 Advantages of Java 8

* Cleaner & concise code
* Functional programming support
* Better performance
* Parallel processing support
* Safer null handling
* Modern Date-Time API

---

## 🔹 One-Line Interview Summary

> *Java 8 introduced functional programming features like lambda expressions, streams, optional, and a new date-time API, making Java code more readable, efficient, and scalable.*

---

## **4. Why we use static method in Functional Inteface?** </br?

## 🔹 Short Answer (Interview Line)

> Static methods in a functional interface are used to provide **utility/helper methods** related to the interface **without affecting the functional nature** of the interface.

---

## 🔹 Detailed Explanation

### 1️⃣ They **do NOT break** functional interface rule

* Functional interface rule: **only one abstract method**
* Static methods are **not abstract**
* So, we can add **any number of static methods** safely

---

### 2️⃣ Provide **Utility / Helper Methods**

* Used to place common logic related to the interface
* Keeps code **organized and cohesive**

📌 Similar to utility classes, but grouped with the interface.

---

### 3️⃣ No Object Creation Needed

* Static methods belong to the **interface itself**
* Called using interface name
* Saves memory and improves clarity

---

### 4️⃣ Cannot Be Overridden

* Static methods are **not inherited**
* Ensures consistent behavior across implementations

---

### 5️⃣ Helps in Code Reusability

* Shared logic across all implementations
* Avoids duplication

---

## 🔹 Example

```java
@FunctionalInterface
interface Calculator {

    int add(int a, int b);   // single abstract method

    static int multiply(int a, int b) {
        return a * b;
    }
}
```

### Usage:

```java
Calculator calc = (a, b) -> a + b;

System.out.println(calc.add(2, 3));               // 5
System.out.println(Calculator.multiply(2, 3));   // 6
```

---

## 🔹 Why not make it default instead?

| Default Method    | Static Method        |
| ----------------- | -------------------- |
| Can be overridden | Cannot be overridden |
| Requires object   | No object required   |
| Instance-level    | Interface-level      |

👉 **Static method** is preferred when:

* Logic is common
* Should not be overridden
* Does not depend on instance state

---

## 🔹 Real-World Example (Java API)

```java
Comparator<Integer> comp = Comparator.naturalOrder();
```

`naturalOrder()` is a **static method** inside `Comparator` interface.

---

## 🔹 When to Use Static Methods in Functional Interfaces

✔ Utility logic
✔ Factory methods
✔ Validation helpers
✔ Common algorithms
✔ Conversion logic

---

## 🔹 One-Line Interview Answer ⭐

> *Static methods in functional interfaces are used to provide utility or helper methods related to the interface without violating the single abstract method rule.*

---

## **5. What is Optional class in java-8?** </br>
## 🔹 Definition

`Optional` is a **container object** introduced in Java-8 that may or may not contain a **non-null value**.
It is used to **avoid `NullPointerException`** and make the absence of a value explicit.

📦 Package: `java.util`

---

## 🔹 Why Optional was introduced?

Before Java-8:

* Methods returned `null`
* Developers forgot to check null
* Result → `NullPointerException`

Java-8 solution:

* Return `Optional<T>` instead of `T`
* Forces the caller to **handle absence safely**

---

## 🔹 Simple Example

```java
Optional<String> name = Optional.ofNullable(getName());
```

Instead of:

```java
String name = getName(); // may cause NPE
```

---

## 🔹 How Optional works

* If value exists → Optional contains it
* If value is absent → Optional is empty
* No direct `null` access

---

## 🔹 Creating Optional Objects

### 1️⃣ `Optional.of()`

```java
Optional<String> opt = Optional.of("Java");
```

⚠️ Throws `NullPointerException` if value is null

---

### 2️⃣ `Optional.ofNullable()`

```java
Optional<String> opt = Optional.ofNullable(null);
```

✔ Safe for null values

---

### 3️⃣ `Optional.empty()`

```java
Optional<String> opt = Optional.empty();
```

---

## 🔹 Important Methods of Optional

| Method          | Purpose                                    |
| --------------- | ------------------------------------------ |
| `isPresent()`   | Checks if value exists                     |
| `ifPresent()`   | Executes logic if value exists             |
| `get()`         | Gets value (not recommended without check) |
| `orElse()`      | Returns default value                      |
| `orElseGet()`   | Lazy default value                         |
| `orElseThrow()` | Throws exception if empty                  |

---

## 🔹 Example Usage

```java
Optional<String> name = Optional.ofNullable(getName());

String result = name.orElse("Default Name");
```

---

## 🔹 `orElse()` vs `orElseGet()`

| orElse()        | orElseGet()            |
| --------------- | ---------------------- |
| Always executed | Executed only if empty |
| Less efficient  | More efficient         |

---

## 🔹 Best Practices

✔ Use Optional as **return type**
✔ Use `orElseGet()` for expensive operations
❌ Do NOT use Optional for fields
❌ Do NOT use Optional for method parameters

---

## 🔹 Common Interview Questions

### ❓ Why Optional should not be used as a field?

* Not Serializable
* Breaks JavaBean conventions
* Adds unnecessary complexity

---

### ❓ Does Optional eliminate NullPointerException completely?

❌ No
✔ It reduces the chances if used properly

---

## 🔹 Real-World Java API Example

```java
Optional<T> findById(ID id); // Spring Data JPA
```

---

## 🔹 Advantages of Optional

* Prevents NullPointerException
* Improves code readability
* Forces null handling
* Better API design

---

## 🔹 One-Line Interview Answer ⭐

> *Optional is a container object introduced in Java-8 to represent the presence or absence of a value and to avoid NullPointerException by enforcing explicit null handling.*

---

## **6. What is the difference between Optional class methods?** </br>
```
	get();                 // returns value (throws exception if empty)
	orElse(defaultValue);  // returns value or default
	orElseGet(() -> val);  // lazy default
	orElseThrow();         // throws NoSuchElementException
	orElseThrow(() -> ex); // custom exception
```

---
## **7. What is the difference between HashMap and ConcurrentHashMap, and when should each be used?** </br>

## 🔹 HashMap

### What is it?

* Part of `java.util`
* **Not thread-safe**
* Allows **one null key** and **multiple null values**

### Characteristics

* Faster in **single-threaded** environment
* No synchronization
* Can cause **data inconsistency** in multi-threaded use

---

## 🔹 ConcurrentHashMap

### What is it?

* Part of `java.util.concurrent`
* **Thread-safe**
* Designed for **high concurrency**

### Characteristics

* No null keys or null values allowed
* Allows **concurrent read and write**
* Uses internal locking (bucket-level / CAS)
* High performance in multi-threaded apps

---

## 🔹 Key Differences (Interview Table)

| Feature                 | HashMap                | ConcurrentHashMap       |
| ----------------------- | ---------------------- | ----------------------- |
| Thread Safety           | ❌ No                   | ✅ Yes                   |
| Synchronization         | None                   | Internal (fine-grained) |
| Performance             | Faster (single-thread) | Faster (multi-thread)   |
| Null Keys               | 1 allowed              | ❌ Not allowed           |
| Null Values             | Allowed                | ❌ Not allowed           |
| Concurrent Modification | ❌ Fail-fast            | ❌ No exception          |
| Iterator                | Fail-fast              | Weakly consistent       |
| Use in Streams          | Risky                  | Safe                    |

---

## 🔹 Internal Working (Important for Interviews)

### HashMap

* Uses array + linked list / tree
* No synchronization
* Multiple threads may corrupt data

---

### ConcurrentHashMap

* Java 8 uses:

  * **CAS (Compare-And-Swap)**
  * **Synchronized blocks at bucket level**
* Allows multiple threads to read/write safely

---

## 🔹 Example

### ❌ HashMap (Multi-threaded – Risky)

```java
Map<Integer, String> map = new HashMap<>();
```

---

### ✅ ConcurrentHashMap (Thread-safe)

```java
Map<Integer, String> map = new ConcurrentHashMap<>();
```

---

## 🔹 Iteration Behavior

### HashMap

* Throws `ConcurrentModificationException`
* Fail-fast iterator

### ConcurrentHashMap

* No exception during modification
* Weakly consistent iterator

---

## 🔹 When to Use HashMap?

✔ Single-threaded applications
✔ No concurrency
✔ Faster access
✔ Allows null keys/values

---

## 🔹 When to Use ConcurrentHashMap?

✔ Multi-threaded applications
✔ High concurrency
✔ Data consistency required
✔ No null keys/values needed

---

## 🔹 Interview One-Liner ⭐

> *Use HashMap in single-threaded environments for better performance, and use ConcurrentHashMap in multi-threaded environments where thread safety and high concurrency are required.*

---

## 🔹 Follow-up Questions Interviewers May Ask

* Why does ConcurrentHashMap not allow null?
* How does ConcurrentHashMap achieve thread safety?
* Difference between `Collections.synchronizedMap()` and `ConcurrentHashMap`?

  </br>

# 1️⃣ Why does **ConcurrentHashMap not allow null**?

### 🔹 Short Answer (Interview Line)

> ConcurrentHashMap does not allow null keys or values to **avoid ambiguity and ensure thread-safe operations**.

---

### 🔹 Detailed Explanation

In a **multi-threaded environment**, `null` creates **confusion**:

### ❓ If `map.get(key)` returns `null`, what does it mean?

* Key is **not present** ❓
* Key is present but value is **null** ❓

👉 In concurrent systems, this ambiguity leads to **incorrect behavior**.

---

### 🔹 Thread Safety Reason

* ConcurrentHashMap uses **non-blocking algorithms (CAS)**.
* Allowing null would require extra checks → **performance hit**.
* To keep operations **lock-free & efficient**, nulls are disallowed.

---

### 🔹 Comparison

| Map Type          | Null Key | Null Value |
| ----------------- | -------- | ---------- |
| HashMap           | ✅        | ✅          |
| ConcurrentHashMap | ❌        | ❌          |

---

# 2️⃣ How does **ConcurrentHashMap achieve thread safety**?

### 🔹 Java 8 Internal Working (Very Important)

ConcurrentHashMap uses:

### ✅ **1. CAS (Compare-And-Swap)**

* Lock-free technique
* Used for inserting/updating entries
* Ensures atomic updates

---

### ✅ **2. Fine-Grained Synchronization**

* Synchronization happens at **bucket level**, not whole map
* Multiple threads can modify **different buckets simultaneously**

---

### ✅ **3. Volatile Variables**

* Ensures visibility of changes across threads

---

### 🔹 Before Java 8 (Old Approach)

* Segment-based locking
* One lock per segment

---

### 🔹 Java 8 Improvement

* No segmentation
* Uses:

  * CAS
  * `synchronized` blocks on buckets
  * Better performance & scalability

---

### 🔹 Result

✔ Thread-safe
✔ High performance
✔ Low contention
✔ Scalable

---

# 3️⃣ Difference between `Collections.synchronizedMap()` and `ConcurrentHashMap`

### 🔹 Overview

Both provide **thread safety**, but **work very differently**.

---

## 🔥 Key Differences (Interview Table)

| Feature           | synchronizedMap() | ConcurrentHashMap |
| ----------------- | ----------------- | ----------------- |
| Thread Safety     | ✅ Yes             | ✅ Yes             |
| Locking           | Whole map         | Bucket-level      |
| Performance       | Slower            | Faster            |
| Concurrent Access | ❌ Limited         | ✅ High            |
| Iterator          | Fail-fast         | Weakly consistent |
| Null Key          | ✅ Allowed         | ❌ Not allowed     |
| Null Value        | ✅ Allowed         | ❌ Not allowed     |
| Blocking          | High              | Low               |

---

### 🔹 synchronizedMap()

```java
Map<Integer, String> map =
    Collections.synchronizedMap(new HashMap<>());
```

* Uses **single lock**
* Only one thread can access map at a time
* High contention in multi-threaded systems

---

### 🔹 ConcurrentHashMap

```java
Map<Integer, String> map = new ConcurrentHashMap<>();
```

* Multiple threads can read/write simultaneously
* Best for **high-concurrency applications**

---

# 🔹 When to Use What?

### ✅ Use `synchronizedMap()` when:

* Low concurrency
* Legacy code
* Simple synchronization needed

---

### ✅ Use `ConcurrentHashMap` when:

* High concurrency
* Performance is critical
* Real-time applications
* Microservices, caching, counters

---

# ⭐ One-Line Interview Summary

> *ConcurrentHashMap avoids null to prevent ambiguity in concurrent access, achieves thread safety using CAS and fine-grained locking, and outperforms synchronizedMap by allowing high concurrent access with minimal blocking.*

---
## **9. What is the difference between LinkedHashMap and WeakHashMap, and when should each be used?** </br>
Great question — this one **tests both Collections knowledge and JVM understanding** 👍
Here’s a **clean, interview-ready explanation** with *what + differences + when to use*.

---

# Difference between **LinkedHashMap** and **WeakHashMap**

---

## 🔹 LinkedHashMap

### What is it?

* Subclass of `HashMap`
* Maintains **order of elements**
* Order can be:

  * **Insertion order**
  * **Access order**

### Key Features

* Predictable iteration order
* Slightly slower than HashMap (extra links)
* Allows **one null key** and **multiple null values**
* Not thread-safe

### Internal Structure

* Hash table + **Doubly Linked List**

---

### Example

```java
Map<Integer, String> map = new LinkedHashMap<>();
map.put(1, "A");
map.put(2, "B");
map.put(3, "C");
```

Iteration order: `1 → 2 → 3`

---

### Access Order Example (LRU Cache)

```java
Map<Integer, String> map =
    new LinkedHashMap<>(16, 0.75f, true);
```

---

## 🔹 WeakHashMap

### What is it?

* Map implementation where **keys are weakly referenced**
* Entries are automatically removed when keys are **garbage collected**

### Key Features

* Uses **Weak References**
* Helps prevent **memory leaks**
* Allows **one null key** and **multiple null values**
* Not thread-safe

---

### Example

```java
Map<Object, String> map = new WeakHashMap<>();

Object key = new Object();
map.put(key, "value");

key = null;
System.gc();  // Entry may be removed
```

---

## 🔹 Key Differences (Interview Table)

| Feature                | LinkedHashMap        | WeakHashMap            |
| ---------------------- | -------------------- | ---------------------- |
| Order                  | Maintains order      | No order               |
| Key Reference          | Strong reference     | Weak reference         |
| Garbage Collection     | Keys not GC’d        | Keys can be GC’d       |
| Memory Leak Prevention | ❌ No                 | ✅ Yes                  |
| Use Case               | Ordered data / Cache | Memory-sensitive cache |
| Null Keys              | 1 allowed            | 1 allowed              |
| Null Values            | Allowed              | Allowed                |
| Thread Safe            | ❌ No                 | ❌ No                   |

---

## 🔹 When to Use LinkedHashMap?

✔ When **order matters**
✔ When insertion/access order is needed
✔ Implementing **LRU Cache**
✔ Predictable iteration required

---

## 🔹 When to Use WeakHashMap?

✔ When keys should be **auto-removed**
✔ To prevent **memory leaks**
✔ For **caches, metadata storage**
✔ Temporary mappings tied to object lifecycle

---

## 🔹 Real-World Examples

### 🔹 LinkedHashMap

* LRU cache implementation
* Maintaining order in UI data
* Request history tracking

---

### 🔹 WeakHashMap

* Caching class loaders
* Listener registration
* Metadata associated with objects

---

## ⭐ Interview One-Liner

> *LinkedHashMap maintains predictable iteration order, while WeakHashMap allows keys to be garbage collected, making it suitable for memory-sensitive caching.*


## 🔥 Common Follow-up Interview Questions

* Why is WeakHashMap preferred over HashMap in caches?
* How does access order work in LinkedHashMap?
* Can WeakHashMap entries disappear automatically?

---
## **10. Have you ever faced collision, and how will you fix it?** </br> 

## 1️⃣ What is a **collision**?

A **collision occurs in a hash-based collection** (like `HashMap`) when **two keys produce the same hash code** and get mapped to the **same bucket**.

* Every key in a `HashMap` is hashed using `key.hashCode() % capacity`.
* If two keys have the same hash, they collide in the same bucket.

---

### Example

```java
Map<Integer, String> map = new HashMap<>();

map.put(1, "A");
map.put(17, "B"); // Suppose HashMap capacity is 16, 1 % 16 = 1 and 17 % 16 = 1
```

* Both keys 1 and 17 go to the **same bucket** → collision.

---

## 2️⃣ How **HashMap handles collisions**

### Java 8 Mechanism

1. **Chaining** (Linked List)

   * Each bucket holds a linked list of entries with same hash.
2. **Treeify** (Red-Black Tree)

   * If a bucket’s linked list grows beyond **8 entries**, it converts into a **balanced tree**.
   * Improves lookup time from **O(n)** to **O(log n)**.

---

### Bucket Example

```
Bucket 1:
[Key=1, Value=A] -> [Key=17, Value=B] -> [Key=33, Value=C]
```

* Before treeify → linked list
* After 8 entries → tree

---

## 3️⃣ How **to fix collisions** / Avoid them

### ✅ 1. Good hash function

* Override `hashCode()` properly for custom objects.
* Example:

```java
@Override
public int hashCode() {
    return Objects.hash(id, name);
}
```

### ✅ 2. Use `equals()` correctly

* Two keys with same hash should be compared with `equals()` to distinguish them.

### ✅ 3. Adjust **initial capacity & load factor**

* Default HashMap: 16 buckets, 0.75 load factor
* If collisions are frequent, **increase initial capacity**.

```java
Map<Integer, String> map = new HashMap<>(32, 0.75f);
```

### ✅ 4. Java 8 Treeify

* Let HashMap automatically convert long chains into a **balanced tree** (handled internally).

---

## 4️⃣ Interview Tips / Answers

### Example Interview Answer

> “Yes, collisions occur in hash-based data structures when two keys have the same hash code. In Java 8 HashMap, collisions are handled using **chaining** with linked lists, and when a bucket has more than 8 entries, it’s converted to a **Red-Black tree** to improve performance.
> To avoid collisions, we can implement a **good hashCode()**, properly override `equals()`, and tune the HashMap’s **initial capacity and load factor**.”

---

## 5️⃣ Bonus Notes

* **HashMap**: Handles collisions internally, no need for manual fixing.
* **ConcurrentHashMap**: Uses segment-level or bucket-level locks; collision handling is similar.
* **TreeMap**: Uses **natural ordering or comparator**; no hash function, so collision does not exist.

---

## **11. What is the difference between @Lazy and @Eager, when should each be used?** </br>
# Difference between **@Lazy** and **@Eager**

> ⚠️ Important first note (interview trap):

* Spring has **`@Lazy` annotation**
* Spring does **NOT** have an `@Eager` annotation
  👉 *Eager loading is the **default behavior***

So when interviewers say **@Eager**, they really mean **eager initialization (default)**.

---

## 1️⃣ **@Lazy**

### What is `@Lazy`?

* Tells Spring to **delay bean creation**
* Bean is created **only when it is first requested**

### Example

```java
@Component
@Lazy
public class EmailService {
    public EmailService() {
        System.out.println("EmailService initialized");
    }
}
```

* Bean is **NOT created at application startup**
* Created only when injected or accessed

---

### `@Lazy` on Injection

```java
@Autowired
@Lazy
private EmailService emailService;
```

* Bean loads only when used

---

## 2️⃣ **Eager Initialization (Default)**

### What is Eager Loading?

* Bean is created **during application startup**
* Default behavior for all Spring beans

### Example

```java
@Component
public class PaymentService {
    public PaymentService() {
        System.out.println("PaymentService initialized");
    }
}
```

* Bean loads **as soon as Spring context starts**

---

## 3️⃣ Key Differences (Interview Table)

| Feature           | @Lazy                | Eager (Default)        |
| ----------------- | -------------------- | ---------------------- |
| Bean Creation     | On first use         | On application startup |
| Startup Time      | Faster               | Slower                 |
| Memory Usage      | Lower initially      | Higher                 |
| First Access Time | Slight delay         | No delay               |
| Default           | ❌ No                 | ✅ Yes                  |
| Use Case          | Heavy/optional beans | Core beans             |

---

## 4️⃣ When Should You Use **@Lazy**?

✔ Heavy objects (DB connections, report generators)
✔ Optional or rarely used beans
✔ Improve application startup time
✔ Break **circular dependencies**
✔ Microservices with faster boot requirement

---

## 5️⃣ When Should You Use **Eager Initialization**?

✔ Core business services
✔ Beans required at startup
✔ Fail-fast (detect errors early)
✔ Performance-critical first request

---

## 6️⃣ Real Interview Scenarios

### Scenario 1: **Microservice Startup Optimization**

* Use `@Lazy` for:

  * Email services
  * External API clients
* Keep core services eager

---

### Scenario 2: **Circular Dependency Fix**

```java
@Component
public class A {
    @Autowired
    @Lazy
    private B b;
}
```

* Prevents circular dependency exception

---

### Scenario 3: **Fail-Fast Requirement**

* Payment, Security, Auth services → eager
* Fail application startup if misconfigured

---

## 7️⃣ Common Interview Follow-ups

### Q: Does `@Lazy` make bean thread-unsafe?

❌ No, Spring still manages singleton safely.

---

### Q: Can we use `@Lazy` at configuration level?

✅ Yes

```java
@Configuration
@Lazy
public class AppConfig {}
```

---

## ⭐ One-Line Interview Answer

> *@Lazy delays bean creation until it’s needed, improving startup time and resource usage, while eager initialization (default) creates beans at application startup to ensure readiness and fail-fast behavior.*

---

If you want next:

* 🔥 `@Lazy vs Prototype`
* 🧠 Spring bean lifecycle diagram
* 🎯 Microservices startup optimization checklist
* ⚔ `@PostConstruct vs @Lazy`

Love this combo 😄 — this is **exactly Spring interview gold**.
I’ll cover **all 4 topics**, clean, crisp, and **notes-style** so you can revise fast.

---

# 🔥 1️⃣ `@Lazy` vs `@Prototype`

> ⚠️ These solve **different problems** — interviewers check if you mix them up.

---

## 🔹 `@Lazy`

### Purpose

* Controls **WHEN** a bean is created

### Key Points

* Bean created **only when first requested**
* Default scope = `singleton`
* Helps reduce startup time

```java
@Component
@Lazy
public class ReportService {}
```

---

## 🔹 `@Prototype`

### Purpose

* Controls **HOW MANY instances** are created

### Key Points

* New instance created **every time**
* Bean created immediately when requested
* Spring does NOT manage full lifecycle

```java
@Component
@Scope("prototype")
public class Task {}
```

---

## 🔥 Comparison Table

| Feature           | @Lazy               | @Prototype       |
| ----------------- | ------------------- | ---------------- |
| Controls          | Initialization time | Instance count   |
| Bean Instances    | One                 | Multiple         |
| Startup Load      | Delayed             | Immediate        |
| Lifecycle Managed | Yes                 | Partial          |
| Use Case          | Heavy beans         | Stateful objects |

---

## ⭐ Interview Line

> *@Lazy controls bean creation time, while @Prototype controls the number of bean instances.*

---

# 🧠 2️⃣ Spring Bean Lifecycle (Diagram + Steps)

```
Spring Container Start
        |
Instantiate Bean
        |
Populate Properties (@Autowired)
        |
Aware Interfaces (BeanNameAware, etc.)
        |
BeanPostProcessor (before init)
        |
@PostConstruct
        |
InitializingBean.afterPropertiesSet()
        |
BeanPostProcessor (after init)
        |
Bean Ready to Use
        |
@PreDestroy
        |
Destroy Bean
```

---

## 🔹 Key Notes

* `@PostConstruct` → runs **after dependency injection**
* `@PreDestroy` → runs **before bean destruction**
* Prototype beans do NOT get destroy callbacks

---

# 🎯 3️⃣ Microservices Startup Optimization Checklist

### ✅ Use `@Lazy` wisely

* Email, Notification, Report services
* External API clients

---

### ✅ Avoid heavy startup logic

❌ Long DB calls in constructors
❌ Blocking network calls in `@PostConstruct`

---

### ✅ Async initialization

```java
@Async
@PostConstruct
public void init() {}
```

---

### ✅ Reduce component scanning

```java
@ComponentScan("com.app.service")
```

---

### ✅ External Config Optimization

* Use config server caching
* Avoid slow property resolution

---

### ✅ JVM Optimizations

* Container-aware JVM flags
* Right heap size

---

## ⭐ Interview Line

> *Startup optimization in microservices focuses on lazy loading, async initialization, minimal scanning, and avoiding blocking operations at startup.*

---

# ⚔ 4️⃣ `@PostConstruct` vs `@Lazy`

> ⚠️ Very common confusion — answer carefully.

---

## 🔹 `@PostConstruct`

### What it does

* Runs **after bean creation**
* Executes initialization logic

```java
@PostConstruct
public void init() {
    loadCache();
}
```

---

## 🔹 `@Lazy`

### What it does

* Delays **bean creation itself**

```java
@Lazy
@Component
public class CacheService {}
```

---

## 🔥 Comparison Table

| Feature        | @PostConstruct      | @Lazy            |
| -------------- | ------------------- | ---------------- |
| Purpose        | Init logic          | Delay creation   |
| Execution Time | After bean creation | Before creation  |
| Startup Impact | Slower              | Faster           |
| Controls       | Behavior            | Lifecycle timing |

---

## ⭐ Interview Line

> *@PostConstruct runs initialization logic after bean creation, whereas @Lazy delays the creation of the bean itself.*

---

# 🔥 Final Rapid-Fire Interview Summary

* `@Lazy` → when to create
* `@Prototype` → how many instances
* `@PostConstruct` → what to run after creation
* Microservices startup → lazy + async + minimal scanning

---


## **12. What is @Autowired when we use @Autowired and Constructor injection, which one is better?** </br>

# 1️⃣ What is `@Autowired`?

### Definition

`@Autowired` is a Spring annotation used for **dependency injection**.
It tells Spring:

> “Inject the required bean automatically.”

---

### Example (Field Injection)

```java
@Component
public class OrderService {

    @Autowired
    private PaymentService paymentService;
}
```

Spring finds a `PaymentService` bean and injects it.

---

## Ways to Use `@Autowired`

### 🔹 1. Field Injection

```java
@Autowired
private UserService userService;
```

### 🔹 2. Setter Injection

```java
@Autowired
public void setUserService(UserService userService) {
    this.userService = userService;
}
```

### 🔹 3. Constructor Injection

```java
@Component
public class OrderService {

    private final PaymentService paymentService;

    @Autowired
    public OrderService(PaymentService paymentService) {
        this.paymentService = paymentService;
    }
}
```

---

# 2️⃣ What is Constructor Injection?

### Definition

Dependencies are provided through the **constructor**.

> Since Spring 4.3+, **`@Autowired` is optional** if there is **only one constructor**.

---

### Modern Best Practice

```java
@Component
public class OrderService {

    private final PaymentService paymentService;

    public OrderService(PaymentService paymentService) {
        this.paymentService = paymentService;
    }
}
```

---

# 3️⃣ When Should We Use `@Autowired`?

✔ When Spring needs to inject dependencies automatically
✔ For setter injection (optional dependencies)
✔ For legacy code

---

# 4️⃣ Constructor Injection vs `@Autowired` (Field Injection)

### 🔥 Interview Comparison Table

| Feature             | Field Injection (@Autowired) | Constructor Injection |
| ------------------- | ---------------------------- | --------------------- |
| Immutability        | ❌ No                         | ✅ Yes (`final`)       |
| Testability         | ❌ Harder                     | ✅ Easier              |
| Null Safety         | ❌ Possible                   | ✅ Guaranteed          |
| Readability         | ❌ Hidden dependencies        | ✅ Explicit            |
| Circular Dependency | ❌ Runtime error              | ✅ Detected early      |
| Recommended         | ❌ No                         | ✅ Yes                 |

---

# 5️⃣ Which One is Better? ⭐ (Important!)

### ✅ **Constructor Injection is BETTER**

### Why?

1. Makes dependencies **mandatory**
2. Enables **immutable objects**
3. Easier unit testing (no Spring context needed)
4. Catches circular dependencies early
5. Cleaner, more maintainable code

---

## ⭐ Interview One-Liner

> *Constructor injection is preferred over @Autowired field injection because it ensures immutability, better testability, and makes dependencies explicit.*

---

# 6️⃣ When Field Injection (`@Autowired`) is Acceptable?

✔ Small demo projects
✔ Legacy applications
✔ Quick prototypes

But **not recommended for production code**.

---

# 7️⃣ Common Follow-up Interview Questions

### Q: Can constructor injection cause circular dependency?

❌ No — it **fails fast** and exposes the problem early.

---

### Q: Can we use both?

⚠️ Technically yes, but **bad practice**.

---

### Q: What if multiple beans exist?

Use:

```java
@Qualifier("paypalPayment")
```

---

# 🔥 Final Summary (Memorize This)

* `@Autowired` injects dependencies
* Constructor injection is best practice
* Field injection hides dependencies
* Spring recommends constructor injection

---

## **13. What is the difference between @Transaction annotaion on class level and method level?** </br>
Excellent question — this is **very common in Spring + JPA interviews** and many people answer it *partially*.
Here’s the **complete, interview-ready explanation** 👇

---

# Difference between `@Transactional` at **Class Level** vs **Method Level**

---

## 1️⃣ What is `@Transactional`?

### Definition

`@Transactional` is a Spring annotation that:

* Defines **transaction boundaries**
* Automatically handles:

  * `BEGIN`
  * `COMMIT`
  * `ROLLBACK`

---

## 2️⃣ `@Transactional` at **Class Level**

### What it means

* Applies **to all public methods** of the class
* Each method runs inside a transaction **by default**

### Example

```java
@Service
@Transactional
public class OrderService {

    public void placeOrder() { }

    public void cancelOrder() { }
}
```

✔ Both methods are transactional
✔ Less boilerplate
❌ Less fine-grained control

---

## 3️⃣ `@Transactional` at **Method Level**

### What it means

* Applies **only to that specific method**
* Overrides class-level transaction settings

### Example

```java
@Service
public class OrderService {

    @Transactional
    public void placeOrder() { }

    public void viewOrder() { }
}
```

✔ Only `placeOrder()` is transactional
✔ More control and clarity

---

## 4️⃣ Priority Rule (Very Important ⚠️)

> **Method-level `@Transactional` overrides class-level `@Transactional`**

### Example

```java
@Service
@Transactional(readOnly = true)
public class UserService {

    @Transactional(readOnly = false)
    public void saveUser() { }
}
```

✔ `saveUser()` is **read-write**
✔ Other methods remain **read-only**

---

## 5️⃣ Key Differences (Interview Table)

| Feature     | Class Level              | Method Level      |
| ----------- | ------------------------ | ----------------- |
| Scope       | All public methods       | Single method     |
| Control     | Broad                    | Fine-grained      |
| Override    | ❌ Cannot override method | ✅ Overrides class |
| Readability | Less explicit            | More explicit     |
| Flexibility | Limited                  | High              |

---

## 6️⃣ When to Use **Class Level**?

✔ All methods require transactions
✔ Same transaction behavior for all methods
✔ Cleaner code, less repetition

---

## 7️⃣ When to Use **Method Level**? ⭐

✔ Different methods need different settings
✔ Some methods are read-only
✔ Performance tuning (`readOnly = true`)
✔ Clear transaction intent

👉 **Method-level is generally preferred in real projects**

---

## 8️⃣ Common Interview Traps ⚠️

### ❌ Private methods

`@Transactional` **does NOT work** on private methods
(Spring uses proxies)

---

### ❌ Self-invocation

```java
this.save(); // Transaction will NOT start
```

---

### ❌ Checked exceptions

* Default rollback only for `RuntimeException`
* Use:

```java
@Transactional(rollbackFor = Exception.class)
```

---

## ⭐ Interview One-Liner (Must Remember)

> *Class-level @Transactional applies the same transaction to all public methods, while method-level @Transactional provides fine-grained control and overrides class-level settings.*

---

## 🔥 Real-World Best Practice

* Use **class-level** for default behavior
* Use **method-level** to override when needed

---

What is intermediate and terminal operator in java-8?
Can we use immutable object as a key in Map?
How do you identify this is Singleton patter?
How do you detect memory leaks?


MultiTreading?
What is the difference between ExecutorService and CompletableFuture class?




How will you design HA & FT architecture in aws?
In the EKS if the microservice is down then how will you dubug this?
What is Nod Scaling and pod scaling?
Explian how you build CICD pipeline?
I need to desing the user transaction microservice to publish the messages to kafka, what are the components required to build this service?
if you get microservice out of memory error then how will you debug it, what are the steps you follow to find rhe root cause? (in EKS)?
How do you scale the microservice?
What all the metrics you can see in grafana?

If the KAFKA consumer is lagging to consume the message, then what could be the reason?
Can Kafka be used as a synchronous service?
	Is it possible to use Kafka in a synchronous communication model?
	Can Kafka support synchronous request–response communication?
	Can Kafka be used to implement synchronous request–response behavior?
	Is Kafka suitable for synchronous service-to-service communication?
**	Why is Kafka considered asynchronous, and can it be used to achieve synchronous behavior?


SQL:
What is index and when you use it?
Why we use indexing?
Is there any performance issue if you use indexing?
How indexing works?
What is Normalizaton and DeNormalization?
What is the difference between Where and Having?
