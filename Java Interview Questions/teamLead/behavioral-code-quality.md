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
