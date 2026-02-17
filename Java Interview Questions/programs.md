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
