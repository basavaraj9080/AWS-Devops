<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/6d103aaf-2e4e-4dad-bdfc-01ed9124f5fe" />
</br>
>
# 🚕 Cab Booking System — Low Level Design (LLD) in Java

For a cab-booking system like Uber/Ola, the core problem is **finding an available driver, temporarily assigning the ride, handling concurrent requests, and completing payment**.

---

## 1. Core LLD

```text
                         ┌──────────────┐
                         │     User     │
                         ├──────────────┤
                         │ id           │
                         │ name         │
                         │ phone        │
                         └──────┬───────┘
                                │
                                │ books
                                ▼
                         ┌──────────────┐
                         │     Ride     │
                         ├──────────────┤
                         │ id           │
                         │ user         │
                         │ driver       │
                         │ pickup       │
                         │ destination  │
                         │ status       │
                         │ fare         │
                         └──────┬───────┘
                                │
                ┌───────────────┼────────────────┐
                │               │                │
                ▼               ▼                ▼
        ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
        │    Driver    │ │    Payment   │ │   Location   │
        ├──────────────┤ ├──────────────┤ ├──────────────┤
        │ id           │ │ id           │ │ latitude     │
        │ name         │ │ rideId       │ │ longitude    │
        │ vehicle      │ │ amount       │ └──────────────┘
        │ status       │ │ status       │
        └──────┬───────┘ └──────────────┘
               │
               ▼
        ┌──────────────┐
        │   Vehicle    │
        ├──────────────┤
        │ number       │
        │ type         │
        │ model        │
        └──────────────┘
```

---

# 2. Main Entities

### User

```java
public class User {
    private Long id;
    private String name;
    private String phone;
    private String email;
}
```

### Driver

```java
public class Driver {
    private Long id;
    private String name;
    private String phone;
    private Vehicle vehicle;
    private DriverStatus status;
    private Location currentLocation;
}
```

```java
public enum DriverStatus {
    OFFLINE,
    AVAILABLE,
    ASSIGNED,
    ON_TRIP
}
```

### Vehicle

```java
public class Vehicle {
    private Long id;
    private String registrationNumber;
    private String model;
    private VehicleType type;
}
```

```java
public enum VehicleType {
    MINI,
    SEDAN,
    SUV,
    PREMIUM
}
```

---

# 3. Location

```java
public class Location {

    private double latitude;
    private double longitude;

    public Location(double latitude, double longitude) {
        this.latitude = latitude;
        this.longitude = longitude;
    }
}
```

In a production system, driver locations would typically be updated frequently and stored in a geo-index such as Redis GEO or another location service.

---

# 4. Ride

```java
public class Ride {

    private Long id;
    private User user;
    private Driver driver;

    private Location pickup;
    private Location destination;

    private RideStatus status;

    private BigDecimal estimatedFare;
    private BigDecimal finalFare;

    private LocalDateTime createdAt;
}
```

```java
public enum RideStatus {

    REQUESTED,
    SEARCHING_DRIVER,
    DRIVER_ASSIGNED,
    DRIVER_ARRIVED,
    TRIP_STARTED,
    COMPLETED,
    CANCELLED
}
```

---

# 5. Payment

```java
public class Payment {

    private Long id;
    private Long rideId;

    private BigDecimal amount;
    private PaymentMethod method;
    private PaymentStatus status;

    private String transactionId;
}
```

```java
public enum PaymentMethod {
    CASH,
    CARD,
    UPI
}

public enum PaymentStatus {
    INITIATED,
    SUCCESS,
    FAILED,
    REFUNDED
}
```

---

# 6. Service Architecture

```text
                   ┌───────────────┐
                   │   REST API    │
                   └───────┬───────┘
                           │
                           ▼
                  ┌─────────────────┐
                  │  RideService    │
                  └────────┬────────┘
                           │
             ┌─────────────┼──────────────┐
             │             │              │
             ▼             ▼              ▼
     ┌──────────────┐ ┌────────────┐ ┌──────────────┐
     │ DriverSearch │ │ FareService│ │PaymentService│
     │   Service    │ │            │ │              │
     └──────┬───────┘ └────────────┘ └──────────────┘
            │
            ▼
     ┌──────────────┐
     │ Location     │
     │ Service      │
     └──────────────┘
```

---

# 7. Driver Matching

The most important part of the LLD is:

> **How do we find an available driver near the customer?**

Create an abstraction:

```java
public interface DriverMatchingStrategy {

    Driver findDriver(
            Location pickup,
            VehicleType vehicleType
    );
}
```

Implementation:

