# Memory Allocation behavior

The `MALLOC` behavior trigger a memory allocation behavior on the tron, and this memory is held permanently. This can be used to simulate a memory leak. The header value must be use to control how much memory should be allocated.

## Value format

The value for the compute behavior has the following format: `[MIN,MAX]`

The `MIN` is an integer value representing the number of killobytes to allocate at the minimum.
The `MAX` is an integer value representing the number of killobytes to allocate at the maximum.

The tron picks a random value between `MIN` and `MAX` (inclusive). The random follows a normal distribution (bell curve), using the Box-Muller transform.

## Example

This causes a memory leak on the tron with an id of `javatron1` for about `1MB`
```bash
curl -i "http://localhost:8081/api/inventory/2" -H "x-demo-malloc-pre-javatron1, [800,1200]"
```

This causes a memory leak on all trons for about `50KB` (interval of `40KB` and `60KB`)
```bash
curl -i "http://localhost:8081/api/inventory/2" -H "x-demo-compute-post-javatron1, [40,60]"
```

## Note

While each tron does the same amount of memory allocation, each language has a different amount of overhead inherent to each object created. 
Here are some measurements observed for the various languages:

* Java, input of 60KB/min, measurement of 125KB/min, overhead ~ *2.08
* Node, input of 10MB/min, measurement of 85MB/min, overhead ~ *8
* Python, input of 2.5MB/min, measurement of 40MB/min, overhead ~ *16
