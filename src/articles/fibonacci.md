---
title: "Fibonacci using recursion – Really Easy or Hard??"
description: " "
tags:
  - fibonacci
  - Java
date: 2016-06-09
---
![Fibonacci](/static/images/fibonacci-number-games.jpg)

How hard is it to find a Fibonacci number? What is the use of this post? Pure waste of time?

Is it really so hard?

What we normally find on internet and school books is this:

```java
public class Fibonacci
{
    private long numRec = 0;
 
    public static void main(String[] args)
    {
        BufferedReader systemReader = new BufferedReader(new InputStreamReader(System.in));
        System.out.println("Enter a number:");
        long number = Long.parseLong(systemReader.readLine());
        Fibonacci f = new Fibonacci();
        long time = System.currentTimeMillis();
        System.out.println("Fibonacci number:"+f.fibonacci(number));
        System.out.println("Number of Recursions:"+f.numRec);
        System.out.println((System.currentTimeMillis()-time)/1000);
    }
 
    long fibonacci(long number)
    {
        numRec++;
        if (number == 0 || number == 1)
            return number;
        else
            return fibonacci(number - 1) + fibonacci(number - 2);
    }
}
```

Now running this above program will give you 46th Fibonacci number in 16 seconds with 3672623805 recursions on an Intel i5 32 bit processor. And for finding 51st Fibonacci number, well I couldn’t wait for program to end. So I set out to find myself what is the problem with what is being taught in schools.

If we analyze the above program then we find that for every recursions we do 2 more recursions:

**f(n) = f(n-1) + f(n-2)**

Now f(n-1) = f(n-2) + f(n-3)

Which clearly means that while calculating f(n-1) program calculates f(n-2) so why calculate f(n-2) again. This is the trouble with above program.

Now what is the solution. Why not we deal with indexes in recursion instead of numbers and use only latest two calculated numbers for calculating next one. After all that’s how its done by humans. Start index with 1 and latest two numbers as 0 and 1. And we get following:

```java
public class Fibonacci
{
 
    private long numRec = 0;
 
    public static void main(String[] args)
    {
        BufferedReader systemReader = new BufferedReader(new InputStreamReader(System.in));
        System.out.println("Enter a number:");
        long number = Long.parseLong(systemReader.readLine());
        Fibonacci f = new Fibonacci();
        long time = System.currentTimeMillis();
        System.out.println("Fibonacci number:"+f.fibonacci(1, number, 1, 0));
        System.out.println("Number of Recursions:"+f.numRec);
        System.out.println((System.currentTimeMillis()-time)/1000);
    }
 
    long fibonacci(long index, long desiredIndex, long number, long lastNumber)
    {
        numRec++;
        number = number + lastNumber;
        lastNumber = number - lastNumber;
        if(desiredIndex == 0 || desiredIndex == 1)
            return desiredIndex;
        if (desiredIndex-index == 1)
            return number;
        return fibonacci(index + 1, desiredIndex, number, lastNumber);
    }
}
```

Running this above program I get 46th Fibonacci number in exactly 44 recursions and 0 sec (basically even less than 1 millisec). So now I calculated 1001st Fibonacci number and this new program took 999 recursions and again 0 sec. So for this program

**number_of_recursions = Fibonacci_number_to_be_found – 2**