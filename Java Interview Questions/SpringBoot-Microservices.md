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


---
---

Absolutely. For a **9-year Java/Spring profile**, I’d explain these with a little more depth than a basic definition, but keep the language simple enough to deliver naturally in an interview.

# 6. Spring MVC / REST — Interview Ready Answers

---

# 1. Difference between `@Controller` and `@RestController`

### `@Controller`

Used mainly for **MVC applications where the response is a view/page**.

```java
@Controller
public class OrderController {

    @GetMapping("/orders")
    public String orders() {
        return "orders";
    }
}
```

Here `"orders"` can represent a view such as:

```text
orders.html
```

---

### `@RestController`

Used for **REST APIs**, where methods generally return data such as JSON/XML.

```java
@RestController
public class OrderController {

    @GetMapping("/orders")
    public List<Order> getOrders() {
        return orderService.getOrders();
    }
}
```

Response:

```json
[
  {
    "id": 101,
    "status": "CREATED"
  }
]
```

### Internal relationship

```text
@Controller
    |
    +---- @ResponseBody on individual methods
```

Whereas:

```text
@RestController
    |
    +---- @Controller
    |
    +---- @ResponseBody
```

### Interview answer

> "`@Controller` is primarily used for Spring MVC views, while `@RestController` is used for REST APIs and effectively combines `@Controller` with `@ResponseBody`."

---

# 2. What happens when `@RestController` is used at class level?

Consider:

```java
@RestController
public class OrderController {

    @GetMapping("/orders")
    public Order getOrder() {
        return new Order(101, "CREATED");
    }
}
```

Because `@RestController` includes `@ResponseBody`, Spring treats the return value of each handler method as the **response body**, rather than as a view name.

The flow is roughly:

```text
HTTP Request
     |
     v
DispatcherServlet
     |
     v
OrderController
     |
     v
getOrder()
     |
     v
Order Java Object
     |
     v
HttpMessageConverter
     |
     v
JSON
     |
     v
HTTP Response
```

For JSON, Spring commonly uses Jackson through an `HttpMessageConverter`.

Example:

```java
return new Order(101, "CREATED");
```

becomes:

```json
{
  "id": 101,
  "status": "CREATED"
}
```

### Interview answer

> "`@RestController` applies `@ResponseBody` semantics to all handler methods in the class, so their return values are written directly to the HTTP response body and typically serialized to JSON."

---

# 3. What is `@RequestMapping`?

`@RequestMapping` is used to **map HTTP requests to controller classes or methods**.

Example:

```java
@RestController
@RequestMapping("/api/orders")
public class OrderController {

    @RequestMapping("/123")
    public Order getOrder() {
        ...
    }
}
```

The endpoint becomes:

```text
/api/orders/123
```

You can specify:

```java
@RequestMapping(
    value = "/orders",
    method = RequestMethod.GET
)
```

It supports:

* URL/path
* HTTP method
* headers
* query parameters
* content type
* accepted response type

### Class + method mapping

```java
@RequestMapping("/orders")
public class OrderController {

    @RequestMapping(
        value = "/{id}",
        method = RequestMethod.GET
    )
    public Order getOrder(@PathVariable Long id) {
        ...
    }
}
```

Flow:

```text
GET /orders/101
       |
       v
Class mapping: /orders
       +
Method mapping: /{id}
       |
       v
getOrder(101)
```

### Interview answer

> "`@RequestMapping` maps incoming HTTP requests to controller classes or methods based on path and other request conditions. The specialized annotations like `@GetMapping` are more concise forms for specific HTTP methods."

---

# 4. Difference between `@GetMapping`, `@PostMapping`, `@PutMapping`, and `@DeleteMapping`

These are specialized versions of `@RequestMapping`.

| Annotation       | HTTP Method | Typical purpose |
| ---------------- | ----------- | --------------- |
| `@GetMapping`    | GET         | Read            |
| `@PostMapping`   | POST        | Create/process  |
| `@PutMapping`    | PUT         | Replace/update  |
| `@DeleteMapping` | DELETE      | Delete          |

Example:

```java
@GetMapping("/orders/{id}")
public Order getOrder(@PathVariable Long id) {
    ...
}
```

```java
@PostMapping("/orders")
public Order createOrder(@RequestBody OrderRequest request) {
    ...
}
```

```java
@PutMapping("/orders/{id}")
public Order updateOrder(
        @PathVariable Long id,
        @RequestBody OrderRequest request) {
    ...
}
```

```java
@DeleteMapping("/orders/{id}")
public void deleteOrder(@PathVariable Long id) {
    ...
}
```

### REST flow

```text
GET       → Read
POST      → Create/process
PUT       → Replace
PATCH     → Partial update
DELETE    → Remove
```

---

# 5. Difference between PUT and PATCH

This is a **very common interview question**.

### PUT

Generally represents **replacement of the resource's representation**.

Suppose current resource is:

```json
{
  "id": 101,
  "name": "John",
  "email": "john@test.com",
  "status": "ACTIVE"
}
```

A PUT request might send:

```http
PUT /users/101
```

```json
{
  "name": "John",
  "email": "new@test.com",
  "status": "ACTIVE"
}
```

Conceptually:

```text
PUT
 |
 +---- Replace/update complete representation
```

---

### PATCH

Used for a **partial modification**.

```http
PATCH /users/101
```

```json
{
  "email": "new@test.com"
}
```

Only email needs to change.

```text
PATCH
 |
 +---- Modify selected fields
```

### Interview answer

> "`PUT` generally represents replacement of the resource representation and is idempotent. `PATCH` is intended for partial modifications and is not inherently required to be idempotent, although a particular PATCH operation can be designed to be idempotent."

### Important nuance

Don't say:

> "PATCH is always non-idempotent."

That's incorrect.

A PATCH operation **can be idempotent depending on how it is designed**.

---

# 6. Difference between PUT and POST

### POST

POST is generally used to:

* create a new resource under a collection
* trigger processing/action where POST semantics are appropriate
* submit data

Example:

```http
POST /orders
```

```json
{
  "productId": 1001,
  "quantity": 2
}
```

Server may generate:

```text
Order ID = 501
```

---

### PUT

PUT usually targets a **specific resource URI**.

```http
PUT /orders/501
```

The client knows the resource URI.

### Key difference

```text
POST /orders
       |
       v
Server typically determines new resource URI/ID

PUT /orders/501
       |
       v
Client specifies target URI
```

### Idempotency

POST:

```text
POST /orders
POST /orders
POST /orders
```

could create:

```text
Order 501
Order 502
Order 503
```

PUT:

```text
PUT /orders/501
PUT /orders/501
PUT /orders/501
```

can leave resource 501 in the same final state.

### Interview answer

> "POST is generally used for creating resources or processing a request where the server controls the resulting resource, while PUT targets a known URI and represents replacement of that resource. PUT is idempotent by HTTP semantics; POST is not."

---

# 7. Can we perform an insert operation using PUT?

### Yes.

This is a slightly tricky question.

PUT can be used to create a resource **if the client knows and specifies the resource URI**, and the server supports that semantics.

Example:

```http
PUT /users/101
```

```json
{
  "name": "John",
  "email": "john@test.com"
}
```

If user `101` doesn't exist, the server could create it.

Conceptually:

```text
PUT /users/101
       |
       +---- Exists?
       |       |
       |      YES → Replace
       |       |
       |      NO
       |       ↓
       |     Create
```

