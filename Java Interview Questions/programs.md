**Program 1** <br>
	Given a list of transactions, find the sum of transaction amounts for each day using Java streams.

	List<Transaction> transactions = Arrays.asList(

		new Transaction("2022-01-01", 100),

		new Transaction("2022-01-01", 200),

		new Transaction("2022-01-02", 300),

		new Transaction("2022-01-02", 400),

		new Transaction("2022-01-03", 500)

	);
  <br>
  
  **Answer** <br>
  You can use **Java Streams** with `Collectors.groupingBy()` and `Collectors.summingInt()` to calculate the sum of transaction amounts for each day.

Here is the complete solution:

```java
import java.util.*;
import java.util.stream.Collectors;

class Transaction {
    private String date;
    private int amount;

    public Transaction(String date, int amount) {
        this.date = date;
        this.amount = amount;
    }

    public String getDate() {
        return date;
    }

    public int getAmount() {
        return amount;
    }
}

public class Main {
    public static void main(String[] args) {

        List<Transaction> transactions = Arrays.asList(
            new Transaction("2022-01-01", 100),
            new Transaction("2022-01-01", 200),
            new Transaction("2022-01-02", 300),
            new Transaction("2022-01-02", 400),
            new Transaction("2022-01-03", 500)
        );

        Map<String, Integer> sumByDate = transactions.stream()
                .collect(Collectors.groupingBy(
                        Transaction::getDate,
                        Collectors.summingInt(Transaction::getAmount)
                ));

        System.out.println(sumByDate);
    }
}
```

### Output:

```
{2022-01-01=300, 2022-01-02=700, 2022-01-03=500}
```

---

### How It Works:

* `groupingBy(Transaction::getDate)` → Groups transactions by date
* `summingInt(Transaction::getAmount)` → Sums the amount for each group

---

### If You Want Ordered Output (By Date)

Use `TreeMap`:

```java
Map<String, Integer> sumByDate = transactions.stream()
        .collect(Collectors.groupingBy(
                Transaction::getDate,
                TreeMap::new,
                Collectors.summingInt(Transaction::getAmount)
        ));
```

This will maintain the dates in sorted order.

---

If you want, I can also show:

* Java 8 alternative using `toMap`
* How to use `LocalDate` instead of String
* Interview-optimized explanation for TCS/MNC 👍

<br>
<br>

**Program 2**
</br>
Let’s analyze the code carefully.

```java
try {

    if (flag) {
        while (true) {
        }
    } else {
        System.exit(1);
    }

} finally {
    System.out.println("In Finally");
}
```

---

## ✅ Case 1: `flag = true`

```java
while (true) { }
```

* This is an **infinite loop**.
* The program never exits the `try` block.
* Since it never exits, the `finally` block is **never executed**.

### ✔ Output:

**No output**
Program runs forever.

---

## ✅ Case 2: `flag = false`

```java
System.exit(1);
```

* `System.exit(1)` terminates the JVM immediately.
* When JVM shuts down, `finally` block **does NOT execute**.

### ✔ Output:

**No output**

---

# 🎯 Final Answer

👉 In **both cases**,

```
In Finally
```

will **NOT** be printed.

---

# 💡 Important Concept (Interview Point)

`finally` block executes:

* After normal completion
* After exception
* Even after `return`

But it does **NOT execute** if:

* `System.exit()` is called
* JVM crashes
* Infinite loop prevents exit

---

If you want, I can give you similar tricky Java interview questions for practice 😊

---
---
<br>

**Program 3**
<br>
replace active with in active using stream

List<Employee> employees = Arrays.asList(

            new Employee(101, "Alice", "Active"),

            new Employee(102, "Bob", "Inactive"),

            new Employee(103, "Charlie", "Active"),

            new Employee(104, "Diana", "On Leave")

        );
<br>

**Answer**
<br>
To replace **"Active"** with **"Inactive"** using Java Streams, you can use `map()` to transform the list.

Here are two approaches depending on whether you want to:

* ✅ Create a **new modified list**
* ✅ Modify the existing objects

---

# ✅ 1️⃣ Create a New List (Recommended – Immutable Style)

```java
import java.util.*;
import java.util.stream.Collectors;

class Employee {
    private int id;
    private String name;
    private String status;

    public Employee(int id, String name, String status) {
        this.id = id;
        this.name = name;
        this.status = status;
    }

    public int getId() { return id; }
    public String getName() { return name; }
    public String getStatus() { return status; }

    @Override
    public String toString() {
        return id + " " + name + " " + status;
    }
}

public class Main {
    public static void main(String[] args) {

        List<Employee> employees = Arrays.asList(
            new Employee(101, "Alice", "Active"),
            new Employee(102, "Bob", "Inactive"),
            new Employee(103, "Charlie", "Active"),
            new Employee(104, "Diana", "On Leave")
        );

        List<Employee> updatedList = employees.stream()
                .map(emp -> 
                    emp.getStatus().equals("Active") 
                    ? new Employee(emp.getId(), emp.getName(), "Inactive")
                    : emp
                )
                .collect(Collectors.toList());

        updatedList.forEach(System.out::println);
    }
}
```

