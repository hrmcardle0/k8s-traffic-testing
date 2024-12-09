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

The nitty gritty details of this involve how `SIGTERM` is sent by the kube scheduler. There is a good write-up about this behavior [here](https://learnk8s.io/graceful-shutdown). 

Docker uses `SIGTERM` to shutdown containers, a big reason why [dumb-init](https://github.com/Yelp/dumb-init) is so widely used across the indstury. As an example, you can build the `go-server` Dockerfile, run it, then run `curl` it locally. While processing this request, stop the container with `docker stop` and you'll see the `SIGTERM` handler was called, causing the client request to fail mid-way through.

![docker-sigterm-1](https://raw.githubusercontent.com/hrmcardle0/k8s-traffic-testing/refs/heads/main/images/docker-sigterm-logs1.png)

![docker-sigterm-2](https://raw.githubusercontent.com/hrmcardle0/k8s-traffic-testing/refs/heads/main/images/docker-sigterm-logs2.png)

Kubernetes operates in the same way.


## Test cases

1. Pod is deleted

2. Pod terminates internally

3. Pod is evicted