### Why is this different from POST?

Because the client knows:

```text
PUT /users/101
```

and can repeat the same request safely.

### Interview answer

> "Yes. PUT can create a resource when the client specifies the resource URI and the API defines PUT that way. The important point is not whether the database operation is technically INSERT; it's the HTTP semantics and idempotency of the API."

That's a **strong senior-level answer**.

---

# 8. What is idempotency in REST?

An operation is **idempotent if making the same request multiple times has the same intended effect on the server as making it once**.

Mathematically:

```text
f(f(x)) = f(x)
```

### Example

```http
PUT /users/101
```

```json
{
  "name": "John",
  "status": "ACTIVE"
}
```

Send it once:

```text
User 101 → ACTIVE
```

Send it again:

```text
User 101 → ACTIVE
```

Send it 10 times:

```text
User 101 → ACTIVE
```

Final state is the same.

### HTTP idempotent methods

Generally:

```text
GET       → Idempotent
PUT       → Idempotent
DELETE    → Idempotent
HEAD      → Idempotent
OPTIONS   → Idempotent
```

POST is **not inherently idempotent**.

### Important nuance

Idempotent does **not** mean:

> "The response must always be identical."

It means the **intended server-side effect** is the same.

For example, two DELETE requests might return:

```text
First → 204 No Content
Second → 404 Not Found
```

The operation can still be considered idempotent because the resource remains deleted.

---

# 9. Give a real-time example of an idempotent REST API

A good real-world example is:

```http
PUT /customers/123/address
```

```json
{
  "city": "Bengaluru",
  "pincode": "560001"
}
```

If the same request is retried because of a network timeout:

```text
Client
  |
  | PUT
  v
API
  |
  X Network timeout
  |
  | retry
  v
API
```

The address still becomes:

```text
Bengaluru / 560001
```

There isn't a second address created.

### Excellent real-world example: payment APIs

For **payments**, blindly relying on POST is dangerous because a network timeout could result in duplicate payments.

A common design is to use an **idempotency key**:

```http
POST /payments
Idempotency-Key: 8f7c-1234
```

Request:

```json
{
  "amount": 1000,
  "currency": "INR"
}
```

Retry with the same key:

```text
Request 1 ──→ Payment Service
Request 2 ──→ Payment Service
Request 3 ──→ Payment Service
                   |
                   v
            Same Idempotency Key
                   |
                   v
            Same payment result
```

The server stores the key/result and prevents duplicate processing.

### Interview answer

> "For payment APIs, I commonly use an idempotency key because clients may retry after a timeout. The same key ensures the same logical payment isn't processed multiple times."

---

# 10. How do you handle exceptions globally in Spring Boot?

Use:

```java
@RestControllerAdvice
```

or:

```java
@ControllerAdvice
```

with `@ExceptionHandler`.

For REST APIs, I commonly use `@RestControllerAdvice`.

Example:

```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(OrderNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleOrderNotFound(
            OrderNotFoundException ex) {

        ErrorResponse error =
                new ErrorResponse("ORDER_NOT_FOUND", ex.getMessage());

        return ResponseEntity
                .status(HttpStatus.NOT_FOUND)
                .body(error);
    }
}
```

Controller:

```java
@GetMapping("/orders/{id}")
public Order getOrder(@PathVariable Long id) {

    return orderService.findById(id)
            .orElseThrow(() ->
                new OrderNotFoundException("Order not found"));
}
```

Instead of putting:

```java
try {
   ...
} catch (...) {
   ...
}
```

inside every controller, exceptions are centralized.

### Architecture

```text
              HTTP Request
                   |
                   v
              Controller
                   |
                   v
               Service
                   |
                   X
             Exception
                   |
                   v
        @RestControllerAdvice
                   |
                   v
             ErrorResponse
```

---

# 11. How does `@ControllerAdvice` work?

`@ControllerAdvice` allows us to define **cross-cutting controller logic globally**.

Most commonly:

```java
@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(Exception.class)
    public ResponseEntity<?> handle(Exception ex) {
        ...
    }
}
```

Spring's MVC infrastructure detects the exception and looks for a matching `@ExceptionHandler`.

Conceptually:

```text
Controller
    |
    X Exception
    |
    v
DispatcherServlet
    |
    v
Exception resolution
    |
    v
@ControllerAdvice
    |
    v
@ExceptionHandler
    |
    v
HTTP Response
```

### `@RestControllerAdvice`

This is effectively:

```text
@ControllerAdvice
+
@ResponseBody
```

So it's especially convenient for REST APIs.

### Senior-level point

You can define handlers for:

```text
Specific business exception
        ↓
Validation exception
        ↓
Authentication/authorization exception
        ↓
Generic unexpected exception
```

And return a consistent error format.

For example:

```json
{
  "timestamp": "2026-09-10T10:20:30Z",
  "status": 404,
  "code": "ORDER_NOT_FOUND",
  "message": "Order 101 not found",
  "path": "/orders/101"
}
```

For newer Spring applications, you can also consider Spring's `ProblemDetail` support for standardized HTTP API error responses.

---

# 12. How do you implement validation in REST APIs?

Use Jakarta Bean Validation.

Example request:

```java
public class CreateUserRequest {

    @NotBlank
    private String name;

    @Email
    @NotBlank
    private String email;

    @Min(18)
    private int age;
}
```

Controller:

```java
@PostMapping("/users")
public ResponseEntity<?> createUser(
        @Valid @RequestBody CreateUserRequest request) {

    return ResponseEntity.ok(userService.create(request));
}
```

### Flow

```text
JSON Request
     |
     v
Jackson deserialization
     |
     v
CreateUserRequest
     |
     v
@Valid
     |
     v
Bean Validation
     |
     +---- Valid ------> Controller
     |
     +---- Invalid ----> Validation Exception
```

For example:

```json
{
  "name": "",
  "email": "abc",
  "age": 15
}
```

Validation can produce errors such as:

```text
name → must not be blank
email → must be a valid email
age → must be >= 18
```

### Common annotations

```text
@NotNull
@NotBlank
@NotEmpty
@Size
@Min
@Max
@Positive
@Email
@Pattern
```

### Important distinction

`@Valid` triggers validation.

`@Validated` is useful especially for **validation groups and method-level validation**.

### Interview answer

> "For request-body validation, I typically use Jakarta Bean Validation annotations on DTOs and `@Valid` on `@RequestBody`. I handle validation failures centrally through `@RestControllerAdvice`."

---

# 13. How do you secure REST APIs?

A typical Spring Boot REST API uses **Spring Security**.

For JWT-based authentication:

```text
Client
   |
   | Authorization: Bearer JWT
   v
Spring Security Filter Chain
   |
   +---- Validate JWT
   |
   +---- Extract user/authorities
   |
   +---- Authorization
   |
   v
Controller
```

Example configuration:

```java
@Bean
SecurityFilterChain securityFilterChain(HttpSecurity http)
        throws Exception {

    http
        .csrf(csrf -> csrf.disable())
        .authorizeHttpRequests(auth -> auth
            .requestMatchers("/public/**").permitAll()
            .requestMatchers("/admin/**")
                .hasRole("ADMIN")
            .anyRequest()
                .authenticated()
        )
        .oauth2ResourceServer(oauth2 ->
            oauth2.jwt(Customizer.withDefaults()));

    return http.build();
}
```

### Typical security layers

```text
HTTPS
  ↓
Authentication
  ↓
Authorization
  ↓
Input validation
  ↓
Business authorization
  ↓
Audit/logging
```

