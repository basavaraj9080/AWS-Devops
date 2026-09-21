For **Spring Boot 3.5.x + Spring Kafka**, here is a production-oriented `application.yml` you can use as a starting point. It covers producer, consumer, listener behavior, JSON serialization, retries/error handling, and the Kafka settings relevant to the questions we've discussed.

```
spring:
  application:
    name: order-service

  kafka:
    # ============================================================
    # Kafka Cluster
    # ============================================================
    bootstrap-servers: localhost:9092

    # ============================================================
    # Producer Configuration
    # ============================================================
    producer:
      # Wait for acknowledgement from all required in-sync replicas
      acks: all

      # Serializer for message key
      key-serializer: org.apache.kafka.common.serialization.StringSerializer

      # Serializer for message value
      value-serializer: org.springframework.kafka.support.serializer.JsonSerializer

      # Retry transient failures
      retries: 10

      # Prevent duplicate records caused by producer retries
      enable-idempotence: true

      # Controls how many records can be sent before receiving
      # acknowledgements. Keep conservative for strict ordering.
      max-in-flight-requests-per-connection: 5

      # Compression
      compression-type: snappy

      # Batch records for better throughput
      batch-size: 16384

      # Wait up to 5ms for additional records to arrive
      linger-ms: 5

      # Total memory available to the producer for buffering
      buffer-memory: 33554432

      # Maximum size of an individual request
      properties:
        spring.json.add.type.headers: true

    # ============================================================
    # Consumer Configuration
    # ============================================================
    consumer:
      group-id: order-service-group

      # IMPORTANT:
      # Disable Kafka's native auto commit.
      # Spring Kafka listener container manages offsets.
      enable-auto-commit: false

      key-deserializer: org.apache.kafka.common.serialization.StringDeserializer

      value-deserializer: org.springframework.kafka.support.serializer.JsonDeserializer

      # If no committed offset exists, consume from earliest available
      auto-offset-reset: earliest

      # Number of records returned from poll()
      max-poll-records: 500

      # Maximum time between poll() calls
      max-poll-interval-ms: 300000

      # How long consumer waits for broker response
      request-timeout-ms: 30000

      # Session timeout
      session-timeout-ms: 45000

      # Heartbeat interval
      heartbeat-interval-ms: 15000

      properties:
        # Trusted package for JSON deserialization
        spring.json.trusted.packages: "com.example.orders"

        # Optional default type
        spring.json.value.default.type: "com.example.orders.OrderEvent"

    # ============================================================
    # Listener Container
    # ============================================================
    listener:

      # Commit offset after successful processing of each record
      ack-mode: record

      # Number of consumer threads per listener container
      concurrency: 3

      # When listener throws exception, don't commit failed record
      # and allow error handler to process it.
      missing-topics-fatal: false

      # Listener type
      type: single

    # ============================================================
    # Kafka Admin
    # ============================================================
    admin:
      auto-create: true
```

 ## But there is one important correction

 The above is a good **baseline**, but I would **not blindly copy every setting into production**.

 For a 9+ years interview, I'd explain the configuration in terms of responsibilities.

 ### Producer

```
producer:
  acks: all
  enable-idempotence: true
  retries: 10
```

 The idea is:

```
Producer
   │
   ▼
Kafka Leader
   │
   ├── Replica 1
   └── Replica 2
```

 `acks: all` asks Kafka to wait for the required in-sync replicas before acknowledging the write.

 `enable-idempotence: true` helps prevent duplicate records caused by producer retries.

---

 # Consumer

 The important part is:

```
consumer:
  enable-auto-commit: false
```

 Then:

```
listener:
  ack-mode: record
```

 So your application flow is:

```
Kafka
  │
  ▼
Consumer
  │
  ▼
@KafkaListener
  │
  ▼
Process message
  │
  ├── SUCCESS
  │      ↓
  │   Commit offset
  │
  └── FAILURE
         ↓
     Error handling
```

 This is generally preferable to:

