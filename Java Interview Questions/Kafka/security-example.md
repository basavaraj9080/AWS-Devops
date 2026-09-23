Order Service
     │
     │ 1. Get access token
     ▼
Identity Provider
(Keycloak / Okta / Azure AD / Auth0)
     │
     │ 2. JWT
     ▼
Order Service
     │
     │ 3. Authorization: Bearer <JWT>
     ▼
Payment Service
     │
     │ 4. Validate JWT
     ▼
Allow / Reject

>
>This diagram shows **how one backend service securely calls another backend service using a JWT access token**.

 Think of it as:

 > **Order Service proves who it is → Identity Provider gives it a token → Order Service presents that token to Payment Service → Payment Service verifies it → request is allowed or rejected.**

 ### Step by step

```
Order Service
     │
     │ 1. Get access token
     ▼
Identity Provider
(Keycloak / Okta / Azure AD / Auth0)
```

 **1\. Order Service asks for an access token.**

 The Order Service needs to call the Payment Service.

 Instead of sending a username/password to Payment Service, it contacts an **Identity Provider (IdP)** such as Keycloak, Okta, Azure AD, or Auth0.

 The IdP authenticates the Order Service and issues an **access token**, commonly a JWT.

---

```
Identity Provider
     │
     │ 2. JWT
     ▼
Order Service
```

 **2\. Identity Provider returns the JWT.**

 A JWT might conceptually contain information like:

```
{
  "iss": "https://auth.example.com",
  "sub": "order-service",
  "aud": "payment-service",
  "scope": "payments:write",
  "exp": 1790000000
}
```

 The JWT says, roughly:

 - **Who issued this?** → `iss`
- **Who/what is this token for?** → `sub`
- **Which service is supposed to receive it?** → `aud`
- **What is it allowed to do?** → `scope`
- **When does it expire?** → `exp`

 The actual JWT is cryptographically signed by the Identity Provider.

---

```
Order Service
     │
     │ 3. Authorization: Bearer <JWT>
     ▼
Payment Service
```

 **3\. Order Service calls Payment Service with the token.**

 For example:

```
POST /payments
Authorization: Bearer eyJhbGciOiJSUzI1NiIs...
Content-Type: application/json
```

 `Bearer` essentially means:

 > "The caller presenting this access token is asking you to authorize this request."

---

```
Payment Service
     │
     │ 4. Validate JWT
     ▼
Allow / Reject
```

 **4\. Payment Service validates the JWT.**

 This is the important security step.

 Payment Service checks things such as:

 - Is the JWT's **signature valid**?
- Was it issued by the trusted Identity Provider?
- Has it **expired**?
- Is the token intended for **Payment Service** (`aud`)?
- Does it have the required **scope/role/permission**?
- Is the token otherwise acceptable according to the service's security configuration?

 If everything is valid:

```
JWT valid + permission sufficient
              ↓
            ALLOW
```

 If something is wrong:

```
JWT invalid/expired/unauthorized
              ↓
            REJECT
```

 Usually an authentication failure results in **401 Unauthorized**, while an authenticated caller lacking sufficient permission commonly results in **403 Forbidden**.

 ## The key idea

 There are actually **two different questions** happening:

 ### Authentication — "Who are you?"

 The **Identity Provider** handles this.

```
Order Service → IdP
                  ↓
              JWT token
```

 ### Authorization — "Are you allowed to do this?"

 The **Payment Service** makes this decision based on the token and its authorization rules.

```
Order Service → Payment Service
                    ↓
              validate JWT
                    ↓
             allowed/rejected
```

 So the Identity Provider does **not necessarily approve every individual payment operation**. It issues an identity/access token, while the Payment Service uses that token to decide whether the particular request is authorized.

 ### One important distinction

 **JWT validation does not mean merely decoding the JWT.**

 Anyone can decode the payload of a JWT. The Payment Service needs to verify its **cryptographic signature** and validate claims such as issuer, audience, expiry, and permissions.

 A simplified architecture is therefore:

```
                    ┌──────────────────┐
                    │ Identity Provider│
                    │ Keycloak / Okta  │
                    └────────┬─────────┘
                             │
                    1. Token │
                             ▼
┌───────────────┐    2. JWT     ┌────────────────┐
│ Order Service │ ────────────► │ Payment Service│
└───────────────┘               └───────┬────────┘
                                        │
                                 3. Validate
                                    JWT
                                        │
                                  ┌─────┴─────┐
                                  ▼           ▼
                                Allow       Reject
```

 In other words, **the JWT is the credential that travels between services; the Identity Provider is the trusted issuer; and the Payment Service is responsible for validating the credential and enforcing authorization.**

---
---
Yes — if the interviewer is asking **service-to-service security**, they are looking beyond Kafka security. They want to know how you secure **microservice A → microservice B**, how B authenticates A, how authorization works, and how this changes between dev/staging/prod.

 A strong production-level answer is:

 ## 1\. Typical architecture

```
                         ┌──────────────────┐
                         │   API Gateway    │
                         └────────┬─────────┘
                                  │ JWT
                                  ▼
                         ┌──────────────────┐
                         │   Order Service  │
                         └────────┬─────────┘
                                  │
                       Service-to-Service
                         authentication
                                  │
                         JWT / OAuth2
                         + mTLS (prod)
                                  │
                                  ▼
                         ┌──────────────────┐
                         │ Payment Service  │
                         └──────────────────┘
```

 The important concepts are:

 - **Authentication** → "Who is calling me?"
- **Authorization** → "Is this service allowed to perform this operation?"
- **Encryption** → "Can somebody intercept the communication?"
- **Secret management** → "Where are credentials stored?"
- **Network security** → "Who can reach this service?"

---

 # 2\. JWT between services

 A common approach is OAuth2/OIDC with JWT.

 For example:

```
Order Service
     │
     │ 1. Get access token
     ▼
Identity Provider
(Keycloak / Okta / Azure AD / Auth0)
     │
     │ 2. JWT
     ▼
Order Service
     │
     │ 3. Authorization: Bearer <JWT>
     ▼
Payment Service
     │
     │ 4. Validate JWT
     ▼
Allow / Reject
```

 The JWT could contain:

```
{
  "iss": "https://identity.example.com",
  "sub": "order-service",
  "aud": "payment-service",
  "scope": "payment:write",
  "exp": 1760000000
}
```

 The receiving service validates:

 - Signature
- Issuer (`iss`)
- Audience (`aud`)
- Expiration (`exp`)
- Required scopes/roles

 **Do not simply decode a JWT and trust its contents.** The signature and claims must be validated.

---

 # 3\. Spring Boot example

 If you're using Spring Boot, the receiving service can be configured as an OAuth2 Resource Server.

 ### `application.yml`

```
spring:
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: ${JWT_ISSUER_URI}
```

 Then Spring Security discovers the provider's public keys and validates JWTs.

 Security configuration:

```
@Configuration
@EnableMethodSecurity
public class SecurityConfig {

    @Bean
    SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        return http
            .csrf(csrf -> csrf.disable())
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/actuator/health").permitAll()
                .requestMatchers(HttpMethod.POST, "/payments/**")
                    .hasAuthority("SCOPE_payment:write")
                .requestMatchers(HttpMethod.GET, "/payments/**")
                    .hasAuthority("SCOPE_payment:read")
                .anyRequest().authenticated()
            )
            .oauth2ResourceServer(oauth2 -> oauth2.jwt())
            .build();
    }
}
```

 Now:

```
POST /payments
Authorization: Bearer <JWT>
```

 requires:

```
scope = payment:write
```

 That's **authorization**, not just authentication.

---

 # 4\. How does Order Service get the JWT?

 For machine-to-machine communication, I would generally use **OAuth2 Client Credentials Grant**.

```
Order Service
      │
      │ client_id + client_secret
      ▼
Identity Provider
      │
      │ access_token
      ▼
Order Service
      │
      │ Authorization: Bearer JWT
      ▼
Payment Service
```

 There is no human user involved.

 For example:

```
spring:
  security:
    oauth2:
      client:
        registration:
          payment-service:
            authorization-grant-type: client_credentials
            client-id: ${PAYMENT_CLIENT_ID}
            client-secret: ${PAYMENT_CLIENT_SECRET}
            scope:
              - payment:write

        provider:
          payment-service:
            token-uri: ${OAUTH_TOKEN_URI}
```

 In production, the secret should **not** be committed into `application.yml`.

 Use:

```
Environment variables
        ↓
Secret Manager / Vault
        ↓
Application
```

 For example:

```
client-secret: ${PAYMENT_CLIENT_SECRET}
```

---

 # 5\. JWT alone isn't the entire production security story

 This is where you can make your interview answer stronger.

 For production service-to-service communication, I would use:

```
                    ┌────────────────────────┐
                    │   Identity Provider    │
                    │ Keycloak / Okta / etc. │
                    └───────────┬────────────┘
                                │
                         OAuth2 / OIDC
                                │
                                ▼
┌─────────────┐          JWT Access Token          ┌───────────────┐
│Order Service│ ─────────────────────────────────► │Payment Service│
└─────────────┘                                    └───────────────┘
       │                                                   │
       │                    TLS / mTLS                    │
       └───────────────────────────────────────────────────┘
```

 Layers:

 ### Authentication

```
OAuth2 Client Credentials
+
JWT
```

 ### Authorization

```
Scopes / Roles / Permissions
```

 Example:

```
order-service
    ↓
payment:write
    ↓
payment-service
```

 ### Encryption

```
HTTPS / TLS
```

 ### Strong workload identity

 For higher-security environments:

```
mTLS
```

 This gives the receiving service cryptographic proof of the calling workload.

---

 # 6\. Lower environment vs production

 This is another area interviewers often expect you to explain.

 ### Local

 You might use:

```
security:
  enabled: false
```

 or a local Keycloak instance:

```
Docker Compose
   │
   ├── Keycloak
   ├── Kafka
   ├── Order Service
   └── Payment Service
```

 But **don't design production security around local shortcuts**.

 ### Dev/Staging

 Use a real identity provider:

```
Order Service
      ↓
Dev Keycloak / Okta tenant
      ↓
JWT
      ↓
Payment Service
```

 Secrets come from environment-specific secret storage.

 ### Production

```
Production IdP
      ↓
Short-lived access tokens
      ↓
mTLS/TLS
      ↓
Service
      ↓
Authorization
      ↓
Business operation
```

 And additionally:

 - Secret manager
- Certificate rotation
- Network policies/firewalls
- Private service endpoints
- Least-privilege service accounts
- Audit logging
- Security monitoring
- Rate limiting
- Vulnerability scanning
- Dependency/container scanning
- Key rotation
- Proper token expiration
- No secrets in Git
- No sensitive information in logs

---

 # 7\. Don't put JWT secrets in `application.yml`

 This is **bad**:

```
spring:
  security:
    oauth2:
      client:
        registration:
          payment:
            client-id: order-service
            client-secret: my-secret-password
```

 Instead:

```
spring:
  security:
    oauth2:
      client:
        registration:
          payment:
            client-id: ${PAYMENT_CLIENT_ID}
            client-secret: ${PAYMENT_CLIENT_SECRET}
```

 And production:

```
AWS Secrets Manager
        ↓
Kubernetes Secret / workload identity
        ↓
Environment / mounted secret
        ↓
Spring Boot
```

 Even better, where supported, use **workload identity / private-key-based authentication** rather than long-lived shared client secrets.

---

 # 8\. Service authorization should be fine-grained

 Don't just check:

```
.authenticated()
```

 For example:

```
.requestMatchers(HttpMethod.POST, "/payments/**")
    .hasAuthority("SCOPE_payment:write")
```

 You can also use method-level authorization:

```
@PreAuthorize("hasAuthority('SCOPE_payment:write')")
public Payment createPayment(PaymentRequest request) {
    // business logic
}
```

 This means:

```
Authentication
      ↓
Is this a valid service?
      ↓
Authorization
      ↓
Does it have payment:write?
      ↓
Business logic
```

---

 # 9\. Kafka security is a separate layer

 Since your previous question was about Kafka, make this distinction in the interview.

 Suppose:

```
Order Service
      │
      ├──── REST ────► Payment Service
      │                  │
      │                  └── JWT/OAuth2 + TLS
      │
      └──── Kafka ────► Kafka
                         │
                         └── SASL/TLS + ACL
```

 For REST:

```
OAuth2/JWT
TLS/mTLS
Authorization
```

 For Kafka:

```
TLS
SASL
ACLs
Network security
```

 **JWT authentication for REST does not automatically secure Kafka.** Kafka has its own authentication and authorization mechanisms.

---

 # 10\. A strong interview answer

 If the interviewer asks:

 > **"How do you secure communication between two microservices in production?"**

 I'd answer:

 > "For service-to-service communication, I use OAuth2/OIDC with service identities. The calling service authenticates with the identity provider using the client-credentials flow and obtains a short-lived access token. It sends that token to the downstream service over TLS. The receiving service acts as an OAuth2 resource server and validates the JWT signature, issuer, audience, expiry and scopes. Authentication establishes the caller's identity, while authorization is handled using scopes or roles so that a service only gets the permissions it needs.
>
>  For stronger production security, I also use mTLS or a service mesh where appropriate, so both sides have cryptographic workload identities. Secrets and private keys are stored in a secret manager and rotated rather than being committed to configuration files. Network policies restrict which services can communicate, and we add rate limiting, audit logging, monitoring, certificate/key rotation and vulnerability scanning.
>
>  In lower environments, we use the same security model with separate identity-provider tenants/configuration and non-production secrets. We avoid disabling authentication entirely because we want lower environments to behave as closely as possible to production.
>
>  For Kafka, I use a separate security layer — TLS for encryption, SASL for broker authentication, and Kafka ACLs for authorization."

 ### The key sentence to remember

 **"Authentication tells me which service is calling; authorization tells me what that service is allowed to do; TLS/mTLS protects the communication channel; and network controls, secret management, logging, and rotation provide the additional production security layers."**

 That framing is usually much stronger in an interview than answering only **"we use JWT."**

 ---
 ---
 ---
 Yes. Below is a **production-oriented Spring Boot example** showing only the **security-related configuration** for:

 1. `order-service → payment-service` using OAuth2/JWT
2. `order-service → Kafka → payment-service` using TLS + SASL/SCRAM + ACLs
3. Lower-environment vs production configuration
4. Where each configuration belongs

 I'll assume **Spring Boot 3.x + Spring Security 6 + Kafka 4/KRaft**.

---

 # 1\. Overall architecture

```
                         Identity Provider
                    ┌────────────────────────┐
                    │ Keycloak / Okta / Azure │
                    │ AD / Auth0              │
                    └───────────┬────────────┘
                                │
                         Client Credentials
                                │
                         Short-lived JWT
                                │
                                ▼
┌─────────────────┐       HTTPS + JWT       ┌──────────────────┐
│  Order Service  │ ──────────────────────► │ Payment Service  │
│                 │                          │                  │
│ OAuth2 Client   │                          │ Resource Server  │
└────────┬────────┘                          └──────────────────┘
         │
         │ TLS + SASL/SCRAM
         │
         ▼
┌─────────────────────────────────────────────────────────────┐
│                         Kafka Cluster                        │
│                                                             │
│ TLS + SASL/SCRAM + ACL                                      │
│                                                             │
│ orders topic                                                │
└─────────────────────────────────────────────────────────────┘
         │
         │ TLS + SASL/SCRAM
         ▼
┌──────────────────┐
│ Payment Service  │
│ Kafka Consumer   │
└──────────────────┘
```

 There are **two completely different security mechanisms** here:

```
REST:
OAuth2 + JWT + TLS

Kafka:
TLS + SASL/SCRAM + ACL
```

---

 # 2\. Order Service → Payment Service

 ## Order Service

 The Order Service is the **OAuth2 client**.

 It obtains an access token from the Identity Provider and sends:

