# Data Consistency Across Microservices

## Interview Question

### How do you make sure data stays consistent across different services, especially if a message fails or gets delayed during processing?

---

# Interview-Ready Answer

In a microservices architecture, each service typically owns its own database, which makes maintaining consistency across services more challenging than in a monolithic application.

To handle this, I use the **Saga Pattern** instead of distributed database transactions. Each service performs its own local transaction and publishes an event that triggers the next step in the business workflow.

For example, in an order-processing system, the Order Service creates the order and publishes an event to Kafka. The Payment Service consumes the event and processes the payment, and then the Inventory Service updates stock levels.

If a Kafka message fails or gets delayed, I use retries with exponential backoff. If processing continues to fail after the configured retry attempts, the message is moved to a Dead Letter Topic (DLT) for investigation and replay.

To prevent duplicate processing, I implement idempotent consumers using unique event IDs or transaction IDs.

I also use the **Transactional Outbox Pattern** to ensure that database updates and event publication remain synchronized, preventing situations where data is saved but the event is never published.

This approach provides **eventual consistency** across services. If a business operation cannot be completed successfully, the Saga executes compensating actions such as refunding a payment or releasing reserved inventory.

Finally, I use monitoring, correlation IDs, distributed tracing, and reconciliation jobs to detect and resolve inconsistencies proactively.

---

# Why Data Consistency Is Challenging

In a monolithic application:

```text
Application
     |
 Single Database
```

A single database transaction can ensure consistency.

In microservices:

```text
Order Service      -> Order DB
Payment Service    -> Payment DB
Inventory Service  -> Inventory DB
```

There is no shared transaction spanning all databases.

As a result:

- Messages may be delayed
- Services may be unavailable
- Events may arrive multiple times
- Partial updates may occur

This is why we use Event-Driven Architecture and Saga patterns.

---

# Order Processing Example

## Successful Flow

```text
Order Service
      |
      | OrderCreated Event
      v
Kafka Topic
      |
      v
Payment Service
      |
      | PaymentCompleted Event
      v
Kafka Topic
      |
      v
Inventory Service
      |
      | InventoryReserved Event
      v
Order Confirmed
```

---

# Solution 1: Saga Pattern

## What Is Saga?

Saga is a sequence of local transactions across multiple services.

Each service:

1. Performs its own transaction.
2. Publishes an event.
3. Triggers the next service.

### Example

```text
Step 1:
Order Service
Create Order

Step 2:
Payment Service
Process Payment

Step 3:
Inventory Service
Reserve Inventory

Step 4:
Order Confirmed
```

---

## What Happens If Inventory Fails?

```text
Order Created
      |
Payment Success
      |
Inventory Failed
```

The Saga triggers compensating actions:

```text
Inventory Failed
      |
Refund Payment
      |
Cancel Order
```

Result:

```text
System Returns To Consistent State
```

---

# Saga Approaches

## 1. Choreography-Based Saga

Services communicate through events.

```text
Order Service
      |
      v
Payment Service
      |
      v
Inventory Service
```

Advantages:

- Loosely coupled
- Easy to start

Disadvantages:

- Complex workflows become harder to track

---

## 2. Orchestration-Based Saga

A central orchestrator drives the workflow.

```text
Saga Orchestrator
       |
       +--> Order Service
       +--> Payment Service
       +--> Inventory Service
```

Advantages:

- Centralized control
- Easier monitoring

Disadvantages:

- Additional component to maintain

---

# Solution 2: Kafka Retries

## Temporary Failures

Examples:

- Database unavailable
- Network timeout
- Dependent service unavailable

Use retries with exponential backoff.

### Example

```text
Attempt 1 -> Fail

Wait 2 sec

Attempt 2 -> Fail

Wait 4 sec

Attempt 3 -> Success
```

### Spring Kafka Example

```java
@RetryableTopic(
    attempts = "3",
    backoff = @Backoff(
        delay = 2000,
        multiplier = 2
    )
)
@KafkaListener(topics = "orders")
public void processOrder(Order order) {
    paymentService.process(order);
}
```

---

# Solution 3: Dead Letter Topic (DLT)

## Problem

Some messages will never succeed.

Example:

```json
{
  "orderId": null
}
```

or

```json
{
  "customerId": ""
}
```

Retries will not fix invalid data.

---

## Solution

Move failed messages to DLT.

```text
orders-topic
      |
retry-topic-1
      |
retry-topic-2
      |
orders-dlt
```

---

## DLT Handler

```java
@DltHandler
public void processFailedMessage(Order order) {

    log.error(
        "Message moved to DLT {}",
        order
    );
}
```

Benefits:

- Prevents consumer blockage
- Allows manual investigation
- Supports replay after correction

---

# Solution 4: Idempotent Consumers

## Problem

Kafka guarantees:

```text
At-Least-Once Delivery
```

The same event may be delivered multiple times.

---

## Example