```
enable-auto-commit: true
```

 for business-critical processing where you want the listener container to coordinate successful processing with offset commits.

---

 # Example `@KafkaListener`

 With the above configuration:

```
@Service
public class OrderConsumer {

    @KafkaListener(topics = "orders")
    public void consume(OrderEvent event) {

        System.out.println("Received: " + event);

        processOrder(event);
    }

    private void processOrder(OrderEvent event) {
        // Business logic
    }
}
```

 You don't need:

```
acknowledgment.acknowledge();
```

 because we're using:

```
ack-mode: record
```

 Spring Kafka handles the acknowledgment/commit after successful processing.

---

 # If you want explicit manual acknowledgment

 Then change:

```
listener:
  ack-mode: manual
```

 and:

```
@KafkaListener(topics = "orders")
public void consume(
        OrderEvent event,
        Acknowledgment acknowledgment) {

    processOrder(event);

    acknowledgment.acknowledge();
}
```

 The flow becomes:

```
Read
 ↓
Process
 ↓
Success?
 ├── Yes → acknowledge()
 │           ↓
 │        Commit
 │
 └── No  → Exception
            ↓
         Don't ACK
```

 For most normal Spring Boot applications, however, I would first consider `ack-mode: record` and use Spring Kafka's error-handling facilities rather than manually managing commits in every listener.

---

 # Production configuration: add error handling

 For a real production application, I would also configure a `DefaultErrorHandler` in Java rather than trying to put all retry behavior into `application.yml`.

 For example:

```
@Configuration
public class KafkaConfig {

    @Bean
    public DefaultErrorHandler kafkaErrorHandler() {

        FixedBackOff backOff =
                new FixedBackOff(1000L, 3);

        return new DefaultErrorHandler(backOff);
    }
}
```

 This means roughly:

```
Message
   ↓
Processing fails
   ↓
Wait 1 second
   ↓
Retry
   ↓
Fails
   ↓
Wait 1 second
   ↓
Retry
   ↓
Fails
   ↓
Retry
   ↓
Fails
   ↓
Error handler gives up
```

 For a serious production system, you'd often add a **Dead Letter Topic (DLT)** after retries are exhausted.

---

 # Recommended architecture for your interview preparation

 Since you're preparing Kafka questions at the **9+ years level**, keep this mental model:

```
                         Kafka Cluster
                              │
             ┌────────────────┼────────────────┐
             │                │                │
          Broker 1         Broker 2         Broker 3
             │                │                │
          P0 Leader        P1 Leader        P2 Leader
             │                │                │
          Replicas         Replicas         Replicas
             │
             ▼
        Consumer Group
             │
       ┌─────┼─────┐
       ▼     ▼     ▼
      C1    C2    C3
       │     │     │
       └─────┼─────┘
             ▼
        Spring Kafka
             │
             ▼
       Business Logic
             │
       ┌─────┴─────┐
       │           │
    Success      Failure
       │           │
    Commit       Retry
                   │
                  DLT
```

 And the important configuration concepts are:

```
Producer
  ├── acks
  ├── idempotence
  ├── retries
  ├── key
  └── serializer

Consumer
  ├── group-id
  ├── enable-auto-commit
  ├── auto-offset-reset
  ├── max-poll-records
  └── deserializer

Listener
  ├── ack-mode
  ├── concurrency
  └── error handling

Kafka Cluster
  ├── partitions
  ├── replication factor
  ├── ISR
  ├── leader
  └── min.insync.replicas
```

 **One thing to keep separate:** the Spring Boot `application.yml` configures your **application's Kafka producer/consumer clients**. Settings such as `replication.factor`, `min.insync.replicas`, and broker-level settings are Kafka **broker/topic configuration**, not normally something you put under `spring.kafka.consumer` or `spring.kafka.producer`.
