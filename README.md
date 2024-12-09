# Kubernetes Pod Lifecycle

This repo is a demonstration and testing grouns for determing how k8s handles scenarios where a pod is terminated and traffic needs to be stopped or redirected. In this case, the [Pod Lifecycle Documentation](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#pod-termination) is not entirely clear on this.

## Setup

For this setup, we are going to deploy on a `Kind` cluster the following resources:

- pod serving HTTP traffic over 80
- service fronting the pod over 80
- nginx ingress controller running locally on the Node on a random port, in our case it's `30650`

This is all running on a `Kind` cluster within Docker and therefore to hit our endpoint will require execing on the worker container-node to curl the localhost endpoint in the form of `curl -H "Host: example.com" http://localhost:30630`.

Our client pod will be running `curl` to hit the endpoint every 1/10th of a second. 

## SIGTERM

The nitty gritty details of this involve how `SIGTERM` is sent by the kube scheduler. 

### Docker

Docker uses `SIGTERM` to shutdown containers, a big reason why [dumb-init](https://github.com/Yelp/dumb-init) is so widely used across the indstury. As an example, you can build the `go-server` Dockerfile, run it, then run `curl` it locally. While processing this request, stop the container with `docker stop` and you'll see the `SIGTERM` handler was called, causing the client request to fail mid-way through.

![docker-sigterm-1](https://raw.githubusercontent.com/hrmcardle0/k8s-traffic-testing/refs/heads/main/images/docker-sigterm-logs.png)

### Kubernetes

Kubernetes operates in the same way. There is a good write-up about this behavior [here](https://learnk8s.io/graceful-shutdown). 

## Endpoints

K8s service use endpoints to target the backend pods. Services themselves have an IP assigned but it's important to remember that these IPs are not actual resources, they are not routable nor do they represent an actual network interface, either physical or virtual. Instead they are simply placeholders that get put into ip tables rules to route traffic to the correct pods.

Upon pod termination, the endpoint should be removed from the service as fast as possible. 

## Results

### Services

For services, the removal happens nearly instantly. The following example shows the deletion of a pod and the subsequent removal of the endpoint from the service.

```
15:23:54.752 - Deleting pod...
```

```
Pod endpoint removed at: 15:23:54.952
```

Interestingly, creating a failed liveness probe on the pod does not remove the endpoint until it fails a certain number of times. During testing, the probe failed, the container restarted, and the endpoint was still present until the probe failed again.

However, with a readiness probe, the endpoint is never registered at all until the probe passes.

Another interesting tidbit, `preStop` hooks cause the endpoint to be removed immidately and the service to stop forwarding traffic immediately. This should be desired behavior, as the point of the `preStop` hook is to allow the pod to finish processing any requests before being terminated.