```text
Order #123 Received
```

Consumer processes payment.

```text
Payment Successful
```

Before committing offset:

```text
Consumer Crashes
```

Kafka redelivers message.

```text
Order #123 Received Again
```

Without protection:

```text
Payment Charged Twice
```

---

## Solution

Use Event IDs.

### Event

```json
{
  "eventId": "EVT-1001",
  "orderId": 123
}
```

### Consumer

```java
if(alreadyProcessed(eventId)) {
    return;
}

processPayment();
saveProcessedEvent(eventId);
```

Result:

```text
Duplicate Event Ignored
```

---

## Database Constraint Approach

```sql
CREATE TABLE payments (
    order_id BIGINT UNIQUE
);
```

This prevents duplicate payment creation.

---

# Solution 5: Transactional Outbox Pattern

## Problem

Consider this scenario:

```text
Order Saved To Database
         |
Application Crashes
         |
Event Not Published
```

Result:

```text
Order Exists
But No Event Generated
```

Other services never know the order was created.

---

## Outbox Solution

Write business data and event into the same transaction.

```text
+--------------------+
| Order Table        |
+--------------------+

+--------------------+
| Outbox Table       |
+--------------------+
```

Single Transaction:

```text
Save Order
Save Outbox Record
Commit
```

A background process publishes events from the Outbox table to Kafka.

---

## Flow

```text
Order Service
      |
Save Order
      |
Save Outbox Event
      |
Commit Transaction
      |
Outbox Publisher
      |
Kafka
```

Benefits:

- No lost events
- Consistent state
- Reliable messaging

---

# Handling Delayed Messages

## Problem

Events may arrive late.

```text
Order Event Arrives
      |
Network Delay
      |
Payment Event Arrives Later
```

---

## Techniques

### Event IDs

```text
EVT-1001
EVT-1002
EVT-1003
```

Track processing status.

---

### Versioning

```json
{
  "orderId": 101,
  "version": 5
}
```

Ignore stale updates.

---

### Event Ordering

Use ordering only when business requirements demand it.

```text
Partition By OrderId
```

This ensures related events remain ordered.

---

# Reconciliation Jobs

## Why Needed?

Even with retries and sagas, rare inconsistencies can occur.

---

## Example

```text
Order = CONFIRMED

Payment = SUCCESS

Inventory = NOT RESERVED
```

---

## Solution

Periodic reconciliation job:

```text
Scan Orders
Compare States
Repair Inconsistencies
```

Typical actions:

- Re-trigger event
- Notify operations team
- Start compensation flow

---

# Monitoring & Traceability

## Correlation IDs

```text
CORR-12345
```

Used across all services.

Example:

```text
Order Service
     |
Payment Service
     |
Inventory Service
```

Same correlation ID follows entire request lifecycle.

---

## Distributed Tracing

Tools:

- Zipkin
- Jaeger
- OpenTelemetry

Benefits:

- Trace request flow
- Detect bottlenecks
- Identify failure points

---

# Reliability Patterns Summary

| Problem | Solution |
|----------|----------|
| Temporary processing failure | Retry with exponential backoff |
| Message permanently invalid | Dead Letter Topic (DLT) |
| Duplicate events | Idempotent Consumer |
| Database updated but event lost | Transactional Outbox |
| Multi-service business transaction | Saga Pattern |
| Delayed messages | Event IDs / Versioning / Ordering |
| Cross-service inconsistencies | Reconciliation Jobs |
| Service observability | Correlation IDs & Distributed Tracing |

---

# Important Interview Point

> Kafka's Exactly-Once Semantics (EOS) helps avoid duplicate message processing within Kafka, but it does not automatically guarantee exactly-once business effects across multiple independent databases.
>
> Idempotency, Saga design, and proper transaction handling are still required to ensure consistency.

---

# If Interviewer Asks: "Which Approach Have You Used?"

### Safe Answer

> In Spring Boot and Kafka-based microservices, I primarily focus on reliable event processing using retries, exponential backoff, Dead Letter Topics, and idempotent consumers. For maintaining consistency across services, I use event-driven architecture principles and understand Saga and Transactional Outbox patterns for coordinating cross-service business transactions. Depending on workflow complexity, I would choose Saga choreography or orchestration, combined with Outbox for reliable event publishing.

---

# Golden Interview Statement

> To maintain consistency across microservices, I use Saga patterns for distributed business workflows, Kafka retries and DLTs for message failures, idempotent consumers to handle duplicate delivery, and the Transactional Outbox pattern to guarantee reliable event publication. Since each service owns its own database, I rely on eventual consistency, compensating transactions, monitoring, and reconciliation processes to ensure the system remains consistent even when messages are delayed or failures occur..
> </br>
<img width="952" height="1816" alt="mermaid-diagram (1)" src="https://github.com/user-attachments/assets/5d298745-dd08-450a-a623-bd8aaad8fb1c" />
