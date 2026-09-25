
# Senior Java Developer — Low-Level System Design (LLD) Answers

Absolutely. Below is a **Senior Java Developer LLD answer set** for all 14 questions I listed. The focus is on what you can actually explain and code in an interview—not just UML.

## 1. Parking Lot

### Requirements
- Multiple floors
- Different vehicle types
- Different parking spot types
- Park/unpark vehicle
- Generate ticket
- Find available spot

### Main classes

```java
enum VehicleType {
    BIKE, CAR, TRUCK
}

class Vehicle {
    private final String number;
    private final VehicleType type;

    public Vehicle(String number, VehicleType type) {
        this.number = number;
        this.type = type;
    }

    public VehicleType getType() {
        return type;
    }

    public String getNumber() {
        return number;
    }
}

abstract class ParkingSpot {
    private final String id;
    private Vehicle vehicle;

    protected ParkingSpot(String id) {
        this.id = id;
    }

    public boolean isAvailable() {
        return vehicle == null;
    }

    public synchronized boolean park(Vehicle vehicle) {
        if (!isAvailable() || !canFit(vehicle)) {
            return false;
        }
        this.vehicle = vehicle;
        return true;
    }

    public synchronized void unpark() {
        vehicle = null;
    }

    protected abstract boolean canFit(Vehicle vehicle);
}

class BikeSpot extends ParkingSpot {
    public BikeSpot(String id) {
        super(id);
    }

    protected boolean canFit(Vehicle vehicle) {
        return vehicle.getType() == VehicleType.BIKE;
    }
}

class CarSpot extends ParkingSpot {
    public CarSpot(String id) {
        super(id);
    }

    protected boolean canFit(Vehicle vehicle) {
        return vehicle.getType() == VehicleType.CAR;
    }
}
```

### Interview concepts
**Factory** can create the appropriate spot, and a **Strategy** can decide how to find the nearest available spot.

Important follow-up: **How do you handle 100 simultaneous parking requests?**

Use thread-safe data structures and atomic reservation/locking around spot allocation.

---

# 2. Rate Limiter

Requirement:

> Allow maximum 100 requests per user per minute.

```java
interface RateLimiter {
    boolean allowRequest(String userId);
}
```

A simple implementation:

```java
class FixedWindowRateLimiter implements RateLimiter {

    private static class Counter {
        long windowStart;
        int count;

        Counter(long windowStart) {
            this.windowStart = windowStart;
        }
    }

    private final int limit;
    private final long windowMillis;
    private final ConcurrentHashMap<String, Counter> counters =
            new ConcurrentHashMap<>();

    public FixedWindowRateLimiter(int limit, long windowMillis) {
        this.limit = limit;
        this.windowMillis = windowMillis;
    }

    @Override
    public boolean allowRequest(String userId) {
        long now = System.currentTimeMillis();

        Counter counter = counters.compute(userId, (key, old) -> {
            if (old == null ||
                now - old.windowStart >= windowMillis) {
                return new Counter(now);
            }

            old.count++;
            return old;
        });

        return counter.count <= limit;
    }
}
```

### Production discussion

For multiple microservice instances:

```text
Client
   |
Load Balancer
   |
+-------+-------+
| Service | Service |
+-------+-------+
      |
     Redis
      |
 Rate Limit
```

Use **Redis** for distributed rate limiting.

Mention:

- Token Bucket
- Sliding Window
- Fixed Window
- Redis atomic operations
- TTL

---

# 3. Payment System

This is a classic **Strategy + Factory** problem.

```java
interface PaymentStrategy {
    void pay(double amount);
}

class CardPayment implements PaymentStrategy {
    public void pay(double amount) {
        System.out.println("Paid using Card: " + amount);
    }
}

class UpiPayment implements PaymentStrategy {
    public void pay(double amount) {
        System.out.println("Paid using UPI: " + amount);
    }
}

class CashPayment implements PaymentStrategy {
    public void pay(double amount) {
        System.out.println("Paid using Cash: " + amount);
    }
}
```

