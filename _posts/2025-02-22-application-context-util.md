---
title: "Application Context"
excerpt_separator: "<!--more-->"
categories:
  - Blog
tags:
  - application-context-util
  - Kotlin
---
## Overview

Application context util is a simple kotlin based library that provides for setting up and using simple key/value context in our application.
Sure key/value pairs can be managed by a simple Map but then passing that map all around the code methods is very cumbersome.

What this library aims is to enable to create and access context anywhere in code statically without needing to pass around in methods meanwhile providing thread/coroutine safety as well.

Central interface of this library is **ApplicationContext**

This allows to store values against named Keys which also store value type information

## Usage

### Maven dependency

```xml
<dependency>
    <groupId>io.github.funofprograming</groupId>
    <artifactId>application-context-util</artifactId>
    <version>LATEST</version>
</dependency>
```

#### Versions
Check for latest versions here: [Releases](https://github.com/funofprograming/application-context-util/releases)

### Kotlin code usage

Globally available context in all threads/coroutine

```kotlin
import io.github.funofprograming.context.impl.*

val contextName: String = "TestGlobalApplicationContext"
val valueSetInThread1 = "Value T1"
val validKey: Key<String> = Key.of("ValidKey", String::class.java)

val def1 = launch {
    val globalContext = getGlobalContext(contextName)
    globalContext?.add(validKey, valueSetInThread1)
}

delay(1000)

val def2 = async {
    val globalContext = getGlobalContext(contextName)
    return@async globalContext?.fetch(validKey)
}


println(valueSetInThread1 == def2.await())
```

Above snippet prints:

```text
true
```

ThreadLocal available context in current thread/coroutine

```kotlin
import io.github.funofprograming.context.impl.*

val contextName: String = "TestThreadLocalApplicationContext"
val valueSetInThread1 = "Value T1"
val validKey: Key<String> = Key.of("ValidKey", String::class.java)

val cs1 = initCoroutineScopeForApplicationContext() //notice the initialization of coroutine scope in case we plan to use a thread local context inside a coroutine
val def1 = cs1.async {
    val localContext = getThreadLocalContext(contextName)
    localContext?.add(validKey, valueSetInThread1)
    return@async getThreadLocalContext(contextName)?.fetch(validKey)
}

delay(1000)
val cs2 = initCoroutineScopeForApplicationContext() //notice the initialization of coroutine scope in case we plan to use a thread local context inside a coroutine
val def2 = cs2.async {
    val localContext = getThreadLocalContext(contextName)
    return@async localContext?.fetch(invalidKey)
}

println(def2.await() == null)
println(valueSetInThread1 == def1.await())
```

Above snippet prints:

```text
true
true
```

Also, the context supports restricting keys of context to some predetermined set as follows:

```kotlin
import io.github.funofprograming.context.impl.*

val contextName: String = "TestApplicationContext"
val validKey: Key<String> = Key.of("ValidKey", String::class.java)
val invalidKey: Key<String> = Key.of("InvalidKey", String::class.java)
val permittedKeys: Set<Key<*>> = setOf(validKey)

val globalContext = getGlobalContext(contextName, permittedKeys)
globalContext?.add(validKey, valueSetInThread1)
globalContext?.fetch(invalidKey) //throws InvalidKeyException here since invalidKey is not part of permittedKeys

val localContext = getThreadLocalContext(contextName, permittedKeys)
localContext?.add(validKey, valueSetInThread1)
localContext?.fetch(invalidKey) //throws InvalidKeyException here since invalidKey is not part of permittedKeys
```

### Java code usage

Globally available context in all threads/coroutine

```java
import io.github.funofprograming.context.impl.*;
import java.util.concurrent.*;

public class TestGlobalApplicationContext{
    public static void main(String[] args) {
        String contextName = "TestGlobalApplicationContext";
        Key<String> validKey = Key.Companion.of("ValidKey", String.class);
        ThreadPoolExecutor executorService = new ThreadPoolExecutor(1, 1, 1L, TimeUnit.MILLISECONDS, new LinkedBlockingQueue<Runnable>());
        String valueSetInThread1 = "Value T1";

        CompletableFuture.runAsync(()->{
            ApplicationContext globalContext = ApplicationContextHoldersKt.getGlobalContext(contextName);
            globalContext.add(validKey, valueSetInThread1);
        });

        Thread.sleep(1000);

        CompletableFuture<String> future2 = CompletableFuture.supplyAsync(()->{
            ApplicationContext globalContext = ApplicationContextHoldersKt.getGlobalContext(contextName);
            return globalContext.fetch(validKey);
        });
        Thread.sleep(1000);
        
        System.out.println(valueSetInThread1.equals(future2.get()));
    }    
}
```

Above snippet prints:

```text
true
```

ThreadLocal available context in current thread/coroutine

```java
import io.github.funofprograming.context.impl.*;
import java.util.concurrent.*;

public class TestThreadLocalApplicationContext{
    public static void main(String[] args) {
        String contextName = "TestThreadLocalApplicationContext";
        Key<String> validKey = Key.Companion.of("ValidKey", String.class);
        ThreadPoolExecutor executorService = new ThreadPoolExecutor(1, 1, 1L, TimeUnit.MILLISECONDS, new LinkedBlockingQueue<Runnable>());
        String valueSetInThread1 = "Value T1";

        CompletableFuture<String> future1 = CompletableFuture.supplyAsync(()->{
            ApplicationContext localContext = ApplicationContextHoldersKt.getThreadLocalContext(contextName);
            localContext.add(validKey, valueSetInThread1);
            return ApplicationContextHoldersKt.getThreadLocalContext(contextName).fetch(validKey);
        }, executorService);

        Thread.sleep(1000);

        CompletableFuture<String> future2 = CompletableFuture.supplyAsync(()->{
            ApplicationContext localContext = ApplicationContextHoldersKt.getThreadLocalContext(contextName);
            return localContext.fetch(validKey);
        }, executorService);

        System.out.println(future2.get() == null);
        System.out.println(valueSetInThread1.equals(future1.get()));
    }
}
```

Above snippet prints:

```text
true
true
```

Also, the context supports restricting keys of context to some predetermined set as follows:

```java
import io.github.funofprograming.context.impl.*;
import java.util.concurrent.*;

public class TestApplicationContext{
    public static void main(String[] args) {
        String contextName = "TestApplicationContext";
        Key<String> validKey = Key.Companion.of("ValidKey", String.class);
        String valueSetInThread1 = "Value T1";
        Key<String> invalidKey = Key.Companion.of("InvalidKey", String.class);
        Set<Key<?>> permittedKeys = new HashSet<>(Arrays.asList(validKey));

        ApplicationContext globalContext = ApplicationContextHoldersKt.getGlobalContext(contextName, permittedKeys);
        globalContext.add(validKey, valueSetInThread1);
        globalContext.fetch(invalidKey); //throws InvalidKeyException here since invalidKey is not part of permittedKeys

        ApplicationContext localContext = ApplicationContextHoldersKt.getThreadLocalContext(contextName, permittedKeys);
        localContext.add(validKey, valueSetInThread1);
        localContext.fetch(invalidKey); //throws InvalidKeyException here since invalidKey is not part of permittedKeys
    }
}
```


## Compatibility matrix

| Application Context Util |  Java  | Kotlin-Std | Kotlin-Coroutines | 
|:------------------------:|:------:|:----------:|:-----------------:|
|          1.0.0           |   21   |  2.1.10    |     1.10.1        |

## License

Application context util is is released under version 2.0 of the [Apache License](https://www.apache.org/licenses/LICENSE-2.0).

## Github
[application-context-util](https://github.com/funofprograming/application-context-util)