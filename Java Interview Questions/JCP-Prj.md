<img width="1600" height="900" alt="image" src="https://github.com/user-attachments/assets/fc9387c3-b511-40e8-a5df-207de46ee8f2" />

>
In my project, we have an event-driven architecture using Java, Spring Boot, and Apache Kafka.

The process starts when an event is published to the eCommPO Kafka topic. Our Java-based Spring Boot consumer consumes the event and performs schema validation to ensure that the incoming message has the expected structure.

After successful validation, the consumer processes the event and retrieves the required reference information from the RMS database, including item details, cross-reference information, and supplier information.

Based on the retrieved data, the application performs business validations, checks item status, and filters the relevant SAS plans. If an item is inactive or an exception occurs, the application has a notification flow that uses the SMTP mail server.

For valid plan data, the application processes store and SSC quantity information, maps the required identifiers such as UUIDs to the plan, and retrieves fiscal date information based on the delivery date.

Once the processing is complete, the application persists the plan information to the RMS database and updates the processing status in the SizeOpt database. The diagram also indicates status tracking and retry-related handling.

Overall, the application integrates Kafka, Spring Boot, multiple databases, and email notifications to support automated plan processing and purchase order-related workflows.
