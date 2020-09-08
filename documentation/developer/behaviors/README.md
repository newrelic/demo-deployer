# Tron Behaviors

## What are Behaviors

Each Tron Service will support a set of well defined runtime behaviors that can be invoked on a per request basis. These behaviors will enable a running service to throw an exception, slowdown response time or stress the cpu.

## How Behaviors work

Each incoming HTTP request cans attach any number of HTTP Headers that conform to the defined behaviors format.  When these HTTP headers are revived by the running service they will be inspected acted upon and sent to any downstream HTTP requests.

## Behaviors format

The HTTP headers are broken down into a series of section that define what and who should take action. 

All incoming tron headers start with 'X-DEMO', followed by the name of the behavior, when the behavior is triggered (before or after handling the request), and optionally which tron identity is targeted.

Format:
`X-DEMO-[BEHAVIOR NAME]-[PRE or POST]{-[APP_ID]}`

Examples:
* X-DEMO-THROW-POST-APP1 . This will cause the behavior THROW to run on the app1 tron after executing the web request
* X-DEMO-SOMETHINGELSE-PRE . This will cause the behavior SOMETHINGELSE to run on any tron before executing the web request

Note, the header format is treated in a case insensitive way by each trons. So `X-DEMO-THROW-POST-APP1` would behave the same if it was sent as `X-Demo-Throw-Post-App1`

## Behavior Capabilities

Not every Tron service will support the exact same set of runtime behaviors. 

To help manage these difference each Tron expose a `/api/behaviors` endpoint that will return a JSON array of all the currently supported behaviors.

Possible Behaviors
* [Throw](throw/README.md)
* [Compute](compute/README.md)
* [Memory Allocation](malloc/README.md)