```
Authorization: Bearer <access-token>
```

 to Payment Service.

 ### `order-service/application.yml`

```
spring:
  security:
    oauth2:
      client:
        registration:
          payment-service:
            provider: company-idp
            authorization-grant-type: client_credentials
            client-id: ${PAYMENT_CLIENT_ID}
            client-secret: ${PAYMENT_CLIENT_SECRET}
            scope:
              - payment:write

        provider:
          company-idp:
            token-uri: ${OAUTH_TOKEN_URI}
```

 Notice that the actual secret isn't here:

```
client-secret: ${PAYMENT_CLIENT_SECRET}
```

 The value comes from the environment/secret manager.

---

 # 3\. Order Service Security Configuration

```
@Configuration
public class OAuth2ClientConfig {

    @Bean
    OAuth2AuthorizedClientManager authorizedClientManager(
            ClientRegistrationRepository registrations,
            OAuth2AuthorizedClientService clientService) {

        var provider = OAuth2AuthorizedClientProviderBuilder.builder()
                .clientCredentials()
                .build();

        var manager = new AuthorizedClientServiceOAuth2AuthorizedClientManager(
                registrations,
                clientService
        );

        manager.setAuthorizedClientProvider(provider);

        return manager;
    }
}
```

 Then configure a `RestClient` to automatically obtain the token.

```
@Configuration
public class RestClientSecurityConfig {

    @Bean
    RestClient paymentRestClient(
            OAuth2AuthorizedClientManager authorizedClientManager) {

        var interceptor =
                new OAuth2ClientHttpRequestInterceptor(
                        authorizedClientManager
                );

        interceptor.setClientRegistrationIdResolver(
                request -> "payment-service"
        );

        return RestClient.builder()
                .requestInterceptor(interceptor)
                .baseUrl("https://payment-service:8443")
                .build();
    }
}
```

 Now when Order Service calls:

```
paymentRestClient
    .post()
    .uri("/payments")
    .body(paymentRequest)
    .retrieve()
    .toBodilessEntity();
```

 the OAuth2 client obtains an access token and sends it to Payment Service.

 Conceptually:

```
Order Service
      │
      │ client_id + client_secret
      ▼
Identity Provider
      │
      │ JWT access token
      ▼
Order Service
      │
      │ Authorization: Bearer JWT
      │ HTTPS
      ▼
Payment Service
```

---

 # 4\. Payment Service

 Payment Service is an **OAuth2 Resource Server**.

 ### `payment-service/application.yml`

```
spring:
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: ${JWT_ISSUER_URI}
```

 For example:

```
JWT_ISSUER_URI=https://identity.company.com/realms/company
```

 Spring Security uses the issuer to discover the provider's public signing keys and validate the JWT.

---

 # 5\. Payment Service Security Configuration

```
@Configuration
@EnableMethodSecurity
public class SecurityConfig {

    @Bean
    SecurityFilterChain securityFilterChain(HttpSecurity http)
            throws Exception {

        return http
                .csrf(csrf -> csrf.disable())

                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/actuator/health")
                        .permitAll()

                        .requestMatchers(HttpMethod.POST, "/payments/**")
                        .hasAuthority("SCOPE_payment:write")

                        .requestMatchers(HttpMethod.GET, "/payments/**")
                        .hasAuthority("SCOPE_payment:read")

                        .anyRequest()
                        .authenticated()
                )

                .oauth2ResourceServer(oauth2 ->
                        oauth2.jwt(jwt -> {})
                )

                .build();
    }
}
```

 Now Payment Service requires:

```
POST /payments
```

 to have:

```
scope = payment:write
```

 So this is not enough:

```
JWT is valid
```

 It must also have:

```
payment:write
```

---

 # 6\. Example JWT

 The Identity Provider could issue something conceptually like:

```
{
  "iss": "https://identity.company.com",
  "sub": "order-service",
  "aud": "payment-service",
  "scope": "payment:write",
  "exp": 1760000000
}
```

 Payment Service validates:

```
✓ Signature
✓ Issuer
✓ Audience
✓ Expiration
✓ Scope
```

 Then:

```
payment:write
       │
       ▼
POST /payments
       │
       ▼
Allowed
```

 But:

```
inventory:read
       │
       ▼
POST /payments
       │
       ▼
403 Forbidden
```

 That's the difference between **authentication and authorization**.

---

 # 7\. TLS between services

 JWT does not replace TLS.

 You still want:

```
Order Service
      │
      │ HTTPS
      │
      ▼
Payment Service
```

 For production, Payment Service should expose HTTPS.

 For example:

```
server:
  port: 8443

  ssl:
    enabled: true
    key-store: ${TLS_KEYSTORE_PATH}
    key-store-password: ${TLS_KEYSTORE_PASSWORD}
    key-store-type: PKCS12
    key-alias: payment-service
```

 And Order Service trusts the Payment Service certificate through its truststore.

```
spring:
  ssl:
    bundle:
      jks:
        payment-service:
          truststore:
            location: ${TLS_TRUSTSTORE_PATH}
            password: ${TLS_TRUSTSTORE_PASSWORD}
            type: PKCS12
```

 The exact Spring SSL configuration can vary with the Spring Boot version and HTTP client being used, but the production concept is:

```
TLS certificate
       +
Truststore
       +
HTTPS
```

---

 # 8\. Even stronger: mTLS

 If your company requires strong workload identity, use **mutual TLS**.

 Normal TLS:

```
Order ──────TLS──────► Payment
                      │
                 proves identity
```

 mTLS:

```
Order ──────mTLS─────► Payment
  │                     │
  │ certificate         │ certificate
  │                     │
  └──── both verify ────┘
```

 Payment Service requires:

```
server:
  ssl:
    enabled: true
    client-auth: need
```

 Now both services authenticate cryptographically.

 In larger Kubernetes environments, a **service mesh** can also provide mTLS, certificate rotation, and workload identity without putting all of that logic into application code.

---

 # 9\. Now Kafka security

 This is separate from the REST security.

 We have:

```
Order Service
      │
      │ TLS + SASL/SCRAM
      ▼
    Kafka
      │
      │ TLS + SASL/SCRAM
      ▼
Payment Service
```

 We want:

```
Authentication:
    SASL/SCRAM

Encryption:
    TLS

Authorization:
    Kafka ACLs
```

---

 # 10\. Kafka broker configuration

 For example, Kafka:

```
services:

  kafka:
    image: apache/kafka:4.0.0

    environment:

      KAFKA_NODE_ID: 1

      KAFKA_PROCESS_ROLES: broker,controller

      KAFKA_CONTROLLER_QUORUM_VOTERS: 1@kafka:9094

      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: >
        BROKER:SASL_SSL,
        CONTROLLER:SASL_SSL,
        CLIENT:SASL_SSL

      KAFKA_LISTENERS: >
        BROKER://0.0.0.0:9092,
        CONTROLLER://0.0.0.0:9094,
        CLIENT://0.0.0.0:9093

      KAFKA_ADVERTISED_LISTENERS: >
        BROKER://kafka:9092,
        CLIENT://kafka:9093

      KAFKA_INTER_BROKER_LISTENER_NAME: BROKER

      KAFKA_CONTROLLER_LISTENER_NAMES: CONTROLLER

      # TLS
      KAFKA_SSL_KEYSTORE_LOCATION: /etc/kafka/secrets/kafka.keystore.p12
      KAFKA_SSL_TRUSTSTORE_LOCATION: /etc/kafka/secrets/kafka.truststore.p12

      KAFKA_SSL_KEYSTORE_PASSWORD: ${KAFKA_KEYSTORE_PASSWORD}
      KAFKA_SSL_KEY_PASSWORD: ${KAFKA_KEY_PASSWORD}
      KAFKA_SSL_TRUSTSTORE_PASSWORD: ${KAFKA_TRUSTSTORE_PASSWORD}

      KAFKA_SSL_KEYSTORE_TYPE: PKCS12
      KAFKA_SSL_TRUSTSTORE_TYPE: PKCS12

      KAFKA_SSL_PROTOCOL: TLSv1.3
      KAFKA_SSL_ENABLED_PROTOCOLS: TLSv1.3

      # SASL
      KAFKA_SASL_ENABLED_MECHANISMS: SCRAM-SHA-512

      KAFKA_SASL_MECHANISM_INTER_BROKER_PROTOCOL: SCRAM-SHA-512

      # Authorization
      KAFKA_AUTHORIZER_CLASS_NAME: org.apache.kafka.metadata.authorizer.StandardAuthorizer

      KAFKA_ALLOW_EVERYONE_IF_NO_ACL_FOUND: "false"

      KAFKA_AUTO_CREATE_TOPICS_ENABLE: "false"
```

 This is **Kafka infrastructure configuration**, so it belongs in the Kafka deployment configuration such as:

```
docker-compose.yml
```

 or Kubernetes/Helm configuration in a real production deployment.

---

 # 11\. Order Service Kafka client

 Order Service is a Kafka producer.

 ### `order-service/application.yml`

```
spring:
  kafka:

    bootstrap-servers: ${KAFKA_BOOTSTRAP_SERVERS}

    properties:

      security.protocol: SASL_SSL

      sasl.mechanism: SCRAM-SHA-512

      sasl.jaas.config: >
        org.apache.kafka.common.security.scram.ScramLoginModule required
        username="${KAFKA_USERNAME}"
        password="${KAFKA_PASSWORD}";

      ssl.truststore.location: ${KAFKA_TRUSTSTORE_PATH}

      ssl.truststore.password: ${KAFKA_TRUSTSTORE_PASSWORD}

      ssl.truststore.type: PKCS12

    producer:

      key-serializer: org.apache.kafka.common.serialization.StringSerializer

      value-serializer: org.springframework.kafka.support.serializer.JsonSerializer
```

 Notice:

```
security.protocol: SASL_SSL
```

 This means:

```
SASL → authenticate
SSL  → encrypt
```

---

 # 12\. Payment Service Kafka client

 Payment Service is a Kafka consumer.

 ### `payment-service/application.yml`

```
spring:
  kafka:

    bootstrap-servers: ${KAFKA_BOOTSTRAP_SERVERS}

    properties:

      security.protocol: SASL_SSL

      sasl.mechanism: SCRAM-SHA-512

      sasl.jaas.config: >
        org.apache.kafka.common.security.scram.ScramLoginModule required
        username="${KAFKA_USERNAME}"
        password="${KAFKA_PASSWORD}";

      ssl.truststore.location: ${KAFKA_TRUSTSTORE_PATH}

      ssl.truststore.password: ${KAFKA_TRUSTSTORE_PASSWORD}

      ssl.truststore.type: PKCS12

    consumer:

      group-id: payment-service

      key-deserializer: org.apache.kafka.common.serialization.StringDeserializer

      value-deserializer: org.springframework.kafka.support.serializer.JsonDeserializer
```

 So both services authenticate to Kafka independently.

---

 # 13\. Kafka users

 Don't use one Kafka credential for every service.

 Create separate identities:

```
order-service
payment-service
notification-service
```

 For example:

```
order-service
    │
    └── can WRITE → orders

payment-service
    │
    └── can READ → orders
```

 This is **least privilege**.

---

 # 14\. Kafka ACLs

 For example, allow Order Service to produce to `orders`:

```
kafka-acls.sh \
  --bootstrap-server kafka:9093 \
  --command-config admin.properties \
  --add \
  --allow-principal User:order-service \
  --operation Write \
  --topic orders
```

 Payment Service can consume:

```
kafka-acls.sh \
  --bootstrap-server kafka:9093 \
  --command-config admin.properties \
  --add \
  --allow-principal User:payment-service \
  --operation Read \
  --topic orders \
  --group payment-service
```

 Now:

```
order-service
      │
      │ WRITE
      ▼
   orders topic
      │
      │ READ
      ▼
payment-service
```

 But if Order Service tries:

```
READ orders
```

 it gets denied if that ACL wasn't granted.

---

 # 15\. Kafka security flow

 This is a very good interview diagram to remember:

```
Order Service
     │
     │ Username + Password
     │
     │ SASL/SCRAM
     │
     │ TLS encryption
     ▼
┌──────────────────┐
│      Kafka       │
│                  │
│ Authentication   │
│      ↓           │
│ SASL/SCRAM       │
│      ↓           │
│ Authorization     │
│      ↓           │
│ Kafka ACL         │
└────────┬─────────┘
         │
         │ TLS + SASL
         ▼
Payment Service
```

---

 # 16\. Lower environment configuration

 For local development, you can simplify things.

 For example:

```
spring:
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: ${JWT_ISSUER_URI}

  kafka:
    bootstrap-servers: ${KAFKA_BOOTSTRAP_SERVERS}
```

 Then:

 ### Local

```
JWT_ISSUER_URI=http://localhost:8080/realms/local
KAFKA_BOOTSTRAP_SERVERS=localhost:9093
```

 ### Dev

```
JWT_ISSUER_URI=https://keycloak-dev.company.com/realms/company
KAFKA_BOOTSTRAP_SERVERS=kafka-dev.company.internal:9093
```

 ### Production

```
JWT_ISSUER_URI=https://identity.company.com/realms/company
KAFKA_BOOTSTRAP_SERVERS=kafka-prod.company.internal:9093
```

 The application code remains the same.

 Only environment-specific configuration changes.

---

 # 17\. Recommended project structure

 I'd structure the two services roughly like this:

```
order-service/
│
├── src/main/java/
│   └── ...
│
├── src/main/resources/
│   ├── application.yml
│   ├── application-local.yml
│   ├── application-dev.yml
│   └── application-prod.yml
│
├── Dockerfile
└── pom.xml

payment-service/
│
├── src/main/java/
│   └── ...
│
├── src/main/resources/
│   ├── application.yml
│   ├── application-local.yml
│   ├── application-dev.yml
│   └── application-prod.yml
│
├── Dockerfile
└── pom.xml

infrastructure/
│
├── docker-compose.yml
│
├── kafka/
│   ├── server.properties
│   └── acl/
│
└── certificates/
```

---

 # 18\. What belongs where?

 This is probably the most important part for your interview.

 | Security concern | Where |
| --- | --- |
| OAuth2 client configuration | `order-service/application.yml` |
| JWT resource server | `payment-service/application.yml` |
| Spring Security authorization | Java `SecurityConfig` |
| TLS for Spring Boot HTTPS | Application config / certificates |
| mTLS | Application/server or service mesh |
| Kafka client security | Each service's `application.yml` |
| Kafka broker TLS | Kafka broker configuration |
| Kafka SASL | Kafka broker configuration |
| Kafka ACLs | Kafka/admin/infrastructure configuration |
| Kafka certificates | Secret manager / mounted secrets |
| OAuth client secret | Secret manager |
| Kafka password | Secret manager |
| Network policies | Kubernetes/cloud/network infrastructure |
| Firewall/security groups | Cloud/infrastructure |
| Certificate rotation | PKI/secret-management infrastructure |

---

 # 19\. Production vs lower environment

 I would explain it like this in an interview:

```
                    LOCAL
                      │
            Simplified configuration
                      │
                      ▼
                    DEV
                      │
              Real OAuth2/JWT
              TLS + Kafka SASL
                      │
                      ▼
                   STAGING
                      │
              Production-like
                      │
                      ▼
                  PRODUCTION
                      │
        ┌─────────────┼──────────────┐
        ▼             ▼              ▼
     OAuth2          mTLS          Kafka ACL
     JWT             / TLS         SASL/TLS
        │             │              │
        └─────────────┼──────────────┘
                      ▼
              Secret Management
                      │
                      ▼
               Monitoring/Audit
```

 The key principle is:

 > **Don't make lower environments completely insecure if you can avoid it. Use the same security architecture with different credentials, certificates, Identity Provider realms/tenants, and infrastructure.**