### Authentication

```text
Who are you?
```

### Authorization

```text
What are you allowed to do?
```

For example:

```text
USER
 └── GET /orders       ✓

USER
 └── DELETE /orders/10 ✗

ADMIN
 └── DELETE /orders/10 ✓
```

### Other important REST security practices

* HTTPS everywhere
* JWT/OAuth2 where appropriate
* Short-lived access tokens
* Secure token handling
* Role/authority-based authorization
* Input validation
* Rate limiting where appropriate
* Avoid sensitive information in logs
* CORS configuration based on actual requirements
* CSRF considerations based on authentication mechanism
* Proper security headers

### Senior-level point

Don't say:

> "JWT makes the API secure."

Better:

> "JWT is an authentication/token mechanism. The overall API security still depends on TLS, token validation, authorization, secure configuration, input validation and other controls."

---

# 14. Difference between HTTP and HTTPS

### HTTP

HTTP sends application data without transport encryption.

```text
Client
   |
   | HTTP
   | plaintext
   v
Server
```

Someone able to observe the network path may potentially read or modify the traffic.

---

### HTTPS

HTTPS is essentially:

```text
HTTP + TLS
```

```text
Client
   |
   | HTTPS
   | encrypted
   v
Server
```

Example:

```text
HTTP
http://example.com

HTTPS
https://example.com
```

### Comparison

| HTTP                               | HTTPS                                              |
| ---------------------------------- | -------------------------------------------------- |
| No TLS encryption                  | Uses TLS                                           |
| Data can be exposed on network     | Data is encrypted in transit                       |
| No server authentication from TLS  | Server authenticated using certificate             |
| Vulnerable to network interception | Protects against many network interception attacks |

### Important point

HTTPS protects **data in transit**.

It doesn't automatically protect:

```text
Database
Application vulnerabilities
Compromised server
Bad authorization
Malicious business logic
```

---

# 15. How does HTTPS provide security?

This is where interviewers may go deeper.

HTTPS uses **TLS — Transport Layer Security**.

It provides three major security properties:

```text
HTTPS / TLS
    |
    +---- Confidentiality
    |
    +---- Integrity
    |
    +---- Authentication
```

---

## Step 1 — Client connects

```text
Client
   |
   | ClientHello
   v
Server
```

Client and server negotiate TLS parameters.

---

## Step 2 — Server provides certificate

```text
Server
   |
   | Certificate
   v
Client
```

The certificate contains information binding the server's identity to a public key and is signed by a trusted Certificate Authority (CA).

Client validates things such as:

```text
Certificate valid?
       |
       +---- Trusted CA?
       |
       +---- Correct hostname?
       |
       +---- Within validity period?
       |
       +---- Not otherwise rejected?
```

---

## Step 3 — Establish cryptographic keys

Modern TLS uses asymmetric cryptography during the handshake to authenticate the server and establish shared session keys.

Then:

```text
Client                  Server
  |                       |
  |==== Encrypted =======>|
  |<=== Encrypted ========|
  |                       |
```

Bulk application data is protected using efficient symmetric cryptography.

---

## Step 4 — Encrypted communication

Suppose the client sends:

```text
password=abc123
```

Over HTTPS, the network does not see the plaintext application data; it sees encrypted TLS records.

Conceptually:

```text
Original Data
     |
     v
TLS Encryption
     |
     v
Encrypted Data
     |
     v
     Network
     |
     v
TLS Decryption
     |
     v
Original Data
```

---

# ⭐ How to explain HTTPS in 30 seconds

This is the answer I'd recommend memorizing:

> "HTTPS is HTTP running over TLS. During the TLS handshake, the server presents a certificate that allows the client to authenticate the server. The handshake establishes cryptographic session keys, and then application data is encrypted and integrity-protected. So HTTPS provides confidentiality and integrity for data in transit and server authentication."

That's a very strong answer for a senior Java interview.

---

# ⭐ Complete REST Request Flow — Memorize This

If an interviewer asks:

**"Explain what happens when a REST request comes into a Spring Boot application."**

Use this diagram:

```text
                    Client
                      |
                      | HTTPS
                      v
              Load Balancer / Gateway
                      |
                      v
            Spring Security Filters
                      |
                      v
               DispatcherServlet
                      |
                      v
              Handler Mapping
                      |
                      v
                Controller
                      |
                      v
                 Service
                      |
                      v
               Repository
                      |
                      v
                  Database
                      |
                      v
               Repository
                      |
                      v
                  Service
                      |
                      v
                Controller
                      |
                      v
             HttpMessageConverter
                      |
                      v
                  JSON
                      |
                      v
                   Client
```

And if something fails:

```text
Controller / Service / Repository
              |
              X
          Exception
              |
              v
     @RestControllerAdvice
              |
              v
       ErrorResponse
```

---

# ⭐ One More Important Interview Topic: REST Status Codes

You will very likely get asked this alongside these questions.

### 2xx — Success

```text
200 OK
201 Created
202 Accepted
204 No Content
```

Typical examples:

```text
GET      → 200
POST     → 201
DELETE   → 204
```

### 4xx — Client/request problem

```text
400 Bad Request
401 Unauthorized
403 Forbidden
404 Not Found
409 Conflict
422 Unprocessable Content
```

Remember the common distinction:

```text
401 → Authentication is missing/invalid
403 → Authentication may exist, but access is forbidden
```

### 5xx — Server-side problem

```text
500 Internal Server Error
502 Bad Gateway
503 Service Unavailable
504 Gateway Timeout
```

---

# 🎯 Final Rapid-Fire Revision

| Question                           | Interview answer                                                            |
| ---------------------------------- | --------------------------------------------------------------------------- |
| `@Controller` vs `@RestController` | View-oriented MVC vs REST response body                                     |
| `@RestController` internally       | `@Controller` + `@ResponseBody`                                             |
| `@RequestMapping`                  | Maps HTTP requests to handlers                                              |
| `@GetMapping`                      | GET                                                                         |
| `@PostMapping`                     | POST                                                                        |
| `@PutMapping`                      | PUT                                                                         |
| `@DeleteMapping`                   | DELETE                                                                      |
| PUT vs PATCH                       | Full replacement vs partial modification                                    |
| PUT vs POST                        | Known target URI/idempotent vs generally server-controlled creation/process |
| Can PUT insert?                    | Yes, if API semantics allow client-defined resource URI                     |
| Idempotency                        | Repeating same request has same intended server-side effect                 |
| Idempotent methods                 | GET, HEAD, PUT, DELETE, OPTIONS                                             |
| Global exceptions                  | `@RestControllerAdvice` + `@ExceptionHandler`                               |
| `@ControllerAdvice`                | Global controller exception/cross-cutting handling                          |
| Validation                         | DTO + Bean Validation + `@Valid`                                            |
| REST security                      | Spring Security + TLS + authentication + authorization                      |
| HTTP vs HTTPS                      | HTTP vs HTTP over TLS                                                       |
| HTTPS security                     | Authentication + encryption + integrity via TLS                             |

## 🔥 The 7 senior-level points worth memorizing

1. **`@RestController = @Controller + @ResponseBody`.**
2. **PUT is idempotent by HTTP semantics; PATCH can be idempotent depending on implementation.**
3. **Idempotency means same intended server-side effect—not necessarily identical response.**
4. **PUT can create a resource if the client specifies the URI and the API defines that behavior.**
5. **Use `@RestControllerAdvice` for centralized REST exception handling.**
6. **Use DTO + `@Valid` rather than exposing persistence entities directly as API contracts.**
7. **HTTPS = HTTP over TLS; TLS provides confidentiality, integrity, and server authentication.**