```java
public class NearestDriverStrategy
        implements DriverMatchingStrategy {

    private final DriverRepository driverRepository;

    @Override
    public Driver findDriver(
            Location pickup,
            VehicleType vehicleType) {

        List<Driver> drivers =
                driverRepository.findAvailableDrivers(
                        pickup,
                        vehicleType
                );

        return drivers.stream()
                .min(Comparator.comparingDouble(
                        d -> distance(
                                pickup,
                                d.getCurrentLocation()
                        )))
                .orElse(null);
    }

    private double distance(
            Location a,
            Location b) {

        // Haversine / geo-distance calculation
        return 0.0;
    }
}
```

This is a good use of the **Strategy Pattern**.

Later you can introduce:

```text
NearestDriverStrategy
HighestRatedDriverStrategy
ShortestETA Strategy
SurgeAwareMatchingStrategy
```

without changing `RideService`.

---

# 8. Ride Service

```java
public interface RideService {

    Ride requestRide(
            Long userId,
            Location pickup,
            Location destination,
            VehicleType vehicleType
    );

    void cancelRide(Long rideId);

    void startRide(Long rideId);

    void completeRide(Long rideId);
}
```

Implementation:

```java
@Service
public class RideServiceImpl implements RideService {

    private final UserRepository userRepository;
    private final DriverMatchingStrategy matchingStrategy;
    private final RideRepository rideRepository;
    private final FareService fareService;

    @Override
    public Ride requestRide(
            Long userId,
            Location pickup,
            Location destination,
            VehicleType vehicleType) {

        User user =
                userRepository.findById(userId);

        BigDecimal fare =
                fareService.calculateFare(
                        pickup,
                        destination,
                        vehicleType
                );

        Ride ride = new Ride();

        ride.setUser(user);
        ride.setPickup(pickup);
        ride.setDestination(destination);
        ride.setEstimatedFare(fare);
        ride.setStatus(
                RideStatus.SEARCHING_DRIVER
        );

        rideRepository.save(ride);

        Driver driver =
                matchingStrategy.findDriver(
                        pickup,
                        vehicleType
                );

        if (driver == null) {
            ride.setStatus(RideStatus.CANCELLED);
            rideRepository.save(ride);

            throw new NoDriverAvailableException();
        }

        driver.setStatus(DriverStatus.ASSIGNED);

        ride.setDriver(driver);
        ride.setStatus(RideStatus.DRIVER_ASSIGNED);

        rideRepository.save(ride);

        return ride;
    }
}
```

---

# 9. Fare Calculation

Use Strategy Pattern here as well.

```java
public interface FareStrategy {

    BigDecimal calculate(
            double distanceKm,
            double durationMinutes
    );
}
```

For example:

```java
public class StandardFareStrategy
        implements FareStrategy {

    private static final BigDecimal BASE_FARE =
            BigDecimal.valueOf(50);

    private static final BigDecimal
            PER_KM = BigDecimal.valueOf(15);

    private static final BigDecimal
            PER_MINUTE = BigDecimal.valueOf(2);

    @Override
    public BigDecimal calculate(
            double distanceKm,
            double durationMinutes) {

        return BASE_FARE
                .add(PER_KM.multiply(
                        BigDecimal.valueOf(distanceKm)))
                .add(PER_MINUTE.multiply(
                        BigDecimal.valueOf(durationMinutes)));
    }
}
```

Other strategies could be:

```text
StandardFareStrategy
PremiumFareStrategy
SurgeFareStrategy
AirportFareStrategy
```

---

# 10. Booking / Driver Assignment Concurrency

This is one of the **most important interview questions**.

Suppose two customers request a ride near the same driver:

```text
             Driver D1
              AVAILABLE
              /       \
             /         \
          User A      User B
```

Without concurrency control:

```text
User A → finds D1 available
User B → finds D1 available

User A → assigns D1
User B → assigns D1

❌ Same driver assigned to two rides
```

We need an atomic operation:

```text
AVAILABLE → ASSIGNED
```

Only one request should succeed.

### Database approach

```sql
UPDATE driver
SET status = 'ASSIGNED'
WHERE id = ?
AND status = 'AVAILABLE';
```

Then check the affected row count:

```text
1 → assignment successful
0 → someone else got the driver
```

This is much safer than:

```java
if (driver.getStatus() == AVAILABLE) {
    driver.setStatus(ASSIGNED);
}
```

because that check-and-update is not atomic.

---

# 11. Driver Repository

```java
public interface DriverRepository {

    List<Driver> findAvailableDrivers(
            Location location,
            VehicleType vehicleType
    );

    boolean assignDriver(Long driverId);

    void releaseDriver(Long driverId);
}
```

Implementation conceptually:

```sql
UPDATE drivers
SET status = 'ASSIGNED'
WHERE id = :driverId
  AND status = 'AVAILABLE';
```

---

# 12. Complete Booking Flow