---

 # 20\. What I would say to the interviewer

 You can give this answer almost directly:

 > **"For service-to-service communication, I separate authentication, authorization and transport security. For REST communication, the calling service uses OAuth2 client credentials to obtain a short-lived JWT from our Identity Provider. The receiving service is configured as an OAuth2 Resource Server and validates the JWT signature, issuer, audience and expiration. We then use scopes or roles for authorization, so for example Order Service can have `payment:write` but not arbitrary Payment Service permissions. Communication itself is protected with TLS, and for high-security production workloads we can use mTLS or a service mesh for workload identity."**
>
>  **"For Kafka, I don't use the REST JWT mechanism directly. Kafka has its own security layer. We use TLS for encryption, SASL/SCRAM for client authentication, and Kafka ACLs for authorization. Each microservice has its own Kafka identity. For example, Order Service gets WRITE access to the orders topic, while Payment Service gets READ access to that topic and its consumer group. We follow least privilege."**
>
>  **"Secrets such as OAuth client credentials, Kafka passwords and private keys are never committed to Git. They come from a secret manager and are rotated. In dev, staging and production we use separate identities, certificates, topics and credentials, while keeping the same security model as much as possible. Network policies, private endpoints, audit logs, monitoring, certificate rotation and vulnerability scanning are additional production controls."**

 ### The mental model to remember

```
                SERVICE SECURITY
                       │
        ┌──────────────┼──────────────┐
        ▼              ▼              ▼
 Authentication   Authorization   Encryption
        │              │              │
      OAuth2          Scopes          TLS
      JWT             Roles           mTLS
      mTLS            ACLs
        │              │
        └──────────────┼──────────────┐
                       ▼              ▼
                 REST API          Kafka
                 JWT + TLS       SASL + TLS
                 Scopes             ACLs
```

 If you can explain **that diagram + the Spring configurations above**, you're covering the main security questions an interviewer is likely to ask around **microservice-to-microservice communication and Kafka security**.

 ---
 ---

 Yes. Below is a **complete runnable reference project** you can use as an interview/demo project.

 It contains:

 - `order-service`
- `payment-service`
- Keycloak for OAuth2/JWT
- Kafka
- REST security: OAuth2 Client Credentials + JWT
- Kafka security: SASL/SCRAM
- Kafka authorization concept via separate service credentials
- Docker Compose
- Environment-specific configuration
- Secrets externalized through environment variables
- Spring Security configuration
- Kafka producer/consumer security

 I’ll use **Java 21 + Spring Boot 3.x \+ Maven**.

 > This is intentionally focused on **security configuration**, not business logic.

---

 # 1\. Project structure

```
secure-microservices/
│
├── docker-compose.yml
├── .env.example
├── .gitignore
│
├── keycloak/
│   └── realm-export.json
│
├── order-service/
│   ├── pom.xml
   │
│   └── src/
│       └── main/
│           ├── java/com/example/order/
│           │   ├── OrderServiceApplication.java
│           │   ├── config/
│           │   │   ├── OAuth2ClientConfig.java
│           │   │   ├── RestClientConfig.java
│           │   │   └── KafkaProducerConfig.java
│           │   └── controller/
│           │       └── OrderController.java
│           │
│           └── resources/
│               ├── application.yml
│               └── application-prod.yml
│
└── payment-service/
    ├── pom.xml
    │
    └── src/
        └── main/
            ├── java/com/example/payment/
            │   ├── PaymentServiceApplication.java
            │   ├── config/
            │   │   ├── SecurityConfig.java
            │   │   └── KafkaConsumerConfig.java
            │   └── controller/
            │       └── PaymentController.java
            │
            └── resources/
                ├── application.yml
                └── application-prod.yml
```

---

 # 2\. Docker Compose

 The local environment will contain:

```
Keycloak
   │
   └── issues JWT

Kafka
   │
   ├── order-service credentials
   └── payment-service credentials

Order Service
   │
   ├── REST + JWT ──────► Payment Service
   │
   └── Kafka producer ──► Kafka

Payment Service
   │
   ├── REST JWT validation
   │
   └── Kafka consumer
```

 ## `docker-compose.yml`

```
services:

  postgres:
    image: postgres:16
    container_name: security-postgres
    environment:
      POSTGRES_DB: keycloak
      POSTGRES_USER: keycloak
      POSTGRES_PASSWORD: keycloak
    volumes:
      - postgres-data:/var/lib/postgresql/data
    networks:
      - secure-network

  keycloak:
    image: quay.io/keycloak/keycloak:26.3
    container_name: security-keycloak

    command:
      - start-dev
      - --import-realm

    environment:
      KC_DB: postgres
      KC_DB_URL: jdbc:postgresql://postgres:5432/keycloak
      KC_DB_USERNAME: keycloak
      KC_DB_PASSWORD: keycloak

      KC_BOOTSTRAP_ADMIN_USERNAME: admin
      KC_BOOTSTRAP_ADMIN_PASSWORD: admin

    ports:
      - "8080:8080"

    volumes:
      - ./keycloak/realm-export.json:/opt/keycloak/data/import/realm-export.json:ro

    depends_on:
      - postgres

    networks:
      - secure-network

  kafka:
    image: bitnami/kafka:3.9
    container_name: security-kafka

    ports:
      - "9093:9093"

    environment:

      # --------------------------------------------------
      # KRaft
      # --------------------------------------------------

      KAFKA_CFG_NODE_ID: 1

      KAFKA_CFG_PROCESS_ROLES: broker,controller

      KAFKA_CFG_CONTROLLER_QUORUM_VOTERS: 1@kafka:9094

      KAFKA_CFG_CONTROLLER_LISTENER_NAMES: CONTROLLER

      # --------------------------------------------------
      # Listeners
      # --------------------------------------------------

      KAFKA_CFG_LISTENERS: >
        INTERNAL://:9092,
       EXTERNAL://:9093,
       CONTROLLER://:9094

      KAFKA_CFG_ADVERTISED_LISTENERS: >
        INTERNAL://kafka:9092,
       EXTERNAL://localhost:9093

      KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP: >
        INTERNAL:SASL_PLAINTEXT,
       EXTERNAL:SASL_PLAINTEXT,
       CONTROLLER:PLAINTEXT

      KAFKA_CFG_INTER_BROKER_LISTENER_NAME: INTERNAL

      # --------------------------------------------------
      # SASL
      # --------------------------------------------------

      KAFKA_CFG_SASL_ENABLED_MECHANISMS: SCRAM-SHA-512

      KAFKA_CFG_SASL_MECHANISM_INTER_BROKER_PROTOCOL: SCRAM-SHA-512

      # --------------------------------------------------
      # Users
      # --------------------------------------------------

      KAFKA_CLIENT_USERS: admin,order-service,payment-service

      KAFKA_CLIENT_PASSWORDS: admin-password,order-password,payment-password

      # --------------------------------------------------
      # Development only
      # --------------------------------------------------

      KAFKA_CFG_AUTO_CREATE_TOPICS_ENABLE: "false"

      KAFKA_CFG_NUM_PARTITIONS: 3

      KAFKA_CFG_DEFAULT_REPLICATION_FACTOR: 1

      KAFKA_CFG_MIN_INSYNC_REPLICAS: 1

      ALLOW_PLAINTEXT_LISTENER: "yes"

    volumes:
      - kafka-data:/bitnami/kafka

    networks:
      - secure-network

volumes:
  postgres-data:
  kafka-data:

networks:
  secure-network:
    driver: bridge
```

 ### Important production note

 This Docker Compose Kafka configuration uses:

```
SASL/SCRAM
```

 but not TLS, because this keeps the local demo manageable.

 In production:

```
SASL_SSL
```

 should be used rather than:

```
SASL_PLAINTEXT
```

 So the production architecture becomes:

```
SASL + TLS + ACL
```

 rather than just:

```
SASL
```

---

 # 3\. Environment variables

 ## `.env.example`