---
---

# 7. Transactions / Hibernate / JPA

The examples below use **Spring Boot, Spring Data JPA, Hibernate, and Java**. The explanations are designed to be easy to present in an interview while still showing 9 years of practical experience.

---

# 1. What is a transaction?

A **transaction** is a group of database operations treated as a single logical unit.

The transaction follows this rule:

> Either all operations succeed and are committed, or the operations are rolled back.

## Real-time example: Money transfer

Suppose we transfer ₹1,000 from Account A to Account B.

```text
1. Debit ₹1,000 from Account A
2. Credit ₹1,000 to Account B
```

Both operations must succeed together.

```text
                 Transaction Starts
                         |
                         v
              Debit Account A
                         |
                         v
              Credit Account B
                         |
                         v
                      COMMIT
```

If crediting Account B fails:

```text
                 Transaction Starts
                         |
                         v
              Debit Account A
                         |
                         v
              Credit Account B
                         |
                         v
                       FAILED
                         |
                         v
                      ROLLBACK
                         |
                         v
             Debit from Account A undone
```

## Spring Boot example

```java
@Service
public class TransferService {

    private final AccountRepository accountRepository;

    public TransferService(AccountRepository accountRepository) {
        this.accountRepository = accountRepository;
    }

    @Transactional
    public void transferMoney(
            Long fromAccountId,
            Long toAccountId,
            BigDecimal amount) {

        accountRepository.debit(fromAccountId, amount);

        accountRepository.credit(toAccountId, amount);
    }
}
```

`@Transactional` tells Spring to execute the method within a transaction.

### Interview answer

> A transaction is a logical unit of work containing one or more database operations. It ensures that the operations are committed together or rolled back together. In Spring, we commonly use `@Transactional` to manage transactions declaratively.

---

# 2. Explain ACID properties

ACID represents the four important properties of a transaction:

```text
A - Atomicity
C - Consistency
I - Isolation
D - Durability
```

| Property    | Meaning                                              |
| ----------- | ---------------------------------------------------- |
| Atomicity   | All operations succeed or all are rolled back        |
| Consistency | Data remains valid before and after the transaction  |
| Isolation   | Concurrent transactions do not interfere incorrectly |
| Durability  | Committed data survives failures                     |

---

## A — Atomicity

Atomicity means:

> A transaction is treated as one indivisible operation.

Example:

```text
Debit Account A
Credit Account B
```

If crediting Account B fails, the debit operation is also rolled back.

```text
Debit A + Credit B
        |
        +---- Both succeed  -> COMMIT
        |
        +---- One fails     -> ROLLBACK
```

---

## C — Consistency

Consistency means:

> A transaction must move the database from one valid state to another valid state.

Example:

```text
Before transfer:

Account A = ₹5,000
Account B = ₹3,000
Total     = ₹8,000
```

After transferring ₹1,000:

```text
Account A = ₹4,000
Account B = ₹4,000
Total     = ₹8,000
```

The total balance remains consistent.

Consistency is maintained through:

* Database constraints
* Foreign keys
* Unique constraints
* Not-null constraints
* Application business rules
* Transaction logic

---

## I — Isolation

Isolation means:

> One transaction should not improperly see the intermediate changes of another transaction.

Example:

```text
Transaction T1: Updating account balance
Transaction T2: Reading account balance
```

Isolation determines what T2 is allowed to see while T1 is still running.

Common isolation levels:

| Isolation level    | General behavior                                     |
| ------------------ | ---------------------------------------------------- |
| `READ_UNCOMMITTED` | Dirty reads are possible                             |
| `READ_COMMITTED`   | Only committed data can be read                      |
| `REPEATABLE_READ`  | Repeated reads generally return the same result      |
| `SERIALIZABLE`     | Highest isolation; transactions behave more serially |

In Spring:

```java
@Transactional(isolation = Isolation.READ_COMMITTED)
public void processPayment() {
    // Database operations
}
```

The exact behavior depends on the database.

---

## D — Durability

Durability means:

> Once a transaction is committed, the data should survive application or database failure.

```text
Transaction COMMIT successful
              |
              v
       Data persisted
              |
              v
 Application restart
              |
              v
       Data still exists
```

### Interview answer

> ACID properties guarantee reliable transactions. Atomicity ensures all-or-nothing execution, consistency maintains valid data, isolation controls concurrent transaction visibility, and durability ensures committed data survives failures.

---

# 3. What is transaction propagation?

Transaction propagation defines:

> How a method should behave when it is called from another method that may already have a transaction.

For example:

```text
Service A
   |
   v
Service B
```

If Service A already has a transaction, should Service B:

* Join the same transaction?
* Start a new transaction?
* Execute without a transaction?
* Fail if no transaction exists?

Spring provides propagation modes through the `@Transactional` annotation.

```java
@Transactional(propagation = Propagation.REQUIRED)
public void processOrder() {
}
```

## Common propagation types

| Propagation     | Behavior                                                     |
| --------------- | ------------------------------------------------------------ |
| `REQUIRED`      | Join existing transaction or create a new one                |
| `REQUIRES_NEW`  | Suspend existing transaction and create a new one            |
| `SUPPORTS`      | Join existing transaction if available                       |
| `MANDATORY`     | Existing transaction must be present                         |
| `NOT_SUPPORTED` | Execute without a transaction                                |
| `NEVER`         | Fail if a transaction exists                                 |
| `NESTED`        | Execute using a nested transaction/savepoint where supported |

The most important types for interviews are:

```text
REQUIRED
REQUIRES_NEW
```

---

# 4. Explain `Propagation.REQUIRED`

`REQUIRED` is the **default Spring transaction propagation mode**.

Its behavior is:

```text
If transaction exists:
    Join the existing transaction

If transaction does not exist:
    Create a new transaction
```

```java
@Transactional(propagation = Propagation.REQUIRED)
public void saveOrder() {
    // Database operations
}
```

Because `REQUIRED` is the default, this is equivalent:

```java
@Transactional
public void saveOrder() {
}
```

## Example

```java
@Service
public class OrderService {

    private final PaymentService paymentService;
    private final OrderRepository orderRepository;

    public OrderService(
            PaymentService paymentService,
            OrderRepository orderRepository) {
        this.paymentService = paymentService;
        this.orderRepository = orderRepository;
    }

    @Transactional
    public void placeOrder() {
        orderRepository.save(new Order());

        paymentService.savePayment();
    }
}
```

```java
@Service
public class PaymentService {

    @Transactional(propagation = Propagation.REQUIRED)
    public void savePayment() {
        // Save payment record
    }
}
```

## Transaction flow

```text
placeOrder()
     |
     | Starts Transaction T1
     v
Save Order
     |
     v
savePayment()
     |
     | Joins existing Transaction T1
     v
Save Payment
     |
     v
Commit T1
```

Both operations belong to the same transaction.

If payment saving fails:

```text
Save Order
     |
     v
Save Payment - FAILED
     |
     v
Rollback T1
     |
     v
Order and Payment changes are rolled back
```

### Important point

With `REQUIRED`, inner methods do not normally create independent transactions.

### Interview answer

