## Movie Ticket Booking — LLD in Java

A good interview design should focus on **Movie → Theatre → Screen → Show → Seat → Booking → Payment**, with concurrency handling for seat booking.

![Image](https://images.openai.com/static-rsc-4/4qVUSU5FBPsR5kPcjFb5pb_6hN8HepTYatiikxYBwsZ1FJykMfsHV2wX21Bz45EpFPxbJHsfgZGj-GGVSbIxcdZmcxQnq5GEc__noyEcl7ThJHsizmjW0kmyQosulyBxxcJAzUW4MJdBqM9uvS4BtLKhpJ-Ze_zHxQVRIfl9aKW6pvo1YyRPoA15vE163FPr?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/EbHSb2_hj9fyg0LqSLGKAdKEMP7MfKezUwhDLeNiEq17D7ZRO3cgBHjOmdRDV6ahosell4ad6f8wxbGw36KSKbenJ-flt1cxPdHdv-bzvCdhs-SnKi_K4VQ6eLJWM0HqLkWou7iCSfGtMuaAByOn_Hk-RMuqvT8_nrMXU08s6ZYIAHHtw9KjeZulR074wWNv?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/ThrIyuWzVVU8cHwdDtnvGmF6mM-jhRMonwEZ0a9KjqVkJrSfCrMDwvqSArQstue0dDe2IJQj-9XJPr31_CkLT37dPCyRZvpxCUH7aEm-uyS2gSAk6rHcibE4bON7EViyJ2cU-oUDlPtMLP73qdurtpaWPUxa4GckqYaCit-CVdQxl7ABnJgud9SkuxEJiE7h?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/vJXAq2tgFZ5UgAu28IXxa66trzd8gLentIx45aC_UIfFV2HR9-RjzErLro11eudzk3Hdl_5rh78TEnQSEmTjP9j945Cx94LPirTfz_FkOOZxYWk-0Gmgpl0av9iOamLeJDWg7PYxVoWtP2rOKsTCml9yPEtfJZpakPXuS-W_S9B-jkQh_ZG5881BUm5MaZDU?purpose=fullsize)

### 1. Core class diagram

```text
                    ┌──────────────┐
                    │     User     │
                    ├──────────────┤
                    │ id           │
                    │ name         │
                    │ email        │
                    └──────┬───────┘
                           │
                           │ creates
                           ▼
                    ┌──────────────┐
                    │   Booking    │
                    ├──────────────┤
                    │ id           │
                    │ userId       │
                    │ show         │
                    │ seats        │
                    │ status       │
                    └──────┬───────┘
                           │
                    ┌──────┴───────┐
                    │              │
                    ▼              ▼
             ┌────────────┐  ┌────────────┐
             │  Payment   │  │   Ticket   │
             └────────────┘  └────────────┘


Movie ────────────────< Show
                        │
                        ▼
                    Theatre
                        │
                        ▼
                      Screen
                        │
                        ▼
                      Seat
```

### 2. Java domain model

```java
class Movie {
    private Long id;
    private String title;
    private String language;
    private int durationMinutes;
}

class Theatre {
    private Long id;
    private String name;
    private String city;
    private List<Screen> screens;
}

class Screen {
    private Long id;
    private String name;
    private List<Seat> seats;
}

class Seat {
    private Long id;
    private String seatNumber;
    private SeatType type;
}

enum SeatType {
    REGULAR,
    PREMIUM,
    RECLINER
}

class Show {
    private Long id;
    private Movie movie;
    private Screen screen;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
}
```

The important point is that **Seat belongs to a Screen**, but its availability is **specific to a Show**.

So don't put:

```java
boolean booked;
```

directly inside `Seat`.

Instead, maintain show-specific seat inventory:

```java
class ShowSeat {
    private Long id;
    private Show show;
    private Seat seat;
    private SeatStatus status;
    private BigDecimal price;
}

enum SeatStatus {
    AVAILABLE,
    LOCKED,
    BOOKED
}
```

---

## 3. Booking model

```java
class Booking {

    private Long id;
    private User user;
    private Show show;
    private List<ShowSeat> seats;

    private BookingStatus status;
    private BigDecimal totalAmount;
    private LocalDateTime createdAt;
}

enum BookingStatus {
    PENDING,
    CONFIRMED,
    FAILED,
    CANCELLED
}
```

Payment:

```java
class Payment {

    private Long id;
    private Long bookingId;
    private BigDecimal amount;
    private PaymentStatus status;
    private String transactionId;
}

enum PaymentStatus {
    INITIATED,
    SUCCESS,
    FAILED,
    REFUNDED
}
```

---

# 4. Service layer

```text
                 ┌───────────────────┐
                 │ BookingController │
                 └─────────┬─────────┘
                           │
                           ▼
                 ┌───────────────────┐
                 │  BookingService   │
                 └───────┬───────────┘
                         │
          ┌──────────────┼──────────────┐
          ▼              ▼              ▼
   SeatLockService PaymentService TicketService
          │              │              │
          ▼              ▼              ▼
        Redis       Payment Gateway    Ticket DB
```

Interfaces:

```java
public interface BookingService {

    BookingResponse bookTicket(
            Long userId,
            Long showId,
            List<Long> seatIds
    );

    void cancelBooking(Long bookingId);
}
```

```java
public interface SeatLockService {

    boolean lockSeats(
            Long showId,
            List<Long> seatIds,
            String lockId
    );

    void releaseSeats(
            Long showId,
            List<Long> seatIds
    );
}
```

```java
public interface PaymentService {

    PaymentResponse pay(
            Long bookingId,
            BigDecimal amount
    );

    void refund(Long bookingId);
}
```

---

# 5. Booking flow

```text
User
 │
 │ Select Movie + Show
 ▼
ShowService
 │
 │ Get available seats
 ▼
SeatInventory
 │
 │ Select A1, A2
 ▼
BookingService
 │
 │ Lock seats
 ▼
Redis / DB
 │
 │ Lock successful
 ▼
PaymentService
 │
 │ Pay ₹500
 ▼
Payment Gateway
 │
 │ SUCCESS
 ▼
BookingService
 │
 │ Mark seats BOOKED
 ▼
TicketService
 │
 ▼
Ticket generated
```

### Why do we lock seats?

Suppose two users simultaneously select **A1**:

```text
User A ──────┐
             ├──> A1
User B ──────┘
```

Without locking:

```text
A checks A1 → AVAILABLE
B checks A1 → AVAILABLE

A books A1
B books A1

❌ Double booking
```

With locking:

```text
A → LOCK A1 → SUCCESS
B → LOCK A1 → FAILED

A → Payment → BOOKED
```

---

# 6. Seat locking with Redis

A typical implementation:

```java
@Service
public class SeatLockServiceImpl
        implements SeatLockService {

    private final RedisTemplate<String, String> redis;

    private static final Duration LOCK_DURATION =
            Duration.ofMinutes(5);

    @Override
    public boolean lockSeats(
            Long showId,
            List<Long> seatIds,
            String lockId) {

        for (Long seatId : seatIds) {

            String key =
                "show:" + showId + ":seat:" + seatId;

            Boolean success = redis.opsForValue()
                    .setIfAbsent(
                        key,
                        lockId,
                        LOCK_DURATION
                    );

            if (!Boolean.TRUE.equals(success)) {
                releaseSeats(showId, seatIds);
                return false;
            }
        }

        return true;
    }

    @Override
    public void releaseSeats(
            Long showId,
            List<Long> seatIds) {

        for (Long seatId : seatIds) {
            String key =
                "show:" + showId + ":seat:" + seatId;

            redis.delete(key);
        }
    }
}
```

In production, the lock/release operation should be made **atomic**—for example using a Redis Lua script or a carefully designed distributed-lock strategy—rather than releasing arbitrary locks that might belong to another booking.

---

# 7. BookingService

```java
@Service
public class BookingServiceImpl
        implements BookingService {

    private final ShowService showService;
    private final SeatLockService seatLockService;
    private final PaymentService paymentService;
    private final BookingRepository bookingRepository;

    @Override
    public BookingResponse bookTicket(
            Long userId,
            Long showId,
            List<Long> seatIds) {

        // 1. Validate show
        Show show = showService.getShow(showId);

        // 2. Validate seats
        showService.validateSeats(show, seatIds);

        String lockId = UUID.randomUUID().toString();

        // 3. Lock seats
        boolean locked =
                seatLockService.lockSeats(
                        showId,
                        seatIds,
                        lockId
                );

        if (!locked) {
            throw new SeatUnavailableException();
        }

        try {
            // 4. Create pending booking
            Booking booking =
                    createPendingBooking(
                        userId,
                        show,
                        seatIds
                    );

            // 5. Payment
            PaymentResponse payment =
                    paymentService.pay(
                        booking.getId(),
                        booking.getTotalAmount()
                    );

            if (!payment.isSuccess()) {
                throw new PaymentFailedException();
            }

            // 6. Confirm booking
            booking.setStatus(
                    BookingStatus.CONFIRMED
            );

            bookingRepository.save(booking);

            // 7. Seats become BOOKED
            showService.markSeatsBooked(
                    showId,
                    seatIds
            );

            return BookingResponse.from(booking);

        } catch (Exception e) {

            seatLockService.releaseSeats(
                    showId,
                    seatIds
            );

            throw e;
        }
    }
}
```

---

# 8. Important database tables

```text
USER
-----
id PK
name
email


MOVIE
-----
id PK
title
language
duration


THEATRE
-------
id PK
name
city


SCREEN
------
id PK
theatre_id FK
name


SEAT
----
id PK
screen_id FK
seat_number
seat_type


SHOW
----
id PK
movie_id FK
screen_id FK
start_time
end_time


SHOW_SEAT
---------
id PK
show_id FK
seat_id FK
price
status


BOOKING
-------
id PK
user_id FK
show_id FK
status
total_amount
created_at


BOOKING_SEAT
------------
booking_id FK
show_seat_id FK


PAYMENT
-------
id PK
booking_id FK
amount
status
transaction_id
```

A useful constraint is:

```text
UNIQUE(show_id, seat_id)
```

on `SHOW_SEAT`.

This ensures that a particular physical seat occurs only once for a particular show.

---

# 9. Interview-level design considerations

### Concurrency

The most important problem is:

> **How do you prevent two users from booking the same seat?**

Use a combination of:

* Redis temporary lock with TTL
* Database transaction
* DB constraint / row locking
* Idempotent payment handling

### Payment failure

```text
Seat selected
     ↓
Seat locked for 5 min
     ↓
Payment
   ↙     ↘
SUCCESS   FAILURE
  ↓          ↓
BOOKED     RELEASE
```

If payment fails, release the lock.

If the user abandons payment, the Redis TTL automatically releases the temporary lock.

### Payment callback

Don't assume the browser response is the final source of truth.

```text
Payment Gateway
       │
       │ webhook
       ▼
PaymentService
       │
       ▼
BookingService
       │
       ▼
CONFIRMED
```

Make the payment callback **idempotent**, because gateways can retry webhooks.

---

## 10. Patterns you can mention in an interview

| Pattern            | Usage                       |
| ------------------ | --------------------------- |
| **Strategy**       | Different payment methods   |
| **Factory**        | Create payment processor    |
| **Repository**     | Database access             |
| **Service Layer**  | Business logic              |
| **Observer/Event** | Notifications after booking |
| **State**          | Booking/payment states      |

For example:

```java
public interface PaymentProcessor {
    PaymentResponse process(PaymentRequest request);
}
```

```java
class CardPaymentProcessor
        implements PaymentProcessor {

    public PaymentResponse process(
            PaymentRequest request) {
        // card payment
    }
}
```

```java
class UpiPaymentProcessor
        implements PaymentProcessor {

    public PaymentResponse process(
            PaymentRequest request) {
        // UPI payment
    }
}
```

Factory:

```java
class PaymentProcessorFactory {

    public PaymentProcessor getProcessor(
            PaymentMethod method) {

        return switch (method) {
            case CARD -> new CardPaymentProcessor();
            case UPI -> new UpiPaymentProcessor();
        };
    }
}
```

### One-line interview summary

> **The core of the Movie Ticket Booking LLD is modeling `Movie → Theatre → Screen → Seat → Show → ShowSeat → Booking`, while using temporary seat locking plus transactional/idempotent booking and payment flows to prevent double booking.**
![Uploading image.png…]()
