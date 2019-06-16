# Manual Integration Test Suite

Run the bal files reside in `resource/http` directory using a ballerina distribution which needs to be tested.
```
jballerina build test.bal
jballerina run test.jar
```

Then execute the project
```
mvn exec:java
```
