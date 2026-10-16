On your team, who keeps writing code that works but is difficult for others to understand and maintain? How would you approach this situation and what specific guidance would you provide?
>
This is a behavioral interview question that tests your leadership, teamwork, code review skills, and ability to improve code quality without blaming colleagues.

## Interview-ready answer

“In my team, if I notice that a team member is writing code that works correctly but is difficult to understand or maintain, I would approach the situation constructively rather than criticize the person.

First, I would understand the business logic and discuss the code with the developer to identify why it is complex. Sometimes the complexity comes from tight deadlines or complicated requirements.

During the code review, I would provide specific, actionable suggestions, such as following the Single Responsibility Principle, using meaningful variable and method names, breaking large methods into smaller ones, avoiding duplicate code, and handling exceptions properly.

For example, if a Spring Boot service contains a single method that validates an order, processes payment, updates inventory, and sends Kafka events, I would suggest separating these responsibilities into smaller, well-named methods or appropriate service classes.

I would also recommend writing unit tests, following our team's coding standards, and using tools such as SonarQube to identify code smells and maintainability issues.

If the same issues continue, I would arrange a short pair-programming session or knowledge-sharing session to help the developer. My goal would be to improve the codebase and help the team member grow, not to blame them.

Ultimately, I believe code should not only work correctly but also be easy for other developers to understand, test, debug, and extend.”

## Specific guidance I would provide

| Issue                     | My recommendation                                           |
| ------------------------- | ----------------------------------------------------------- |
| Very large methods        | Break them into smaller, focused methods                    |
| Unclear variable names    | Use meaningful, domain-specific names                       |
| Duplicate logic           | Extract reusable methods or components                      |
| Too many responsibilities | Follow SOLID principles, especially Single Responsibility   |
| Complex conditional logic | Simplify conditions and use guard clauses where appropriate |
| Missing tests             | Add unit tests for business logic and edge cases            |
| Poor error handling       | Use meaningful exceptions and appropriate logging           |
| Inconsistent coding style | Follow team conventions and SonarQube rules                 |

## A simple Java example

Before — difficult to maintain:

```
public void process(Order order) {
    if (order != null) {
        if (order.getAmount() > 0) {
            // validate order
            // process payment
            // update inventory
            // publish Kafka event
        }
    }
}
```

After — easier to understand:

```
public void process(Order order) {
    validateOrder(order);
    paymentService.processPayment(order);
    inventoryService.updateInventory(order);
    eventPublisher.publishOrderCreated(order);
}
```

This makes the workflow easier to read, test, and maintain. Each responsibility can be developed and tested independently.

Strong closing statement for the interview:

“My approach is to give respectful, evidence-based feedback during code reviews, explain why a change improves maintainability, and establish consistent coding standards across the team. I focus on improving both the code and the developer's skills.”

---
---
## So you mentioned explaining architecture and raising code review comments. Could you give a specific example of a code review comment you'd make for hard-to-read code?
>
“In a code review, suppose I see a method in a Spring Boot service that validates an order, processes payment, updates inventory, and publishes a Kafka event all in one method.

I would leave a comment like this:

Example code review comment:

Could we refactor this method into smaller, well-named methods to improve readability and maintainability? Currently, it handles multiple responsibilities, which makes the code harder to understand, test, and modify.

For example, we could separate order validation, payment processing, inventory updates, and Kafka event publishing into dedicated methods or service classes.

This would improve separation of concerns, make unit testing easier, and reduce the risk of introducing bugs when modifying individual steps.

I would also suggest discussing the change with the developer if the design is complex, rather than just requesting changes without an explanation.

The key point is that my review comment is specific, respectful, and actionable. I explain what needs improvement, why it matters, and how the developer can address it.”

---
---
## Guide the junior to refactor or improve that method. What would you suggest to make it clearer and more maintainable?
>
You can answer this in your interview with a practical Java and Spring Boot example.

## Interview-ready answer

“I would guide the junior developer to follow the Single Responsibility Principle and break the large method into smaller methods, each handling one specific task.

First, I would ask them to identify the different responsibilities in the existing method, such as order validation, payment processing, inventory updates, and Kafka event publishing.

Then, I would suggest extracting these responsibilities into well-named methods or separate service classes. I would also recommend using meaningful variable names, avoiding duplicate code, handling exceptions properly, and writing unit tests for each component.

For example, instead of putting the entire order processing workflow into one large method, we could make the main method read like a sequence of business steps.

I would work with the junior developer through a code review or pair-programming session, explain why the changes improve readability, and encourage them to apply the same principles in future implementations.”

## Example: Before and after refactoring

Before — difficult to maintain

```
public void processOrder(Order order) {
    if (order != null && order.getAmount() > 0) {
        // Validate order
        // Process payment
        // Update inventory
        // Publish Kafka event
    }
}
```

After — clearer structure

```
public void processOrder(Order order) {
    validateOrder(order);
    paymentService.processPayment(order);
    inventoryService.updateInventory(order);
    eventPublisher.publishOrderCreated(order);
}

private void validateOrder(Order order) {
    if (order == null || order.getAmount() <= 0) {
        throw new IllegalArgumentException("Invalid order");
    }
}
```

In a real application, I would keep payment, inventory, and event publishing in appropriate Spring service components, with clear transaction boundaries and error handling.

Key point to tell the interviewer: “I don't just ask a junior developer to rewrite code. I explain the reasoning, demonstrate a better approach, review the changes together, and ensure the refactored code has appropriate unit tests without changing the existing business behavior.”

---
---
## Splitting the task makes sense. What if the junior developer struggles with naming or structuring those new methods? How would you help them get better at that?
>
## Interview-ready answer

“I would guide the junior developer by explaining how to choose method names based on business intent and responsibility, rather than implementation details.

For example, instead of naming a method `processData()` or `doTask()`, I would encourage names like `validateOrder()`, `processPayment()`, and `publishOrderCreatedEvent()`. These names clearly communicate what each method does.

For structuring methods, I would teach them to keep each method focused on one responsibility and make the main workflow easy to read from top to bottom.

I would use pair programming to refactor one example together, explain why I chose particular names and boundaries, and then ask them to apply the same approach to another method independently.

I would also recommend following our team's naming conventions, reviewing existing well-written code, and using code reviews as a learning opportunity. Over time, I would give them more ownership and constructive feedback so they develop confidence in making these decisions themselves.

My goal is not just to fix the current code, but to help the junior developer build the skills to write clean, maintainable code independently.”

### Quick example

Instead of:

```
void process(Order o) {
    check(o);
    pay(o);
    update(o);
    send(o);
}
```

I would guide them toward:

```
void processOrder(Order order) {
    validateOrder(order);
    paymentService.processPayment(order);
    inventoryService.updateInventory(order);
    eventPublisher.publishOrderCreated(order);
}
```

Key takeaway: Teach through examples, explain the reasoning, practise together, and gradually encourage independent decision-making.

---
---
