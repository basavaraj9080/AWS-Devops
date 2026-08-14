**Question: @Transactional propagation types**

In Spring, **`@Transactional` propagation** defines **what a method should do when it is called while another transaction is already running**.

The main propagation types are:

| Propagation     | Existing transaction? | Behavior                                     |
| --------------- | --------------------- | -------------------------------------------- |
| `REQUIRED`      | Yes                   | Join it                                      |
| `REQUIRED`      | No                    | Create new one                               |
| `REQUIRES_NEW`  | Yes                   | Suspend existing, create new                 |
| `SUPPORTS`      | Yes                   | Join it; otherwise run without transaction   |
| `NOT_SUPPORTED` | Yes                   | Suspend it; run without transaction          |
| `MANDATORY`     | Yes                   | Join it                                      |
| `MANDATORY`     | No                    | Throw exception                              |
| `NEVER`         | Yes                   | Throw exception                              |
| `NEVER`         | No                    | Run without transaction                      |
| `NESTED`        | Yes                   | Create savepoint within existing transaction |
| `NESTED`        | No                    | Usually behaves like `REQUIRED`              |

### 1. `REQUIRED` — default

```java
@Transactional(propagation = Propagation.REQUIRED)
public void method() {}
```

If a transaction exists → **join it**.

If no transaction exists → **create one**.

```text
A() @Transactional
  └── B() REQUIRED
        └── uses A's transaction
```

This is the **most commonly used** propagation.

---

### 2. `REQUIRES_NEW`

Always creates a **new transaction**.

If another transaction exists, it is **suspended** temporarily.

```text
Transaction A
   │
   ├── call B()
   │
   │   suspend A
   │   ┌─────────────┐
   │   │ Transaction B│
   │   └─────────────┘
   │
   └── resume A
```

Useful when B must commit/rollback **independently**.

Example:

```java
@Transactional
public void processOrder() {
    orderRepository.save(order);

    auditService.log(); // REQUIRES_NEW
}
```

If `processOrder()` later rolls back, the audit transaction can still remain committed.

---

### 3. `SUPPORTS`

```java
@Transactional(propagation = Propagation.SUPPORTS)
```

* Transaction exists → **use it**
* No transaction → **run without one**

Useful for operations that **can work either way**.

---

### 4. `MANDATORY`

```java
@Transactional(propagation = Propagation.MANDATORY)
```

A transaction **must already exist**.

* Existing transaction → join it
* No transaction → exception

Think:

> "You are not allowed to call me unless you're already inside a transaction."

---

### 5. `NOT_SUPPORTED`

```java
@Transactional(propagation = Propagation.NOT_SUPPORTED)
```

Always executes **without a transaction**.

If a transaction currently exists, Spring **suspends it**.

Useful for operations that shouldn't participate in the current transaction.

---

### 6. `NEVER`

```java
@Transactional(propagation = Propagation.NEVER)
```

The opposite of `MANDATORY`.

* No transaction → okay
* Existing transaction → **exception**

Think:

> "I refuse to run inside a transaction."

---

### 7. `NESTED`

```java
@Transactional(propagation = Propagation.NESTED)
```

Creates a **savepoint** inside the existing transaction.

Example:

```text
Transaction A
   │
   ├── operation 1
   │
   ├── B() NESTED
   │     └── savepoint
   │
   └── operation 3
```

If B fails, Spring can roll B back to its **savepoint** without necessarily rolling back the entire outer transaction.

**Important:** `NESTED` is not the same as `REQUIRES_NEW`.

* `REQUIRES_NEW` → separate physical transaction
* `NESTED` → same transaction + savepoint

Also, `NESTED` support depends on the transaction manager/database configuration.

---

### ⭐ Interview shortcut

Remember the four most important ones:

```text
REQUIRED      → Join existing / create if none
REQUIRES_NEW  → Always create new transaction
SUPPORTS      → Use transaction if one exists
NESTED        → Same transaction + savepoint
```

And the conceptual opposites:

```text
MANDATORY     → Transaction MUST exist
NEVER         → Transaction MUST NOT exist

NOT_SUPPORTED → Suspend transaction and run without one
```

