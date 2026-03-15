---
title: "PriorityExecutorService in Java"
description: "Priority based ExecutorService whereby priority of task can be submitted along with task"
tags:
  - priority executor
  - Java
date: 2016-10-08
image: /static/images/common-threads-reflections-614.jpg
---
![PriorityExecutorService]({{ image }})

After searching a lot on internet when I could not find any appropriate ExecutorService which would allow one to mention priority of the task at the time of submitting it to ExecutorService; that was the time when I decided to code one myself.

Now lets see what we need. We need a ExecutorService with following:

1. Ability to submit priority of task at the time of submitting the task. The priorities should be same as that of Thread i.e. between Thread.MIN_PRIORITY and Thread.MAX_PRIORITY.
1. The service should be able to prioritize the tasks as per task priorities mentioned at the time of submitting tasks
1. The service should not only be able to order tasks but also set priorities on worker threads so that at time of contention the OS thread scheduler knows which thread has a higher priority.
1. The service should provide methods to resolve starvation i.e. service should provide methods to know which are the first and last task in the service queue and an ability to change priorities and so tasks should move up/down as per changed priorities.

So lets call our ExecutorService as PriorityExecutorService and it should be something like this:

{% downloadsourcefilenote %}
<pre data-src="/static/java/PriorityExecutorService.java" data-download-link></pre>

Now we need a way to attach priority with each task. We know executors store tasks as FutureTask. So we will need to extend FutureTask to attach priority with each task. Hence we get a PriorityFutureTask.

{% downloadsourcefilenote %}
<pre data-src="/static/java/PriorityFutureTask.java" data-download-link></pre>

Now notice the run method. The worker thread priority is set to task priority before executing the task and set back to its original priority after task execution is complete.

Now we are ready for implementation of PriorityExecutorService. Our implementation should just extend ThreadPoolExecutor and should be able to order tasks as per submitted priorities. So it would be:

{% downloadsourcefilenote %}
<pre data-src="/static/java/PriorityThreadPoolExecutor.java" data-download-link></pre>

See that PriorityBlockingDeque is used for storing the PriorityFutureTask with a PriorityFutureTaskComparator that will allow the PriorityBlockingDeque to order PriorityFutureTask based on their priorities. Notice that PriorityBlockingDeque is not a standard Java API. Instead I coded it myself for resolving starvation problem in PriorityExecutorService. For a detailed discussion on PriorityBlockingDeque click here.
Next we just need a helper class, Executors, for quick and common initializations of PriorityExecutionService:

{% downloadsourcefilenote %}
<pre data-src="/static/java/Executors.java" data-download-link></pre>

One of simple examples for using this will be:

```java 
public class Main {
 
    public static void main(String[] args)
    {
        PriorityExecutorService s = Executors.newPriorityFixedThreadPool(2);
 
        for(int i=0;i<10;i++)
            s.submit(new TestThread(3), 3);
 
        for(int i=0;i<10;i++)
            s.submit(new TestThread(5), 5);
 
        for(int i=0;i<10;i++)
            s.submit(new TestThread(8), 8);
 
        s.changePriorities(5, 10);
    }
 
    private static class TestThread implements Runnable
    {
        int priority;
        TestThread(int priority)
        {
            this.priority = priority;
        }
        @Override
        public void run()
        {
            System.out.println("Thread Id: "+Thread.currentThread().getId()+"| Original Task Priority: "+priority+"| Current Task priority: "+Thread.currentThread().getPriority());
 
            try
            {
                Thread.sleep(2000);
            }
            catch (InterruptedException e)
            {
                e.printStackTrace();
            }
        }
    }
}
```

The output of above program would look like this:

```text
Thread Id: 8| Original Task Priority: 3| Current Task priority: 3
Thread Id: 9| Original Task Priority: 3| Current Task priority: 3
Thread Id: 8| Original Task Priority: 5| Current Task priority: 10
Thread Id: 9| Original Task Priority: 5| Current Task priority: 10
Thread Id: 8| Original Task Priority: 5| Current Task priority: 10
Thread Id: 9| Original Task Priority: 5| Current Task priority: 10
Thread Id: 8| Original Task Priority: 5| Current Task priority: 10
Thread Id: 9| Original Task Priority: 5| Current Task priority: 10
Thread Id: 8| Original Task Priority: 5| Current Task priority: 10
Thread Id: 9| Original Task Priority: 5| Current Task priority: 10
Thread Id: 8| Original Task Priority: 5| Current Task priority: 10
Thread Id: 9| Original Task Priority: 5| Current Task priority: 10
Thread Id: 8| Original Task Priority: 8| Current Task priority: 8
Thread Id: 9| Original Task Priority: 8| Current Task priority: 8
Thread Id: 8| Original Task Priority: 8| Current Task priority: 8
Thread Id: 9| Original Task Priority: 8| Current Task priority: 8
Thread Id: 8| Original Task Priority: 8| Current Task priority: 8
Thread Id: 9| Original Task Priority: 8| Current Task priority: 8
Thread Id: 8| Original Task Priority: 8| Current Task priority: 8
Thread Id: 9| Original Task Priority: 8| Current Task priority: 8
Thread Id: 8| Original Task Priority: 8| Current Task priority: 8
Thread Id: 9| Original Task Priority: 8| Current Task priority: 8
Thread Id: 8| Original Task Priority: 3| Current Task priority: 3
Thread Id: 9| Original Task Priority: 3| Current Task priority: 3
Thread Id: 8| Original Task Priority: 3| Current Task priority: 3
Thread Id: 9| Original Task Priority: 3| Current Task priority: 3
Thread Id: 8| Original Task Priority: 3| Current Task priority: 3
Thread Id: 9| Original Task Priority: 3| Current Task priority: 3
Thread Id: 8| Original Task Priority: 3| Current Task priority: 3
Thread Id: 9| Original Task Priority: 3| Current Task priority: 3
```

So we can see that our ExecutorService allowed users to submit priority along with task and tasks as ordered as per their priority and also allows us to change priorities thereby solving the starvation issue.