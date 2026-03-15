---
title: "Timeseries"
description: "Data structure to manage timeseries data"
excerpt_separator: "<!--more-->"
ghrepo: "https://github.com/funofprograming/timeseries"
tags:
  - timeseries
  - Kotlin
  - Java
image: /static/images/timeseries.png
---

![Timeseries]({{ image }})

## Overview

Timeseries is a simple kotlin based library that provides a data structure to manage timeseries data.


This library aims to provide a simple but efficient in-memory data structure for handling and manipulating timeseries data. Sure same can be achieved by using a simple NavigableMap but then one will have to code a lot of methods for timeseries handling. This library does that by providing implementations that use NavigableMap internally.

Central interface of this library is **Timeseries**

## Usage

### Maven dependency

```xml
<dependency>
    <groupId>io.github.funofprograming</groupId>
    <artifactId>timeseries</artifactId>
    <version>LATEST</version>
</dependency>
```

#### Versions
Check for latest versions here: [Releases](https://github.com/funofprograming/timeseries/releases)

### Code


This library provides 2 interfaces namely [Timeseries](https://github.com/funofprograming/timeseries/blob/master/src/main/kotlin/io/github/funofprograming/timeseries/Timeseries.kt) which is immutable. And then a mutable version as [MutableTimeseries](https://github.com/funofprograming/timeseries/blob/master/src/main/kotlin/io/github/funofprograming/timeseries/MutableTimeseries.kt). 

All entries in and out of these interfaces are done via [TimeseriesEntry](https://github.com/funofprograming/timeseries/blob/master/src/main/kotlin/io/github/funofprograming/timeseries/TimeseriesEntry.kt) class.

Following Junit classes show how to use these 3 interfaces.

TimeseriesEntry
{% tabber "tsTabs1", {"ts-kotlin1":"Kotlin", "ts-java1":"Java"} %}
{% tab "ts-kotlin1" %}
```kotlin
package io.github.funofprograming.timeseries

import io.github.funofprograming.timeseries.impl.TimeseriesImpl
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Assertions.*
import java.time.Instant
import java.util.UUID

class TestTimeseriesEntry {

    @Test
    fun testInitializeTimeseriesEntry_nullEventId() {
        val instant = Instant.now()
        val event = 1
        val timeseriesEntry: TimeseriesEntry<Int> = timeseriesEntryOf<Int>(instant, event)
        assertNotNull(timeseriesEntry)
        assertEquals(instant, timeseriesEntry.eventInstant)
        assertEquals(event, timeseriesEntry.event)
        assertNull(timeseriesEntry.eventId)
    }

    @Test
    fun testInitializeTimeseriesEntry_nonNullEventId() {
        val instant = Instant.now()
        val event = 1
        val eventId = UUID.randomUUID()
        val timeseriesEntry: TimeseriesEntry<Int> = timeseriesEntryOf<Int>(instant, event, eventId)
        assertNotNull(timeseriesEntry)
        assertEquals(instant, timeseriesEntry.eventInstant)
        assertEquals(event, timeseriesEntry.event)
        assertEquals(eventId, timeseriesEntry.eventId)
    }
}
```
{% endtab %} 

{% tab "ts-java1" %}
```java
package io.github.funofprograming.timeseries;

import org.junit.jupiter.api.Test;
import java.time.Instant;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static io.github.funofprograming.timeseries.TimeseriesBuildersKt.*;

class TestJavaTimeseriesEntry {

    @Test
    void testInitializeTimeseriesEntry_nullEventId() {
        Instant instant = Instant.now();
        Integer event = 1;
        TimeseriesEntry<Integer> timeseriesEntry = timeseriesEntryOf(instant, event, null);
        assertNotNull(timeseriesEntry);
        assertEquals(instant, timeseriesEntry.getEventInstant());
        assertEquals(event, timeseriesEntry.getEvent());
        assertNull(timeseriesEntry.getEventId());
    }

    @Test
    void testInitializeTimeseriesEntry_nonNullEventId() {
        Instant instant = Instant.now();
        Integer event = 1;
        UUID eventId = UUID.randomUUID();
        TimeseriesEntry<Integer> timeseriesEntry = timeseriesEntryOf(instant, event, eventId);
        assertNotNull(timeseriesEntry);
        assertEquals(instant, timeseriesEntry.getEventInstant());
        assertEquals(event, timeseriesEntry.getEvent());
        assertEquals(eventId, timeseriesEntry.getEventId());
    }
}
```
{% endtab %} 

Timeseries
{% tabber "tsTabs2", {"ts-kotlin2":"Kotlin", "ts-java2":"Java"} %}
{% tab "ts-kotlin2" %}
```kotlin
package io.github.funofprograming.timeseries

import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Assertions.*
import java.time.Instant
import java.util.NavigableMap
import java.util.TreeMap
import kotlin.collections.containsKey

class TestTimeseries {

    @Test
    fun testInitializeTimeseries_empty() {
        val timeseries = timeseriesOf<Int>()
        assertNotNull(timeseries)
    }

    @Test
    fun testInitializeTimeseries_oneEntry() {
        val timeseries = timeseriesOf<Int>(timeseriesEntryOf(Instant.now(), 1))
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(1, timeseries.countEvents())
    }

    @Test
    fun testInitializeTimeseries_entryCollection_differentTime() {
        val timeseries = timeseriesOf<Int>(
            setOf(
                timeseriesEntryOf(Instant.now(), 1)
                , timeseriesEntryOf(Instant.now(), 2)
                , timeseriesEntryOf(Instant.now(), 3)
        ))
        assertNotNull(timeseries)
        assertEquals(3, timeseries.countInstants())
        assertEquals(3, timeseries.countEvents())
    }

    @Test
    fun testInitializeTimeseries_entryCollection_sameTime() {
        val instant = Instant.now()
        val timeseries = timeseriesOf<Int>(
            setOf(
                timeseriesEntryOf(instant, 1)
                , timeseriesEntryOf(instant, 2)
                , timeseriesEntryOf(instant, 3)
            ))
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(3, timeseries.countEvents())
    }

    @Test
    fun testInitializeTimeseries_entryMap() {
        val instant = Instant.now()
        val timeseriesEntrySet = setOf(
            timeseriesEntryOf(instant, 1)
            , timeseriesEntryOf(instant, 2)
            , timeseriesEntryOf(instant, 3)
        )
        val timeseriesEntryMap = TreeMap<Instant, Collection<TimeseriesEntry<Int>>>()
        timeseriesEntryMap[instant] = timeseriesEntrySet
        val timeseries = timeseriesOf<Int>(timeseriesEntryMap)

        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(3, timeseries.countEvents())
    }

    @Test
    fun testInitializeTimeseries_copy() {
        val instant = Instant.now()
        val timeseries = timeseriesOf<Int>(
            setOf(
                timeseriesEntryOf(instant, 1)
                , timeseriesEntryOf(instant, 2)
                , timeseriesEntryOf(instant, 3)
            ))
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(3, timeseries.countEvents())

        val timeseriesCopy = timeseriesOf(timeseries)
        assertNotNull(timeseriesCopy)
        assertFalse { timeseriesCopy === timeseries } //different objects
        assertTrue { timeseriesCopy == timeseries } //same entries
        assertEquals(1, timeseriesCopy.countInstants())
        assertEquals(3, timeseriesCopy.countEvents())
    }

    @Test
    fun testPlus_singleEntry_overwriteFalse() {
        val timeseries = timeseriesOf<Int>(timeseriesEntryOf(Instant.now(), 1))
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(1, timeseries.countEvents())
        val timeseries2 = timeseries.plus((timeseriesEntryOf(Instant.now(), 2)), false)
        assertNotNull(timeseries2)
        assertFalse { timeseries2 === timeseries } //different objects
        assertFalse { timeseries2 == timeseries } //different objects
        assertEquals(2, timeseries2.countInstants())
        assertEquals(2, timeseries2.countEvents())
    }

    @Test
    fun testPlus_singleEntry_overwriteTrue() {
        val instant = Instant.now()
        val timeseries = timeseriesOf<Int>(timeseriesEntryOf(instant, 1))
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(1, timeseries.countEvents())
        val timeseries2 = timeseries.plus((timeseriesEntryOf(instant, 1)))
        assertNotNull(timeseries2)
        assertFalse { timeseries2 === timeseries } //different objects
        assertTrue { timeseries2 == timeseries } //same entries because overwrite=true
        assertEquals(1, timeseries2.countInstants())
        assertEquals(1, timeseries2.countEvents())
    }

    @Test
    fun testPlus_collectionEntry_overwriteFalse() {
        val timeseries = timeseriesOf<Int>(timeseriesEntryOf(Instant.now(), 1))
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(1, timeseries.countEvents())
        val timeseries2 = timeseries.plus(setOf(
                                                            timeseriesEntryOf(Instant.now(), 2)
                                                            , timeseriesEntryOf(Instant.now(), 3)
                                                            , timeseriesEntryOf(Instant.now(), 4))
                                , false)
        assertNotNull(timeseries2)
        assertFalse { timeseries2 === timeseries } //different objects
        assertFalse { timeseries2 == timeseries } //different objects
        assertEquals(4, timeseries2.countInstants())
        assertEquals(4, timeseries2.countEvents())
    }

    @Test
    fun testPlus_collectionEntry_overwriteTrue() {
        val instant = Instant.now()
        val timeseries = timeseriesOf<Int>(setOf(
                                                            timeseriesEntryOf(instant, 2)
                                                            , timeseriesEntryOf(instant, 3)
                                                            , timeseriesEntryOf(instant, 4)))
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(3, timeseries.countEvents())
        val timeseries2 = timeseries.plus(setOf(
                                                            timeseriesEntryOf(instant, 2)
                                                            , timeseriesEntryOf(instant, 5)
                                                            , timeseriesEntryOf(instant, 6)))
        assertNotNull(timeseries2)
        assertFalse { timeseries2 === timeseries } //different objects
        assertFalse { timeseries2 == timeseries } //different objects
        assertEquals(1, timeseries2.countInstants())
        assertEquals(5, timeseries2.countEvents()) //one entry is overwritten so total 5 events instead of 6
    }

    @Test
    fun testGet() {
        val instant = Instant.now()
        val timeseries = timeseriesOf<Int>(setOf(
            timeseriesEntryOf(instant, 2)
            , timeseriesEntryOf(instant, 3)
            , timeseriesEntryOf(instant, 4)))
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(3, timeseries.countEvents())
        val instantEvents = timeseries.get(instant)
        assertNotNull(instantEvents)
        assertTrue { instantEvents.isNotEmpty() }
        assertTrue { instantEvents.size == 3 }
        assertTrue { instantEvents.contains(timeseriesEntryOf(instant, 2)) }
        assertTrue { instantEvents.contains(timeseriesEntryOf(instant, 3)) }
        assertTrue { instantEvents.contains(timeseriesEntryOf(instant, 4)) }
        assertFalse { instantEvents.contains(timeseriesEntryOf(instant, 5)) }

        val instantEvents2 = timeseries.get(Instant.now())
        assertNotNull(instantEvents2)
        assertTrue { instantEvents2.isEmpty() }
    }

    @Test
    fun testGetAll() {
        val instant = Instant.now()
        val timeseries = timeseriesOf<Int>(setOf(
            timeseriesEntryOf(instant, 2)
            , timeseriesEntryOf(instant, 3)
            , timeseriesEntryOf(instant, 4)))
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(3, timeseries.countEvents())
        val instantEvents = timeseries.getAll()
        assertNotNull(instantEvents)
        assertTrue { instantEvents.isNotEmpty() }
        assertTrue { instantEvents.size == 1 }
        assertTrue { instantEvents.keys.contains(instant) }
        assertTrue { instantEvents[instant]?.contains(timeseriesEntryOf(instant, 2)) ?: false }
        assertTrue { instantEvents[instant]?.contains(timeseriesEntryOf(instant, 3)) ?: false }
        assertTrue { instantEvents[instant]?.contains(timeseriesEntryOf(instant, 4)) ?: false }
    }

    @Test
    fun getAllInstants() {
        val instant = Instant.now()
        val timeseries = timeseriesOf<Int>(setOf(
            timeseriesEntryOf(instant, 2)
            , timeseriesEntryOf(instant, 3)
            , timeseriesEntryOf(instant, 4)))
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(3, timeseries.countEvents())
        val instants = timeseries.getAllInstants()
        assertNotNull(instants)
        assertTrue { instants.isNotEmpty() }
        assertTrue { instants.size == 1 }
        assertTrue { instants.contains(instant) }
    }

    @Test
    fun testMinus_singleEntry() {
        val instant = Instant.now()
        val timeseries = timeseriesOf<Int>(setOf(
            timeseriesEntryOf(instant, 2)
            , timeseriesEntryOf(instant, 3)
            , timeseriesEntryOf(instant, 4)))
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(3, timeseries.countEvents())
        val timeseries2 = timeseries.minus((timeseriesEntryOf(instant, 1)))
        assertNotNull(timeseries2)
        assertFalse { timeseries2 === timeseries } //different objects
        assertTrue { timeseries2 == timeseries } //same entries because minus entry does not exist
        assertEquals(1, timeseries2.countInstants())
        assertEquals(3, timeseries2.countEvents())
        val timeseries3 = timeseries.minus((timeseriesEntryOf(instant, 2)))
        assertFalse { timeseries3 === timeseries } //different objects
        assertFalse { timeseries3 == timeseries } //different objects
        assertEquals(1, timeseries3.countInstants())
        assertEquals(2, timeseries3.countEvents())
    }

    @Test
    fun testMinus_collectionEntry() {
        val instant = Instant.now()
        val timeseries = timeseriesOf<Int>(setOf(
            timeseriesEntryOf(instant, 2)
            , timeseriesEntryOf(instant, 3)
            , timeseriesEntryOf(instant, 4)))
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(3, timeseries.countEvents())
        val timeseries2 = timeseries.minus(setOf(
            timeseriesEntryOf(instant, 1)
            , timeseriesEntryOf(instant, 7)))
        assertNotNull(timeseries2)
        assertFalse { timeseries2 === timeseries } //different objects
        assertTrue { timeseries2 == timeseries } //same entries because minus entry does not exist
        assertEquals(1, timeseries2.countInstants())
        assertEquals(3, timeseries2.countEvents())
        val timeseries3 = timeseries.minus(setOf(timeseriesEntryOf(instant, 2)
                                                            , timeseriesEntryOf(instant, 3)))
        assertFalse { timeseries3 === timeseries } //different objects
        assertFalse { timeseries3 == timeseries } //different objects
        assertEquals(1, timeseries3.countInstants())
        assertEquals(1, timeseries3.countEvents())
    }

    @Test
    fun testMinus_instant() {
        val instant = Instant.now()
        val timeseries = timeseriesOf<Int>(setOf(
            timeseriesEntryOf(instant, 2)
            , timeseriesEntryOf(instant, 3)
            , timeseriesEntryOf(instant, 4)))
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(3, timeseries.countEvents())
        val timeseries2 = timeseries.minus(Instant.EPOCH)
        assertNotNull(timeseries2)
        assertFalse { timeseries2 === timeseries } //different objects
        assertTrue { timeseries2 == timeseries } //same entries because minus entry does not exist
        assertEquals(1, timeseries2.countInstants())
        assertEquals(3, timeseries2.countEvents())
        val timeseries3 = timeseries.minus(instant)
        assertFalse { timeseries3 === timeseries } //different objects
        assertFalse { timeseries3 == timeseries } //different objects
        assertEquals(0, timeseries3.countInstants())
        assertEquals(0, timeseries3.countEvents())
    }

    @Test
    fun testContains_instant() {
        val instant = Instant.now()
        val timeseries = timeseriesOf<Int>(
            setOf(
                timeseriesEntryOf(instant, 2)
                , timeseriesEntryOf(instant, 3)
                , timeseriesEntryOf(instant, 4)
            )
        )
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(3, timeseries.countEvents())
        assertTrue { timeseries.contains(instant) }
        assertFalse { timeseries.contains(Instant.EPOCH) }
    }

    @Test
    fun testContains_event() {
        val instant = Instant.now()
        val timeseries = timeseriesOf<Int>(
            setOf(
                timeseriesEntryOf(instant, 2)
                , timeseriesEntryOf(instant, 3)
                , timeseriesEntryOf(instant, 4)
            )
        )
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(3, timeseries.countEvents())
        assertTrue { timeseries.contains(2) }
        assertFalse { timeseries.contains(5) }
    }

    @Test
    fun testCountInstants() {
        val instant = Instant.now()
        val timeseries = timeseriesOf<Int>(
            setOf(
                timeseriesEntryOf(instant, 2)
                , timeseriesEntryOf(instant, 3)
                , timeseriesEntryOf(instant, 4)
            )
        )
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(3, timeseries.countEvents())
    }

    @Test
    fun testCountEvents() {
        val instant = Instant.now()
        val timeseries = timeseriesOf<Int>(
            setOf(
                timeseriesEntryOf(instant, 2)
                , timeseriesEntryOf(instant, 3)
                , timeseriesEntryOf(instant, 4)
            )
        )
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(3, timeseries.countEvents())
    }

    @Test
    fun testIsEmpty() {
        val instant = Instant.now()
        val timeseries = timeseriesOf<Int>(
            setOf(
                timeseriesEntryOf(instant, 2)
                , timeseriesEntryOf(instant, 3)
                , timeseriesEntryOf(instant, 4)
            )
        )
        assertNotNull(timeseries)
        assertFalse { timeseries.isEmpty() }
        val timeseries2 = timeseriesOf<Int>()
        assertNotNull(timeseries2)
        assertTrue { timeseries2.isEmpty() }
    }

    @Test
    fun testIsNotEmpty() {
        val instant = Instant.now()
        val timeseries = timeseriesOf<Int>(
            setOf(
                timeseriesEntryOf(instant, 2)
                , timeseriesEntryOf(instant, 3)
                , timeseriesEntryOf(instant, 4)
            )
        )
        assertNotNull(timeseries)
        assertTrue { timeseries.isNotEmpty() }
        val timeseries2 = timeseriesOf<Int>()
        assertNotNull(timeseries2)
        assertFalse { timeseries2.isNotEmpty() }
    }

    @Test
    fun testGetEntriesSubMap_exclusive() {
        val instant1 = Instant.parse("2024-01-01T00:00:00Z")
        val instant2 = Instant.parse("2024-01-02T00:00:00Z")
        val instant3 = Instant.parse("2024-01-03T00:00:00Z")
        val timeseries = timeseriesOf<Int>(setOf(
            timeseriesEntryOf(instant1, 1),
            timeseriesEntryOf(instant2, 2),
            timeseriesEntryOf(instant3, 3)
        ))

        val subMap = timeseries.getEntriesSubMap(instant1, instant3)
        assertNotNull(subMap)
        assertEquals(1, subMap.size)
        assertTrue { subMap.containsKey(instant2) }
        assertFalse { subMap.containsKey(instant1) }
        assertFalse { subMap.containsKey(instant3) }
    }

    @Test
    fun testGetEntriesSubMap_inclusive() {
        val instant1 = Instant.parse("2024-01-01T00:00:00Z")
        val instant2 = Instant.parse("2024-01-02T00:00:00Z")
        val instant3 = Instant.parse("2024-01-03T00:00:00Z")
        val timeseries = timeseriesOf<Int>(setOf(
            timeseriesEntryOf(instant1, 1),
            timeseriesEntryOf(instant2, 2),
            timeseriesEntryOf(instant3, 3)
        ))

        val subMap = timeseries.getEntriesSubMap(instant1, true, instant3, true)
        assertNotNull(subMap)
        assertEquals(3, subMap.size)
        assertTrue { subMap.containsKey(instant1) }
        assertTrue { subMap.containsKey(instant2) }
        assertTrue { subMap.containsKey(instant3) }
    }

    @Test
    fun testGetEntriesHeadMap_exclusive() {
        val instant1 = Instant.parse("2024-01-01T00:00:00Z")
        val instant2 = Instant.parse("2024-01-02T00:00:00Z")
        val instant3 = Instant.parse("2024-01-03T00:00:00Z")
        val timeseries = timeseriesOf<Int>(setOf(
            timeseriesEntryOf(instant1, 1),
            timeseriesEntryOf(instant2, 2),
            timeseriesEntryOf(instant3, 3)
        ))

        val headMap = timeseries.getEntriesHeadMap(instant3)
        assertNotNull(headMap)
        assertEquals(2, headMap.size)
        assertTrue { headMap.containsKey(instant1) }
        assertTrue { headMap.containsKey(instant2) }
        assertFalse { headMap.containsKey(instant3) }
    }

    @Test
    fun testGetEntriesHeadMap_inclusive() {
        val instant1 = Instant.parse("2024-01-01T00:00:00Z")
        val instant2 = Instant.parse("2024-01-02T00:00:00Z")
        val instant3 = Instant.parse("2024-01-03T00:00:00Z")
        val timeseries = timeseriesOf<Int>(setOf(
            timeseriesEntryOf(instant1, 1),
            timeseriesEntryOf(instant2, 2),
            timeseriesEntryOf(instant3, 3)
        ))

        val headMap = timeseries.getEntriesHeadMap(instant3, true)
        assertNotNull(headMap)
        assertEquals(3, headMap.size)
        assertTrue { headMap.containsKey(instant1) }
        assertTrue { headMap.containsKey(instant2) }
        assertTrue { headMap.containsKey(instant3) }
    }

    @Test
    fun testGetEntriesTailMap_exclusive() {
        val instant1 = Instant.parse("2024-01-01T00:00:00Z")
        val instant2 = Instant.parse("2024-01-02T00:00:00Z")
        val instant3 = Instant.parse("2024-01-03T00:00:00Z")
        val timeseries = timeseriesOf<Int>(setOf(
            timeseriesEntryOf(instant1, 1),
            timeseriesEntryOf(instant2, 2),
            timeseriesEntryOf(instant3, 3)
        ))

        val tailMap = timeseries.getEntriesTailMap(instant1)
        assertNotNull(tailMap)
        assertEquals(2, tailMap.size)
        assertFalse { tailMap.containsKey(instant1) }
        assertTrue { tailMap.containsKey(instant2) }
        assertTrue { tailMap.containsKey(instant3) }
    }

    @Test
    fun testGetEntriesTailMap_inclusive() {
        val instant1 = Instant.parse("2024-01-01T00:00:00Z")
        val instant2 = Instant.parse("2024-01-02T00:00:00Z")
        val instant3 = Instant.parse("2024-01-03T00:00:00Z")
        val timeseries = timeseriesOf<Int>(setOf(
            timeseriesEntryOf(instant1, 1),
            timeseriesEntryOf(instant2, 2),
            timeseriesEntryOf(instant3, 3)
        ))

        val tailMap = timeseries.getEntriesTailMap(instant1, true)
        assertNotNull(tailMap)
        assertEquals(3, tailMap.size)
        assertTrue { tailMap.containsKey(instant1) }
        assertTrue { tailMap.containsKey(instant2) }
        assertTrue { tailMap.containsKey(instant3) }
    }

    @Test
    fun testStart() {
        val instant1 = Instant.parse("2024-01-01T00:00:00Z")
        val instant2 = Instant.parse("2024-01-02T00:00:00Z")
        val instant3 = Instant.parse("2024-01-03T00:00:00Z")
        val timeseries = timeseriesOf<Int>(setOf(
            timeseriesEntryOf(instant3, 3),
            timeseriesEntryOf(instant1, 1),
            timeseriesEntryOf(instant2, 2)
        ))

        val startEntries = timeseries.start()
        assertNotNull(startEntries)
        assertTrue { startEntries?.isNotEmpty() ?: false }
        assertTrue { startEntries?.contains(timeseriesEntryOf(instant1, 1)) ?: false }
    }

    @Test
    fun testStart_empty() {
        val timeseries = timeseriesOf<Int>()
        val startEntries = timeseries.start()
        assertNull(startEntries)
    }

    @Test
    fun testEnd() {
        val instant1 = Instant.parse("2024-01-01T00:00:00Z")
        val instant2 = Instant.parse("2024-01-02T00:00:00Z")
        val instant3 = Instant.parse("2024-01-03T00:00:00Z")
        val timeseries = timeseriesOf<Int>(setOf(
            timeseriesEntryOf(instant1, 1),
            timeseriesEntryOf(instant3, 3),
            timeseriesEntryOf(instant2, 2)
        ))

        val endEntries = timeseries.end()
        assertNotNull(endEntries)
        assertTrue { endEntries?.isNotEmpty() ?: false }
        assertTrue { endEntries?.contains(timeseriesEntryOf(instant3, 3)) ?: false }
    }

    @Test
    fun testEnd_empty() {
        val timeseries = timeseriesOf<Int>()
        val endEntries = timeseries.end()
        assertNull(endEntries)
    }

    @Test
    fun testIterator_ascending() {
        val instant1 = Instant.parse("2024-01-01T00:00:00Z")
        val instant2 = Instant.parse("2024-01-02T00:00:00Z")
        val instant3 = Instant.parse("2024-01-03T00:00:00Z")
        val timeseries = timeseriesOf<Int>(setOf(
            timeseriesEntryOf(instant3, 3),
            timeseriesEntryOf(instant1, 1),
            timeseriesEntryOf(instant2, 2)
        ))

        val iterator = timeseries.iterator()
        assertNotNull(iterator)
        assertTrue { iterator.hasNext() }

        val first = iterator.next()
        assertTrue { first.contains(timeseriesEntryOf(instant1, 1)) }

        val second = iterator.next()
        assertTrue { second.contains(timeseriesEntryOf(instant2, 2)) }

        val third = iterator.next()
        assertTrue { third.contains(timeseriesEntryOf(instant3, 3)) }

        assertFalse { iterator.hasNext() }
    }

    @Test
    fun testDescendingIterator() {
        val instant1 = Instant.parse("2024-01-01T00:00:00Z")
        val instant2 = Instant.parse("2024-01-02T00:00:00Z")
        val instant3 = Instant.parse("2024-01-03T00:00:00Z")
        val timeseries = timeseriesOf<Int>(
            setOf(
                timeseriesEntryOf(instant1, 1),
                timeseriesEntryOf(instant3, 3),
                timeseriesEntryOf(instant2, 2)
            )
        )

        val iterator = timeseries.descendingIterator()
        assertNotNull(iterator)
        assertTrue { iterator.hasNext() }

        val first = iterator.next()
        assertTrue { first.contains(timeseriesEntryOf(instant3, 3)) }

        val second = iterator.next()
        assertTrue { second.contains(timeseriesEntryOf(instant2, 2)) }

        val third = iterator.next()
        assertTrue { third.contains(timeseriesEntryOf(instant1, 1)) }

        assertFalse { iterator.hasNext() }
    }
}
```
{% endtab %} 

{% tab "ts-java2" %}
```java
package io.github.funofprograming.timeseries;

import org.junit.jupiter.api.Test;
import java.time.Instant;
import java.util.*;

import static org.junit.jupiter.api.Assertions.*;
import static io.github.funofprograming.timeseries.TimeseriesBuildersKt.*;

class TestJavaTimeseries {

    @Test
    void testInitializeTimeseries_empty() {
        Timeseries<Integer> timeseries = timeseriesOf();
        assertNotNull(timeseries);
    }

    @Test
    void testInitializeTimeseries_oneEntry() {
        Timeseries<Integer> timeseries = timeseriesOf(
                timeseriesEntryOf(Instant.now(), 1, null)
        );
        assertNotNull(timeseries);
        assertEquals(1, timeseries.countInstants());
        assertEquals(1, timeseries.countEvents());
    }

    @Test
    void testInitializeTimeseries_entryCollection_differentTime() {
        Timeseries<Integer> timeseries = timeseriesOf(
                Set.of(
                        timeseriesEntryOf(Instant.now(), 1, null),
                        timeseriesEntryOf(Instant.now().plusSeconds(1), 2, null),
                        timeseriesEntryOf(Instant.now().plusSeconds(2), 3, null)
                )
        );
        assertNotNull(timeseries);
        assertEquals(3, timeseries.countInstants());
        assertEquals(3, timeseries.countEvents());
    }

    @Test
    void testInitializeTimeseries_entryCollection_sameTime() {
        Instant instant = Instant.now();
        Timeseries<Integer> timeseries = timeseriesOf(
                Set.of(
                        timeseriesEntryOf(instant, 1, null),
                        timeseriesEntryOf(instant, 2, null),
                        timeseriesEntryOf(instant, 3, null)
                )
        );
        assertNotNull(timeseries);
        assertEquals(1, timeseries.countInstants());
        assertEquals(3, timeseries.countEvents());
    }

    @Test
    void testInitializeTimeseries_entryMap() {
        Instant instant = Instant.now();
        Collection<TimeseriesEntry<Integer>> timeseriesEntrySet = Set.of(
                timeseriesEntryOf(instant, 1, null),
                timeseriesEntryOf(instant, 2, null),
                timeseriesEntryOf(instant, 3, null)
        );

        NavigableMap<Instant, Collection<TimeseriesEntry<Integer>>> timeseriesEntryMap = new TreeMap<>();
        timeseriesEntryMap.put(instant, timeseriesEntrySet);

        Timeseries<Integer> timeseries = timeseriesOf(timeseriesEntryMap);

        assertNotNull(timeseries);
        assertEquals(1, timeseries.countInstants());
        assertEquals(3, timeseries.countEvents());
    }

    @Test
    void testInitializeTimeseries_copy() {
        Instant instant = Instant.now();
        Timeseries<Integer> timeseries = timeseriesOf(
                Set.of(
                        timeseriesEntryOf(instant, 1, null),
                        timeseriesEntryOf(instant, 2, null),
                        timeseriesEntryOf(instant, 3, null)
                )
        );

        Timeseries<Integer> timeseriesCopy = timeseriesOf(timeseries);
        assertNotNull(timeseriesCopy);
        assertNotSame(timeseries, timeseriesCopy); // different objects
        assertEquals(timeseries, timeseriesCopy);  // same entries
        assertEquals(1, timeseriesCopy.countInstants());
        assertEquals(3, timeseriesCopy.countEvents());
    }

    @Test
    void testPlus_singleEntry_overwriteFalse() {
        Timeseries<Integer> timeseries = timeseriesOf(timeseriesEntryOf(Instant.now(), 1, null));

        Timeseries<Integer> timeseries2 = timeseries.plus(timeseriesEntryOf(Instant.now(), 2, null), false);

        assertNotNull(timeseries2);
        assertNotSame(timeseries, timeseries2);
        assertNotEquals(timeseries, timeseries2);
        assertEquals(2, timeseries2.countInstants());
        assertEquals(2, timeseries2.countEvents());
    }

    @Test
    void testPlus_singleEntry_overwriteTrue() {
        Instant instant = Instant.now();
        Timeseries<Integer> timeseries = timeseriesOf(timeseriesEntryOf(instant, 1, null));

        Timeseries<Integer> timeseries2 = timeseries.plus(timeseriesEntryOf(instant, 1, null), true);

        assertNotNull(timeseries2);
        assertNotSame(timeseries, timeseries2);
        assertEquals(timeseries, timeseries2); // same entries because overwrite=true
        assertEquals(1, timeseries2.countInstants());
        assertEquals(1, timeseries2.countEvents());
    }

    @Test
    void testPlus_collectionEntry_overwriteFalse() {
        Timeseries<Integer> timeseries = timeseriesOf(timeseriesEntryOf(Instant.now(), 1, null));

        Timeseries<Integer> timeseries2 = timeseries.plus(Set.of(
                timeseriesEntryOf(Instant.now(), 2, null),
                timeseriesEntryOf(Instant.now(), 3, null),
                timeseriesEntryOf(Instant.now(), 4, null)
        ), false);

        assertNotNull(timeseries2);
        assertEquals(4, timeseries2.countInstants());
        assertEquals(4, timeseries2.countEvents());
    }

    @Test
    void testPlus_collectionEntry_overwriteTrue() {
        Instant instant = Instant.now();
        Timeseries<Integer> timeseries = timeseriesOf(Set.of(
                timeseriesEntryOf(instant, 2, null),
                timeseriesEntryOf(instant, 3, null),
                timeseriesEntryOf(instant, 4, null)
        ));

        Timeseries<Integer> timeseries2 = timeseries.plus(Set.of(
                timeseriesEntryOf(instant, 2, null),
                timeseriesEntryOf(instant, 5, null),
                timeseriesEntryOf(instant, 6, null)
        ), true);

        assertNotNull(timeseries2);
        assertEquals(1, timeseries2.countInstants());
        assertEquals(5, timeseries2.countEvents()); // one entry is overwritten, total 5
    }

    @Test
    void testGet() {
        Instant instant = Instant.now();
        Timeseries<Integer> timeseries = timeseriesOf(Set.of(
                timeseriesEntryOf(instant, 2, null),
                timeseriesEntryOf(instant, 3, null),
                timeseriesEntryOf(instant, 4, null)
        ));

        Collection<TimeseriesEntry<Integer>> instantEvents = timeseries.get(instant);
        assertNotNull(instantEvents);
        assertFalse(instantEvents.isEmpty());
        assertEquals(3, instantEvents.size());
        assertTrue(instantEvents.contains(timeseriesEntryOf(instant, 2, null)));
        assertFalse(instantEvents.contains(timeseriesEntryOf(instant, 5, null)));

        Collection<TimeseriesEntry<Integer>> instantEvents2 = timeseries.get(Instant.now());
        assertTrue(instantEvents2.isEmpty());
    }

    @Test
    void testGetAll() {
        Instant instant = Instant.now();
        Timeseries<Integer> timeseries = timeseriesOf(Set.of(
                timeseriesEntryOf(instant, 2, null),
                timeseriesEntryOf(instant, 3, null)
        ));

        Map<Instant, Collection<TimeseriesEntry<Integer>>> allEvents = timeseries.getAll();
        assertEquals(1, allEvents.size());
        assertTrue(allEvents.containsKey(instant));
    }

    @Test
    void testMinus_singleEntry() {
        Instant instant = Instant.now();
        Timeseries<Integer> timeseries = timeseriesOf(Set.of(
                timeseriesEntryOf(instant, 2, null),
                timeseriesEntryOf(instant, 3, null)
        ));

        Timeseries<Integer> timeseries2 = timeseries.minus(timeseriesEntryOf(instant, 1, null));
        assertEquals(2, timeseries2.countEvents()); // Not found, no change

        Timeseries<Integer> timeseries3 = timeseries.minus(timeseriesEntryOf(instant, 2, null));
        assertEquals(1, timeseries3.countEvents());
    }

    @Test
    void testMinus_instant() {
        Instant instant = Instant.now();
        Timeseries<Integer> timeseries = timeseriesOf(Set.of(
                timeseriesEntryOf(instant, 2, null)
        ));

        Timeseries<Integer> timeseries2 = timeseries.minus(instant);
        assertEquals(0, timeseries2.countInstants());
    }

    @Test
    void testGetEntriesSubMap_exclusive() {
        Instant i1 = Instant.parse("2024-01-01T00:00:00Z");
        Instant i2 = Instant.parse("2024-01-02T00:00:00Z");
        Instant i3 = Instant.parse("2024-01-03T00:00:00Z");

        Timeseries<Integer> timeseries = timeseriesOf(Set.of(
                timeseriesEntryOf(i1, 1, null),
                timeseriesEntryOf(i2, 2, null),
                timeseriesEntryOf(i3, 3, null)
        ));

        NavigableMap<Instant, Collection<TimeseriesEntry<Integer>>> subMap = timeseries.getEntriesSubMap(i1, i3);
        assertEquals(1, subMap.size());
        assertTrue(subMap.containsKey(i2));
    }

    @Test
    void testStart() {
        Instant i1 = Instant.parse("2024-01-01T00:00:00Z");
        Instant i2 = Instant.parse("2024-01-02T00:00:00Z");
        Timeseries<Integer> timeseries = timeseriesOf(Set.of(
                timeseriesEntryOf(i2, 2, null),
                timeseriesEntryOf(i1, 1, null)
        ));

        Collection<TimeseriesEntry<Integer>> startEntries = timeseries.start();
        assertNotNull(startEntries);
        assertTrue(startEntries.contains(timeseriesEntryOf(i1, 1, null)));
    }

    @Test
    void testIterator_ascending() {
        Instant i1 = Instant.parse("2024-01-01T00:00:00Z");
        Instant i2 = Instant.parse("2024-01-02T00:00:00Z");
        Timeseries<Integer> timeseries = timeseriesOf(Set.of(
                timeseriesEntryOf(i2, 2, null),
                timeseriesEntryOf(i1, 1, null)
        ));

        Iterator<Collection<TimeseriesEntry<Integer>>> iterator = timeseries.iterator();
        assertTrue(iterator.hasNext());
        assertTrue(iterator.next().contains(timeseriesEntryOf(i1, 1, null)));
        assertTrue(iterator.next().contains(timeseriesEntryOf(i2, 2, null)));
    }
}
```
{% endtab %} 

MutableTimeseries
{% tabber "tsTabs3", {"ts-kotlin3":"Kotlin", "ts-java3":"Java"} %}
{% tab "ts-kotlin3" %}
```kotlin
package io.github.funofprograming.timeseries

import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Assertions.*
import java.time.Instant
import java.util.NavigableMap
import java.util.TreeMap
import java.util.UUID
import kotlin.collections.containsKey

class TestMutableTimeseries {

    @Test
    fun testInitializeTimeseries_empty() {
        val timeseries = mutableTimeseriesOf<Int>()
        assertNotNull(timeseries)
    }

    @Test
    fun testInitializeTimeseries_oneEntry() {
        val timeseries = mutableTimeseriesOf<Int>(timeseriesEntryOf(Instant.now(), 1))
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(1, timeseries.countEvents())
    }

    @Test
    fun testInitializeTimeseries_entryCollection_differentTime() {
        val timeseries = mutableTimeseriesOf<Int>(
            setOf(
                timeseriesEntryOf(Instant.now(), 1)
                , timeseriesEntryOf(Instant.now(), 2)
                , timeseriesEntryOf(Instant.now(), 3)
            ))
        assertNotNull(timeseries)
        assertEquals(3, timeseries.countInstants())
        assertEquals(3, timeseries.countEvents())
    }

    @Test
    fun testInitializeTimeseries_entryCollection_sameTime() {
        val instant = Instant.now()
        val timeseries = mutableTimeseriesOf<Int>(
            setOf(
                timeseriesEntryOf(instant, 1)
                , timeseriesEntryOf(instant, 2)
                , timeseriesEntryOf(instant, 3)
            ))
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(3, timeseries.countEvents())
    }

    @Test
    fun testInitializeTimeseries_entryMap() {
        val instant = Instant.now()
        val timeseriesEntrySet = setOf(
            timeseriesEntryOf(instant, 1)
            , timeseriesEntryOf(instant, 2)
            , timeseriesEntryOf(instant, 3)
        )
        val timeseriesEntryMap = TreeMap<Instant, Collection<TimeseriesEntry<Int>>>()
        timeseriesEntryMap[instant] = timeseriesEntrySet
        val timeseries = mutableTimeseriesOf<Int>(timeseriesEntryMap)

        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(3, timeseries.countEvents())
    }

    @Test
    fun testInitializeTimeseries_copy() {
        val instant = Instant.now()
        val timeseries = mutableTimeseriesOf<Int>(
            setOf(
                timeseriesEntryOf(instant, 1)
                , timeseriesEntryOf(instant, 2)
                , timeseriesEntryOf(instant, 3)
            ))
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(3, timeseries.countEvents())

        val timeseriesCopy = mutableTimeseriesOf(timeseries)
        assertNotNull(timeseriesCopy)
        assertFalse { timeseriesCopy === timeseries } //different objects
        assertTrue { timeseriesCopy == timeseries } //same entries
        assertEquals(1, timeseriesCopy.countInstants())
        assertEquals(3, timeseriesCopy.countEvents())
    }

    @Test
    fun testPlus_singleEntry_overwriteFalse() {
        val timeseries = mutableTimeseriesOf<Int>(timeseriesEntryOf(Instant.now(), 1))
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(1, timeseries.countEvents())
        val timeseries2 = timeseries.plus((timeseriesEntryOf(Instant.now(), 2)), false)
        assertNotNull(timeseries2)
        assertTrue { timeseries2 === timeseries } //same objects
        assertTrue { timeseries2 == timeseries } //same objects
        assertEquals(2, timeseries2.countInstants())
        assertEquals(2, timeseries2.countEvents())
    }

    @Test
    fun testPlus_singleEntry_overwriteTrue() {
        val instant = Instant.now()
        val timeseries = mutableTimeseriesOf<Int>(timeseriesEntryOf(instant, 1))
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(1, timeseries.countEvents())
        val timeseries2 = timeseries.plus((timeseriesEntryOf(instant, 1)))
        assertNotNull(timeseries2)
        assertTrue { timeseries2 === timeseries } //same objects
        assertTrue { timeseries2 == timeseries } //same objects
        assertEquals(1, timeseries2.countInstants())
        assertEquals(1, timeseries2.countEvents())
    }

    @Test
    fun testPlus_collectionEntry_overwriteFalse() {
        val timeseries = mutableTimeseriesOf<Int>(timeseriesEntryOf(Instant.now(), 1))
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(1, timeseries.countEvents())
        val timeseries2 = timeseries.plus(setOf(
            timeseriesEntryOf(Instant.now(), 2)
            , timeseriesEntryOf(Instant.now(), 3)
            , timeseriesEntryOf(Instant.now(), 4))
            , false)
        assertNotNull(timeseries2)
        assertTrue { timeseries2 === timeseries } //same objects
        assertTrue { timeseries2 == timeseries } //same objects
        assertEquals(4, timeseries2.countInstants())
        assertEquals(4, timeseries2.countEvents())
    }

    @Test
    fun testPlus_collectionEntry_overwriteTrue() {
        val instant = Instant.now()
        val timeseries = mutableTimeseriesOf<Int>(setOf(
            timeseriesEntryOf(instant, 2)
            , timeseriesEntryOf(instant, 3)
            , timeseriesEntryOf(instant, 4)))
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(3, timeseries.countEvents())
        val timeseries2 = timeseries.plus(setOf(
            timeseriesEntryOf(instant, 2)
            , timeseriesEntryOf(instant, 5)
            , timeseriesEntryOf(instant, 6)))
        assertNotNull(timeseries2)
        assertTrue { timeseries2 === timeseries } //same objects
        assertTrue { timeseries2 == timeseries } //same objects
        assertEquals(1, timeseries2.countInstants())
        assertEquals(5, timeseries2.countEvents()) //one entry is overwritten so total 5 events instead of 6
    }

    @Test
    fun testAdd_singleEntry_overwriteFalse() {
        val timeseries = mutableTimeseriesOf<Int>(timeseriesEntryOf(Instant.now(), 1))
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(1, timeseries.countEvents())
        val uuid = timeseries.add((timeseriesEntryOf(Instant.now(), 2)), false)
        assertNotNull(uuid)
        assertEquals(2, timeseries.countInstants())
        assertEquals(2, timeseries.countEvents())
    }

    @Test
    fun testAdd_singleEntry_overwriteTrue() {
        val instant = Instant.now()
        val timeseries = mutableTimeseriesOf<Int>(timeseriesEntryOf(instant, 1))
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(1, timeseries.countEvents())
        val uuid = timeseries.add((timeseriesEntryOf(instant, 1)))
        assertNotNull(uuid)
        assertEquals(1, timeseries.countInstants())
        assertEquals(1, timeseries.countEvents())
    }

    @Test
    fun testAdd_collectionEntry_overwriteFalse() {
        val timeseries = mutableTimeseriesOf<Int>(timeseriesEntryOf(Instant.now(), 1))
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(1, timeseries.countEvents())
        val uuids = timeseries.add(setOf(
            timeseriesEntryOf(Instant.now(), 2)
            , timeseriesEntryOf(Instant.now(), 3)
            , timeseriesEntryOf(Instant.now(), 4))
            , false)
        assertNotNull(uuids)
        assertTrue { uuids.isNotEmpty() }
        assertEquals(3, uuids.size)
        assertEquals(4, timeseries.countInstants())
        assertEquals(4, timeseries.countEvents())
    }

    @Test
    fun testAdd_collectionEntry_overwriteTrue() {
        val instant = Instant.now()
        val timeseries = mutableTimeseriesOf<Int>(setOf(
            timeseriesEntryOf(instant, 2)
            , timeseriesEntryOf(instant, 3)
            , timeseriesEntryOf(instant, 4)))
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(3, timeseries.countEvents())
        val uuids = timeseries.add(setOf(
            timeseriesEntryOf(instant, 2)
            , timeseriesEntryOf(instant, 5)
            , timeseriesEntryOf(instant, 6)))
        assertNotNull(uuids)
        assertTrue { uuids.isNotEmpty() }
        assertEquals(3, uuids.size)
        assertEquals(1, timeseries.countInstants())
        assertEquals(5, timeseries.countEvents()) //one entry is overwritten so total 5 events instead of 6
    }

    @Test
    fun testGet() {
        val instant = Instant.now()
        val timeseries = mutableTimeseriesOf<Int>(setOf(
            timeseriesEntryOf(instant, 2)
            , timeseriesEntryOf(instant, 3)
            , timeseriesEntryOf(instant, 4)))
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(3, timeseries.countEvents())
        val instantEvents = timeseries.get(instant)
        assertNotNull(instantEvents)
        assertTrue { instantEvents.isNotEmpty() }
        assertTrue { instantEvents.size == 3 }
        assertTrue { instantEvents.contains(timeseriesEntryOf(instant, 2)) }
        assertTrue { instantEvents.contains(timeseriesEntryOf(instant, 3)) }
        assertTrue { instantEvents.contains(timeseriesEntryOf(instant, 4)) }
        assertFalse { instantEvents.contains(timeseriesEntryOf(instant, 5)) }

        val instantEvents2 = timeseries.get(Instant.now())
        assertNotNull(instantEvents2)
        assertTrue { instantEvents2.isEmpty() }
    }

    @Test
    fun testGetAll() {
        val instant = Instant.now()
        val timeseries = mutableTimeseriesOf<Int>(setOf(
            timeseriesEntryOf(instant, 2)
            , timeseriesEntryOf(instant, 3)
            , timeseriesEntryOf(instant, 4)))
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(3, timeseries.countEvents())
        val instantEvents = timeseries.getAll()
        assertNotNull(instantEvents)
        assertTrue { instantEvents.isNotEmpty() }
        assertTrue { instantEvents.size == 1 }
        assertTrue { instantEvents.keys.contains(instant) }
        assertTrue { instantEvents[instant]?.contains(timeseriesEntryOf(instant, 2)) ?: false }
        assertTrue { instantEvents[instant]?.contains(timeseriesEntryOf(instant, 3)) ?: false }
        assertTrue { instantEvents[instant]?.contains(timeseriesEntryOf(instant, 4)) ?: false }
    }

    @Test
    fun testGetAllInstants() {
        val instant = Instant.now()
        val timeseries = mutableTimeseriesOf<Int>(setOf(
            timeseriesEntryOf(instant, 2)
            , timeseriesEntryOf(instant, 3)
            , timeseriesEntryOf(instant, 4)))
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(3, timeseries.countEvents())
        val instants = timeseries.getAllInstants()
        assertNotNull(instants)
        assertTrue { instants.isNotEmpty() }
        assertTrue { instants.size == 1 }
        assertTrue { instants.contains(instant) }
    }

    @Test
    fun testGet_instant_eventId() {
        val instant = Instant.now()
        val timeseries = mutableTimeseriesOf<Int>()
        val uuids = timeseries.add(setOf(
            timeseriesEntryOf(instant, 2)
            , timeseriesEntryOf(instant, 5)
            , timeseriesEntryOf(instant, 6)))
        val entry = timeseries.get(instant, uuids.first())
        assertNotNull(entry)
        assertEquals(2, entry?.event ?: null)
    }

    @Test
    fun testMinus_singleEntry() {
        val instant = Instant.now()
        val timeseries = mutableTimeseriesOf<Int>(setOf(
            timeseriesEntryOf(instant, 2)
            , timeseriesEntryOf(instant, 3)
            , timeseriesEntryOf(instant, 4)))
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(3, timeseries.countEvents())
        val timeseries2 = timeseries.minus((timeseriesEntryOf(instant, 1)))
        assertNotNull(timeseries2)
        assertTrue { timeseries2 === timeseries } //same objects
        assertTrue { timeseries2 == timeseries } //same objects
        assertEquals(1, timeseries2.countInstants())
        assertEquals(3, timeseries2.countEvents())
        val timeseries3 = timeseries.minus((timeseriesEntryOf(instant, 2)))
        assertTrue { timeseries3 === timeseries } //same objects
        assertTrue { timeseries3 == timeseries } //same objects
        assertEquals(1, timeseries3.countInstants())
        assertEquals(2, timeseries3.countEvents())
    }

    @Test
    fun testMinus_collectionEntry() {
        val instant = Instant.now()
        val timeseries = mutableTimeseriesOf<Int>(setOf(
            timeseriesEntryOf(instant, 2)
            , timeseriesEntryOf(instant, 3)
            , timeseriesEntryOf(instant, 4)))
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(3, timeseries.countEvents())
        val timeseries2 = timeseries.minus(setOf(
            timeseriesEntryOf(instant, 1)
            , timeseriesEntryOf(instant, 7)))
        assertNotNull(timeseries2)
        assertTrue { timeseries2 === timeseries } //same objects
        assertTrue { timeseries2 == timeseries } //same objects
        assertEquals(1, timeseries2.countInstants())
        assertEquals(3, timeseries2.countEvents())
        val timeseries3 = timeseries.minus(setOf(timeseriesEntryOf(instant, 2)
            , timeseriesEntryOf(instant, 3)))
        assertTrue { timeseries3 === timeseries } //same objects
        assertTrue { timeseries3 == timeseries } //same objects
        assertEquals(1, timeseries3.countInstants())
        assertEquals(1, timeseries3.countEvents())
    }

    @Test
    fun testMinus_instant() {
        val instant = Instant.now()
        val timeseries = mutableTimeseriesOf<Int>(setOf(
            timeseriesEntryOf(instant, 2)
            , timeseriesEntryOf(instant, 3)
            , timeseriesEntryOf(instant, 4)))
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(3, timeseries.countEvents())
        val timeseries2 = timeseries.minus(Instant.EPOCH)
        assertNotNull(timeseries2)
        assertTrue { timeseries2 === timeseries } //same objects
        assertTrue { timeseries2 == timeseries } //same objects
        assertEquals(1, timeseries2.countInstants())
        assertEquals(3, timeseries2.countEvents())
        val timeseries3 = timeseries.minus(instant)
        assertTrue { timeseries3 === timeseries } //same objects
        assertTrue { timeseries3 == timeseries } //same objects
        assertEquals(0, timeseries3.countInstants())
        assertEquals(0, timeseries3.countEvents())
    }

    @Test
    fun testRemove_singleEntry() {
        val instant = Instant.now()
        val timeseries = mutableTimeseriesOf<Int>(setOf(
            timeseriesEntryOf(instant, 2)
            , timeseriesEntryOf(instant, 3)
            , timeseriesEntryOf(instant, 4)))
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(3, timeseries.countEvents())
        val removed = timeseries.remove((timeseriesEntryOf(instant, 1)))
        assertNotNull(removed)
        assertFalse { removed }
        assertEquals(1, timeseries.countInstants())
        assertEquals(3, timeseries.countEvents())
        val removed2 = timeseries.remove((timeseriesEntryOf(instant, 2)))
        assertNotNull(removed)
        assertTrue { removed2 }
        assertEquals(1, timeseries.countInstants())
        assertEquals(2, timeseries.countEvents())
    }

    @Test
    fun testRemove_collectionEntry() {
        val instant = Instant.now()
        val timeseries = mutableTimeseriesOf<Int>(setOf(
            timeseriesEntryOf(instant, 2)
            , timeseriesEntryOf(instant, 3)
            , timeseriesEntryOf(instant, 4)))
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(3, timeseries.countEvents())
        val removed = timeseries.remove(setOf(
            timeseriesEntryOf(instant, 1)
            , timeseriesEntryOf(instant, 7)))
        assertNotNull(removed)
        assertFalse { removed }
        assertEquals(1, timeseries.countInstants())
        assertEquals(3, timeseries.countEvents())
        val removed2 = timeseries.remove(setOf(timeseriesEntryOf(instant, 2)
            , timeseriesEntryOf(instant, 3)))
        assertNotNull(removed)
        assertTrue { removed2 }
        assertEquals(1, timeseries.countInstants())
        assertEquals(1, timeseries.countEvents())
    }

    @Test
    fun testRemove_instant() {
        val instant = Instant.now()
        val timeseries = mutableTimeseriesOf<Int>(setOf(
            timeseriesEntryOf(instant, 2)
            , timeseriesEntryOf(instant, 3)
            , timeseriesEntryOf(instant, 4)))
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(3, timeseries.countEvents())
        val removed = timeseries.remove(Instant.EPOCH)
        assertNotNull(removed)
        assertFalse { removed }
        assertEquals(1, timeseries.countInstants())
        assertEquals(3, timeseries.countEvents())
        val removed2 = timeseries.remove(instant)
        assertNotNull(removed)
        assertTrue { removed2 }
        assertEquals(0, timeseries.countInstants())
        assertEquals(0, timeseries.countEvents())
    }

    @Test
    fun testClear() {
        val instant = Instant.now()
        val timeseries = mutableTimeseriesOf<Int>(setOf(
            timeseriesEntryOf(instant, 2)
            , timeseriesEntryOf(instant, 3)
            , timeseriesEntryOf(instant, 4)))
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(3, timeseries.countEvents())
        timeseries.clear()
        assertEquals(0, timeseries.countInstants())
        assertEquals(0, timeseries.countEvents())
    }

    @Test
    fun testContains_instant() {
        val instant = Instant.now()
        val timeseries = mutableTimeseriesOf<Int>(
            setOf(
                timeseriesEntryOf(instant, 2)
                , timeseriesEntryOf(instant, 3)
                , timeseriesEntryOf(instant, 4)
            )
        )
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(3, timeseries.countEvents())
        assertTrue { timeseries.contains(instant) }
        assertFalse { timeseries.contains(Instant.EPOCH) }
    }

    @Test
    fun testContains_event() {
        val instant = Instant.now()
        val timeseries = mutableTimeseriesOf<Int>(
            setOf(
                timeseriesEntryOf(instant, 2)
                , timeseriesEntryOf(instant, 3)
                , timeseriesEntryOf(instant, 4)
            )
        )
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(3, timeseries.countEvents())
        assertTrue { timeseries.contains(2) }
        assertFalse { timeseries.contains(5) }
    }

    @Test
    fun testContains_eventId() {
        val instant = Instant.now()
        val timeseries = mutableTimeseriesOf<Int>(
            setOf(
                timeseriesEntryOf(instant, 2)
                , timeseriesEntryOf(instant, 3)
                , timeseriesEntryOf(instant, 4)
            )
        )
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(3, timeseries.countEvents())
        val uuid = timeseries.add(timeseriesEntryOf(instant, 5))
        assertTrue { timeseries.contains(uuid) }
        assertFalse { timeseries.contains(UUID.randomUUID()) }
    }

    @Test
    fun testCountInstants() {
        val instant = Instant.now()
        val timeseries = mutableTimeseriesOf<Int>(
            setOf(
                timeseriesEntryOf(instant, 2)
                , timeseriesEntryOf(instant, 3)
                , timeseriesEntryOf(instant, 4)
            )
        )
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(3, timeseries.countEvents())
    }

    @Test
    fun testCountEvents() {
        val instant = Instant.now()
        val timeseries = mutableTimeseriesOf<Int>(
            setOf(
                timeseriesEntryOf(instant, 2)
                , timeseriesEntryOf(instant, 3)
                , timeseriesEntryOf(instant, 4)
            )
        )
        assertNotNull(timeseries)
        assertEquals(1, timeseries.countInstants())
        assertEquals(3, timeseries.countEvents())
    }

    @Test
    fun testIsEmpty() {
        val instant = Instant.now()
        val timeseries = mutableTimeseriesOf<Int>(
            setOf(
                timeseriesEntryOf(instant, 2)
                , timeseriesEntryOf(instant, 3)
                , timeseriesEntryOf(instant, 4)
            )
        )
        assertNotNull(timeseries)
        assertFalse { timeseries.isEmpty() }
        val timeseries2 = mutableTimeseriesOf<Int>()
        assertNotNull(timeseries2)
        assertTrue { timeseries2.isEmpty() }
    }

    @Test
    fun testIsNotEmpty() {
        val instant = Instant.now()
        val timeseries = mutableTimeseriesOf<Int>(
            setOf(
                timeseriesEntryOf(instant, 2)
                , timeseriesEntryOf(instant, 3)
                , timeseriesEntryOf(instant, 4)
            )
        )
        assertNotNull(timeseries)
        assertTrue { timeseries.isNotEmpty() }
        val timeseries2 = mutableTimeseriesOf<Int>()
        assertNotNull(timeseries2)
        assertFalse { timeseries2.isNotEmpty() }
    }

    @Test
    fun testGetEntriesSubMap_exclusive() {
        val instant1 = Instant.parse("2024-01-01T00:00:00Z")
        val instant2 = Instant.parse("2024-01-02T00:00:00Z")
        val instant3 = Instant.parse("2024-01-03T00:00:00Z")
        val timeseries = mutableTimeseriesOf<Int>(setOf(
            timeseriesEntryOf(instant1, 1),
            timeseriesEntryOf(instant2, 2),
            timeseriesEntryOf(instant3, 3)
        ))

        val subMap = timeseries.getEntriesSubMap(instant1, instant3)
        assertNotNull(subMap)
        assertEquals(1, subMap.size)
        assertTrue { subMap.containsKey(instant2) }
        assertFalse { subMap.containsKey(instant1) }
        assertFalse { subMap.containsKey(instant3) }
    }

    @Test
    fun testGetEntriesSubMap_inclusive() {
        val instant1 = Instant.parse("2024-01-01T00:00:00Z")
        val instant2 = Instant.parse("2024-01-02T00:00:00Z")
        val instant3 = Instant.parse("2024-01-03T00:00:00Z")
        val timeseries = mutableTimeseriesOf<Int>(setOf(
            timeseriesEntryOf(instant1, 1),
            timeseriesEntryOf(instant2, 2),
            timeseriesEntryOf(instant3, 3)
        ))

        val subMap = timeseries.getEntriesSubMap(instant1, true, instant3, true)
        assertNotNull(subMap)
        assertEquals(3, subMap.size)
        assertTrue { subMap.containsKey(instant1) }
        assertTrue { subMap.containsKey(instant2) }
        assertTrue { subMap.containsKey(instant3) }
    }

    @Test
    fun testGetEntriesHeadMap_exclusive() {
        val instant1 = Instant.parse("2024-01-01T00:00:00Z")
        val instant2 = Instant.parse("2024-01-02T00:00:00Z")
        val instant3 = Instant.parse("2024-01-03T00:00:00Z")
        val timeseries = mutableTimeseriesOf<Int>(setOf(
            timeseriesEntryOf(instant1, 1),
            timeseriesEntryOf(instant2, 2),
            timeseriesEntryOf(instant3, 3)
        ))

        val headMap = timeseries.getEntriesHeadMap(instant3)
        assertNotNull(headMap)
        assertEquals(2, headMap.size)
        assertTrue { headMap.containsKey(instant1) }
        assertTrue { headMap.containsKey(instant2) }
        assertFalse { headMap.containsKey(instant3) }
    }

    @Test
    fun testGetEntriesHeadMap_inclusive() {
        val instant1 = Instant.parse("2024-01-01T00:00:00Z")
        val instant2 = Instant.parse("2024-01-02T00:00:00Z")
        val instant3 = Instant.parse("2024-01-03T00:00:00Z")
        val timeseries = mutableTimeseriesOf<Int>(setOf(
            timeseriesEntryOf(instant1, 1),
            timeseriesEntryOf(instant2, 2),
            timeseriesEntryOf(instant3, 3)
        ))

        val headMap = timeseries.getEntriesHeadMap(instant3, true)
        assertNotNull(headMap)
        assertEquals(3, headMap.size)
        assertTrue { headMap.containsKey(instant1) }
        assertTrue { headMap.containsKey(instant2) }
        assertTrue { headMap.containsKey(instant3) }
    }

    @Test
    fun testGetEntriesTailMap_exclusive() {
        val instant1 = Instant.parse("2024-01-01T00:00:00Z")
        val instant2 = Instant.parse("2024-01-02T00:00:00Z")
        val instant3 = Instant.parse("2024-01-03T00:00:00Z")
        val timeseries = mutableTimeseriesOf<Int>(setOf(
            timeseriesEntryOf(instant1, 1),
            timeseriesEntryOf(instant2, 2),
            timeseriesEntryOf(instant3, 3)
        ))

        val tailMap = timeseries.getEntriesTailMap(instant1)
        assertNotNull(tailMap)
        assertEquals(2, tailMap.size)
        assertFalse { tailMap.containsKey(instant1) }
        assertTrue { tailMap.containsKey(instant2) }
        assertTrue { tailMap.containsKey(instant3) }
    }

    @Test
    fun testGetEntriesTailMap_inclusive() {
        val instant1 = Instant.parse("2024-01-01T00:00:00Z")
        val instant2 = Instant.parse("2024-01-02T00:00:00Z")
        val instant3 = Instant.parse("2024-01-03T00:00:00Z")
        val timeseries = mutableTimeseriesOf<Int>(setOf(
            timeseriesEntryOf(instant1, 1),
            timeseriesEntryOf(instant2, 2),
            timeseriesEntryOf(instant3, 3)
        ))

        val tailMap = timeseries.getEntriesTailMap(instant1, true)
        assertNotNull(tailMap)
        assertEquals(3, tailMap.size)
        assertTrue { tailMap.containsKey(instant1) }
        assertTrue { tailMap.containsKey(instant2) }
        assertTrue { tailMap.containsKey(instant3) }
    }

    @Test
    fun testStart() {
        val instant1 = Instant.parse("2024-01-01T00:00:00Z")
        val instant2 = Instant.parse("2024-01-02T00:00:00Z")
        val instant3 = Instant.parse("2024-01-03T00:00:00Z")
        val timeseries = mutableTimeseriesOf<Int>(setOf(
            timeseriesEntryOf(instant3, 3),
            timeseriesEntryOf(instant1, 1),
            timeseriesEntryOf(instant2, 2)
        ))

        val startEntries = timeseries.start()
        assertNotNull(startEntries)
        assertTrue { startEntries?.isNotEmpty() ?: false }
        assertTrue { startEntries?.contains(timeseriesEntryOf(instant1, 1)) ?: false }
    }

    @Test
    fun testStart_empty() {
        val timeseries = mutableTimeseriesOf<Int>()
        val startEntries = timeseries.start()
        assertNull(startEntries)
    }

    @Test
    fun testEnd() {
        val instant1 = Instant.parse("2024-01-01T00:00:00Z")
        val instant2 = Instant.parse("2024-01-02T00:00:00Z")
        val instant3 = Instant.parse("2024-01-03T00:00:00Z")
        val timeseries = mutableTimeseriesOf<Int>(setOf(
            timeseriesEntryOf(instant1, 1),
            timeseriesEntryOf(instant3, 3),
            timeseriesEntryOf(instant2, 2)
        ))

        val endEntries = timeseries.end()
        assertNotNull(endEntries)
        assertTrue { endEntries?.isNotEmpty() ?: false }
        assertTrue { endEntries?.contains(timeseriesEntryOf(instant3, 3)) ?: false }
    }

    @Test
    fun testEnd_empty() {
        val timeseries = mutableTimeseriesOf<Int>()
        val endEntries = timeseries.end()
        assertNull(endEntries)
    }

    @Test
    fun testIterator_ascending() {
        val instant1 = Instant.parse("2024-01-01T00:00:00Z")
        val instant2 = Instant.parse("2024-01-02T00:00:00Z")
        val instant3 = Instant.parse("2024-01-03T00:00:00Z")
        val timeseries = mutableTimeseriesOf<Int>(setOf(
            timeseriesEntryOf(instant3, 3),
            timeseriesEntryOf(instant1, 1),
            timeseriesEntryOf(instant2, 2)
        ))

        val iterator = timeseries.iterator()
        assertNotNull(iterator)
        assertTrue { iterator.hasNext() }

        val first = iterator.next()
        assertTrue { first.contains(timeseriesEntryOf(instant1, 1)) }

        val second = iterator.next()
        assertTrue { second.contains(timeseriesEntryOf(instant2, 2)) }

        val third = iterator.next()
        assertTrue { third.contains(timeseriesEntryOf(instant3, 3)) }

        assertFalse { iterator.hasNext() }
    }

    @Test
    fun testDescendingIterator() {
        val instant1 = Instant.parse("2024-01-01T00:00:00Z")
        val instant2 = Instant.parse("2024-01-02T00:00:00Z")
        val instant3 = Instant.parse("2024-01-03T00:00:00Z")
        val timeseries = mutableTimeseriesOf<Int>(
            setOf(
                timeseriesEntryOf(instant1, 1),
                timeseriesEntryOf(instant3, 3),
                timeseriesEntryOf(instant2, 2)
            )
        )

        val iterator = timeseries.descendingIterator()
        assertNotNull(iterator)
        assertTrue { iterator.hasNext() }

        val first = iterator.next()
        assertTrue { first.contains(timeseriesEntryOf(instant3, 3)) }

        val second = iterator.next()
        assertTrue { second.contains(timeseriesEntryOf(instant2, 2)) }

        val third = iterator.next()
        assertTrue { third.contains(timeseriesEntryOf(instant1, 1)) }

        assertFalse { iterator.hasNext() }
    }
}
```
{% endtab %} 

{% tab "ts-java3" %}
```java
package io.github.funofprograming.timeseries;

import org.junit.jupiter.api.Test;

import java.time.Instant;
import java.util.*;

import static io.github.funofprograming.timeseries.TimeseriesBuildersKt.mutableTimeseriesOf;
import static io.github.funofprograming.timeseries.TimeseriesBuildersKt.timeseriesEntryOf;
import static org.junit.jupiter.api.Assertions.*;

class TestJavaMutableTimeseries {

    @Test
    void testInitializeTimeseries_empty() {
        MutableTimeseries<Integer> timeseries = mutableTimeseriesOf();
        assertNotNull(timeseries);
    }

    @Test
    void testInitializeTimeseries_oneEntry() {
        MutableTimeseries<Integer> timeseries = mutableTimeseriesOf(timeseriesEntryOf(Instant.now(), 1, null));
        assertNotNull(timeseries);
        assertEquals(1, timeseries.countInstants());
        assertEquals(1, timeseries.countEvents());
    }

    @Test
    void testInitializeTimeseries_entryCollection_differentTime() {
        Set<TimeseriesEntry<Integer>> entries = new HashSet<>(Arrays.asList(
                timeseriesEntryOf(Instant.now(), 1, null),
                timeseriesEntryOf(Instant.now(), 2, null),
                timeseriesEntryOf(Instant.now(), 3, null)
        ));
        MutableTimeseries<Integer> timeseries = mutableTimeseriesOf(entries);
        assertNotNull(timeseries);
        assertEquals(3, timeseries.countInstants());
        assertEquals(3, timeseries.countEvents());
    }

    @Test
    void testInitializeTimeseries_entryCollection_sameTime() {
        Instant instant = Instant.now();
        Set<TimeseriesEntry<Integer>> entries = new HashSet<>(Arrays.asList(
                timeseriesEntryOf(instant, 1, null),
                timeseriesEntryOf(instant, 2, null),
                timeseriesEntryOf(instant, 3, null)
        ));
        MutableTimeseries<Integer> timeseries = mutableTimeseriesOf(entries);
        assertNotNull(timeseries);
        assertEquals(1, timeseries.countInstants());
        assertEquals(3, timeseries.countEvents());
    }

    @Test
    void testInitializeTimeseries_entryMap() {
        Instant instant = Instant.now();
        Set<TimeseriesEntry<Integer>> timeseriesEntrySet = new HashSet<>(Arrays.asList(
                timeseriesEntryOf(instant, 1, null),
                timeseriesEntryOf(instant, 2, null),
                timeseriesEntryOf(instant, 3, null)
        ));
        TreeMap<Instant, Collection<TimeseriesEntry<Integer>>> timeseriesEntryMap = new TreeMap<>();
        timeseriesEntryMap.put(instant, timeseriesEntrySet);

        MutableTimeseries<Integer> timeseries = mutableTimeseriesOf(timeseriesEntryMap);

        assertNotNull(timeseries);
        assertEquals(1, timeseries.countInstants());
        assertEquals(3, timeseries.countEvents());
    }

    @Test
    void testInitializeTimeseries_copy() {
        Instant instant = Instant.now();
        Set<TimeseriesEntry<Integer>> entries = new HashSet<>(Arrays.asList(
                timeseriesEntryOf(instant, 1, null),
                timeseriesEntryOf(instant, 2, null),
                timeseriesEntryOf(instant, 3, null)
        ));
        MutableTimeseries<Integer> timeseries = mutableTimeseriesOf(entries);

        MutableTimeseries<Integer> timeseriesCopy = mutableTimeseriesOf(timeseries);
        assertNotNull(timeseriesCopy);
        assertNotSame(timeseries, timeseriesCopy); // different objects
        assertEquals(timeseries, timeseriesCopy);   // same entries (equals)
        assertEquals(1, timeseriesCopy.countInstants());
        assertEquals(3, timeseriesCopy.countEvents());
    }

    @Test
    void testPlus_singleEntry_overwriteFalse() {
        MutableTimeseries<Integer> timeseries = mutableTimeseriesOf(timeseriesEntryOf(Instant.now(), 1, null));
        MutableTimeseries<Integer> timeseries2 = timeseries.plus(timeseriesEntryOf(Instant.now(), 2, null), false);

        assertSame(timeseries, timeseries2);
        assertEquals(2, timeseries2.countInstants());
        assertEquals(2, timeseries2.countEvents());
    }

    @Test
    void testPlus_collectionEntry_overwriteTrue() {
        Instant instant = Instant.now();
        Set<TimeseriesEntry<Integer>> entries = new HashSet<>(Arrays.asList(
                timeseriesEntryOf(instant, 2, null),
                timeseriesEntryOf(instant, 3, null),
                timeseriesEntryOf(instant, 4, null)
        ));
        MutableTimeseries<Integer> timeseries = mutableTimeseriesOf(entries);

        Set<TimeseriesEntry<Integer>> newEntries = new HashSet<>(Arrays.asList(
                timeseriesEntryOf(instant, 2, null),
                timeseriesEntryOf(instant, 5, null),
                timeseriesEntryOf(instant, 6, null)
        ));

        MutableTimeseries<Integer> timeseries2 = timeseries.plus(newEntries, true);
        assertEquals(1, timeseries2.countInstants());
        assertEquals(5, timeseries2.countEvents()); // one overwritten
    }

    @Test
    void testGet() {
        Instant instant = Instant.now();
        Set<TimeseriesEntry<Integer>> entries = new HashSet<>(Arrays.asList(
                timeseriesEntryOf(instant, 2, null),
                timeseriesEntryOf(instant, 3, null),
                timeseriesEntryOf(instant, 4, null)
        ));
        MutableTimeseries<Integer> timeseries = mutableTimeseriesOf(entries);

        Collection<TimeseriesEntry<Integer>> instantEvents = timeseries.get(instant);
        assertNotNull(instantEvents);
        assertFalse(instantEvents.isEmpty());
        assertEquals(3, instantEvents.size());
        assertTrue(instantEvents.contains(timeseriesEntryOf(instant, 2, null)));
    }

    @Test
    void testGet_instant_eventId() {
        Instant instant = Instant.now();
        MutableTimeseries<Integer> timeseries = mutableTimeseriesOf();
        Set<TimeseriesEntry<Integer>> entries = new LinkedHashSet<>(Arrays.asList(
                timeseriesEntryOf(instant, 2, null),
                timeseriesEntryOf(instant, 5, null)
        ));
        Collection<UUID> uuids = timeseries.add(entries, true);

        TimeseriesEntry<Integer> entry = timeseries.get(instant, uuids.iterator().next());
        assertNotNull(entry);
        assertEquals(2, entry.getEvent());
    }

    @Test
    void testMinus_instant() {
        Instant instant = Instant.now();
        MutableTimeseries<Integer> timeseries = mutableTimeseriesOf(new HashSet<>(Arrays.asList(
                timeseriesEntryOf(instant, 2, null)
        )));

        MutableTimeseries<Integer> timeseries2 = timeseries.minus(Instant.EPOCH);
        assertSame(timeseries, timeseries2);
        assertEquals(1, timeseries2.countInstants());

        MutableTimeseries<Integer> timeseries3 = timeseries.minus(instant);
        assertEquals(0, timeseries3.countInstants());
        assertEquals(0, timeseries3.countEvents());
    }

    @Test
    void testClear() {
        MutableTimeseries<Integer> timeseries = mutableTimeseriesOf(timeseriesEntryOf(Instant.now(), 2, null));
        timeseries.clear();
        assertEquals(0, timeseries.countInstants());
        assertEquals(0, timeseries.countEvents());
    }

    @Test
    void testGetEntriesSubMap_exclusive() {
        Instant i1 = Instant.parse("2024-01-01T00:00:00Z");
        Instant i2 = Instant.parse("2024-01-02T00:00:00Z");
        Instant i3 = Instant.parse("2024-01-03T00:00:00Z");

        MutableTimeseries<Integer> ts = mutableTimeseriesOf(new HashSet<>(Arrays.asList(
                timeseriesEntryOf(i1, 1, null)
                , timeseriesEntryOf(i2, 2, null)
                , timeseriesEntryOf(i3, 3, null)
        )));

        NavigableMap<Instant, Collection<TimeseriesEntry<Integer>>> subMap = ts.getEntriesSubMap(i1, i3);
        assertEquals(1, subMap.size());
        assertTrue(subMap.containsKey(i2));
        assertFalse(subMap.containsKey(i1));
    }

    @Test
    void testStart() {
        Instant i1 = Instant.parse("2024-01-01T00:00:00Z");
        Instant i2 = Instant.parse("2024-01-02T00:00:00Z");
        MutableTimeseries<Integer> ts = mutableTimeseriesOf(new HashSet<>(Arrays.asList(
                timeseriesEntryOf(i2, 2, null)
                , timeseriesEntryOf(i1, 1, null)
        )));

        Collection<TimeseriesEntry<Integer>> startEntries = ts.start();
        assertNotNull(startEntries);
        assertTrue(startEntries.contains(timeseriesEntryOf(i1, 1, null)));
    }

    @Test
    void testIterator_ascending() {
        Instant i1 = Instant.parse("2024-01-01T00:00:00Z");
        Instant i2 = Instant.parse("2024-01-02T00:00:00Z");
        MutableTimeseries<Integer> ts = mutableTimeseriesOf(new HashSet<>(Arrays.asList(
                timeseriesEntryOf(i2, 2, null)
                , timeseriesEntryOf(i1, 1, null)
        )));

        Iterator<Collection<TimeseriesEntry<Integer>>> iterator = ts.iterator();
        assertTrue(iterator.hasNext());
        assertTrue(iterator.next().contains(timeseriesEntryOf(i1, 1, null)));
        assertTrue(iterator.next().contains(timeseriesEntryOf(i2, 2, null)));
    }
}
```
{% endtab %} 
{% endtabber %}

Above Junit showcase how to initialize and use all the methods of Timeseries and MutableTimeseries interfaces.

## Compatibility matrix

| Timeseries |  Java  | Kotlin-Std |
|:----------:|:------:|:----------:|
|   1.0.0    |   21   |  2.3.10    |

## License

Timeseries is released under version 2.0 of the [Apache License](https://www.apache.org/licenses/LICENSE-2.0).

## Source
{% github "timeseries", ghrepo %}

