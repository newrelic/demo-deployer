# Diagnosing error alerts

In this tutorial, you'll use New Relic to understand why some services are raising alerts.

## Prerequisites

This user story assumes you're familiar with the [infrastructure of Telco Lite](README.md#application-design), you've [set up your local environment](prereqs.md), and you've [deployed and instrumented the Telco Lite services](deployment.md).

## Investigate the alerts

To begin, log into [New Relic One](one.newrelic.com) and select **APM** from the top navigation menu. Here, you see an overview of all eight Telco Lite services, including the service names, response times, and throughputs. Notice that **Telco-Login Service** and **Telco-Web Portal** have opened critical violations for high error percentages:

![Error alerts](imgs/error-alerts.png)

> **Note:** If you don't see all the same alerts, don't worry. The simulated issues happen at regular intervals, so you should start seeing these problems in New Relic within 30 minutes to an hour.

The deployment has created an alert condition for cases where a service's error percentage rises above 10% for 5 minutes or longer. A critical violation means that the service's conditions violate that threshold.

Begin your investigation by selecting the **Telco-Web Portal** service name.

## View the web portal's errors

You're now on the web portal's APM summary page. The top graph, **Web transactions time**, shows you the service's response times. By default, it also displays periods of critical violation. On the right-hand side of the view, **Application activity** shows when violations opened and closed:

![Web portal alerts](imgs/web-portal-apm-summary.png)

To learn more about the errors, themselves, select **Events > Errors** from the left-hand navigation:

![Web portal errors](imgs/web-portal-errors.png)

At the bottom of the view, the errors table shows you what errors occurred in the service along with number of times each error occurred.

In this scenario, the only error in the service has the following message:

```
An error occurred during a downstream request to http://35.182.223.70:7001/api/inventory detail:response code 500
```

This is a helpful message which explains that the web portal made a request to another service, raised an error, and responded with a response code of 500, indicating an **Internal server error**.

Since this message tells you that the error occurred while the web portal was making an outbound request, you can use distributed tracing to better understand the issue. Select **Monitor > Distributed tracing** from the left-hand navigation.

## Use distributed tracing

![Web portal distributed tracing](imgs/web-portal-dt.png)

Distributed tracing provides end-to-end information about a request. In this case, you're looking for a request to the web portal that raised an error, so that you can better understand what happened during that request. Filter the table, by selecting the **Errors** column header twice, to order by descending counts:

![Web portal traces, ordered by descending error counts](imgs/web-portal-dt-ordered.png)

Select the first row in the table:

![Web portal trace data](imgs/web-portal-dt-row.png)

This trace gives a lot of information about what happened with the request once the web portal received it. One of the things the trace tells you is that the web portal made a `GET` request to **Telco-Login Service** and received an error. The trace indicates an error by coloring the text red.

Select the row (called a span) to see more information about the request to the login service:

![Distributed trace error details](imgs/dt-error-details.png)

Expand **Error details** to see the error message:

```
java.lang.Exception: The application is not yet ready to accept traffic
```

Interesting! This message says that, at the time that the web portal made the `GET` request to the login service, the login service was not ready to accept traffic. To dive further into the root cause of these cascading errors, you need to inspect the login service.

Select **APM > Telco-Login Service**.

## Move to the login service

![Login service APM summary](imgs/login-apm-summary.png)

Notice that the APM summary for **Telco-Login Service** has similar red flags to the ones in the web portal: **Web transactions time** has a red error indicator, and **Application activity** shows critical violations. More than that, the times that the errors occurred in both services match up (around 10:53 AM, in this example).

## Investigate the JVM

**Web transactions time**, in the APM, shows you that requests to the login service spend all their time in Java code. So, open **Monitor > JVMs** in the left-hand navigation:

![JVMs overview](imgs/jvm-overview.png)

Java Virtual Machines, or JVMs, run Java processes, such as those used by the login service. This view shows you resource graphs for each JVM your service uses. Change the time slice to look at data for the last 3 hours, so you can get a better idea of how the service has been behaving:

![JVM heap memory usage](imgs/jvm-heap-mem.png)

Notice, in **Heap memory usage**, that the line for **Used Heap** rises consistently over 30 minute intervals. About two-thirds of the way through that interval, the line for **Committed Heap** (the amount of JVM heap memory dedicated for use by Java processes) quickly rises to accommodate the increasing memory demands. This graph indicates that the Java process is leaking memory.

## Check host resources

Your Java process is leaking memory, but you need to understand the extent of the leak's impact. To dive a little deeper, navigate to the login service's host infrastructure view.

First, go to the **Telco-Login Service** summary page and turn off **Show new view**:

![APM summary old view](imgs/apm-login-old-view.png)

Then, scroll to the bottom of the page, and select the host's name:

![Login APM select host](imgs/apm-login-select-host.png)

> **Note:** Right now, you can only select the host's name from the old version of the UI (we're working on it). So, make sure you toggled **Show new view** to "off".

In this infrastructure view, **Memory Used %** for **Telco-Authentication-host** consistently climbs from around 60% to around 90% over 30-minute intervals, matching the intervals in the JVM's heap memory usage graph:

![Authentication host memory](imgs/infra-auth-host.png)

Therefore, the memory leak effects the login service's entire host. Click and drag on **Memory Used %** to narrow the time slice to one of the peaks:

![Authentication host, new time slice](imgs/auth-host-zoomed.png)

Now, you can compare this graph with the login service's **Errors** graph to see how they relate.

## Comparing the memory leak with errors

In a new tab, navigate to the login service's **Errors** view: **APM > Telco-Login Service > Events > Errors**:

![Login service errors](imgs/login-errors.png)

If you compare these graphs, you'll see that the memory percentage reached its peak at 10:25 AM (in this example), and then dropped off. You'll also see that errors started occurring in the login service just after that, at 10:26 AM. The message for those errors is the same one you saw earlier:

```
java.lang.Exception: The application is not yet ready to accept traffic
```

This suggests that the memory leaks cause the application to fail for a time. To understand the error a bit more, select the error class from the table at the bottom of the view:

![Login service error details](imgs/login-error-class.png)

The stack trace shows that the service raised an `UnhandledException` from a function called `EnsureAppIsStarted`:

![Login error stack trace](imgs/login-error-stack-trace.png)

With the information you've collected so far, you can conclude that **Telco-Login Service's** java code has a memory leak. Also, the login service restarts the application when it runs out of memory, and it raises an `UnhandledException` when it receives requests while the app is restarting.

You also know the login service is effecting the Web Portal, because that is what introduced you to this problem, but does the issue effect any other services?

## Observe the dependencies

You can visualize service dependencies using service maps. First, navigate back to **APM > Telco-Login Service** and select  **Monitor > Service map**:

![Login service map](imgs/login-service-map.png)

Both **Telco-Web Portal** and **Telco-Warehouse Portal** depend on **Telco-Login Service**. So, when the login service goes down, you start seeing errors in the portals.

> **Extra Credit:** Use the same steps you used to investigate issues in the web portal to confirm there are issues in the warehouse portal.

## Conclusion

At the end of your investigation, you discovered:

- **Telco-Login Service** and **Telco-Web Portal** raise alerts during critical violations
- The login service's Java processes leak memory
- When the login service's host, **Telco-Authentication-host**, runs out of memory, it restarts the login application
- While the login application is restarting, it raises an `UnhandledException` when it receives requests
- When the web portal and the warehouse portal make requests to the login service while it's restarting, they receive errors and raise errors of their own

Now, as a Telco Lite developer, you have enough information to debug the issue causing the memory leak. Congratulations!

You can learn more about using New Relic by diagnosing [other issues](deployment.md#view-your-services). If this is your last issue, you can [tear down](deployment.md#tear-down-telco-lite) all the Telco Lite services.