Payment service:

```java
class PaymentService {

    private final PaymentStrategy strategy;

    public PaymentService(PaymentStrategy strategy) {
        this.strategy = strategy;
    }

    public void processPayment(double amount) {
        strategy.pay(amount);
    }
}
```

Usage:

```java
PaymentService service =
        new PaymentService(new UpiPayment());

service.processPayment(1000);
```

### Why Strategy?

Instead of:

```java
if (type == CARD) ...
else if (type == UPI) ...
else if (type == CASH) ...
```

we can add:

```java
class WalletPayment implements PaymentStrategy {
    ...
}
```

without modifying existing payment logic.

That's **Open/Closed Principle**.

---

# 4. Notification System

Support:

- Email
- SMS
- Push notification

```java
interface Notification {
    void send(String message, String recipient);
}
```

Implementations:

```java
class EmailNotification implements Notification {

    public void send(String message, String recipient) {
        System.out.println("Email sent to " + recipient);
    }
}

class SmsNotification implements Notification {

    public void send(String message, String recipient) {
        System.out.println("SMS sent to " + recipient);
    }
}

class PushNotification implements Notification {

    public void send(String message, String recipient) {
        System.out.println("Push sent to " + recipient);
    }
}
```

Factory:

```java
class NotificationFactory {

    public static Notification getNotification(String type) {

        return switch (type.toUpperCase()) {
            case "EMAIL" -> new EmailNotification();
            case "SMS" -> new SmsNotification();
            case "PUSH" -> new PushNotification();
            default -> throw new IllegalArgumentException(
                    "Unsupported notification type");
        };
    }
}
```

Service:

```java
class NotificationService {

    public void send(
            String type,
            String recipient,
            String message) {

        Notification notification =
                NotificationFactory.getNotification(type);

        notification.send(message, recipient);
    }
}
```

### Interview follow-up

> What if SMS provider fails?

Discuss:

```text
Retry
  ↓
Exponential Backoff
  ↓
Maximum retries
  ↓
Dead Letter Queue
```

For your Kafka experience, you can explain how notification requests could be asynchronously processed through Kafka.

---

# 5. Elevator System

### Entities

```text
ElevatorSystem
Elevator
Floor
Request
```

```java
enum Direction {
    UP, DOWN, IDLE
}

class Request {
    private final int floor;

    public Request(int floor) {
        this.floor = floor;
    }

    public int getFloor() {
        return floor;
    }
}
```

Elevator:

```java
class Elevator {

    private int currentFloor;
    private Direction direction = Direction.IDLE;

    public Elevator(int currentFloor) {
        this.currentFloor = currentFloor;
    }

    public void moveTo(int floor) {

        if (floor > currentFloor) {
            direction = Direction.UP;
        } else if (floor < currentFloor) {
            direction = Direction.DOWN;
        } else {
            direction = Direction.IDLE;
        }

        currentFloor = floor;
    }
}
```

### Important design question

How do you select an elevator?

Create:

```java
interface ElevatorSelectionStrategy {
    Elevator select(List<Elevator> elevators, Request request);
}
```

Possible strategies:

- Nearest elevator
- Least busy elevator
- Direction-based selection

This demonstrates **Strategy Pattern**.

---

# 6. Logger System

Classic LLD question.

Requirements:

- DEBUG
- INFO
- ERROR
- Different output destinations
- Console/file/database

```java
enum LogLevel {
    DEBUG, INFO, ERROR
}
```

Handler:

```java
abstract class LogHandler {

    protected LogHandler next;

    public void setNext(LogHandler next) {
        this.next = next;
    }

    public abstract void log(
            LogLevel level,
            String message);
}
```

Console handler:

```java
class ConsoleHandler extends LogHandler {

    public void log(LogLevel level, String message) {

        System.out.println(level + ": " + message);

        if (next != null) {
            next.log(level, message);
        }
    }
}
```

File handler:

```java
class FileHandler extends LogHandler {

    public void log(LogLevel level, String message) {

        // write to file

        if (next != null) {
            next.log(level, message);
        }
    }
}
```

