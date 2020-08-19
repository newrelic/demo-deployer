# Compute behavior

The `COMPUTE` behavior triggers a processing on the tron for a specific length of time. The header value must be use to control the time the processing should take.

## Value format

The value for the compute behavior has the following format: `[MIN,MAX{,CONCURRENCY}]`

The `MIN` is an integer value representing the number of milliseconds to process at the minimum.
The `MAX` is an integer value representing the number of milliseconds to process at the maximum.

The tron picks a random value between `MIN` and `MAX` (inclusive). The random follows a normal distribution (bell curve), using the Box-Muller transform.

The `CONCURRENCY` parameter is the 3rd and optional param that can be use to control the concurrency of the processing. This parameter is useful when running on larger host that have multiple cores. For example, on a 4 core CPU, to take adventage of all the cores, a concurrency value of `300` should be passed in.
For single core host, this parameter should NOT be passed, the default value of `10` is sufficient.

Note, some languages are inherently limited to run on a single core, like nodeJS. Consequently, Nodetron will only spike 1 of the core on the host. If you're planning to have a tron to take all the available CPU on a multi-core host, you would want to pick either Javatron or Pythontron instead.

## Example

This causes a CPU spike on the tron with an id of `javatron1` for about `1s` (interval of `.8s` and `1.2s`)
```bash
curl -i "http://localhost:8081/api/inventory/2" -H "x-demo-compute-pre-javatron1, [800,1200,300]"
```

This causes a CPU spike on all trons for about `.5s` (interval of `.4s` and `.6s`)
```bash
curl -i "http://localhost:8081/api/inventory/2" -H "x-demo-compute-post-javatron1, [400,600]"
```