### ✅ Output:

```
101 Alice Inactive
102 Bob Inactive
103 Charlie Inactive
104 Diana On Leave
```

---

# ✅ 2️⃣ Modify Existing List (If Setter Exists)

If `Employee` has `setStatus()`:

```java
employees.stream()
        .filter(emp -> emp.getStatus().equals("Active"))
        .forEach(emp -> emp.setStatus("Inactive"));
```

---

# 🎯 Interview Tip

* `map()` → Used for transformation
* `filter()` → Used for condition selection
* Prefer creating a **new list** in functional programming style

---

If you want, I can also show:

* Case-insensitive replacement
* Using `replaceAll()`
* Java 17 optimized version

<br>
---
---
<br>

**Program 5**
<br>
perform all math operation

@FunctionalInterface
interface MathOperation{
	
	public int mathOpp(int a, int b);
}

<br>

**Answer**
<br>
Since you have a **@FunctionalInterface**, you can perform all math operations using **Lambda expressions**.

Here is the complete example:

---

## ✅ Functional Interface

```java
@FunctionalInterface
interface MathOperation {
    public int mathOpp(int a, int b);
}
```

---

## ✅ Perform All Math Operations Using Lambda

```java
public class Main {

    public static void main(String[] args) {

        MathOperation addition = (a, b) -> a + b;
        MathOperation subtraction = (a, b) -> a - b;
        MathOperation multiplication = (a, b) -> a * b;
        MathOperation division = (a, b) -> a / b;

        int a = 20;
        int b = 10;

        System.out.println("Addition: " + addition.mathOpp(a, b));
        System.out.println("Subtraction: " + subtraction.mathOpp(a, b));
        System.out.println("Multiplication: " + multiplication.mathOpp(a, b));
        System.out.println("Division: " + division.mathOpp(a, b));
    }
}
```

---

## ✅ Output

```
Addition: 30
Subtraction: 10
Multiplication: 200
Division: 2
```

---

# 🎯 Cleaner Interview Version (Reusable Method)

```java
public class Main {

    public static void operate(int a, int b, MathOperation op) {
        System.out.println(op.mathOpp(a, b));
    }

    public static void main(String[] args) {

        operate(20, 10, (a, b) -> a + b);
        operate(20, 10, (a, b) -> a - b);
        operate(20, 10, (a, b) -> a * b);
        operate(20, 10, (a, b) -> a / b);
    }
}
```

---

# 💡 Interview Points

* Functional Interface → Only **one abstract method**
* Lambda Expression → Implements functional interface
* Enables **behavior passing**

---

If you want, I can also show:

* Using Method Reference
* Handling divide-by-zero
* Using Built-in `BiFunction<Integer, Integer, Integer>`

<br>
---
---

<br>

**Program 6**
<br>
abcd reverse the string w/o using inbuilt fun
<br>

**Answer**
<br>
If you cannot use:

* ❌ Inbuilt functions (`toCharArray()`, `reverse()`, etc.)
* ❌ `for` loop
* ❌ `while` loop

Then the best way is **Recursion** ✅

---

# ✅ Reverse String Using Recursion (No Loop, No Inbuilt)

```java
public class Main {

    public static void main(String[] args) {
        String str = "abcd";
        reverse(str, str.length() - 1);
    }

    public static void reverse(String str, int index) {
        if (index < 0) {
            return;
        }
        System.out.print(str.charAt(index));
        reverse(str, index - 1);
    }
}
```

---

## ✅ Output:

```
dcba
```

---

# 🔎 How It Works

For `"abcd"`:

```
reverse(str, 3) → prints 'd'
reverse(str, 2) → prints 'c'
reverse(str, 1) → prints 'b'
reverse(str, 0) → prints 'a'
```

Stops when index < 0.

---

# 🎯 Interview Explanation

* No loop used
* No inbuilt reverse function
* Uses recursion stack
* Time Complexity → O(n)
* Space Complexity → O(n) (because of recursion call stack)

---

If you want, I can also show:

* Recursive method returning reversed string instead of printing
* Reverse without even using `charAt()`
* One-line recursive trick 😄

<br>
---
---
<br>

**Program**
<br>
explian this

Time Complexity → O(n)

Space Complexity → O(n) (because of recursion call stack)

<br>

**Answer**
<br>
Let’s clearly understand this step-by-step 👇

We are talking about this recursive method:

```java
public static void reverse(String str, int index) {
    if (index < 0) {
        return;
    }
    System.out.print(str.charAt(index));
    reverse(str, index - 1);
}
```

