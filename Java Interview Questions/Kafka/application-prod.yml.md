Yes. For **Spring Boot 3.5.x + Spring Kafka \+ Confluent Schema Registry \+ SASL/SSL + Avro \+ retries + DLT**, I'd structure the configuration like this.

 One important point: **YAML can configure the Kafka clients, but `DefaultErrorHandler` \+ `DeadLetterPublishingRecoverer` should still be configured in Java**. Don't try to force the entire retry/DLT mechanism into YAML.

 ## `application.yml`

```
spring:
  application:
    name: order-service

  kafka:

    # ============================================================
    # KAFKA CLUSTER
    # ============================================================
    bootstrap-servers: ${KAFKA_BOOTSTRAP_SERVERS}

    # ============================================================
    # COMMON SECURITY
    # ============================================================
    security:
      protocol: SASL_SSL

    properties:

      # ----------------------------------------------------------
      # SASL
      # ----------------------------------------------------------
      sasl:
        mechanism: ${KAFKA_SASL_MECHANISM:PLAIN}

        jaas:
          config: >-
            org.apache.kafka.common.security.plain.PlainLoginModule required
            username="${KAFKA_USERNAME}"
            password="${KAFKA_PASSWORD}";

    # ============================================================
    # SSL / TLS
    # ============================================================
    ssl:
      protocol: TLSv1.3

      enabled-protocols:
        - TLSv1.2
        - TLSv1.3

      trust-store-location: ${KAFKA_TRUSTSTORE_LOCATION}
      trust-store-password: ${KAFKA_TRUSTSTORE_PASSWORD}
      trust-store-type: JKS

    # ============================================================
    # PRODUCER
    # ============================================================
    producer:

      key-serializer: org.apache.kafka.common.serialization.StringSerializer

      value-serializer: io.confluent.kafka.serializers.KafkaAvroSerializer

      # ----------------------------------------------------------
      # Durability
      # ----------------------------------------------------------

      # Wait for all required in-sync replicas
      acks: all

      # Retry transient failures
      retries: 10

      # Producer idempotence
      properties:
        enable.idempotence: true

        # Maximum number of unacknowledged requests
        max.in.flight.requests.per.connection: 5

        # --------------------------------------------------------
        # Timeouts
        # --------------------------------------------------------

        request.timeout.ms: 30000

        delivery.timeout.ms: 120000

        # --------------------------------------------------------
        # Performance
        # --------------------------------------------------------

        linger.ms: 5

        batch.size: 32768

        compression.type: zstd

        # --------------------------------------------------------
        # Schema Registry
        # --------------------------------------------------------

        schema.registry.url: ${SCHEMA_REGISTRY_URL}

        basic.auth.credentials.source: USER_INFO

        schema.registry.basic.auth.user.info: >-
          ${SCHEMA_REGISTRY_USERNAME}:${SCHEMA_REGISTRY_PASSWORD}

        # --------------------------------------------------------
        # Schema Registry TLS
        # --------------------------------------------------------

        schema.registry.ssl.truststore.location: ${SCHEMA_REGISTRY_TRUSTSTORE_LOCATION}

        schema.registry.ssl.truststore.password: ${SCHEMA_REGISTRY_TRUSTSTORE_PASSWORD}

        schema.registry.ssl.truststore.type: JKS

        # --------------------------------------------------------
        # Avro
        # --------------------------------------------------------

        # Recommended when schemas are managed through CI/CD
        # rather than dynamically created by applications.
        auto.register.schemas: false

    # ============================================================
    # CONSUMER
    # ============================================================
    consumer:

      group-id: ${KAFKA_CONSUMER_GROUP:order-service}

      key-deserializer: org.apache.kafka.common.serialization.StringDeserializer

      value-deserializer: io.confluent.kafka.serializers.KafkaAvroDeserializer

      # ----------------------------------------------------------
      # Offset Management
      # ----------------------------------------------------------

      # Let Spring Kafka manage offsets
      enable-auto-commit: false

      # Used only when no committed offset exists
      auto-offset-reset: earliest

      # ----------------------------------------------------------
      # Performance
      # ----------------------------------------------------------

      max-poll-records: 500

      fetch-min-size: 1

      fetch-max-wait: 500

      # ----------------------------------------------------------
      # Consumer Stability
      # ----------------------------------------------------------

      properties:

        session.timeout.ms: 45000

        heartbeat.interval.ms: 15000

        max.poll.interval.ms: 300000

        # --------------------------------------------------------
        # Schema Registry
        # --------------------------------------------------------

        schema.registry.url: ${SCHEMA_REGISTRY_URL}

        basic.auth.credentials.source: USER_INFO

        schema.registry.basic.auth.user.info: >-
          ${SCHEMA_REGISTRY_USERNAME}:${SCHEMA_REGISTRY_PASSWORD}

        # --------------------------------------------------------
        # Schema Registry TLS
        # --------------------------------------------------------

        schema.registry.ssl.truststore.location: ${SCHEMA_REGISTRY_TRUSTSTORE_LOCATION}

        schema.registry.ssl.truststore.password: ${SCHEMA_REGISTRY_TRUSTSTORE_PASSWORD}

        schema.registry.ssl.truststore.type: JKS

        # --------------------------------------------------------
        # Avro
        # --------------------------------------------------------

        specific.avro.reader: true

    # ============================================================
    # LISTENER
    # ============================================================
    listener:

      # Commit after successful processing of each record
      ack-mode: record

      # Number of Kafka consumer threads
      concurrency: 3

      # Don't fail application startup if topic doesn't exist
      missing-topics-fatal: false

    # ============================================================
    # ADMIN
    # ============================================================
    admin:

      # Recommended to manage topics through IaC/DevOps
      # rather than automatically creating them.
      auto-create: false

      operation-timeout: 30s

    # ============================================================
    # NON-BLOCKING RETRY TOPICS
    # ============================================================
    #
    # Disabled because the configuration below uses
    # DefaultErrorHandler + DeadLetterPublishingRecoverer.
    #
    retry:
      topic:
        enabled: false
```

 ## Environment variables

 The production application should provide secrets externally:

