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
Got it 👍
Below are **clean, exam/interview-ready NOTES** you can **directly copy into your notebook**.
Concise • Structured • Easy to revise.

---

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

Why we use static method in Functional Inteface?
What is Optional class in java-8?
What is the difference between Optional class methods?
	orElse(defaultValue);  // returns value or default
	orElseGet(() -> val);  // lazy default
	
	get();                 // returns value (throws exception if empty)
	orElse(defaultValue);  // returns value or default
	orElseGet(() -> val);  // lazy default
	orElseThrow();         // throws NoSuchElementException
	orElseThrow(() -> ex); // custom exception

What is the difference between HashMap and ConcurrentHashMap, and when should each be used?
What is the difference between LinkedHashMap and WeakHashMap, and when should each be used?
Have you ever faced collision, and how will you fix it? 
What is the difference between @Lazy and @Eager, when should each be used?
What is @Autowiring when we use @Autowiring and Constructor injection, which one is better?
What is the difference between @Transaction annotaion on class level and method level?
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