Assume:

```
str = "abcd"
n = 4
```

---

# ✅ Time Complexity → O(n)

### What is Time Complexity?

It tells how many times the function runs depending on input size.

### What happens here?

If string length = **n**

The function calls itself:

```
reverse(str, 3)
reverse(str, 2)
reverse(str, 1)
reverse(str, 0)
reverse(str, -1)
```

It runs **once for each character**.

So total function calls = **n**

If string has:

* 4 characters → 4 calls
* 100 characters → 100 calls
* 10,000 characters → 10,000 calls

So execution grows linearly with input size.

👉 Therefore:

```
Time Complexity = O(n)
```

---

# ✅ Space Complexity → O(n)

Now this is important.

### What is Space Complexity?

It tells how much **extra memory** the program uses.

In recursion, every function call is stored in something called the **Call Stack**.

---

### What happens internally?

For `"abcd"`:

When `reverse(str, 3)` runs,
it waits for `reverse(str, 2)` to finish.

So Java stores:

```
reverse(3)
reverse(2)
reverse(1)
reverse(0)
```

All these are kept in memory **until recursion finishes**.

If string length = n
Then maximum recursive calls stored at once = n

So memory usage grows linearly.

👉 Therefore:

```
Space Complexity = O(n)
```

---

# 🔥 Why Not O(1)?

Because:

* We are not using a loop
* Each recursive call consumes stack memory
* Stack depth = n

If we used a loop instead:

```
Space Complexity = O(1)
```

Because loop does not store multiple function calls.

---

# 🎯 Simple Summary

| Concept          | Value | Why                              |
| ---------------- | ----- | -------------------------------- |
| Time Complexity  | O(n)  | Function runs once per character |
| Space Complexity | O(n)  | Recursion stack stores n calls   |

---

# 🧠 Interview Tip

If interviewer asks:

👉 “Which is better — loop or recursion?”

Answer:

* Loop → Better space (O(1))
* Recursion → Uses extra stack (O(n))
* Both → Time complexity O(n)

---

If you want, I can also explain with memory diagram visualization for better understanding 😊

<br>
Yes
<br>
Great 👍 Let’s visualize how memory works internally for recursion.

We’ll use:

```java
reverse("abcd", 3);
```

---

# 🧠 Step-by-Step Recursion Call Stack

### Initial Call:

```
reverse("abcd", 3)
```

Since index = 3 → prints **d**
Then calls:

```
reverse("abcd", 2)
```

---

## 📦 How Call Stack Builds

Think of stack like plates placed on top of each other.

### Step 1

```
| reverse(3) |
```

### Step 2

```
| reverse(2) |
| reverse(3) |
```

### Step 3

```
| reverse(1) |
| reverse(2) |
| reverse(3) |
```

### Step 4

```
| reverse(0) |
| reverse(1) |
| reverse(2) |
| reverse(3) |
```

### Step 5 (Base Case)

```
| reverse(-1) |
| reverse(0)  |
| reverse(1)  |
| reverse(2)  |
| reverse(3)  |
```

Now index < 0 → returns.

---

# 🔁 Stack Starts Unwinding

Now functions start finishing one by one:

```
reverse(-1) → returns
reverse(0)  → finishes
reverse(1)  → finishes
reverse(2)  → finishes
reverse(3)  → finishes
```

Stack becomes empty.

---

# 📊 Why Space Complexity = O(n)

At peak time, stack had:

```
n function calls
```

If string length = 4 → stack depth = 4
If string length = 100 → stack depth = 100
If string length = 10,000 → stack depth = 10,000

So memory grows linearly.

👉 Therefore:

```
Space Complexity = O(n)
```

---

# ⏱ Why Time Complexity = O(n)

Because function executes once per character.

For "abcd":

```
4 meaningful calls
```

For length n:

```
n calls
```

So:

```
Time Complexity = O(n)
```

---

# 🔥 Important Interview Insight

### Recursion Memory Formula

```
Total Stack Space = 
(number of recursive calls) × (memory per call)
```

Since number of calls = n

→ Space = O(n)

---

# 💡 Compare With Loop Version

### Loop:

```
for(int i=n-1; i>=0; i--)
```

Only one function call.

Stack looks like:

```
| main() |
```

No stacking.

So:

```
Space Complexity = O(1)
```

---

# 🎯 Final Quick Comparison

| Method    | Time | Space |
| --------- | ---- | ----- |
| Loop      | O(n) | O(1)  |
| Recursion | O(n) | O(n)  |

---

If you want, I can also show:

* 🔥 What happens if string length is 1 lakh (StackOverflowError explanation)
* 🔥 Tail recursion optimization
* 🔥 Dry run using real memory numbers (bytes)

Which one do you want?