```
# --------------------------------------------------
# Keycloak
# --------------------------------------------------

KEYCLOAK_ADMIN=admin
KEYCLOAK_ADMIN_PASSWORD=admin

# --------------------------------------------------
# Order Service OAuth2
# --------------------------------------------------

PAYMENT_CLIENT_ID=order-service
PAYMENT_CLIENT_SECRET=order-service-secret

OAUTH_TOKEN_URI=http://localhost:8080/realms/company/protocol/openid-connect/token

JWT_ISSUER_URI=http://localhost:8080/realms/company

# --------------------------------------------------
# Kafka
# --------------------------------------------------

KAFKA_BOOTSTRAP_SERVERS=localhost:9093

ORDER_KAFKA_USERNAME=order-service
ORDER_KAFKA_PASSWORD=order-password

PAYMENT_KAFKA_USERNAME=payment-service
PAYMENT_KAFKA_PASSWORD=payment-password
```

 Copy it:

```
cp .env.example .env
```

 Do **not** commit `.env`.

---

 # 4\. `.gitignore`

```
.env
target/
.idea/
*.iml
*.log
.DS_Store
```

---

 # 5\. Keycloak

 We'll create:

```
Realm:
company

Client:
order-service

Scope:
payment:write
```

 The Order Service gets a JWT containing:

```
payment:write
```

 and Payment Service validates it.

---

 # 6\. Keycloak realm

 ## `keycloak/realm-export.json`

```
{
  "realm": "company",
  "enabled": true,

  "clients": [
    {
      "clientId": "order-service",
      "name": "Order Service",
      "enabled": true,

      "clientAuthenticatorType": "client-secret",

      "secret": "order-service-secret",

      "serviceAccountsEnabled": true,
      "standardFlowEnabled": false,
      "directAccessGrantsEnabled": false,

      "protocol": "openid-connect",

      "attributes": {
        "access.token.signed.response.alg": "RS256"
      },

      "defaultClientScopes": [
        "profile",
        "email"
      ]
    }
  ],

  "clientScopes": [
    {
      "name": "payment:write",
      "description": "Permission to create payments",
      "protocol": "openid-connect",

      "protocolMappers": [
        {
          "name": "payment-write-scope",
          "protocol": "openid-connect",
          "protocolMapper": "oidc-hardcoded-scope",
          "config": {
            "scope": "payment:write"
          }
        }
      ]
    }
  ]
}
```

 For a production Keycloak setup, you'd configure the client scope and service account permissions more carefully rather than treating this local export as production configuration.

---

 # 7\. Order Service Maven configuration

 ## `order-service/pom.xml`

```
<?xml version="1.0" encoding="UTF-8"?>

<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="
           http://maven.apache.org/POM/4.0.0
           https://maven.apache.org/xsd/maven-4.0.0.xsd">

    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.5.0</version>
        <relativePath/>
    </parent>

    <groupId>com.example</groupId>
    <artifactId>order-service</artifactId>
    <version>1.0.0</version>

    <properties>
        <java.version>21</java.version>
    </properties>

    <dependencies>

        <!-- REST -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <!-- OAuth2 Client -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-oauth2-client</artifactId>
        </dependency>

        <!-- Kafka -->
        <dependency>
            <groupId>org.springframework.kafka</groupId>
            <artifactId>spring-kafka</artifactId>
        </dependency>

        <!-- Validation -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>

        <!-- Actuator -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>

        <!-- Test -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>

        <dependency>
            <groupId>org.springframework.security</groupId>
            <artifactId>spring-security-test</artifactId>
            <scope>test</scope>
        </dependency>

    </dependencies>

    <build>
        <plugins>

            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>

        </plugins>
    </build>

</project>
```

---

 # 8\. Order Service application

 ## `OrderServiceApplication.java`

```
package com.example.order;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class OrderServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(OrderServiceApplication.class, args);
    }
}
```

---

 # 9\. Order Service OAuth2 configuration

 ## `OAuth2ClientConfig.java`

```
package com.example.order.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.oauth2.client.*;
import org.springframework.security.oauth2.client.registration.ClientRegistrationRepository;

@Configuration
public class OAuth2ClientConfig {

    @Bean
    OAuth2AuthorizedClientManager authorizedClientManager(
            ClientRegistrationRepository clientRegistrationRepository,
            OAuth2AuthorizedClientService authorizedClientService) {

        OAuth2AuthorizedClientProvider provider =
                OAuth2AuthorizedClientProviderBuilder.builder()
                        .clientCredentials()
                        .build();

        AuthorizedClientServiceOAuth2AuthorizedClientManager manager =
                new AuthorizedClientServiceOAuth2AuthorizedClientManager(
                        clientRegistrationRepository,
                        authorizedClientService
                );

        manager.setAuthorizedClientProvider(provider);

        return manager;
    }
}
```

 This is responsible for:

```
Order Service
     │
     │ client credentials
     ▼
Keycloak
     │
     │ access token
     ▼
Order Service
```

---

 # 10\. Secure RestClient

 ## `RestClientConfig.java`

```
package com.example.order.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.oauth2.client.web.client.OAuth2ClientHttpRequestInterceptor;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClientManager;
import org.springframework.web.client.RestClient;

@Configuration
public class RestClientConfig {

    @Bean
    RestClient paymentRestClient(
            OAuth2AuthorizedClientManager authorizedClientManager) {

        OAuth2ClientHttpRequestInterceptor interceptor =
                new OAuth2ClientHttpRequestInterceptor(
                        authorizedClientManager
                );

        interceptor.setClientRegistrationIdResolver(
                request -> "payment-service"
        );

        return RestClient.builder()
                .baseUrl("http://localhost:8082")
                .requestInterceptor(interceptor)
                .build();
    }
}
```

 For production this should be:

```
https://payment-service
```

 rather than:

```
http://localhost:8082
```

---

 # 11\. Order Service application.yml

 ## `order-service/src/main/resources/application.yml`

```
server:
  port: 8081

spring:

  application:
    name: order-service

  # ==================================================
  # OAuth2 Client
  # ==================================================

  security:
    oauth2:

      client:

        registration:

          payment-service:

            provider: company-idp

            authorization-grant-type: client_credentials

            client-id: ${PAYMENT_CLIENT_ID}

            client-secret: ${PAYMENT_CLIENT_SECRET}

            scope:
              - payment:write

        provider:

          company-idp:

            token-uri: ${OAUTH_TOKEN_URI}

  # ==================================================
  # Kafka
  # ==================================================

  kafka:

    bootstrap-servers: ${KAFKA_BOOTSTRAP_SERVERS}

    properties:

      security.protocol: SASL_PLAINTEXT

      sasl.mechanism: SCRAM-SHA-512

      sasl.jaas.config: >
        org.apache.kafka.common.security.scram.ScramLoginModule required
        username="${ORDER_KAFKA_USERNAME}"
        password="${ORDER_KAFKA_PASSWORD}";

    producer:

      key-serializer: org.apache.kafka.common.serialization.StringSerializer

      value-serializer: org.springframework.kafka.support.serializer.JsonSerializer

management:

  endpoints:
    web:
      exposure:
        include: health,info
```

 Again:

```
LOCAL:
SASL_PLAINTEXT

PRODUCTION:
SASL_SSL
```

---

 # 12\. Order Controller

 This demonstrates the two communication methods.

 ## `OrderController.java`

```
package com.example.order.controller;

import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestClient;

import java.util.Map;

@RestController
@RequestMapping("/orders")
public class OrderController {

    private final RestClient paymentRestClient;

    public OrderController(RestClient paymentRestClient) {
        this.paymentRestClient = paymentRestClient;
    }

    @PostMapping("/pay")
    public String pay() {

        return paymentRestClient
                .post()
                .uri("/payments")
                .body(Map.of(
                        "orderId", "ORDER-1001",
                        "amount", 100
                ))
                .retrieve()
                .body(String.class);
    }
}
```

 When:

```
POST /orders/pay
```

 is called:

```
Order Service
      │
      │ OAuth2 Client Credentials
      ▼
Keycloak
      │
      │ JWT
      ▼
Order Service
      │
      │ Bearer JWT
      ▼
Payment Service
```

