Absolutely. Since you have **9 years of Java experience**, I’d answer these in an interview with a **definition → simple example → internal flow/diagram → practical point** structure.

Below is an interview-ready version. The examples use modern Spring Boot style, especially `SecurityFilterChain` rather than the older `WebSecurityConfigurerAdapter`.

---

# Spring Core / Spring Boot — Interview Guide

## 1. What is Dependency Injection?

### Simple interview answer

**Dependency Injection (DI)** means that a class does not create its own dependencies. Instead, **Spring creates the dependency and injects it into the class**.

Without DI:

```java
public class OrderService {

    private PaymentService paymentService = new PaymentService();

}
```

Here `OrderService` is tightly coupled to `PaymentService`.

With DI:

```java
@Service
public class OrderService {

    private final PaymentService paymentService;

    public OrderService(PaymentService paymentService) {
        this.paymentService = paymentService;
    }
}
```

Spring creates both objects:

```text
Spring Container
      |
      +---- PaymentService object
      |
      +---- OrderService object
                 |
                 +---- PaymentService
```

### Types of Dependency Injection

1. **Constructor Injection — recommended**
2. Setter Injection
3. Field Injection — generally discouraged

Constructor injection:

```java
@Service
public class OrderService {

    private final PaymentService paymentService;

    public OrderService(PaymentService paymentService) {
        this.paymentService = paymentService;
    }
}
```

### Why constructor injection?

* Dependency is mandatory.
* Object cannot be created without required dependencies.
* Easy to unit test.
* Supports immutable fields.
* Makes dependencies explicit.

### Interview one-liner

> "Dependency Injection is a design pattern where the Spring container creates an object's dependencies and injects them instead of the object creating those dependencies itself."

---

# 2. What is Inversion of Control?

### Simple answer

**IoC means the control of object creation and dependency management is transferred from our application code to the Spring container.**

Normally:

```text
Our Code
   |
   +-- creates OrderService
   |
   +-- creates PaymentService
   |
   +-- connects them
```

With Spring:

```text
              Spring IoC Container
                      |
          +-----------+-----------+
          |                       |
   creates PaymentService   creates OrderService
                                  |
                                  +---- injects PaymentService
```

### IoC vs DI

These two are related but not exactly the same.

```text
IoC
 |
 +-- General principle:
 |   "Spring controls object creation/lifecycle"
 |
 +-- DI
     Mechanism used to achieve IoC
```

### Interview answer

> "IoC is the principle where Spring takes control of object creation, configuration and lifecycle. Dependency Injection is one of the primary mechanisms Spring uses to implement IoC."

---

# 3. Difference between `@Component`, `@Service`, and `@Repository`

All three are Spring stereotype annotations and cause Spring to detect the class as a bean during component scanning.

```text
                 @Component
                     |
        +------------+------------+
        |            |            |
   @Service     @Repository   Other Components
```

### `@Component`

Generic Spring-managed component.

```java
@Component
public class EmailUtil {
}
```

### `@Service`

Used for **business/service layer**.

```java
@Service
public class OrderService {
}
```

### `@Repository`

Used for **DAO/persistence layer**.

```java
@Repository
public class OrderRepository {
}
```

One important difference:

`@Repository` also participates in **Spring's exception translation mechanism**, converting certain persistence exceptions into Spring's `DataAccessException` hierarchy.

### Typical architecture

```text
Controller
    |
    v
@Service
OrderService
    |
    v
@Repository
OrderRepository
    |
    v
Database
```

### Interview answer

> "`@Component` is generic, `@Service` semantically represents the business layer, and `@Repository` represents the persistence layer and additionally enables exception translation."

---

# 4. Difference between `@Qualifier` and `@Primary`

Suppose we have two implementations:

```java
public interface PaymentService {
    void pay();
}
```

```java
@Service
public class CreditCardPayment implements PaymentService {
}
```

```java
@Service
public class UPIPayment implements PaymentService {
}
```

Now:

```java
@Autowired
private PaymentService paymentService;
```

Spring sees:

```text
PaymentService
       |
       +---- CreditCardPayment
       |
       +---- UPIPayment
```

Spring doesn't know which one to inject.

---

## `@Primary`

Tell Spring:

> "Use this bean by default when there are multiple candidates."

