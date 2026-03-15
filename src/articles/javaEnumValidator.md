---
title: "Java Enum Validator"
description: "Java enum validation using Java Bean Validation framework"
tags:
  - enum-validator
  - Java
date: 2016-09-29
image: /static/images/validation.jpg
---
![JavaEnumValidator]({{ image }})

A lot of times while designing web services some data attribute to be exchanged is an enum. So how to validate such data at service end. One way is to write boilerplate code for this purpose but then what’s the use of Java Bean Validation. So how to use Java Bean Validation for validating a String attribute against an Enum values.First the annotation @Enum

```java
import java.lang.annotation.Documented;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;
 
import javax.validation.Constraint;
import javax.validation.Payload;
 
@Documented
@Constraint(validatedBy = {EnumValueValidator.class})
@Target({ ElementType.METHOD, ElementType.FIELD, ElementType.PARAMETER })
@Retention(RetentionPolicy.RUNTIME)
public @interface Enum
{
    public abstract String message() default "Invalid value. This is not permitted.";
     
    public abstract Class<?>[] groups() default {};
  
    public abstract Class<? extends Payload>[] payload() default {};
     
    public abstract Class<? extends java.lang.Enum<?>> enumClass();
     
    public abstract boolean ignoreCase() default false;
}
```

Now this annotation @Enum provides a boolean option of ignoring the case while validation. We will see next how it is used in EnumValueValidator class

```java
import javax.validation.ConstraintValidator;
import javax.validation.ConstraintValidatorContext;
 
public class EnumValueValidator implements ConstraintValidator<Enum, String>
{
    private Enum annotation;
 
    @Override
    public void initialize(Enum annotation)
    {
        this.annotation = annotation;
    }
 
    @Override
    public boolean isValid(String valueForValidation, ConstraintValidatorContext constraintValidatorContext)
    {
        boolean result = false;
         
        Object[] enumValues = this.annotation.enumClass().getEnumConstants();
         
        if(enumValues != null)
        {
            for(Object enumValue:enumValues)
            {
                if(valueForValidation.equals(enumValue.toString()) 
                   || (this.annotation.ignoreCase() && valueForValidation.equalsIgnoreCase(enumValue.toString())))
                {
                    result = true; 
                    break;
                }
            }
        }
         
        return result;
    }
}
```

As we can see from class EnumValueValidator’s method isValid, the ignoreCase option is used to match values while ignoring case of the values being matched. This validator will match the incoming value that needs to be checked with String representation of the Enum against which validation is to be performed.

Now how to use it. Consider the following enum

```java
public enum SampleEnum
{
    VALUE1,
    VALUE2,
    VALUE3;
}
```

Now consider the JavaBean that gets created upon getting values from some source like a Web service/client, database, network, etc

```java
public class SampleBean
{
    @Enum(enumClass=SampleEnum.class, ignoreCase=true) 
    String sample;
 
    public String getSample()
    {
        return sample;
    }
 
    public void setSample(String sample)
    {
        this.sample = sample;
    }
     
}
```

In this scenario our validator will validate the sample attribute of SampleBean and check if its value is same as one of the SampleEnum values.This is how we can extend JavaBean validation to have a Enum validator. 