---

 # 13\. Kafka Producer

 ## `KafkaProducerConfig.java`

```
package com.example.order.config;

import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.common.serialization.StringSerializer;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.core.DefaultKafkaProducerFactory;
import org.springframework.kafka.core.KafkaTemplate;

import java.util.HashMap;
import java.util.Map;

@Configuration
public class KafkaProducerConfig {

    public KafkaTemplate<String, String> kafkaTemplate(
            org.springframework.boot.autoconfigure.kafka.KafkaProperties properties) {

        Map<String, Object> config = new HashMap<>();

        config.put(
                ProducerConfig.BOOTSTRAP_SERVERS_CONFIG,
                properties.getBootstrapServers()
        );

        config.put(
                ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG,
                StringSerializer.class
        );

        config.put(
                ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG,
                StringSerializer.class
        );

        config.put(
                "security.protocol",
                "SASL_PLAINTEXT"
        );

        config.put(
                "sasl.mechanism",
                "SCRAM-SHA-512"
        );

        return new KafkaTemplate<>(
                new DefaultKafkaProducerFactory<>(config)
        );
    }
}
```

 For a production implementation, I'd normally let Spring Boot's Kafka auto-configuration create the `KafkaTemplate` and keep the security properties in configuration, rather than duplicating them in Java.

 So the cleaner production approach is actually to **remove this custom configuration** unless you have a specific reason to customize the producer.

---

 # 14\. Payment Service Maven configuration

 ## `payment-service/pom.xml`

```
<?xml version="1.0" encoding="UTF-8"?>

<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="
           http://maven.apache.org/POM/4.0.0
           https://maven.apache.org/xsd/maven-4.0.0.xsd">

    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.5.0</version>
        <relativePath/>
    </parent>

    <groupId>com.example</groupId>
    <artifactId>payment-service</artifactId>
    <version>1.0.0</version>

    <properties>
        <java.version>21</java.version>
    </properties>

    <dependencies>

        <!-- REST -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <!-- Resource Server -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-oauth2-resource-server</artifactId>
        </dependency>

        <!-- Kafka -->
        <dependency>
            <groupId>org.springframework.kafka</groupId>
            <artifactId>spring-kafka</artifactId>
        </dependency>

        <!-- Actuator -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>

        <!-- Test -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>

        <dependency>
            <groupId>org.springframework.security</groupId>
            <artifactId>spring-security-test</artifactId>
            <scope>test</scope>
        </dependency>

    </dependencies>

    <build>
        <plugins>

            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>

        </plugins>
    </build>

</project>
```

---

 # 15\. Payment Service application

 ## `PaymentServiceApplication.java`

```
package com.example.payment;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class PaymentServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(PaymentServiceApplication.class, args);
    }
}
```

---

 # 16\. Payment Service JWT security

 ## `SecurityConfig.java`

```
package com.example.payment.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableMethodSecurity
public class SecurityConfig {

    @Bean
    SecurityFilterChain securityFilterChain(
            HttpSecurity http) throws Exception {

        http
            .csrf(csrf -> csrf.disable())

            .authorizeHttpRequests(auth -> auth

                // Health check
                .requestMatchers("/actuator/health")
                .permitAll()

                // Payment write
                .requestMatchers(
                        HttpMethod.POST,
                        "/payments/**"
                )
                .hasAuthority("SCOPE_payment:write")

                // Payment read
                .requestMatchers(
                        HttpMethod.GET,
                        "/payments/**"
                )
                .hasAuthority("SCOPE_payment:read")

                // Everything else
                .anyRequest()
                .authenticated()
            )

            .oauth2ResourceServer(
                oauth2 -> oauth2.jwt()
            );

        return http.build();
    }
}
```

---

 # 17\. Payment Service application.yml

```
server:
  port: 8082

spring:

  application:
    name: payment-service

  # ==================================================
  # JWT Resource Server
  # ==================================================

  security:

    oauth2:

      resourceserver:

        jwt:

          issuer-uri: ${JWT_ISSUER_URI}

  # ==================================================
  # Kafka Consumer
  # ==================================================

  kafka:

    bootstrap-servers: ${KAFKA_BOOTSTRAP_SERVERS}

    properties:

      security.protocol: SASL_PLAINTEXT

      sasl.mechanism: SCRAM-SHA-512

      sasl.jaas.config: >
        org.apache.kafka.common.security.scram.ScramLoginModule required
        username="${PAYMENT_KAFKA_USERNAME}"
        password="${PAYMENT_KAFKA_PASSWORD}";

    consumer:

      group-id: payment-service

      auto-offset-reset: earliest

      key-deserializer:
        org.apache.kafka.common.serialization.StringDeserializer

      value-deserializer:
        org.apache.kafka.common.serialization.StringDeserializer

management:

  endpoints:

    web:

      exposure:

        include:
          - health
          - info
```

---

 # 18\. Payment Controller

 ## `PaymentController.java`

```
package com.example.payment.controller;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/payments")
public class PaymentController {

    @PostMapping
    @PreAuthorize("hasAuthority('SCOPE_payment:write')")
    public Map<String, Object> createPayment(
            @RequestBody Map<String, Object> request) {

        return Map.of(
                "status", "PAYMENT_CREATED",
                "orderId", request.get("orderId"),
                "amount", request.get("amount")
        );
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAuthority('SCOPE_payment:read')")
    public Map<String, Object> getPayment(
            @PathVariable String id) {

        return Map.of(
                "paymentId", id,
                "status", "SUCCESS"
        );
    }
}
```

 Notice that authorization is enforced at **two levels**:

```
HTTP configuration
       +
@PreAuthorize
```

 For a real application, avoid unnecessary duplication, but method-level authorization is useful for protecting business operations even if an endpoint is later exposed through another path.

---

 # 19\. Payment Kafka consumer

```
package com.example.payment.config;

import org.springframework.context.annotation.Configuration;

@Configuration
public class KafkaConsumerConfig {
}
```

 Because the Kafka security properties are already in:

```
spring.kafka.properties
```

 Spring Boot can configure the consumer automatically.

 Then a consumer can be:

```
package com.example.payment.kafka;

import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Component
public class PaymentEventConsumer {

    @KafkaListener(
            topics = "orders",
            groupId = "payment-service"
    )
    public void consume(String message) {

        System.out.println(
                "Received secured Kafka message: " + message
        );
    }
}
```

---

 # 20\. Sending a Kafka message from Order Service

 You can inject Spring's `KafkaTemplate`:

```
package com.example.order.kafka;

import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;

@Component
public class OrderEventProducer {

    private final KafkaTemplate<String, String> kafkaTemplate;

    public OrderEventProducer(
            KafkaTemplate<String, String> kafkaTemplate) {

        this.kafkaTemplate = kafkaTemplate;
    }

    public void publishOrder(String orderId) {

        kafkaTemplate.send(
                "orders",
                orderId,
                "Order created: " + orderId
        );
    }
}
```

 Spring uses:

```
spring:
  kafka:
    properties:
      security.protocol: SASL_PLAINTEXT
      sasl.mechanism: SCRAM-SHA-512
```

 so the connection is authenticated with the `order-service` Kafka credentials.

---

 # 21\. Kafka authorization

 The important production concept is:

```
Kafka users:

order-service
payment-service
notification-service
```

 Do **not** use:

```
username=admin
```

 for every application.

 Instead:

```
                  Kafka
                    │
       ┌────────────┼────────────┐
       │            │            │
       ▼            ▼            ▼
 order-service payment-service notification-service
       │            │            │
       │            │            │
      ACL          ACL          ACL
```

 For example:

```
order-service:
    WRITE orders

payment-service:
    READ orders
    WRITE payments

notification-service:
    READ payments
```

 This is least privilege.

---

 # 22\. Production Kafka configuration

 For production, change:

```
security.protocol: SASL_PLAINTEXT
```

 to:

```
security.protocol: SASL_SSL
```

 and configure:

```
spring:
  kafka:

    properties:

      security.protocol: SASL_SSL

      sasl.mechanism: SCRAM-SHA-512

      sasl.jaas.config: >
        org.apache.kafka.common.security.scram.ScramLoginModule required
        username="${KAFKA_USERNAME}"
        password="${KAFKA_PASSWORD}";

      ssl.truststore.location: ${KAFKA_TRUSTSTORE_PATH}

      ssl.truststore.password: ${KAFKA_TRUSTSTORE_PASSWORD}

      ssl.truststore.type: PKCS12
```

 Now:

```
Application
    │
    │ SASL authentication
    │
    │ TLS encryption
    ▼
Kafka
```

---

 # 23\. Production application configuration

 Don't do this:

```
client-secret: my-production-secret
```

 Instead:

```
client-secret: ${PAYMENT_CLIENT_SECRET}
```

 And:

```
sasl.jaas.config: >
  org.apache.kafka.common.security.scram.ScramLoginModule required
  username="${KAFKA_USERNAME}"
  password="${KAFKA_PASSWORD}";
```

 Then:

```
                 Secret Manager
                       │
            ┌──────────┴──────────┐
            ▼                     ▼
       OAuth secret          Kafka secret
            │                     │
            └──────────┬──────────┘
                       ▼
                 Application
```

 Examples of production secret stores include:

```
AWS Secrets Manager
Azure Key Vault
GCP Secret Manager
HashiCorp Vault
Kubernetes Secrets
```

---

 # 24\. Production profile

 ## `payment-service/application-prod.yml`

```
server:
  port: 8443

  ssl:
    enabled: true
    key-store: ${TLS_KEYSTORE_PATH}
    key-store-password: ${TLS_KEYSTORE_PASSWORD}
    key-store-type: PKCS12
    key-alias: payment-service

spring:

  security:

    oauth2:

      resourceserver:

        jwt:

          issuer-uri: ${JWT_ISSUER_URI}

  kafka:

    bootstrap-servers: ${KAFKA_BOOTSTRAP_SERVERS}

    properties:

      security.protocol: SASL_SSL

      sasl.mechanism: SCRAM-SHA-512

      sasl.jaas.config: >
        org.apache.kafka.common.security.scram.ScramLoginModule required
        username="${PAYMENT_KAFKA_USERNAME}"
        password="${PAYMENT_KAFKA_PASSWORD}";

      ssl.truststore.location: ${KAFKA_TRUSTSTORE_PATH}

      ssl.truststore.password: ${KAFKA_TRUSTSTORE_PASSWORD}

      ssl.truststore.type: PKCS12
```

---

 # 25\. Production Order Service

 ## `order-service/application-prod.yml`

```
server:
  port: 8441

  ssl:
    enabled: true
    key-store: ${TLS_KEYSTORE_PATH}
    key-store-password: ${TLS_KEYSTORE_PASSWORD}
    key-store-type: PKCS12
    key-alias: order-service

spring:

  security:

    oauth2:

      client:

        registration:

          payment-service:

            provider: company-idp

            authorization-grant-type: client_credentials

            client-id: ${PAYMENT_CLIENT_ID}

            client-secret: ${PAYMENT_CLIENT_SECRET}

            scope:
              - payment:write

        provider:

          company-idp:

            token-uri: ${OAUTH_TOKEN_URI}

  kafka:

    bootstrap-servers: ${KAFKA_BOOTSTRAP_SERVERS}

    properties:

      security.protocol: SASL_SSL

      sasl.mechanism: SCRAM-SHA-512

      sasl.jaas.config: >
        org.apache.kafka.common.security.scram.ScramLoginModule required
        username="${ORDER_KAFKA_USERNAME}"
        password="${ORDER_KAFKA_PASSWORD}";

      ssl.truststore.location: ${KAFKA_TRUSTSTORE_PATH}

      ssl.truststore.password: ${KAFKA_TRUSTSTORE_PASSWORD}

      ssl.truststore.type: PKCS12
```

---

 # 26\. Complete security flow

 Now you can explain exactly what happens.

 ## REST

```
1. Client calls Order Service

        │
        ▼

2. Order Service needs Payment Service

        │
        │ client credentials
        ▼

3. Keycloak

        │
        │ signed JWT
        ▼

4. Order Service

        │
        │ HTTPS
        │ Authorization: Bearer JWT
        ▼

5. Payment Service

        │
        ├── validate signature
        ├── validate issuer
        ├── validate audience
        ├── validate expiration
        └── validate scope

        │
        ▼

6. payment:write

        │
        ▼

7. Payment operation allowed
```

---

 # 27\. Kafka flow

```
Order Service
      │
      │ username/password
      ▼
   SASL/SCRAM
      │
      │ TLS
      ▼
    Kafka
      │
      │ ACL
      ▼
 orders topic
      │
      │ READ permission
      ▼
Payment Service
```

 Kafka therefore has:

```
Authentication → SASL/SCRAM
Encryption     → TLS
Authorization  → ACL
```

---

 # 28\. REST vs Kafka — interview comparison

 |  | REST | Kafka |
| --- | --- | --- |
| Authentication | OAuth2/JWT | SASL/SCRAM |
| Authorization | OAuth scopes/roles | Kafka ACLs |
| Encryption | TLS | TLS |
| Strong identity | mTLS | mTLS/TLS depending architecture |
| Credentials | Secret Manager | Secret Manager |
| Network | Private network | Private network |
| Audit | Application/security logs | Kafka/audit logs |
| Rotation | Token/key rotation | Credential/certificate rotation |

---

 # 29\. What changes from local to production?

 ### Local

```
REST:
JWT + HTTP

Kafka:
SASL_PLAINTEXT
```

 ### Dev/Staging

```
REST:
JWT + HTTPS

Kafka:
SASL_SSL + ACL
```

 ### Production

```
REST:
OAuth2/JWT
+
HTTPS
+
mTLS where required
+
Scopes
+
Network policies

Kafka:
SASL/SCRAM
+
TLS
+
ACLs
+
Private networking
+
Credential/certificate rotation
```

---

 # 30\. The production security checklist

 For your interview, remember these layers:

```
                 PRODUCTION SECURITY
                         │
       ┌─────────────────┼──────────────────┐
       │                 │                  │
       ▼                 ▼                  ▼
 Authentication    Authorization       Encryption
       │                 │                  │
 OAuth2/JWT          Scopes/Roles          TLS
 mTLS                Kafka ACL             mTLS
       │                 │                  │
       └─────────────────┼──────────────────┘
                         │
                         ▼
                  Secret Management
                         │
                         ▼
                   Network Security
                         │
                         ▼
                  Logging / Auditing
                         │
                         ▼
                  Monitoring / Alerting
                         │
                         ▼
                Certificate Rotation
                         │
                         ▼
                  Vulnerability Scan
```

 ### The interview answer I'd memorize

 > **"For REST communication, Order Service authenticates to the identity provider using OAuth2 client credentials and gets a short-lived JWT. It calls Payment Service over TLS with the JWT. Payment Service is an OAuth2 resource server and validates the JWT signature, issuer, audience and expiry, then uses scopes such as `payment:write` for authorization. For higher-security production workloads, we can additionally use mTLS for workload identity."**
>
>  **"For Kafka, I use a separate security mechanism. Each service has its own Kafka identity. Kafka clients authenticate using SASL/SCRAM, communication is encrypted using TLS, and authorization is controlled through Kafka ACLs. For example, Order Service can only write to the `orders` topic while Payment Service can only read that topic using its consumer group."**
>
>  **"Secrets and certificates are never stored in Git or hardcoded in application YAML. They come from a secret manager and are rotated. Dev, staging and production have separate credentials, certificates, identity-provider configuration and Kafka access, while keeping the same security model across environments."**

 One important correction to the earlier examples: **the production Kafka setup should be a multi-broker cluster with TLS and ACLs; the single-broker Docker Compose configuration above is for demonstrating the security flow locally, not for production HA.** Similarly, the Keycloak realm export is a local/demo bootstrap mechanism; in production, the identity provider should be managed with controlled configuration, separate environments, secret management, key rotation, and restricted administrative access.
 