```java
@Service
@Primary
public class CreditCardPayment implements PaymentService {
}
```

Now:

```text
PaymentService
       |
       +---- CreditCardPayment  <-- @Primary
       |
       +---- UPIPayment
```

---

## `@Qualifier`

Tell Spring exactly which bean you want.

```java
@Service("upiPayment")
public class UPIPayment implements PaymentService {
}
```

Then:

```java
@Autowired
@Qualifier("upiPayment")
private PaymentService paymentService;
```

### Difference

| `@Primary`                | `@Qualifier`                 |
| ------------------------- | ---------------------------- |
| Defines default candidate | Selects specific candidate   |
| Useful globally           | Useful at injection point    |
| Can have one primary      | Can use different qualifiers |
| Less explicit             | More explicit                |

### Important interview point

If both `@Primary` and `@Qualifier` are present:

> **`@Qualifier` generally wins because it narrows the candidate set.**

---

# 5. How does `@Qualifier` work internally?

This is a good **9-year experience** question.

Consider:

```java
@Service("creditCard")
public class CreditCardPayment implements PaymentService {
}
```

```java
@Service("upi")
public class UPIPayment implements PaymentService {
}
```

Injection:

```java
@Autowired
@Qualifier("upi")
private PaymentService paymentService;
```

Conceptually Spring does:

```text
@Autowired
    |
    v
Find beans matching PaymentService
    |
    +---- creditCard
    |
    +---- upi
    |
    v
Apply qualifier "upi"
    |
    v
upi bean selected
    |
    v
Inject into OrderService
```

Internally, Spring's bean resolution involves components such as:

```text
BeanFactory
   |
   v
Dependency resolution
   |
   v
AutowireCandidateResolver
   |
   v
Qualifier matching
   |
   v
Selected BeanDefinition
```

Spring stores metadata about beans and qualifiers in their bean definitions. During autowiring, it first identifies candidates compatible with the required type and then uses qualifier information to narrow those candidates.

### Interview-friendly explanation

> "`@Qualifier` doesn't create a new bean. It provides additional metadata at the injection point that Spring uses during autowire candidate resolution to select the matching bean among multiple candidates."

### Important distinction

`@Qualifier`:

```java
@Qualifier("upi")
```

doesn't mean:

> "Create a bean called upi."

It means:

> "When resolving this dependency, prefer the candidate matching this qualifier."

---

# 6. What is `@SpringBootApplication`?

`@SpringBootApplication` is the main annotation normally placed on the Spring Boot application's main class.

```java
@SpringBootApplication
public class OrderApplication {

    public static void main(String[] args) {
        SpringApplication.run(OrderApplication.class, args);
    }
}
```

It tells Spring Boot:

> "This is the primary configuration class; scan my components and enable Boot's auto-configuration."

Conceptually:

```text
@SpringBootApplication
        |
        +---- Configuration
        |
        +---- Component Scanning
        |
        +---- Auto Configuration
```

---

# 7. What annotations are included inside `@SpringBootApplication`?

The important three are:

```java
@SpringBootConfiguration
@EnableAutoConfiguration
@ComponentScan
```

Conceptually:

```text
@SpringBootApplication
        |
        +-------------------------+
        |                         |
        v                         v
@SpringBootConfiguration    @EnableAutoConfiguration
        |
        v
Configuration class

        +
        
@ComponentScan
        |
        v
Find @Component
@Service
@Repository
@Controller
...
```

### 1. `@SpringBootConfiguration`

Specialized form of `@Configuration`.

It tells Spring:

> "This class is a configuration class for the Spring Boot application."

### 2. `@EnableAutoConfiguration`

Tells Spring Boot to configure beans based on:

* classpath dependencies
* configuration properties
* conditional annotations
* application environment

Example:

If you add:

```xml
spring-boot-starter-web
```

Spring Boot detects relevant web dependencies and configures things such as an embedded servlet container and MVC infrastructure.

### 3. `@ComponentScan`

Scans packages for Spring components.

If your main class is:

```text
com.company.order.OrderApplication
```

Spring typically scans:

```text
com.company.order
    |
    +-- controller
    +-- service
    +-- repository
    +-- config
```

### Interview answer