> `Propagation.REQUIRED` joins the current transaction if one exists. If no transaction exists, Spring creates a new one. It is the default propagation mode and is useful when multiple service operations must commit or roll back together.

---

# 5. Explain `Propagation.REQUIRES_NEW`

`REQUIRES_NEW` means:

> Always execute the method in a new, independent transaction.

If an outer transaction already exists, Spring:

1. Suspends the outer transaction.
2. Starts a new transaction.
3. Executes the inner method.
4. Commits or rolls back the inner transaction.
5. Resumes the outer transaction.

```java
@Transactional(propagation = Propagation.REQUIRES_NEW)
public void saveAuditLog() {
    // Independent transaction
}
```

## Example

```java
@Service
public class OrderService {

    private final AuditService auditService;
    private final OrderRepository orderRepository;

    public OrderService(
            AuditService auditService,
            OrderRepository orderRepository) {
        this.auditService = auditService;
        this.orderRepository = orderRepository;
    }

    @Transactional
    public void placeOrder() {
        orderRepository.save(new Order());

        auditService.saveAuditLog();

        // Other order processing
    }
}
```

```java
@Service
public class AuditService {

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void saveAuditLog() {
        // Save audit record independently
    }
}
```

## Flow

```text
placeOrder()
     |
     | Start Transaction T1
     v
Save Order
     |
     v
Suspend T1
     |
     v
Start Transaction T2
     |
     v
Save Audit Log
     |
     v
Commit T2
     |
     v
Resume T1
     |
     v
Continue placeOrder()
     |
     v
Commit or Rollback T1
```

The audit log transaction is independent of the order transaction.

## Common use cases

`REQUIRES_NEW` is often used for:

* Audit logging
* Error logging
* Independent status history
* Retry tracking
* Recording failure details
* Saving an outbox record in a separate transaction, depending on the design

### Important practical point

The inner transaction usually needs separate transaction resources, such as another database connection. Therefore, excessive use of `REQUIRES_NEW` can increase connection-pool usage.

---

# 6. Difference between `REQUIRED` and `REQUIRES_NEW`

| Feature                   | `REQUIRED`                       | `REQUIRES_NEW`                      |
| ------------------------- | -------------------------------- | ----------------------------------- |
| Existing transaction      | Joins it                         | Suspends it                         |
| Creates a new transaction | Only if no transaction exists    | Always                              |
| Transaction independence  | No                               | Yes                                 |
| Rollback boundary         | Shared                           | Independent                         |
| Typical use               | Order and payment together       | Independent audit record            |
| Database resources        | Usually shares current resources | Usually requires separate resources |
| Outer transaction         | Continues normally               | Suspended temporarily               |

## Visual comparison

### `REQUIRED`

```text
Outer method
    |
    v
Transaction T1 starts
    |
    +---- Inner method joins T1
    |
    +---- Another method joins T1
    |
    v
Commit or Rollback T1
```

### `REQUIRES_NEW`

```text
Outer method
    |
    v
Transaction T1 starts
    |
    v
Suspend T1
    |
    v
Inner method starts T2
    |
    v
Commit or Rollback T2
    |
    v
Resume T1
    |
    v
Commit or Rollback T1
```

### Easy interview statement

> `REQUIRED` means “use the existing transaction if available.” `REQUIRES_NEW` means “always create a separate transaction and suspend the existing one temporarily.”

---

# 7. What happens if an inner `REQUIRES_NEW` transaction fails?

The inner transaction and outer transaction have separate transaction boundaries.

The result depends on whether the exception is handled.

---

## Case 1: Inner transaction fails and the exception is handled

```java
@Service
public class OrderService {

    @Transactional
    public void placeOrder() {
        orderRepository.save(new Order());

        try {
            auditService.saveAuditLog();
        } catch (Exception exception) {
            // Handle audit failure
            System.out.println("Audit failed");
        }

        paymentRepository.save(new Payment());
    }
}
```

```java
@Service
public class AuditService {

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void saveAuditLog() {
        throw new RuntimeException("Audit database error");
    }
}
```

## Flow

```text
Outer T1 starts
     |
     v
Save Order
     |
     v
Suspend T1
     |
     v
Start inner T2
     |
     v
Audit operation fails
     |
     v
Rollback T2
     |
     v
Exception handled by outer method
     |
     v
Resume T1
     |
     v
Save Payment
     |
     v
Commit T1
```

Possible result:

```text
Order       -> Committed
Audit Log   -> Rolled back
Payment     -> Committed
```

---

## Case 2: Inner exception is not handled

```java
@Transactional
public void placeOrder() {
    orderRepository.save(new Order());

    auditService.saveAuditLog(); // Throws exception

    paymentRepository.save(new Payment());
}
```

Flow:

```text
T1 starts
   |
   v
Suspend T1
   |
   v
T2 starts
   |
   v
T2 fails
   |
   v
Rollback T2
   |
   v
Exception propagates to T1
   |
   v
T1 may also roll back
```

If the exception reaches the outer transaction and is an unchecked exception, Spring normally marks the outer transaction for rollback.

### Important distinction

`REQUIRES_NEW` separates transaction boundaries, but it does not automatically suppress exceptions.

> The inner transaction may roll back independently, but if its exception propagates to the outer method, the outer transaction may also roll back.

### Additional interview point

If the outer transaction is suspended and the inner transaction fails, the outer transaction is resumed after the inner transaction completes or rolls back.

---

# 8. What is first-level cache in Hibernate?

The **first-level cache** is the cache maintained by a Hibernate `Session` or JPA `EntityManager`.

It is:

* Enabled by default.
* Associated with one persistence context.
* Not shared between different sessions.
* Used to store managed entities.

## Example

```java
User user1 = entityManager.find(User.class, 1L);

User user2 = entityManager.find(User.class, 1L);
```

Conceptually:

```text
First find:
    |
    v
Check first-level cache
    |
    v
Cache miss
    |
    v
Execute database query
    |
    v
Store User ID 1 in cache
```

Second find:

```text
Second find:
    |
    v
Check first-level cache
    |
    v
Cache hit
    |
    v
Return managed User object
```

## Diagram

```text
EntityManager / Hibernate Session
              |
              v
      First-Level Cache
              |
       +------+------+
       |             |
   User ID 1     User ID 2
       |
       v
   User object
```

Within the same persistence context, Hibernate generally avoids executing the same entity lookup query repeatedly.

## Example with Hibernate Session

```java
Session session = sessionFactory.openSession();

User user1 = session.get(User.class, 1L);
User user2 = session.get(User.class, 1L);
```

Both lookups refer to the same entity identity within that session.

## Clearing the cache

```java
entityManager.clear();
```

This clears the persistence context.

To detach one entity:

```java
entityManager.detach(user1);
```

### Interview answer

> First-level cache is the persistence-context-level cache maintained by Hibernate Session or JPA EntityManager. It is enabled by default and is not shared between sessions. It prevents repeated database access for the same entity within the same persistence context.

---

# 9. What is second-level cache in Hibernate?

The **second-level cache** is an optional cache associated with the Hibernate `SessionFactory`.

Unlike first-level cache, it can be shared by multiple sessions.

It normally requires a cache provider or implementation, such as:

* Ehcache
* Infinispan
* Other supported providers

## Diagram

```text
Session 1 --------\
                    \
Session 2 -----------> Second-Level Cache
                    /
Session 3 --------/
```

## Example flow

