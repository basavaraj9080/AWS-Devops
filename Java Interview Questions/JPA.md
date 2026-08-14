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