This demonstrates **Chain of Responsibility**.

Production discussion:

```text
Application
    |
Async Logger
    |
Queue
    |
+--------+---------+
Console             File
```

Mention:

- Thread safety
- Async logging
- Log rotation
- Log levels
- Structured logging
- Correlation ID

---

# 7. Movie Ticket Booking

### Entities

```text
Movie
Theatre
Screen
Seat
Show
Booking
Payment
```

Relationships:

```text
Theatre
  |
  +-- Screen
        |
        +-- Seat
        |
        +-- Show
              |
              +-- Movie
```

Seat:

```java
enum SeatStatus {
    AVAILABLE, LOCKED, BOOKED
}

class Seat {

    private final String id;
    private SeatStatus status = SeatStatus.AVAILABLE;

    public Seat(String id) {
        this.id = id;
    }

    public synchronized boolean lock() {

        if (status != SeatStatus.AVAILABLE) {
            return false;
        }

        status = SeatStatus.LOCKED;
        return true;
    }

    public synchronized void confirmBooking() {
        if (status != SeatStatus.LOCKED) {
            throw new IllegalStateException();
        }

        status = SeatStatus.BOOKED;
    }
}
```

### Critical interview discussion

Two users select the same seat.

You need:

```text
AVAILABLE
    ↓
LOCKED
    ↓
BOOKED
```

The lock should have an expiry.

For distributed systems, use:

- Database transaction + row lock
- Redis distributed lock
- Optimistic locking/version column

---

# 8. Vending Machine

This is primarily a **State Pattern** question.

States:

```text
Idle
 ↓
CoinInserted
 ↓
ProductSelected
 ↓
Dispensing
```

Interface:

```java
interface VendingState {

    void insertCoin(VendingMachine machine);

    void selectProduct(
            VendingMachine machine,
            String product);

    void dispense(VendingMachine machine);
}
```

Machine:

```java
class VendingMachine {

    private VendingState state;

    public VendingMachine() {
        state = new IdleState();
    }

    public void setState(VendingState state) {
        this.state = state;
    }

    public void insertCoin() {
        state.insertCoin(this);
    }

    public void selectProduct(String product) {
        state.selectProduct(this, product);
    }

    public void dispense() {
        state.dispense(this);
    }
}
```

### Why State Pattern?

Without State Pattern:

```java
if (coinInserted && productSelected) ...
else if (...)
else if (...)
```

This becomes difficult to maintain.

---

# 9. Cab Booking System

Entities:

```text
Customer
Driver
Vehicle
Ride
Location
Payment
```

Flow:

```text
Customer
   |
Request Ride
   |
Find Driver
   |
Accept Ride
   |
Start Ride
   |
Complete Ride
   |
Payment
```

Driver matching:

```java
interface DriverMatchingStrategy {

    Driver findDriver(
            List<Driver> drivers,
            Location pickup);
}
```

Implementations:

```text
NearestDriverStrategy
RatingBasedStrategy
SurgeAwareStrategy
```

This is another **Strategy Pattern**.

### Important follow-up

> Multiple customers request the same driver.

You need an atomic state transition:

```text
AVAILABLE → ASSIGNED
```

Only one request should succeed.

---

# 10. Food Ordering System

Entities:

```text
Customer
Restaurant
Menu
MenuItem
Order
OrderItem
Payment
Delivery
```

Order states:

```text
CREATED
   ↓
CONFIRMED
   ↓
PREPARING
   ↓
READY
   ↓
OUT_FOR_DELIVERY
   ↓
DELIVERED
```

Use State Pattern:

```java
interface OrderState {
    void next(Order order);
    void cancel(Order order);
}
```

Order:

```java
class Order {

    private OrderState state;

    public void setState(OrderState state) {
        this.state = state;
    }

    public void next() {
        state.next(this);
    }

    public void cancel() {
        state.cancel(this);
    }
}
```

### Follow-up

> Can an order be cancelled after delivery?