> "`@SpringBootApplication` is a convenience annotation combining `@SpringBootConfiguration`, `@EnableAutoConfiguration`, and `@ComponentScan`."

---

# 8. How do you configure environment-specific properties?

Typical environments:

```text
Development
Testing
QA
Production
```

Use Spring profiles.

Create:

```text
application.yml
application-dev.yml
application-qa.yml
application-prod.yml
```

Example:

### `application.yml`

```yaml
spring:
  application:
    name: order-service
```

### `application-dev.yml`

```yaml
server:
  port: 8081

spring:
  datasource:
    url: jdbc:mysql://localhost/orderdb
```

### `application-prod.yml`

```yaml
server:
  port: 8080

spring:
  datasource:
    url: jdbc:mysql://prod-db/orderdb
```

Activate:

```properties
spring.profiles.active=prod
```

Or using command line:

```bash
java -jar order-service.jar --spring.profiles.active=prod
```

Or environment variable:

```bash
SPRING_PROFILES_ACTIVE=prod
```

### Diagram

```text
                 Spring Boot
                     |
                     v
             Active Profile?
                     |
          +----------+----------+
          |          |          |
         dev        qa        prod
          |          |          |
          v          v          v
 application-   application- application-
 dev.yml         qa.yml       prod.yml
```

### Production best practice

Don't normally hard-code production secrets in Git.

Use:

```text
Environment variables
Secret Manager
Vault
Kubernetes Secrets
Cloud secret management
```

---

# 9. How does Spring Boot identify which environment/profile is active?

Spring Boot checks the configured property:

```properties
spring.profiles.active=prod
```

It can come from multiple configuration sources, including:

```text
Command line arguments
       ↓
Environment variables
       ↓
System properties
       ↓
Configuration files
       ↓
Other property sources
```

For example:

```bash
java -jar app.jar --spring.profiles.active=prod
```

Spring Boot creates an environment containing property sources and determines the active profile.

You can also activate profiles programmatically/configurationally, but command-line/environment configuration is generally preferable for deployments.

### Interview answer

> "Spring Boot determines the active profile from the Spring Environment, with the profile typically supplied through `spring.profiles.active`, command-line arguments, environment variables, or configuration."

---

# 10. How do you configure logs for different environments?

A common approach is:

```text
application-dev.yml
application-prod.yml
```

Example:

### Development

```yaml
logging:
  level:
    root: INFO
    com.company.order: DEBUG
```

### Production

```yaml
logging:
  level:
    root: WARN
    com.company.order: INFO
```

For more complex logging, use:

```text
logback-spring.xml
```

Spring Boot's Logback integration supports profile-specific configuration.

Example conceptually:

```xml
<springProfile name="dev">
    ...
</springProfile>

<springProfile name="prod">
    ...
</springProfile>
```

### Production architecture

```text
Application
    |
    v
Logging Framework
    |
    +---- Console
    |
    +---- File / JSON logs
    |
    v
Log aggregation
    |
    +---- ELK
    +---- Splunk
    +---- Cloud logging
```

For microservices, structured JSON logs are often preferred because they are easier for centralized logging systems to parse.

---

# 11. What are the different log levels?

Common levels:

```text
TRACE
DEBUG
INFO
WARN
ERROR
```

From most verbose to least verbose:

```text
TRACE
  ↓
DEBUG
  ↓
INFO
  ↓
WARN
  ↓
ERROR
```

### Example

```java
log.trace("Entering method");
log.debug("Order ID = {}", orderId);
log.info("Order created successfully");
log.warn("Payment retry");
log.error("Payment failed", exception);
```

### Meaning

| Level | Purpose                              |
| ----- | ------------------------------------ |
| TRACE | Very detailed diagnostic information |
| DEBUG | Developer troubleshooting            |
| INFO  | Normal application events            |
| WARN  | Potential problem                    |
| ERROR | Failure/problem                      |

There is also `FATAL` in some logging frameworks, but **Spring Boot's standard Logback setup does not provide a separate FATAL level**; fatal conditions are generally logged as `ERROR`.

### Interview tip

> "In production, I normally keep application logs around INFO and selectively enable DEBUG for specific packages when troubleshooting."

---

# 12. How do you connect Spring Boot to multiple databases?

You can configure multiple `DataSource` beans.

