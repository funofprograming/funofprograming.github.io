---
title: "PriorityDeque and PriorityBlockingDeque using Min-Max Heap in Java"
description: " "
tags:
  - priority deque
  - priority blocking deque
  - Java
date: 2016-10-08
---
![PriorityDeque](/static/images/queue.jpg)

I always wondered that if Java provides PriorityQueue then why not PriorityDeque. I mean how hard it is to implement a Deque based on a Min-Max Heap technique. A question that only Oracle can now answer.

So for the moment friends we shall have some fun in programing. 

PriorityDeque should be something like this:

{% downloadsourcefilenote %}
<pre data-src="/static/java/PriorityDeque.java" data-range="12,51" data-download-link></pre>


Which means it is a Deque because of which it is also Queue and so Collection as well. I created this deque using Min-Max heap algorithm which means it is not doing silly Collections.sort again and again on each insertion. All the insertion operations in this deque take O(log n) and all removal operations are constant time operations.

Now lets see how to use it. For simplicity we will store integers in our PriorityDeque. Check the following example:

```java
public static void main(String[] args) 
{ 
    PriorityDeque<Integer> q = new PriorityDeque<>();
 
    Random r = new Random();
 
    System.out.print("Input: ");
    for (int i = 0; i < 100; i++) 
    { 
        int x = r.nextInt(1000);
        System.out.print(x + " ");
        q.offer(x); 
    } 
 
    System.out.println(); 
    System.out.print("Output: "); 
 
    while (q.size() > 0)
        System.out.print(q.pollFirst() + " "); 
}
```

In this example we store integers in the deque and then start taking out from front of the deque. One of the output that I got was (Each time it is run the output will be different because of Random but order of elements in Output will always be same)

```text
Input: 602 368 334 696 239 539 722 343 918 313 100 217 988 380 476 724 643 613 110 237 725 17 512 705 663 304 244 760 88 190 549 427 292 883 815 614 497 693 176 313 909 909 140 584 786 215 866 523 552 306 849 216 413 872 37 779 67 392 468 767 790 87 80 191 592 357 945 62 531 611 176 412 315 818 218 137 869 998 679 92 176 658 814 541 119 670 191 817 767 955 260 595 387 398 949 871 474 731 271 786
Output: 17 37 62 67 80 87 88 92 100 110 119 137 140 176 176 176 190 191 191 215 216 217 218 237 239 244 260 271 292 304 306 313 313 315 334 343 357 368 380 387 392 398 412 413 427 468 474 476 497 512 523 531 539 541 549 552 584 592 595 602 611 613 614 643 658 663 670 679 693 696 705 722 724 725 731 760 767 767 779 786 786 790 814 815 817 818 849 866 869 871 872 883 909 909 918 945 949 955 988 998
```

Next we store integers again and this time we will take out from end of deque.

```java
public static void main(String[] args)
{
    PriorityDeque<Integer> q = new PriorityDeque<>();
 
    Random r = new Random();
 
    System.out.print("Input: ");
    for (int i = 0; i < 100; i++)
    {
        int x = r.nextInt(1000);
        System.out.print(x + " ");
        q.offer(x);
    }
 
    System.out.println();
    System.out.print("Output: ");
 
    while (q.size() > 0)
        System.out.print(q.pollLast() + " ");
}
```

Output that I got this time was (Each time it is run the output will be different because of Random but order of elements in Output will always be same)

```text
Input: 248 498 757 841 808 971 502 95 512 460 76 778 931 696 354 472 415 689 951 556 959 813 542 455 238 12 66 74 218 972 831 650 928 984 379 248 46 843 172 380 811 237 499 325 651 249 390 792 599 555 691 555 209 288 143 301 813 827 391 148 986 105 782 506 656 243 862 836 996 622 410 816 127 424 335 883 13 944 354 709 440 842 44 178 381 639 35 597 54 53 10 875 71 168 129 993 676 620 687 530
Output: 996 993 986 984 972 971 959 951 944 931 928 883 875 862 843 842 841 836 831 827 816 813 813 811 808 792 782 778 757 709 696 691 689 687 676 656 651 650 639 622 620 599 597 556 555 555 542 530 512 506 502 499 498 472 460 455 440 424 415 410 391 390 381 380 379 354 354 335 325 301 288 249 248 248 243 238 237 218 209 178 172 168 148 143 129 127 105 95 76 74 71 66 54 53 46 44 35 13 12 10
```

So we see that if we take out elements from front of PriorityDeque then we get elements in ascending order and if we pull out from end of PriorityDeque then we get elements in descending order.

Voila! We have a Deque that can retrieve elements in ascending and descending order both at same time. FUN!

Note: PriorityDeque is not thread safe. For concurrent version use PriorityBlockingDeque which extends BlockingDeque. PriorityBlockingDeque algorithm is exactly same as PriorityDeque with additional concurrency features. 

This is how PriorityBlockingDeque looks like:

{% downloadsourcefilenote %}
<pre data-src="/static/java/PriorityBlockingDeque.java" data-range="12,59" data-download-link></pre>