The state object determines whether cancellation is allowed.

---

# 11. ATM

Classic **State Pattern**.

States:

```text
Idle
CardInserted
Authenticated
CashWithdrawal
```

ATM:

```java
class ATM {

    private ATMState state;

    public ATM() {
        state = new IdleState();
    }

    public void setState(ATMState state) {
        this.state = state;
    }

    public void insertCard() {
        state.insertCard(this);
    }

    public void enterPin(String pin) {
        state.enterPin(this, pin);
    }

    public void withdraw(double amount) {
        state.withdraw(this, amount);
    }
}
```

Possible interface:

```java
interface ATMState {

    void insertCard(ATM atm);

    void enterPin(
            ATM atm,
            String pin);

    void withdraw(
            ATM atm,
            double amount);
}
```

Important concerns:

- Authentication
- Balance validation
- Cash availability
- Transaction atomicity
- Card retained after repeated failures

---

# 12. Chess Game

Entities:

```text
Game
Board
Cell
Piece
Player
Move
```

Piece:

```java
abstract class Piece {

    protected boolean white;

    protected Piece(boolean white) {
        this.white = white;
    }

    public abstract boolean canMove(
            Board board,
            Position from,
            Position to);
}
```

Implement:

```text
King
Queen
Rook
Bishop
Knight
Pawn
```

Example:

```java
class Knight extends Piece {

    public Knight(boolean white) {
        super(white);
    }

    @Override
    public boolean canMove(
            Board board,
            Position from,
            Position to) {

        int rowDiff =
                Math.abs(from.row() - to.row());

        int colDiff =
                Math.abs(from.col() - to.col());

        return (rowDiff == 2 && colDiff == 1)
                || (rowDiff == 1 && colDiff == 2);
    }
}
```

Main concept:

**Polymorphism**.

Instead of:

```java
if (piece == KNIGHT) ...
if (piece == ROOK) ...
if (piece == BISHOP) ...
```

each piece owns its movement logic.

---

# 13. Splitwise

Requirements:

- Users
- Groups
- Expenses
- Split expense
- Calculate balances
- Settle balance

```java
class User {

    private final String id;
    private final String name;

    public User(String id, String name) {
        this.id = id;
        this.name = name;
    }
}
```

Split strategy:

```java
interface SplitStrategy {

    Map<User, Double> split(
            double amount,
            List<User> users);
}
```

Equal split:

```java
class EqualSplitStrategy implements SplitStrategy {

    public Map<User, Double> split(
            double amount,
            List<User> users) {

        double share = amount / users.size();

        Map<User, Double> result = new HashMap<>();

        for (User user : users) {
            result.put(user, share);
        }

        return result;
    }
}
```

Other strategies:

```text
EqualSplit
ExactSplit
PercentageSplit
```

Again, **Strategy Pattern**.

---

# 14. Car Rental System

Entities:

```text
Customer
Vehicle
VehicleType
Branch
Reservation
Payment
```

Vehicle:

```java
enum VehicleStatus {
    AVAILABLE,
    RESERVED,
    RENTED
}

class Vehicle {

    private final String number;
    private final VehicleType type;
    private VehicleStatus status;

    public boolean reserve() {

        if (status != VehicleStatus.AVAILABLE) {
            return false;
        }

        status = VehicleStatus.RESERVED;
        return true;
    }
}
```

Pricing:

```java
interface PricingStrategy {
    double calculatePrice(
            Vehicle vehicle,
            long hours);
}
```

Implementations:

```text
HourlyPricing
DailyPricing
WeekendPricing
PremiumVehiclePricing
```

This is **Strategy Pattern**.

---

# ⭐ Patterns you should remember for the interview

| Problem | Main Pattern |
|---|---|
| Parking Lot | Factory + Strategy |
| Rate Limiter | Strategy |
| Payment | Strategy + Factory |
| Notification | Factory + Strategy |
| Elevator | Strategy |
| Logger | Chain of Responsibility |
| Movie Booking | State + concurrency |
| Vending Machine | State |
| Cab Booking | Strategy |
| Food Ordering | State |
| ATM | State |
| Chess | Polymorphism |
| Splitwise | Strategy |
| Car Rental | Strategy |