For example:

```text
Spring Boot Application
       |
       +------------------+
       |                  |
       v                  v
DataSource 1          DataSource 2
       |                  |
       v                  v
MySQL                 PostgreSQL
```

Example:

```java
@Configuration
public class DataSourceConfig {

    @Bean
    @Primary
    @ConfigurationProperties("app.datasource.mysql")
    public DataSource mysqlDataSource() {
        return DataSourceBuilder.create().build();
    }

    @Bean
    @ConfigurationProperties("app.datasource.postgres")
    public DataSource postgresDataSource() {
        return DataSourceBuilder.create().build();
    }
}
```

Properties:

```yaml
app:
  datasource:
    mysql:
      url: jdbc:mysql://localhost/orderdb
      username: root
      password: password

    postgres:
      url: jdbc:postgresql://localhost/customerdb
      username: postgres
      password: password
```

### With JPA

If both databases use JPA, configuration becomes more involved because you generally need separate:

```text
DataSource
EntityManagerFactory
TransactionManager
Repository packages
```

Conceptually:

```text
                  Application
                       |
             +---------+---------+
             |                   |
             v                   v
       Order DB config      Customer DB config
             |                   |
       DataSource          DataSource
             |                   |
       EntityManager       EntityManager
             |                   |
       OrderRepository     CustomerRepository
```

### Interview answer

> "For multiple databases, I configure multiple DataSources, usually mark one as `@Primary`, and if using JPA, configure a separate EntityManagerFactory and transaction manager for each persistence unit."

---

# 13. How do you configure different data sources?

Example:

```yaml
app:
  datasource:
    order:
      url: jdbc:mysql://localhost/orderdb
      username: root
      password: xxx

    audit:
      url: jdbc:postgresql://localhost/auditdb
      username: postgres
      password: xxx
```

Then:

```java
@Bean
@ConfigurationProperties("app.datasource.order")
public DataSource orderDataSource() {
    return DataSourceBuilder.create().build();
}
```

And:

```java
@Bean
@ConfigurationProperties("app.datasource.audit")
public DataSource auditDataSource() {
    return DataSourceBuilder.create().build();
}
```

You can use:

```java
@Qualifier("orderDataSource")
```

when injecting a specific datasource.

### Important interview distinction

**Multiple databases** means:

```text
DB1 + DB2
```

**Multiple data sources** means:

```text
DataSource1 + DataSource2
```

A data source represents the application's connection/pooling configuration to a database endpoint.

---

# 14. How do you configure a different application server instead of Tomcat?

Spring Boot's web starter traditionally brings embedded Tomcat.

If you want Jetty:

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
    <exclusions>
        <exclusion>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-tomcat</artifactId>
        </exclusion>
    </exclusions>
</dependency>
```

Then:

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-jetty</artifactId>
</dependency>
```

Architecture:

```text
Spring Boot
    |
    +---- Spring MVC
    |
    +---- Embedded Server
             |
             +---- Tomcat
             OR
             +---- Jetty
             OR
             +---- Undertow
```

The exact supported server options depend on your Spring Boot version and whether you're using servlet or reactive web stack.

---

# 15. How would you configure WebLogic instead of Tomcat?

This is particularly relevant in enterprise interviews.

Instead of running:

```bash
java -jar application.jar
```

you can package the application as a **WAR** and deploy it to WebLogic.

### Step 1 — Change packaging

```xml
<packaging>war</packaging>
```

### Step 2 — Make embedded Tomcat provided

Conceptually:

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-tomcat</artifactId>
    <scope>provided</scope>
</dependency>
```

### Step 3 — Extend `SpringBootServletInitializer`

```java
@SpringBootApplication
public class OrderApplication
        extends SpringBootServletInitializer {

    @Override
    protected SpringApplicationBuilder configure(
            SpringApplicationBuilder application) {

        return application.sources(OrderApplication.class);
    }

    public static void main(String[] args) {
        SpringApplication.run(OrderApplication.class, args);
    }
}
```

### Deployment

```text
                 WebLogic Server
                       |
                       v
                    WAR file
                       |
                       v
              Spring Boot Application
