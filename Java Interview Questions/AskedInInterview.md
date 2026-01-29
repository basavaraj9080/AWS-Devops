Write a program to print second highest employee salary using java 8
	List<Integer> list = Arrays.asList(5,6,9,12,18,16);
	list.stream().sorted()
	.limit(2)
	.skip(1)

## **Write a program to reverse the charecter of the string and should not change the special charecter place?**
	String input = "abcd@efg#hi"; </br>
	Output string: ihgf@edc#ba </br>

	public class Test {

    public static void main(String[] args) {
        String input = "abcd@efg#hi";
        char[] chars = input.toCharArray();

        int left = 0;
        int right = chars.length - 1;

        while (left < right) {
            if (!Character.isLetter(chars[left])) {
                left++;
            } else if (!Character.isLetter(chars[right])) {
                right--;
            } else {
                char temp = chars[left];
                chars[left] = chars[right];
                chars[right] = temp;
                left++;
                right--;
            }
        }

        System.out.println(new String(chars));
    }
}

	
Print the departmentwise highest salary? using groupingBy or using map

Explian the features of Java-8?
Why we use static method in Functional Inteface?
What is Optional class in java-8?
What is the difference between Optional class methods?
	orElse(defaultValue);  // returns value or default
	orElseGet(() -> val);  // lazy default
	
	get();                 // returns value (throws exception if empty)
	orElse(defaultValue);  // returns value or default
	orElseGet(() -> val);  // lazy default
	orElseThrow();         // throws NoSuchElementException
	orElseThrow(() -> ex); // custom exception

What is the difference between HashMap and ConcurrentHashMap, and when should each be used?
What is the difference between LinkedHashMap and WeakHashMap, and when should each be used?
Have you ever faced collision, and how will you fix it? 
What is the difference between @Lazy and @Eager, when should each be used?
What is @Autowiring when we use @Autowiring and Constructor injection, which one is better?
What is the difference between @Transaction annotaion on class level and method level?
What is intermediate and terminal operator in java-8?
Can we use immutable object as a key in Map?
How do you identify this is Singleton patter?
How do you detect memory leaks?


MultiTreading?
What is the difference between ExecutorService and CompletableFuture class?




How will you design HA & FT architecture in aws?
In the EKS if the microservice is down then how will you dubug this?
What is Nod Scaling and pod scaling?
Explian how you build CICD pipeline?
I need to desing the user transaction microservice to publish the messages to kafka, what are the components required to build this service?
if you get microservice out of memory error then how will you debug it, what are the steps you follow to find rhe root cause? (in EKS)?
How do you scale the microservice?
What all the metrics you can see in grafana?

If the KAFKA consumer is lagging to consume the message, then what could be the reason?
Can Kafka be used as a synchronous service?
	Is it possible to use Kafka in a synchronous communication model?
	Can Kafka support synchronous request–response communication?
	Can Kafka be used to implement synchronous request–response behavior?
	Is Kafka suitable for synchronous service-to-service communication?
**	Why is Kafka considered asynchronous, and can it be used to achieve synchronous behavior?


SQL:
What is index and when you use it?
Why we use indexing?
Is there any performance issue if you use indexing?
How indexing works?
What is Normalizaton and DeNormalization?
What is the difference between Where and Having?