### The most important thing for your interview

Don't memorize 14 implementations.

For a **Senior Java Developer**, practice these five deeply:

**1. Parking Lot → OOP + SOLID**

**2. Rate Limiter → Java concurrency**

**3. Payment → Strategy + Factory**

**4. Movie Booking → concurrency + locking**

**5. Vending Machine → State Pattern**

Also be prepared for the interviewer to take your design and ask:

> "Now make it thread-safe."

> "How would you scale this?"

> "What if we add another type?"

> "Which SOLID principle are you following?"

> "Why did you choose this design pattern?"

> "How would you implement this using Spring Boot?"

> "How would multiple instances of this service work?"

Those follow-ups are often more important at your experience level than the initial class diagram.


---
---
---

Below is a **Java LLD interview-style solution** for all 4 topics, with the key design decisions and code structure.

---

# 1. Thread Safety

For an LLD interview, start by defining what needs to be thread-safe.

### Example: Counter

A naive implementation:

```java
class Counter {
    private int count;

    public void increment() {
        count++;
    }

    public int get() {
        return count;
    }
}
```

`count++` is **not atomic**. It is effectively:

```text
read count
add 1
write count
```

Two threads can read the same value and overwrite each other's updates.

### Option 1 — `AtomicInteger`

```java
class Counter {
    private final AtomicInteger count = new AtomicInteger(0);

    public void increment() {
        count.incrementAndGet();
    }

    public int get() {
        return count.get();
    }
}
```

For simple atomic state changes, this is usually preferable to explicit locking.

### Option 2 — Immutable objects

A powerful way to reduce thread-safety problems is to make objects immutable.

```java
final class Product {
    private final String sku;
    private final double price;

    public Product(String sku, double price) {
        this.sku = sku;
        this.price = price;
    }

    public String getSku() {
        return sku;
    }

    public double getPrice() {
        return price;
    }
}
```

No thread can modify a `Product` after construction.

### Option 3 — Concurrent collections

Use Java's concurrent collections instead of manually synchronizing ordinary collections.

```java
Map<String, Product> products =
        new ConcurrentHashMap<>();
```

Useful classes:

```text
AtomicInteger
AtomicLong
AtomicReference
ConcurrentHashMap
ConcurrentLinkedQueue
CopyOnWriteArrayList
BlockingQueue
```

---

# 2. In-memory Inventory — 1000 concurrent requests, no explicit lock/synchronized

This is a very common interview question.

### Requirement

Suppose SKU `IPHONE-15` has:

```text
inventory = 10
```

1000 concurrent requests call:

```java
buy("IPHONE-15", 1)
```

Only **10 requests should succeed**.

We don't want:

```java
synchronized
Lock
ReentrantLock
```

The key is to use **CAS (Compare-And-Set)** through `AtomicInteger`.

---

## Design

```text
                InventoryService
                       |
                       v
             ConcurrentHashMap
                       |
                 SKU -> Stock
                       |
                       v
                 AtomicInteger
```

### Stock

```java
class Stock {
    private final AtomicInteger quantity;

    public Stock(int quantity) {
        this.quantity = new AtomicInteger(quantity);
    }

    public boolean reserve(int requested) {
        while (true) {
            int current = quantity.get();

            if (current < requested) {
                return false;
            }

            int updated = current - requested;

            if (quantity.compareAndSet(current, updated)) {
                return true;
            }
        }
    }

    public int getQuantity() {
        return quantity.get();
    }
}
```

### Inventory

```java
class Inventory {

    private final ConcurrentHashMap<String, Stock> inventory =
            new ConcurrentHashMap<>();

    public void addSku(String sku, int quantity) {
        inventory.put(sku, new Stock(quantity));
    }

    public boolean reserve(String sku, int quantity) {
        Stock stock = inventory.get(sku);

        if (stock == null) {
            return false;
        }

        return stock.reserve(quantity);
    }

    public int getStock(String sku) {
        Stock stock = inventory.get(sku);

        return stock == null
                ? 0
                : stock.getQuantity();
    }
}
```