```

### Interview answer

> "For WebLogic deployment, I generally package the Boot application as a WAR, mark the embedded servlet container as provided, extend `SpringBootServletInitializer`, and deploy the WAR to WebLogic."

### Important

WebLogic/Spring Boot compatibility depends on the **specific versions** of WebLogic, Spring Boot, Jakarta/Java EE APIs, and Java. In a real project I would verify the supported combination before deployment.

---

# 16. How do you configure multiple servers in a Spring Boot application?

There are two interpretations.

## Case 1 — Multiple application instances

Usually the preferred production approach is:

```text
                 Load Balancer
                /      |      \
               /       |       \
              v        v        v
          Instance1 Instance2 Instance3
```

Each instance runs the same Spring Boot application:

```bash
server.port=8081
server.port=8082
server.port=8083
```

Then a load balancer distributes requests.

---

## Case 2 — Multiple connectors/ports in one application

For embedded Tomcat, you can configure an additional connector programmatically.

Conceptually:

```text
Spring Boot Application
        |
        +---- Port 8080
        |
        +---- Port 9090
```

But this is **not the same as running multiple independent application servers**.

### Interview answer

> "For production scalability, I prefer multiple Spring Boot instances behind a load balancer rather than trying to run multiple independent servers inside one JVM. If the requirement is multiple ports in the same application, additional connectors can be configured."

---

# 17. Which annotation is used to load database properties?

There are two common approaches.

## `@ConfigurationProperties` — preferred for grouped configuration

```java
@ConfigurationProperties(prefix = "spring.datasource")
public class DatabaseProperties {

    private String url;
    private String username;
    private String password;

    // getters/setters
}
```

Enable/register it using:

```java
@ConfigurationPropertiesScan
```

or:

```java
@EnableConfigurationProperties(DatabaseProperties.class)
```

depending on your configuration.

---

## `@Value`

You can also inject individual properties:

```java
@Value("${spring.datasource.url}")
private String url;
```

### Which should I use?

For multiple related properties:

```text
@ConfigurationProperties
        ↓
url
username
password
driver
pool settings
```

is generally cleaner than many `@Value` fields.

### Interview answer

> "For structured database configuration, I prefer `@ConfigurationProperties`. `@Value` is useful for injecting individual properties."

---

# 18. How do you enable security in Spring Boot?

Add:

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>
```

Then configure security using a `SecurityFilterChain`.