**Most common interview question:**
**`REQUIRED` vs `REQUIRES_NEW` vs `NESTED`**

> `REQUIRED` participates in the caller's transaction. `REQUIRES_NEW` suspends the caller's transaction and starts an independent one. `NESTED` stays within the caller's transaction but creates a savepoint for partial rollback.

---
---

** Realtime Example for previous question **

Absolutely. The easiest way to understand transaction propagation is with **real business scenarios**.

Assume an e-commerce application:

```text
OrderController
      ↓
OrderService
      ↓
OrderRepository
      ↓
Database
```

## 1. `REQUIRED` — "Use the current transaction"

**Real example: Place an order**

```java
@Service
public class OrderService {

    @Transactional
    public void placeOrder(Order order) {
        orderRepository.save(order);
        paymentService.charge(order);
        inventoryService.reduceStock(order);
    }
}
```

Suppose all three operations use `REQUIRED`:

```text
placeOrder()       → Transaction T1
    ↓
save order         → T1
    ↓
charge payment     → T1
    ↓
reduce inventory   → T1
```

If inventory fails:

```text
T1 ROLLBACK
   ↓
Order NOT saved
Payment NOT saved
Inventory NOT updated
```

This is usually what you want when the operations should succeed or fail **as one unit**.

**Think:**

> "If there's already a transaction, I'll join it. Otherwise I'll create one."

---

# 2. `REQUIRES_NEW` — "I need my own transaction"

### Real example: Audit logging

Suppose:

```java
@Transactional
public void placeOrder(Order order) {

    orderRepository.save(order);

    auditService.log("Order created");

    throw new RuntimeException("Payment failed");
}
```

And:

```java
@Transactional(propagation = Propagation.REQUIRES_NEW)
public void log(String message) {
    auditRepository.save(message);
}
```

What happens?

```text
Transaction T1
│
├── save order
│
├── auditService.log()
│     │
│     ├── Suspend T1
│     ├── Start T2
│     ├── save audit
│     ├── COMMIT T2
│     └── Resume T1
│
└── payment fails
      ↓
    ROLLBACK T1
```

Final database:

```text
Order → NOT saved
Audit → SAVED
```

This is useful for things such as:

* Audit records
* Transaction history
* Certain notification/outbox records
* Independent logging that must survive the outer rollback

### Important interview point

`REQUIRES_NEW` means **a completely independent transaction**.

---

# 3. `NESTED` — "Give me a savepoint"

Imagine a batch processing system:

```java
@Transactional
public void processOrders(List<Order> orders) {

    for (Order order : orders) {
        processSingleOrder(order);
    }
}
```

And:

```java
@Transactional(propagation = Propagation.NESTED)
public void processSingleOrder(Order order) {
    // process one order
}
```

Conceptually:

```text
Transaction T1
│
├── Order 1
│    └── Savepoint S1
│
├── Order 2
│    └── Savepoint S2
│         ↓ failure
│       rollback to S2
│
└── Order 3
```

The idea is:

> "If this inner operation fails, roll back to the savepoint rather than necessarily destroying the entire outer transaction."

### `NESTED` vs `REQUIRES_NEW`

This is a **very common interview question**.

```text
REQUIRES_NEW

T1 ───── suspend ───────────── resume ─────
              │
              T2
              └── COMMIT
```

Two independent transactions.

Whereas:

```text
NESTED

T1 ────────────────┬──────────────────────
                   │
                Savepoint
                   │
                inner work
                   │
                rollback
                   ↓
              continue T1
```

Same outer transaction, with a savepoint.

---

# 4. `SUPPORTS` — "I'll use a transaction if you have one"

Imagine a method that simply reads some data:

```java
@Transactional(propagation = Propagation.SUPPORTS)
public User getUser(Long id) {
    return userRepository.findById(id);
}
```

Called from:

```java
@Transactional
public void processOrder() {
    User user = getUser(10L);
}
```

Then:

```text
processOrder()
    ↓
Transaction T1
    ↓
getUser()
    ↓
uses T1
```

But if called directly:

```java
getUser(10L);
```

there is no transaction:

```text
getUser()
   ↓
No transaction
   ↓
execute normally
```

So:

> **Transaction exists → participate.**
> **No transaction → don't create one.**