```text
Session 1 loads User ID 1
          |
          v
First-level cache miss
          |
          v
Second-level cache miss
          |
          v
Database query
          |
          v
Store data in second-level cache
```

Later:

```text
Session 2 loads User ID 1
          |
          v
First-level cache miss
          |
          v
Second-level cache hit
          |
          v
Database query may be avoided
```

## Entity configuration example

In Hibernate-specific configuration, an entity may be marked cacheable:

```java
@Entity
@Cacheable
@org.hibernate.annotations.Cache(
        usage = CacheConcurrencyStrategy.READ_ONLY
)
public class Country {

    @Id
    private Long id;

    private String name;
}
```

This is suitable for relatively static data such as countries or currencies.

### Interview answer

> Second-level cache is an optional Hibernate cache associated with the SessionFactory. It is shared across sessions and can reduce database queries for frequently read data. It requires explicit configuration and an appropriate cache provider.

---

# 10. Difference between first-level and second-level cache

| Feature                 | First-Level Cache                       | Second-Level Cache                           |
| ----------------------- | --------------------------------------- | -------------------------------------------- |
| Scope                   | Session / EntityManager                 | SessionFactory                               |
| Enabled by default      | Yes                                     | No                                           |
| Shared between sessions | No                                      | Yes                                          |
| Configuration           | Automatic                               | Requires configuration                       |
| Lifecycle               | Persistence context                     | SessionFactory/cache lifecycle               |
| Main purpose            | Avoid repeated reads in one session     | Avoid repeated reads across sessions         |
| Typical use             | Managed entities in current transaction | Frequently read entities across transactions |

## Diagram

```text
                    Application
                         |
          +--------------+--------------+
          |                             |
       Session 1                     Session 2
          |                             |
    First-Level Cache             First-Level Cache
          |                             |
          +--------------+--------------+
                         |
                 Second-Level Cache
                         |
                         v
                      Database
```

### Easy interview statement

> First-level cache is session-specific and always enabled. Second-level cache is shared across sessions, optional, and configured at the SessionFactory level.

---

# 11. How do you manage sessions in Hibernate?

A Hibernate `Session` represents a unit of work with the database.

It is responsible for:

* Loading entities
* Persisting entities
* Updating entities
* Deleting entities
* Maintaining the persistence context
* Managing first-level cache

---

## Traditional Hibernate session management

```java
Session session = sessionFactory.openSession();
Transaction transaction = null;

try {
    transaction = session.beginTransaction();

    User user = session.get(User.class, 1L);

    transaction.commit();

} catch (Exception exception) {
    if (transaction != null) {
        transaction.rollback();
    }

    throw exception;

} finally {
    session.close();
}
```

## Session lifecycle

```text
Open Session
     |
     v
Begin Transaction
     |
     v
Perform Database Operations
     |
     v
Commit or Rollback
     |
     v
Close Session
```

---

## Session management in Spring Boot

In Spring Boot with Spring Data JPA, we normally do not manually open and close sessions.

Spring manages the persistence context using:

* `@Transactional`
* `EntityManager`
* `JpaTransactionManager`
* Spring Data JPA repositories

```java
@Service
public class UserService {

    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Transactional
    public User getUser(Long id) {
        return userRepository.findById(id)
                .orElseThrow();
    }
}
```

Spring generally binds the persistence context to the transaction.

## Best practices

1. Keep transactions short.
2. Do not share a Hibernate Session between threads.
3. Do not manually close a container-managed `EntityManager`.
4. Prefer service-layer transaction boundaries.
5. Avoid lazy-loading relationships after the transaction has ended.
6. Avoid holding a transaction while calling slow external services.
7. Use batching for large inserts or updates.

### Interview answer

> In traditional Hibernate, we explicitly open, begin, commit or roll back, and close a Session. In Spring Boot, Spring usually manages the persistence context through `@Transactional`, EntityManager, and the transaction manager. We should define transaction boundaries at the service layer and never share a session between threads.

---

# 12. What is lazy loading?

**Lazy loading** means related data is loaded only when it is accessed.

It avoids loading unnecessary data from the database.

## Example

```java
@Entity
public class Department {

    @Id
    private Long id;

    private String name;

    @OneToMany(fetch = FetchType.LAZY)
    private List<Employee> employees;
}
```

When we load a department:

```java
Department department =
        departmentRepository.findById(1L)
                .orElseThrow();
```

Hibernate may execute only:

```sql
SELECT *
FROM department
WHERE id = 1;
```

The employees are not loaded immediately.

When we access the relationship:

```java
int count = department.getEmployees().size();
```

Hibernate may then execute:

```sql
SELECT *
FROM employee
WHERE department_id = 1;
```

## Diagram

```text
Load Department
      |
      v
Department loaded
Employees not loaded
      |
      v
Access getEmployees()
      |
      v
Hibernate loads employees
```

## Advantages

* Reduces initial database queries.
* Avoids loading unnecessary relationships.
* Useful for large collections.
* Can improve performance when relationships are not always needed.

## Common problem

If the persistence context is closed before accessing the relationship:

```java
department.getEmployees();
```

Hibernate may throw:

```text
LazyInitializationException
```

### Interview answer

> Lazy loading delays loading of an associated entity or collection until the relationship is accessed. It improves performance by avoiding unnecessary data retrieval, but the persistence context must still be available when the relationship is accessed.

---

# 13. What is eager loading?

**Eager loading** means associated data is loaded immediately or as part of the entity loading process.

## Example

```java
@Entity
public class Employee {

    @Id
    private Long id;

    private String name;

    @ManyToOne(fetch = FetchType.EAGER)
    private Department department;
}
```

When an employee is loaded, the department is also loaded according to the provider's fetching strategy.

```text
Load Employee
      |
      v
Employee + Department loaded
```

## Advantages

* Related data is available immediately.
* Reduces some lazy initialization problems.

## Disadvantages

* May load data that is not needed.
* Can increase memory usage.
* Can produce additional queries or large joins.
* Can cause performance issues when relationships are large.
* May contribute to N+1 problems depending on the mapping and access pattern.

### Important point

`EAGER` does not necessarily mean Hibernate will always use one SQL join. Hibernate may use a join or separate SQL queries depending on the query, mapping, and provider behavior.

### Interview answer

> Eager loading loads associated data immediately along with the main entity or during the entity loading process. It is useful when the relationship is always required, but it can cause unnecessary data loading and performance issues.

---

# 14. What is the N+1 query problem?

The **N+1 query problem** occurs when:

1. One query loads a list of parent entities.
2. One additional query is executed for each parent to load its related data.

If there are `N` parent records:

```text
1 query for parents
+
N queries for children
=
N + 1 queries
```

## Example

Suppose the database contains 100 departments.

```java
List<Department> departments =
        departmentRepository.findAll();

for (Department department : departments) {
    System.out.println(
            department.getEmployees().size()
    );
}
```

Hibernate may execute:

```sql
-- Query 1
SELECT *
FROM department;
```

Then:

```sql
-- Query 2
SELECT *
FROM employee
WHERE department_id = 1;

-- Query 3
SELECT *
FROM employee
WHERE department_id = 2;

-- Query 4
SELECT *
FROM employee
WHERE department_id = 3;

-- ...
-- Query 101
SELECT *
FROM employee
WHERE department_id = 100;
```

Total:

```text
1 + 100 = 101 queries
```

## Diagram