Example:

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    SecurityFilterChain securityFilterChain(HttpSecurity http)
            throws Exception {

        http
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/public/**").permitAll()
                .anyRequest().authenticated()
            )
            .httpBasic(Customizer.withDefaults());

        return http.build();
    }
}
```

Architecture:

```text
HTTP Request
     |
     v
Security Filter Chain
     |
     +---- Authentication
     |
     +---- Authorization
     |
     v
Controller
```

### Authentication vs Authorization

```text
Authentication
     |
     +-- Who are you?

Authorization
     |
     +-- What are you allowed to access?
```

### For JWT

A typical microservice architecture:

```text
Client
  |
  | JWT
  v
Spring Security
  |
  +-- Validate token
  |
  +-- Extract authorities
  |
  v
Controller
```

### Interview answer

> "Adding Spring Security enables the security infrastructure. In modern Spring Security, I typically configure a `SecurityFilterChain` bean for authorization rules, authentication mechanisms, CSRF, sessions, JWT, OAuth2, etc."

---

# 19. What is prototype scope?

Spring beans are singleton by default.

Prototype means:

> **Spring creates a new bean instance every time the bean is requested from the container.**

Example:

```java
@Component
@Scope(ConfigurableBeanFactory.SCOPE_PROTOTYPE)
public class ReportGenerator {
}
```

If we request it twice:

```java
ReportGenerator r1 = context.getBean(ReportGenerator.class);
ReportGenerator r2 = context.getBean(ReportGenerator.class);
```

Then:

```text
getBean()
   |
   +----> ReportGenerator #1

getBean()
   |
   +----> ReportGenerator #2
```

Therefore:

```java
r1 != r2
```

### Singleton

```text
getBean()
    |
    v
Same object
```

### Prototype

```text
getBean()
    |
    +----> New object

getBean()
    |
    +----> New object
```

### Important interview point

Spring manages the creation/configuration of prototype beans, but **does not manage the complete lifecycle/destroy phase of prototype instances in the same way it does for singleton beans**.

---

# 20. What are the different Spring bean scopes?

The commonly discussed scopes are:

| Scope       | Meaning                            |
| ----------- | ---------------------------------- |
| Singleton   | One instance per Spring container  |
| Prototype   | New instance when requested        |
| Request     | One instance per HTTP request      |
| Session     | One instance per HTTP session      |
| Application | One instance per ServletContext    |
| WebSocket   | One instance per WebSocket session |

### Diagram

```text
Spring Bean Scopes
       |
       +---- Singleton
       |
       +---- Prototype
       |
       +---- Web scopes
               |
               +---- Request
               +---- Session
               +---- Application
               +---- WebSocket
```

### Most commonly used

```text
@Service       -> Singleton
@Repository    -> Singleton
@Controller    -> Singleton
```

Unless you explicitly change the scope.

### Interview warning

Don't say:

> "Singleton means one object for the entire JVM."

Better say:

> "Singleton means one bean instance per Spring IoC container."

---

# 21. What is a cyclic dependency in Spring?

A cyclic dependency occurs when:

```text
A depends on B
B depends on A
```

Example:

```java
@Service
public class OrderService {

    private final PaymentService paymentService;

    public OrderService(PaymentService paymentService) {
        this.paymentService = paymentService;
    }
}
```

And:

```java
@Service
public class PaymentService {

    private final OrderService orderService;

    public PaymentService(OrderService orderService) {
        this.orderService = orderService;
    }
}
```

Now:

```text
OrderService
      |
      v
PaymentService
      |
      v
OrderService
      |
      v
...
```

Spring cannot construct either object because each constructor requires the other first.

### Typical result

With constructor injection, Spring detects the circular dependency during bean creation and fails startup.

---

# 22. How do you resolve cyclic dependencies?

There are several approaches.

## Approach 1 — Best solution: Redesign

Usually a circular dependency indicates a design problem.

Instead of:

```text
OrderService <----> PaymentService
```

introduce another abstraction:

```text
        OrderService
             |
             v
       PaymentCoordinator
          /        \
         v          v
OrderRepository  PaymentService
```

Or move shared functionality to another service.

---

## Approach 2 — Use `@Lazy`

Example:

```java
@Service
public class OrderService {

    private final PaymentService paymentService;

    public OrderService(@Lazy PaymentService paymentService) {
        this.paymentService = paymentService;
    }
}
```

`@Lazy` tells Spring to defer creation/resolution of that dependency.

Conceptually:

```text
OrderService
     |
     +---- proxy/lazy reference
                |
                v
        PaymentService
```

This can break certain initialization cycles, but it shouldn't be the first architectural solution.

---

## Approach 3 — Setter injection

Historically, circular dependencies could sometimes be handled using setter/field injection because the objects could be instantiated before all dependencies were populated.

But don't present this as the preferred solution.

### Why?

Because:

```text
Constructor injection
       ↓
Dependencies are mandatory
       ↓
Circular dependency exposed immediately
       ↓
Better design
```

### Interview answer

> "My first choice is to remove the circular dependency by redesigning the services. `@Lazy` can be used when there is a legitimate initialization cycle, but I wouldn't use it just to hide a design problem. Constructor injection is useful because it exposes these cycles early."

---

# ⭐ Bonus: The Spring Boot startup flow

For a senior interview, knowing the startup flow is useful.

When you run:

```java
SpringApplication.run(OrderApplication.class, args);
```

conceptually:

```text
main()
  |
  v
SpringApplication.run()
  |
  v
Create Spring Application Context
  |
  v
Determine environment/profiles
  |
  v
Load configuration
  |
  v
Component scanning
  |
  v
Auto-configuration
  |
  v
Create BeanDefinitions
  |
  v
Instantiate beans
  |
  v
Dependency Injection
  |
  v
Bean lifecycle callbacks
  |
  v
ApplicationReadyEvent
  |
  v
Application Ready
```

This is a very useful diagram to remember.

---

# ⭐ Bonus: How Spring resolves an `@Autowired` dependency

Suppose:

```java
@Service
public class OrderService {

    public OrderService(PaymentService paymentService) {
        ...
    }
}
```

Spring roughly does:

```text
Need PaymentService
       |
       v
Find beans of type PaymentService
       |
       v
How many candidates?
       |
       +---- 0 ----> NoSuchBeanDefinitionException
       |
       +---- 1 ----> Inject it
       |
       +---- Multiple
                |
                v
          Check @Qualifier
                |
                v
          Check @Primary
                |
                v
        Resolve candidate
                |
                v
             Inject
```

If multiple candidates remain ambiguous, you get a `NoUniqueBeanDefinitionException`.

---

# ⭐ Quick Interview Revision Sheet

If the interviewer asks rapid-fire questions, remember these:

| Question                 | Short answer                                                              |
| ------------------------ | ------------------------------------------------------------------------- |
| DI                       | Spring injects dependencies instead of classes creating them              |
| IoC                      | Spring takes control of object creation/lifecycle                         |
| `@Component`             | Generic Spring bean                                                       |
| `@Service`               | Business/service layer                                                    |
| `@Repository`            | Persistence layer + exception translation                                 |
| `@Primary`               | Default bean among multiple candidates                                    |
| `@Qualifier`             | Explicitly selects a candidate                                            |
| `@SpringBootApplication` | Boot configuration + auto-configuration + component scanning              |
| Profiles                 | `application-{profile}.yml`                                               |
| Active profile           | `spring.profiles.active`                                                  |
| Logs                     | `logging.level.*`, `logback-spring.xml`                                   |
| Log levels               | TRACE → DEBUG → INFO → WARN → ERROR                                       |
| Multiple DBs             | Multiple DataSources; JPA may need multiple EMFs/transaction managers     |
| Other server             | Exclude Tomcat and add supported server dependency                        |
| WebLogic                 | Usually WAR + provided servlet container + `SpringBootServletInitializer` |
| Multiple servers         | Prefer multiple app instances behind LB                                   |
| DB properties            | Prefer `@ConfigurationProperties` for grouped config                      |
| Security                 | `spring-boot-starter-security` + `SecurityFilterChain`                    |
| Prototype                | New bean instance when requested                                          |
| Default scope            | Singleton                                                                 |
| Circular dependency      | A → B → A                                                                 |
| Resolve cycle            | Redesign first; `@Lazy` when appropriate                                  |

---

# 🎯 The 5 diagrams I would memorize for an interview

### 1. DI / IoC

```text
             Spring Container
                    |
        +-----------+-----------+
        |                       |
        v                       v
 PaymentService             OrderService
                                |
                                +---- PaymentService
```

**Say:**

> "Spring controls object creation and injects dependencies."

---

### 2. Component hierarchy

```text
                 @Component
                     |
       +-------------+-------------+
       |             |             |
   @Service      @Repository   @Controller
       |             |
 Business         Persistence
```

---

### 3. `@Primary` vs `@Qualifier`

```text
             PaymentService
                  |
        +---------+---------+
        |                   |
   CreditCard              UPI
    @Primary             @Qualifier("upi")
        |
        +---- Default
```

**Say:**

> "`@Primary` gives me the default; `@Qualifier` lets me explicitly choose."

---

### 4. Profiles

```text
                 Spring Boot
                      |
              Active Profile
                      |
        +-------------+-------------+
        |             |             |
       dev            qa           prod
        |             |             |
     dev.yml        qa.yml       prod.yml
```

---

### 5. Circular dependency

```text
       +------------------+
       |                  |
       v                  |
OrderService -------> PaymentService
       ^                  |
       |                  |
       +------------------+
```

**Say:**

> "This is a design smell. I would first remove the bidirectional dependency rather than simply hiding it with `@Lazy`."

---

## ⭐ Senior-level way to answer Spring questions

With **9 years of experience**, don't stop at definitions. A strong interview pattern is:

> **"What it is → why it exists → how Spring handles it internally → practical example → what I would do in production."**

For example, don't merely say:

> "`@Qualifier` selects a bean."

Say:

> "`@Qualifier` is used when multiple beans match the required type. During dependency resolution, Spring first identifies type-compatible candidates and then uses qualifier metadata to narrow the candidates. I use it when I need explicit selection, whereas I use `@Primary` when one implementation should be the default."

That sounds considerably more like a **senior Java/Spring engineer** than a textbook answer.
