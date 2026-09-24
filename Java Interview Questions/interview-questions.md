In Java, both `ArrayList` and `LinkedList` implement the `List` interface, but their internal structures differ.

| Feature                    | `ArrayList`                | `LinkedList`                                    |
| -------------------------- | -------------------------- | ----------------------------------------------- |
| Internal structure         | Dynamic array              | Doubly linked list                              |
| Access by index            | Fast — **O(1)**            | Slower — **O(n)**                               |
| Add at end                 | Usually **O(1)** amortized | **O(1)**                                        |
| Insert/delete at beginning | **O(n)** due to shifting   | **O(1)**                                        |
| Insert/delete in middle    | **O(n)**                   | **O(n)** to locate; **O(1)** once node is known |
| Memory usage               | Lower                      | Higher due to node links                        |
| Cache performance          | Better                     | Usually worse                                   |
| Implements                 | `List`                     | `List`, `Deque`                                 |

### Example

```java
List<String> arrayList = new ArrayList<>();
arrayList.add("A");
arrayList.add("B");
System.out.println(arrayList.get(1)); // Fast random access

LinkedList<String> linkedList = new LinkedList<>();
linkedList.addFirst("A");
linkedList.addFirst("B");
linkedList.removeFirst(); // Efficient operation
```

**Rule of thumb:** Use `ArrayList` for most general-purpose lists, especially when you frequently access elements by index. Use `LinkedList` when you specifically need `Deque` operations such as frequent additions/removals at both ends.

A common interview answer is: **`ArrayList` is generally better for accessing elements, while `LinkedList` can be better for insertion/deletion when you already have the relevant position/node.**

>
>
---
## In Java, **fail-fast** and **fail-safe** describe how an iterator behaves when a collection is modified while you're iterating over it.

### 1. Fail-fast

A **fail-fast iterator** immediately throws a `ConcurrentModificationException` if it detects that the collection has been structurally modified during iteration.

Example:

```java
List<String> list = new ArrayList<>();
list.add("A");
list.add("B");
list.add("C");

for (String s : list) {
    list.add("D");  // ConcurrentModificationException
}
```

`ArrayList`, `HashMap`, and `HashSet` iterators are commonly described as fail-fast.

**Idea:**

> "Something changed unexpectedly → stop immediately."

---

### 2. Fail-safe

A **fail-safe iterator** does not throw `ConcurrentModificationException` when the underlying collection is modified. Typically, it iterates over a snapshot or uses concurrency-aware behavior.

Example:

```java
CopyOnWriteArrayList<String> list =
        new CopyOnWriteArrayList<>();

list.add("A");
list.add("B");
list.add("C");

for (String s : list) {
    list.add("D");  // No ConcurrentModificationException
}
```

`CopyOnWriteArrayList` is a common example.

**Idea:**

> "Something changed → continue safely using the iterator's view."

### Key difference

|                               | Fail-fast                       | Fail-safe                                       |
| ----------------------------- | ------------------------------- | ----------------------------------------------- |
| Modification during iteration | Usually throws exception        | Doesn't throw `ConcurrentModificationException` |
| Example                       | `ArrayList`                     | `CopyOnWriteArrayList`                          |
| Iterator works on             | Generally the collection itself | Often a snapshot / concurrency-safe view        |
| Performance                   | Usually faster                  | Can use more memory / have copying overhead     |

### Important interview point

**Fail-fast is not a concurrency-safety guarantee.** It is generally implemented using modification tracking (such as `modCount`) and is described by Java's collection documentation as **best-effort**. You should not rely on `ConcurrentModificationException` for program correctness.

Also, if you want to **remove elements while iterating**, use the iterator's `remove()` method rather than modifying the collection directly:

```java
Iterator<String> iterator = list.iterator();

while (iterator.hasNext()) {
    if (iterator.next().equals("B")) {
        iterator.remove();  // Correct
    }
}
```

**Easy way to remember:**
**Fail-fast → detects modification and fails.**
**Fail-safe → tolerates modification and continues.**