### Why this works

Suppose quantity = `1`.

Two threads execute:

```text
Thread A                  Thread B

read 1                    read 1

updated = 0               updated = 0

CAS(1 -> 0) SUCCESS       CAS(1 -> 0) FAILURE
                           |
                           v
                         retry

                         read 0
                         current < requested
                         return false
```

So the **check + decrement** behaves atomically.

### Why not simply do this?

```java
if (quantity.get() >= requested) {
    quantity.addAndGet(-requested);
    return true;
}
```

Because these are two separate operations:

```text
check
   |
   v
decrement
```

Another thread can modify the value between them.

CAS solves exactly this problem.

### Interview point

Say:

> "I don't need mutual exclusion here. I need an atomic conditional update, so I use CAS through `AtomicInteger`."

That's an important distinction.

### What if quantity can be huge?

`AtomicLong` can be used.

### What if reservation involves multiple SKUs?

That's much harder.

For:

```text
Order:
  SKU-A = 2
  SKU-B = 3
```

you need **all-or-nothing reservation**.

Independent CAS operations don't automatically give transaction semantics.

At that point you can discuss:

```text
transactional database
distributed inventory service
reservation state
rollback/compensation
distributed lock
```

depending on the requirements.

---

# 3. Pricing Engine — Myntra-style promotions

The requirement is particularly suitable for the **Strategy + Composite/Chain of Responsibility** style.

We want to be able to add:

```text
10% discount
Flat ₹500 discount
Buy 2 get 1
Category discount
Coupon discount
Festival discount
Bank discount
```

without modifying existing rules.

The key principle:

> Each promotion is an independent rule implementing a common interface.

---

## Domain model

```java
class CartItem {
    private final String sku;
    private final String category;
    private final int quantity;
    private final double price;

    public CartItem(
            String sku,
            String category,
            int quantity,
            double price) {

        this.sku = sku;
        this.category = category;
        this.quantity = quantity;
        this.price = price;
    }

    public double total() {
        return quantity * price;
    }

    public String getCategory() {
        return category;
    }

    public int getQuantity() {
        return quantity;
    }
}
```

```java
class Cart {
    private final List<CartItem> items;

    public Cart(List<CartItem> items) {
        this.items = items;
    }

    public List<CartItem> getItems() {
        return items;
    }

    public double subtotal() {
        return items.stream()
                .mapToDouble(CartItem::total)
                .sum();
    }
}
```

---

## Promotion interface

```java
interface Promotion {

    boolean isApplicable(Cart cart);

    double calculateDiscount(Cart cart);
}
```

Now each promotion becomes independent.

---

## 10% discount

```java
class PercentageDiscount implements Promotion {

    private final double percentage;

    public PercentageDiscount(double percentage) {
        this.percentage = percentage;
    }

    @Override
    public boolean isApplicable(Cart cart) {
        return cart.subtotal() >= 2000;
    }

    @Override
    public double calculateDiscount(Cart cart) {
        return cart.subtotal() * percentage / 100;
    }
}
```

---

## Flat discount

```java
class FlatDiscount implements Promotion {

    private final double amount;

    public FlatDiscount(double amount) {
        this.amount = amount;
    }

    @Override
    public boolean isApplicable(Cart cart) {
        return cart.subtotal() >= 5000;
    }

    @Override
    public double calculateDiscount(Cart cart) {
        return amount;
    }
}
```

---

# Important: promotions may or may not apply

This is where the design gets interesting.

Suppose:

```text
Cart = ₹10,000

Rule A = 10% discount
Rule B = ₹500 discount
Rule C = category discount
Rule D = bank discount
```

You don't want:

```java
if (coupon ...)
else if (...)
else if (...)
```

inside `PricingEngine`.

Instead:

```java
class PricingEngine {

    private final List<Promotion> promotions;

    public PricingEngine(List<Promotion> promotions) {
        this.promotions = promotions;
    }

    public double calculatePrice(Cart cart) {

        double discount = 0;

        for (Promotion promotion : promotions) {

            if (promotion.isApplicable(cart)) {
                discount += promotion.calculateDiscount(cart);
            }
        }

        return Math.max(0, cart.subtotal() - discount);
    }
}
```

Adding a new promotion:

```java
class FestivalDiscount implements Promotion {
    ...
}
```

doesn't require changing `PricingEngine`.

That's **Open/Closed Principle**.

---

# But promotions often cannot simply be added

Real e-commerce pricing has rules like:

```text
10% coupon
+
bank discount
+
category discount

BUT

only one coupon can be applied
```

Or:

```text
Choose the maximum discount among these rules.
```

This is where I'd introduce a **PromotionGroup / Composite**.

---

## Promotion group

```java
interface DiscountRule {

    DiscountResult apply(Cart cart);
}
```

```java
record DiscountResult(
        boolean applicable,
        double discount,
        String description) {
}
```

Then:

```java
class BestOfPromotion implements DiscountRule {

    private final List<DiscountRule> rules;

    public BestOfPromotion(List<DiscountRule> rules) {
        this.rules = rules;
    }

    @Override
    public DiscountResult apply(Cart cart) {

        return rules.stream()
                .map(rule -> rule.apply(cart))
                .filter(DiscountResult::applicable)
                .max(Comparator.comparingDouble(
                        DiscountResult::discount))
                .orElse(new DiscountResult(
                        false, 0, "No discount"));
    }
}
```

Now you can compose:

```text
Pricing Engine
     |
     +-- Stackable promotions
     |
     +-- Best-of promotions
     |
     +-- Coupon promotions
     |
     +-- Bank promotions
```

This makes the system much easier to extend.

---

# Even better design

I'd separate:

```text
Eligibility
Calculation
Composition
```

For example:

```java
interface Promotion {

    PromotionResult evaluate(PricingContext context);
}
```

```java
record PricingContext(
        Cart cart,
        String coupon,
        String paymentMethod,
        String userId) {
}
```

Then:

```java
record PromotionResult(
        boolean applicable,
        Money discount,
        String promotionId) {
}
```

This avoids putting everything into `Cart`.

---

# 4. Meeting Room Booking — overlapping intervals

The important part here is identifying the **interval problem**.

Suppose meetings are:

```text
A: 10:00 - 11:00
B: 10:30 - 12:00
C: 11:30 - 13:00
D: 14:00 - 15:00
```

Overlapping intervals:

```text
10:00 ---------------- 11:00
       10:30 ---------------------- 12:00
                 11:30 ---------------------- 13:00
```

Canonical merged window:

```text
10:00 ------------------------------ 13:00

14:00 -------- 15:00
```

This is the classic **Merge Intervals** algorithm.

---

## Interval

```java
record Interval(
        LocalDateTime start,
        LocalDateTime end) {
}
```

---

## Merge algorithm

```java
class IntervalMerger {

    public List<Interval> merge(List<Interval> intervals) {

        if (intervals.isEmpty()) {
            return List.of();
        }

        List<Interval> sorted =
                intervals.stream()
                        .sorted(Comparator.comparing(Interval::start))
                        .toList();

        List<Interval> result = new ArrayList<>();

        Interval current = sorted.get(0);

        for (int i = 1; i < sorted.size(); i++) {

            Interval next = sorted.get(i);

            if (!next.start().isAfter(current.end())) {

                current = new Interval(
                        current.start(),
                        max(current.end(), next.end())
                );

            } else {

                result.add(current);
                current = next;
            }
        }

        result.add(current);

        return result;
    }

    private LocalDateTime max(
            LocalDateTime a,
            LocalDateTime b) {

        return a.isAfter(b) ? a : b;
    }
}
```

Complexity:

```text
Sorting: O(N log N)
Merge:   O(N)

Total:   O(N log N)
Space:   O(N)
```