```text
Load all departments
        |
        v
     1 query
        |
        v
For every department:
        |
        +---- Query employees for Department 1
        |
        +---- Query employees for Department 2
        |
        +---- Query employees for Department 3
        |
        +---- ...
        |
        +---- Query employees for Department N
```

### Interview answer

> The N+1 problem occurs when Hibernate executes one query to fetch parent records and then executes one additional query for each parent to fetch its children. It can cause serious performance degradation when the parent list is large.

---

# 15. How do you resolve the N+1 query problem?

There are several approaches.

---

## Approach 1: Use `JOIN FETCH`

```java
@Query("""
       SELECT DISTINCT d
       FROM Department d
       LEFT JOIN FETCH d.employees
       """)
List<Department> findDepartmentsWithEmployees();
```

This fetches departments and employees together.

Conceptually:

```sql
SELECT d.*, e.*
FROM department d
LEFT JOIN employee e
       ON e.department_id = d.id;
```

## Diagram

```text
One JOIN FETCH query
          |
          v
Departments + Employees
```

### Why use `DISTINCT`?

When joining a collection, one department may appear in multiple result rows—one for each employee. `DISTINCT` helps remove duplicate parent entities from the result list.

### Important caution

Fetching multiple large collections using joins can create a Cartesian product or a very large result set. Use it carefully.

---

## Approach 2: Use `@EntityGraph`

```java
@EntityGraph(attributePaths = {"employees"})
List<Department> findAll();
```

This tells Spring Data JPA to fetch the `employees` relationship as part of the query.

It is useful when you want to define fetching behavior without writing explicit JPQL.

---

## Approach 3: Use batch fetching

Hibernate can fetch relationships in groups instead of one at a time.

```java
@OneToMany(fetch = FetchType.LAZY)
@BatchSize(size = 20)
private List<Employee> employees;
```

Or configure globally:

```properties
spring.jpa.properties.hibernate.default_batch_fetch_size=20
```

Instead of:

```text
100 separate queries
```

Hibernate may issue queries in batches:

```text
5 queries, each handling approximately 20 parent IDs
```

The exact number depends on the data and generated SQL.

---

## Approach 4: Use DTO projection

If the API only needs selected fields, fetch only those fields.

```java
@Query("""
       SELECT new com.example.dto.DepartmentEmployeeDto(
           d.id,
           d.name,
           e.name
       )
       FROM Department d
       JOIN d.employees e
       """)
List<DepartmentEmployeeDto> findDepartmentEmployeeData();
```

DTO projections avoid loading complete entities and unnecessary relationships.

---

## Approach 5: Use explicit queries

Instead of relying on implicit lazy loading, explicitly fetch the data required by the use case using:

* JPQL
* Native SQL
* Criteria API
* Entity graphs
* DTO projections

## Do not blindly change relationships to `EAGER`

Changing everything to `EAGER` is generally not a proper solution because it may:

* Load too much data.
* Create additional queries.
* Increase memory consumption.
* Cause new performance issues.

### Interview answer

> I resolve N+1 problems using fetch joins, `@EntityGraph`, batch fetching, DTO projections, or carefully designed queries. I do not blindly change relationships to `EAGER`, because that can create unnecessary database work.

---

# 16. What are different Hibernate cache strategies?

Hibernate cache strategies describe how cached data behaves when entities are read or updated.

The common concurrency strategies are:

| Strategy               | Description                                                 | Suitable for                                  |
| ---------------------- | ----------------------------------------------------------- | --------------------------------------------- |
| `READ_ONLY`            | Data is immutable and cannot be updated through the cache   | Static reference data                         |
| `NONSTRICT_READ_WRITE` | Allows temporary stale data                                 | Rarely updated data                           |
| `READ_WRITE`           | Provides stronger consistency using locking or coordination | Read-mostly mutable data                      |
| `TRANSACTIONAL`        | Cache participates in transactions where supported          | Transactionally consistent cache environments |

---

## 1. `READ_ONLY`

Used when data never changes.

Examples:

* Country codes
* Currency codes
* Time zones
* Immutable reference data

```java
@Cacheable
@org.hibernate.annotations.Cache(
        usage = CacheConcurrencyStrategy.READ_ONLY
)
@Entity
public class Country {
}
```

Advantages:

* Good read performance.
* Simple cache behavior.

Limitation:

* Not suitable for frequently updated entities.

---

## 2. `NONSTRICT_READ_WRITE`

This strategy allows a small period of stale data.

It is suitable when:

* Data changes rarely.
* Slightly outdated information is acceptable.
* Strong consistency is not required for every read.

Examples:

* Product descriptions
* Non-critical catalog metadata

```text
Database updated
      |
      v
Cache may temporarily contain old value
```

---

## 3. `READ_WRITE`

This strategy provides stronger consistency than `NONSTRICT_READ_WRITE`.

It uses cache coordination and locking-related mechanisms to reduce inconsistent reads.

It can be used for:

* Frequently read entities.
* Entities that are updated occasionally.
* Applications requiring better cache consistency.

---

## 4. `TRANSACTIONAL`

This strategy allows the cache to participate in transactions when the cache provider supports it.

It requires:

* A compatible cache provider.
* Appropriate transaction integration.
* Correct infrastructure configuration.

### Important interview distinction

Do not confuse cache levels with cache concurrency strategies.

```text
Cache levels:
    First-level cache
    Second-level cache
    Query cache

Cache concurrency strategies:
    READ_ONLY
    NONSTRICT_READ_WRITE
    READ_WRITE
    TRANSACTIONAL
```

---

# 17. What are different types of cache?

Caching can be discussed at different levels.

## 1. First-level cache

* Managed by Hibernate Session or EntityManager.
* Enabled by default.
* Exists within one persistence context.
* Not shared between sessions.

```text
EntityManager
      |
      v
First-Level Cache
```

---

## 2. Second-level cache

* Managed at the Hibernate SessionFactory level.
* Optional.
* Shared across sessions belonging to the same SessionFactory.
* Requires configuration.

```text
Multiple Sessions
        |
        v
Second-Level Cache
```

---

## 3. Query cache

The query cache stores query-related information, often including identifiers of matching entities.

For example:

```sql
SELECT *
FROM users
WHERE status = 'ACTIVE';
```

The query cache may store the identifiers of users matching the query.

Important points:

* It is optional.
* It generally works with the second-level cache.
* It requires careful invalidation.
* It may not be useful for highly dynamic queries.

---

## 4. Application-level cache

This cache is implemented at the service or application layer.

Examples:

* Spring Cache
* Caffeine
* Guava Cache
* Redis
* Hazelcast

```text
Controller
    |
    v
Service
    |
    v
Application Cache
    |
    +---- Cache hit -> Return data
    |
    +---- Cache miss -> Repository -> Database
```

---

## 5. Distributed cache

A distributed cache is shared by multiple application instances.

Examples:

* Redis
* Hazelcast
* Infinispan

```text
Application 1 ----\
                    \
Application 2 ------> Distributed Cache
                    /
Application 3 ----/
```

This is useful when the application is deployed on multiple servers.

## Summary

| Cache type         | Scope                               |
| ------------------ | ----------------------------------- |
| First-level cache  | One persistence context             |
| Second-level cache | Hibernate SessionFactory            |
| Query cache        | Query result information            |
| Application cache  | Application/service layer           |
| Distributed cache  | Shared across application instances |

---

# 18. How would you implement caching in a Spring Boot application?

Spring Boot provides a caching abstraction through **Spring Cache**.

The general implementation steps are:

```text
1. Add cache dependency
2. Enable caching
3. Use @Cacheable
4. Use @CachePut for updates
5. Use @CacheEvict for deletion/invalidation
6. Configure a cache provider
```

---

## Step 1: Add dependency

For Spring’s caching abstraction:

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-cache</artifactId>
</dependency>
```

For a production application, we can use a provider such as:

* Caffeine
* Redis
* Hazelcast

---

## Step 2: Enable caching

```java
@Configuration
@EnableCaching
public class CacheConfig {
}
```

`@EnableCaching` enables Spring’s cache interception mechanism.

---

## Step 3: Use `@Cacheable`

```java
@Service
public class ProductService {

    private final ProductRepository productRepository;

    public ProductService(ProductRepository productRepository) {
        this.productRepository = productRepository;
    }

    @Cacheable(value = "products", key = "#id")
    public Product getProduct(Long id) {
        System.out.println("Fetching product from database");

        return productRepository.findById(id)
                .orElseThrow();
    }
}
```

## First call

```java
productService.getProduct(10L);
```

```text
Check cache
     |
     v
Cache miss
     |
     v
Execute database query
     |
     v
Store result in cache
     |
     v
Return product
```

## Second call

```java
productService.getProduct(10L);
```

```text
Check cache
     |
     v
Cache hit
     |
     v
Return cached product
```

The database method is normally not executed on the second call.

---

## Step 4: Use `@CachePut`

`@CachePut` always executes the method and updates the cache with the returned result.

```java
@CachePut(value = "products", key = "#result.id")
public Product updateProduct(Product product) {
    return productRepository.save(product);
}
```

Flow:

```text
Update database
      |
      v
Update cache with returned object
```

---

## Step 5: Use `@CacheEvict`

`@CacheEvict` removes data from the cache.

```java
@CacheEvict(value = "products", key = "#id")
public void deleteProduct(Long id) {
    productRepository.deleteById(id);
}
```

To clear all entries:

```java
@CacheEvict(value = "products", allEntries = true)
public void clearProductCache() {
}
```

---

## Step 6: Use `@Caching`

`@Caching` groups multiple cache operations.

```java
@Caching(
        put = {
            @CachePut(
                    value = "products",
                    key = "#result.id"
            )
        },
        evict = {
            @CacheEvict(
                    value = "productList",
                    allEntries = true
            )
        }
)
public Product updateProduct(Product product) {
    return productRepository.save(product);
}
```

This example:

1. Updates the individual product cache.
2. Clears the product-list cache because the list may have changed.

---

# Complete Spring Cache example

```java
@Configuration
@EnableCaching
public class CacheConfig {
}
```

```java
@Service
@CacheConfig(cacheNames = "products")
public class ProductService {

    private final ProductRepository productRepository;

    public ProductService(ProductRepository productRepository) {
        this.productRepository = productRepository;
    }

    @Cacheable(key = "#id")
    public Product getProduct(Long id) {
        return productRepository.findById(id)
                .orElseThrow();
    }

    @CachePut(key = "#result.id")
    public Product updateProduct(Long id, Product product) {
        product.setId(id);
        return productRepository.save(product);
    }

    @CacheEvict(key = "#id")
    public void deleteProduct(Long id) {
        productRepository.deleteById(id);
    }
}
```

## Cache flow

```text
                 Client Request
                       |
                       v
                 ProductService
                       |
                       v
                   Check Cache
                   /          \
                Hit            Miss
                 |               |
                 v               v
          Return Cached     Query Database
          Product                 |
                                  v
                           Store in Cache
                                  |
                                  v
                            Return Product
```

---

# Using Redis as a distributed cache

For multiple application instances, Redis is a common choice.

## Architecture

```text
                         Client
                           |
                           v
                     Load Balancer
                           |
                 +---------+---------+
                 |                   |
                 v                   v
          Application 1       Application 2
                 |                   |
                 +---------+---------+
                           |
                           v
                          Redis
                           |
                           v
                        Database
```

Both application instances use the same Redis cache.

Typical configuration:

```properties
spring.cache.type=redis
spring.data.redis.host=localhost
spring.data.redis.port=6379
```

The exact configuration properties may vary depending on the Spring Boot version and Redis setup.

---

# Important caching concepts

## 1. Cache-aside pattern

The application checks the cache first.

```text
Read request
     |
     v
Check cache
     |
     +---- Hit ----> Return cached data
     |
     +---- Miss
              |
              v
        Read database
              |
              v
        Store in cache
              |
              v
        Return data
```

`@Cacheable` commonly supports this type of behavior.

---

## 2. Cache invalidation

When data changes, the cache must be updated or removed.

```text
Update database
      |
      v
Update or evict cache
```

If invalidation is incorrect, users may see stale data.

---

## 3. Cache key design

The cache key must uniquely identify the data.

```java
@Cacheable(value = "products", key = "#id")
public Product getProduct(Long id) {
    // ...
}
```

For multiple parameters:

```java
@Cacheable(
        value = "products",
        key = "#category + ':' + #page + ':' + #size"
)
public Page<Product> getProducts(
        String category,
        int page,
        int size) {
    // ...
}
```

---

## 4. Spring caching is proxy-based

Spring caching is commonly implemented using proxies.

Therefore, self-invocation may bypass caching.

```java
@Service
public class ProductService {

    public void methodA() {
        methodB(); // May bypass Spring cache proxy
    }

    @Cacheable("products")
    public Product methodB() {
        // Database operation
        return null;
    }
}
```

Calling `methodB()` from another Spring bean through the proxy generally allows caching to work.

---

## 5. Common caching problems

* Stale data
* Incorrect cache keys
* Cache stampede
* Cache penetration
* Cache eviction problems
* Excessive memory usage
* Serialization issues
* Inconsistent cache across application instances
* Caching sensitive or rapidly changing data
* Cache invalidation failures

---

# Final quick revision table

| Topic                        | Easy interview answer                                                         |
| ---------------------------- | ----------------------------------------------------------------------------- |
| Transaction                  | A logical unit of work committed or rolled back together                      |
| ACID                         | Atomicity, Consistency, Isolation, Durability                                 |
| Propagation                  | Defines how a method participates in a transaction                            |
| `REQUIRED`                   | Joins an existing transaction or creates one                                  |
| `REQUIRES_NEW`               | Suspends the existing transaction and creates a new one                       |
| `REQUIRED` vs `REQUIRES_NEW` | Shared transaction vs independent transaction                                 |
| Inner `REQUIRES_NEW` failure | Inner transaction rolls back; outer transaction depends on exception handling |
| First-level cache            | Session/EntityManager-level cache, enabled by default                         |
| Second-level cache           | Optional cache shared across sessions in a SessionFactory                     |
| Session management           | Spring usually manages sessions through `@Transactional` and EntityManager    |
| Lazy loading                 | Loads relationships when accessed                                             |
| Eager loading                | Loads relationships immediately or during entity loading                      |
| N+1 problem                  | One parent query plus one query for each parent                               |
| N+1 solutions                | Fetch join, EntityGraph, batch fetching, DTO projection                       |
| Hibernate cache strategies   | `READ_ONLY`, `NONSTRICT_READ_WRITE`, `READ_WRITE`, `TRANSACTIONAL`            |
| Cache types                  | First-level, second-level, query, application, distributed                    |
| Spring Boot caching          | `@EnableCaching`, `@Cacheable`, `@CachePut`, `@CacheEvict`                    |