---

# 5. `MANDATORY` — "You MUST already have a transaction"

Imagine a low-level operation that should **never be called outside a transaction**.

```java
@Transactional(propagation = Propagation.MANDATORY)
public void updateAccountBalance(Account account) {
    // update balance
}
```

Correct:

```java
@Transactional
public void transferMoney() {

    updateAccountBalance(account);
}
```

```text
transferMoney()
    ↓
T1
    ↓
updateAccountBalance()
    ↓
joins T1
```

But:

```java
updateAccountBalance(account);
```

directly will fail because there is no transaction.

Think:

> `MANDATORY` = "You better bring a transaction with you."

---

# 6. `NOT_SUPPORTED` — "Don't run inside a transaction"

Imagine you have a very long-running report:

```java
@Transactional(propagation = Propagation.NOT_SUPPORTED)
public Report generateLargeReport() {
    // expensive reporting operation
}
```

Suppose it is called from:

```java
@Transactional
public void process() {

    // database work

    generateLargeReport();

    // more database work
}
```

Spring conceptually does:

```text
T1 starts
 │
 ├── database work
 │
 ├── suspend T1
 │
 ├── generateLargeReport()
 │      └── NO transaction
 │
 ├── resume T1
 │
 └── more database work
```

Useful when you don't want a long-running operation holding transaction resources.

---

# 7. `NEVER` — "I absolutely don't want a transaction"

```java
@Transactional(propagation = Propagation.NEVER)
public void doSomething() {
}
```

If called without a transaction:

```text
doSomething()
   ↓
OK
```

If called from:

```java
@Transactional
public void process() {
    doSomething();
}
```

then:

```text
T1
 ↓
doSomething()
 ↓
EXCEPTION
```

Think:

> `NEVER` = "If you have a transaction, don't call me."

---

# A practical example combining them

Imagine a payment system:

```text
                    placeOrder()
                         │
                    REQUIRED
                         │
        ┌────────────────┼────────────────┐
        ↓                ↓                ↓
   Save Order       Charge Card      Reduce Stock
    REQUIRED        REQUIRED          REQUIRED
        │                │                │
        └────────────────┼────────────────┘
                         ↓
                    Transaction T1
```

Everything participates in **T1**.

Now suppose we add audit logging:

```text
placeOrder()
    │
    │ T1
    ├── Save Order
    │
    ├── Charge Card
    │
    ├── Audit Log
    │      │
    │      ├── suspend T1
    │      ├── T2
    │      ├── save audit
    │      ├── COMMIT T2
    │      └── resume T1
    │
    └── failure
          ↓
       ROLLBACK T1
```

Result:

```text
Order       ❌ rolled back
Payment     ❌ rolled back
Inventory   ❌ rolled back
Audit       ✅ committed
```

That's a **real-world reason to use `REQUIRES_NEW`**.

---

## Quick way to remember all 7

| Type            | Easy meaning           | Real-world thought                   |
| --------------- | ---------------------- | ------------------------------------ |
| `REQUIRED`      | Join/create            | "We're part of the same operation."  |
| `REQUIRES_NEW`  | New transaction        | "My work must be independent."       |
| `NESTED`        | Savepoint              | "Let me partially roll back."        |
| `SUPPORTS`      | Optional transaction   | "I'll use yours if available."       |
| `MANDATORY`     | Transaction required   | "Don't call me without one."         |
| `NOT_SUPPORTED` | No transaction         | "Suspend yours while I work."        |
| `NEVER`         | No transaction allowed | "Calling me inside one is an error." |

### ⭐ If you're preparing for Spring interviews

Focus especially on these three:

**`REQUIRED` vs `REQUIRES_NEW` vs `NESTED`**

The simplest mental model is:

```text
REQUIRED
   → Same transaction

REQUIRES_NEW
   → Completely new transaction

NESTED
   → Same transaction + savepoint
```

One more **very important Spring interview gotcha**: `@Transactional` usually works through a Spring proxy. So if one method in a class calls another `@Transactional` method **directly via `this.method()`**, the transactional proxy may be bypassed. This becomes particularly important when you're testing `REQUIRES_NEW` or `NESTED`.