```
KAFKA_BOOTSTRAP_SERVERS=kafka-1:9093,kafka-2:9093,kafka-3:9093

KAFKA_USERNAME=order-service

KAFKA_PASSWORD=<secret>

KAFKA_SASL_MECHANISM=SCRAM-SHA-512

KAFKA_TRUSTSTORE_LOCATION=/etc/kafka/secrets/kafka-truststore.jks

KAFKA_TRUSTSTORE_PASSWORD=<secret>

SCHEMA_REGISTRY_URL=https://schema-registry:8081

SCHEMA_REGISTRY_USERNAME=order-service

SCHEMA_REGISTRY_PASSWORD=<secret>

SCHEMA_REGISTRY_TRUSTSTORE_LOCATION=/etc/kafka/secrets/schema-registry-truststore.jks

SCHEMA_REGISTRY_TRUSTSTORE_PASSWORD=<secret>

KAFKA_CONSUMER_GROUP=order-service
```

 Don't put those actual passwords in Git.

---

 # DLT + Retry Java configuration

 I would keep this separate from `application.yml`.

```
@Configuration
public class KafkaErrorHandlerConfig {

    @Bean
    public DefaultErrorHandler kafkaErrorHandler(
            KafkaTemplate<Object, Object> kafkaTemplate) {

        DeadLetterPublishingRecoverer recoverer =
                new DeadLetterPublishingRecoverer(
                        kafkaTemplate,
                        (record, exception) ->
                                new TopicPartition(
                                        record.topic() + ".DLT",
                                        record.partition()
                                )
                );

        ExponentialBackOff backOff =
                new ExponentialBackOff(1000L, 2.0);

        backOff.setMaxElapsedTime(30_000L);

        return new DefaultErrorHandler(
                recoverer,
                backOff
        );
    }
}
```

 The resulting flow is:

```
                 orders
                    │
                    ▼
              Kafka Consumer
                    │
                    ▼
              @KafkaListener
                    │
             ┌──────┴──────┐
             │             │
          SUCCESS        FAILURE
             │             │
             ▼             ▼
        Commit offset    Retry
                           │
                     ┌─────┴─────┐
                     │           │
                   Retry       Retry
                     │           │
                     └─────┬─────┘
                           │
                    Retry exhausted
                           │
                           ▼
                       orders.DLT
```

 ## Listener

 Your application code remains clean:

```
@KafkaListener(topics = "orders")
public void consume(OrderEvent event) {

    orderService.process(event);
}
```

 No manual commit is necessary because:

```
spring:
  kafka:
    consumer:
      enable-auto-commit: false

    listener:
      ack-mode: record
```

 means Spring Kafka handles the offset after successful listener processing.

---

 ## Production architecture

 For the setup you're preparing for in a **9+ years interview**, I'd describe the complete flow as:

```
                         ┌──────────────────┐
                         │    Producer      │
                         │                  │
                         │ Idempotence      │
                         │ acks=all         │
                         │ retries          │
                         └────────┬─────────┘
                                  │
                              SASL_SSL
                                  │
                                  ▼
                    ┌─────────────────────────┐
                    │      Kafka Cluster      │
                    │                         │
                    │ Broker 1   Broker 2     │
                    │    │          │         │
                    │  Leader    Replica      │
                    │    │          │         │
                    │    └──── ISR ─┘         │
                    └──────────┬──────────────┘
                               │
                               ▼
                         Consumer Group
                               │
                               ▼
                         Spring Kafka
                               │
                         @KafkaListener
                               │
                       ┌───────┴────────┐
                       │                │
                    Success          Failure
                       │                │
                       ▼                ▼
                  Commit offset       Retry
                                         │
                                         ▼
                                       DLT
                                         │
                                         ▼
                                  Manual Recovery

             ┌───────────────────────────────┐
             │       Schema Registry         │
             │                               │
             │ Avro schemas                  │
             │ Compatibility                 │
             │ Schema versions               │
             └───────────────────────────────┘
```

 ### The key production settings to remember

```
producer:
  acks: all
  retries: 10
  enable.idempotence: true

consumer:
  enable-auto-commit: false
  auto-offset-reset: earliest

listener:
  ack-mode: record
```

 And then:

 **SASL\_SSL + Schema Registry + Avro + DefaultErrorHandler + exponential backoff + DLT + monitoring.**

 One caveat: the exact SASL mechanism and TLS configuration depends on whether you're running **self-managed Kafka, Confluent Platform/Cloud, AWS MSK, or another managed Kafka service**. The YAML above is a solid generic production baseline, but those provider-specific security properties should be adjusted accordingly.