---

# Meeting Room Booking

Now combine this with an actual booking system.

```text
MeetingRoom
     |
     +-- roomId
     +-- capacity
     +-- bookings
```

```java
record Booking(
        String bookingId,
        String roomId,
        LocalDateTime start,
        LocalDateTime end) {
}
```

A booking is valid if:

```text
newStart >= existingEnd
OR
newEnd <= existingStart
```

Otherwise:

```text
overlap exists
```

Equivalent overlap condition:

```java
boolean overlaps(
        LocalDateTime newStart,
        LocalDateTime newEnd,
        LocalDateTime existingStart,
        LocalDateTime existingEnd) {

    return newStart.isBefore(existingEnd)
            && newEnd.isAfter(existingStart);
}
```

---

# Better LLD structure

I'd design it as:

```text
                 MeetingRoomService
                        |
            +-----------+-----------+
            |                       |
       RoomRepository        BookingRepository
            |                       |
            v                       v
        Room data              Bookings
```

Domain:

```text
Room
Booking
TimeInterval
```

Service:

```text
MeetingRoomService
    |
    +-- createRoom()
    +-- searchAvailableRooms()
    +-- bookRoom()
    +-- cancelBooking()
```

---

# Booking flow

```text
bookRoom(roomId, start, end)
             |
             v
      Validate interval
             |
             v
      Get existing bookings
             |
             v
       Check overlap
          /       \
        yes        no
        |           |
     reject       create
                    |
                    v
             save booking
```

---

# One important concurrency issue

Two users can simultaneously do:

```text
User A: check room → available
User B: check room → available

User A: book
User B: book
```

Now you have a **double booking**.

So the LLD interview may move from:

> "How do I check overlap?"

to:

> "How do I guarantee no double booking under concurrent requests?"

For an in-memory single-JVM implementation, you need an atomic critical section or another concurrency mechanism around:

```text
check availability
+
create booking
```

If the interviewer explicitly says **no locks/synchronized**, you can discuss a CAS-based version using an immutable booking snapshot held in `AtomicReference`, but for a real multi-instance service, the stronger solution is generally a **database transaction/constraint or distributed coordination mechanism**.

---

# 5. Burger King / Aggregate example

If by "Burger King example" you mean aggregating overlapping availability/order windows, the same interval model applies.

For example:

```text
Restaurant availability:

09:00 - 11:00
10:30 - 12:00
13:00 - 15:00
14:00 - 16:00
```

Canonical representation:

```text
09:00 - 12:00
13:00 - 16:00
```

The algorithm is:

```text
1. Sort by start time

2. Take first interval as current

3. For every next interval:
      if next.start <= current.end
           merge
           current.end = max(current.end, next.end)
      else
           push current
           current = next

4. Push final current
```

This same pattern appears in:

* Meeting rooms
* Restaurant availability
* Delivery windows
* Employee availability
* Calendar events
* Hotel room availability
* Booking systems
* Machine maintenance windows

---

## What I'd emphasize in an interview

| Problem               | Core Java/design concept                        |
| --------------------- | ----------------------------------------------- |
| Thread safety         | Immutability, atomicity, concurrent collections |
| Inventory             | `ConcurrentHashMap` + `AtomicInteger` + CAS     |
| Pricing               | Strategy + Composite + Open/Closed Principle    |
| Promotions            | Independent rules + composition                 |
| Meeting booking       | Interval overlap                                |
| Canonical windows     | Sort + Merge Intervals                          |
| Concurrent booking    | Atomic check-and-create / transaction           |
| Extensibility         | Program to interfaces                           |
| Multi-instance system | DB transaction / distributed coordination       |

The **strongest interview answer** isn't just writing classes. Explain the invariant you're protecting:

> **Inventory:** stock must never become negative.
> **Pricing:** adding a promotion must not require changing existing promotions.
> **Booking:** two overlapping bookings must never be committed for the same room.
> **Intervals:** overlapping windows should be represented by one canonical interval.