```text
User
 │
 │ Request ride
 ▼
RideController
 │
 ▼
RideService
 │
 ├── Calculate Fare
 │
 ├── Find nearby drivers
 │
 ▼
DriverMatchingStrategy
 │
 ▼
Location Service / Redis GEO
 │
 ▼
Nearest drivers
 │
 ▼
Atomic driver assignment
 │
 ├──── failure ────> Try next driver
 │
 ▼
Driver ASSIGNED
 │
 ▼
Notify Driver
 │
 ▼
Driver accepts
 │
 ▼
Driver arrives
 │
 ▼
START RIDE
 │
 ▼
TRIP_STARTED
 │
 ▼
Destination reached
 │
 ▼
Calculate final fare
 │
 ▼
Payment
 │
 ▼
COMPLETED
```

---

# 13. Sequence Diagram

```text
User       RideService    DriverService    PaymentService
 │              │               │                │
 │ Request Ride │               │                │
 ├─────────────>│               │                │
 │              │               │                │
 │              │ Find Driver   │                │
 │              ├──────────────>│                │
 │              │               │                │
 │              │  Driver       │                │
 │              │<──────────────┤                │
 │              │               │                │
 │              │ Assign Driver │                │
 │              ├──────────────>│                │
 │              │               │                │
 │              │   Assigned    │                │
 │              │<──────────────┤                │
 │              │               │                │
 │ Driver arrives               │                │
 │              │               │                │
 │ Start Ride   │               │                │
 ├─────────────>│               │                │
 │              │               │                │
 │              │ Trip Started  │                │
 │              │               │                │
 │ Complete     │               │                │
 ├─────────────>│               │                │
 │              │               │                │
 │              │ Calculate Fare│                │
 │              │               │                │
 │              │ Payment       │                │
 │              ├───────────────────────────────>│
 │              │               │                │
 │              │               │    Success     │
 │              │<───────────────────────────────┤
 │              │               │                │
 │   Receipt    │               │                │
 │<─────────────┤               │                │
```

---

# 14. Database Design

```text
USER
----
id PK
name
phone
email


DRIVER
------
id PK
name
phone
vehicle_id FK
status
current_latitude
current_longitude


VEHICLE
-------
id PK
registration_number
model
type


RIDE
----
id PK
user_id FK
driver_id FK
pickup_latitude
pickup_longitude
destination_latitude
destination_longitude
status
estimated_fare
final_fare
created_at


PAYMENT
-------
id PK
ride_id FK
amount
method
status
transaction_id
created_at
```

---

# 15. Production Architecture

```text
                  ┌───────────────┐
                  │ Mobile / Web  │
                  └───────┬───────┘
                          │
                    Load Balancer
                          │
          ┌───────────────┼────────────────┐
          ▼               ▼                ▼
   ┌────────────┐  ┌────────────┐  ┌─────────────┐
   │ Ride       │  │ Driver     │  │ Payment     │
   │ Service    │  │ Service    │  │ Service     │
   └─────┬──────┘  └─────┬──────┘  └──────┬──────┘
         │               │                │
         └───────────────┼────────────────┘
                         │
              ┌──────────┴──────────┐
              │                     │
         ┌────▼─────┐         ┌─────▼─────┐
         │  Redis   │         │ PostgreSQL│
         │ GEO/Cache│         │           │
         └──────────┘         └───────────┘
              │
              ▼
       ┌──────────────┐
       │ Kafka / MQ   │
       └──────┬───────┘
              │
      ┌───────┼─────────┐
      ▼       ▼         ▼
 Notification Analytics Location
```

### Why Redis?

For a cab system, constantly querying PostgreSQL for:

> "Find available drivers within 3 km of this location"

doesn't scale well.

A geo-index such as Redis GEO can be used for nearby-driver lookup.

### Why Kafka/message queue?

Non-critical asynchronous work can be moved out of the booking path:

```text
Ride completed
      │
      ▼
Kafka Event
  ┌───┼───────┐
  ▼   ▼       ▼
SMS Email  Analytics
```

The user shouldn't have to wait for every notification/analytics operation before the ride request completes.

---

## 16. Most Important Interview Points

If this is a **45–60 minute Java LLD interview**, concentrate on these:

1. **Entities:** `User`, `Driver`, `Vehicle`, `Ride`, `Payment`, `Location`
2. **Ride state machine:** `REQUESTED → DRIVER_ASSIGNED → ON_TRIP → COMPLETED`
3. **Strategy Pattern:** driver matching and fare calculation
4. **Concurrency:** atomic `AVAILABLE → ASSIGNED`
5. **Location search:** geo-index / Redis GEO
6. **Payment:** interface + multiple payment implementations
7. **Failure handling:** no driver, driver rejects, payment fails, cancellation
8. **Idempotency:** payment callbacks and ride-completion APIs
9. **Async events:** notifications and analytics through a message queue
10. **Persistence:** transactional updates for ride/driver state

### One-line interview summary

> **The core LLD is `User → Ride → Driver → Vehicle`, with Strategy-based driver matching/fare calculation, a geo-index for nearby drivers, and atomic driver assignment to prevent the same driver from being assigned to multiple rides.**
