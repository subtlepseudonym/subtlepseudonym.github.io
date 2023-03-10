---
date: 2019-07-15
title: "Pihole on Kubernetes"
draft: false
---
If you've never heard of [pi-hole](https://pi-hole.net/), it's fantastic tool that blocks DNS requests to ad servers. That means you can surf the web without having to look at ads on every page.

I'm a big fan of running absolutely everything in docker, so I previously had a pi-hole container on my network, but it's time to up my game.

### Before we begin
For the purposes of this tutorial, I'm going to assume that you've assigned your Raspberry Pi a static IP address and know how to route DNS requests to it. If you've read my previous post on [setting up a kubernetes cluster on Raspberry Pis](/articles/k8s-on-pi), you'll be able to follow along as I get pi-hole running in kubernetes.

And finally, if at any point you have questions about definition schema or I haven't linked documentation, you may be able to find answers in the [kubernetes documentation](https://kubernetes.io/docs/home/).

### Let's get started

The biggest gotcha for running pi-hole containers is the need for persistent storage. Where volumes are a bit more of a free-for-all in docker, they need to be specified more explicitly in kubernetes. For this tutorial, we're going to use local storage for our volumes. This isn't the best way to do persistent storage, but it's simpler to set up and this was my first dive into kubernetes.

Here's the docker command I used to create the pi-hole container as a reference for the values we'll be building our manifest with:

```bash
docker run -d \
  --name pihole \
  -p 53:53/tcp -p 53:53/udp \
  -p 8000:80 \
  -e TZ="America/New_York" \
  -e WEBPASSWORD="secret" \
  -v /path/to/volume/etc/:/etc/pihole/ \
  -v /path/to/volume/dnsmasq.d/:/etc/dnsmasq.d/ \
  --dns=0.0.0.0 --dns=1.1.1.1 \
  pihole/pihole:latest
```

### Define the StorageClass

Create a `pihole.yaml` file and we'll get started building our manifest with a [StorageClass definition](https://kubernetes.io/docs/concepts/storage/storage-classes/). Keep in mind that kubernetes requires the manifest to be indented using spaces, not tabs.

```yaml
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
```

- [.apiVersion](https://kubernetes.io/docs/concepts/overview/kubernetes-api/) defines the kubernetes API that we're using and the yaml selectors that are available to us
- [.kind](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/#required-fields) defines the type of definition we're writing
- [.metadata](https://kubernetes.io/docs/concepts/overview/working-with-objects/names/) allows us to attach names, UIDs, and other identifying information to our definition. In our case, we just need a name so that we can reference this definition later
- [.provisioner](https://kubernetes.io/docs/concepts/storage/storage-classes/#provisioner) is used by kubernetes to provision disk space for our StorageClass, but we're going to do that manually because it's on the local filesystem
- [.volumeBindingMode](https://kubernetes.io/docs/concepts/storage/storage-classes/#volume-binding-mode) defines when volume binding and dynamic provisioning should occur

### Define a PersistentVolume
Now that our **StorageClass** is defined, we need to start using it. Next up is our first [**PersistentVolume**](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) definition.

> As we're adding things to `pihole.yaml`, make sure the definitions are delimited by `---`. These definitions can also be stored in their own separate files, though it will change our final `kubectl create` command slightly.

```yaml
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pihole-local-etc-volume
  labels:
    directory: etc
spec:
  capacity:
    storage: 1Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  storageClassName: local
  local:
    path: /path/to/volume/on/host
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - node1
```

- **.spec.metadata.name** lets us reference this volume later in our PersistentVolumeClaim.
Notice that we've used a service-location-directory-volume format. This volume is for our pi-hole /etc folder. We're going define another PersistentVolume later for dnsmasq.d
- **.spec.metadata.labels** applies labels to the PersistentVolume so that we can identify it explicitly. We'll be using this to ensure that the correct PersistentVolumeClaim attaches to this PersistentVolume.
- [.spec.capacity.storage](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#capacity) sets the amount of storage that our volume has. I have an 8Gb sd card in my Raspberry Pi, so 1Gi for this volume is a decent amount of space while still leaving room for other applications.
- [.spec.accessModes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes) defines how our volume can be accessed by PersistentVolumeClaims. We're setting up this volume to be used by only a single pi-hole service, so we're using ReadWriteOnce. You can also use RWO for shorthand.
- [.spec.persistentVolumeReclaimPolicy](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#reclaiming) defines what to do when a PersistentVolumeClaim releases its claim on the PersistentVolume. Unfortunately, there's not a great way to hang on to our data locally after shutting down our pi-hole deployment in a way that won't cause issues with the next deployment. So, we're using Delete.
- **.spec.storageClassName** specifies which StorageClass to use. We're just pasting in the name from the StorageClass we defined earlier.
- **.spec.local.path** defines where on the host filesystem to store our volume. Make sure that the directories you define here exist on your Raspberry Pi.
- **.spec.nodeAffinity.required.nodeSelectorTerms** lets us decide which node to mount the volume on. In our definition, we're ensuring that the node's hostname (defined by the built-in label kubernetes.io/hostname) matches the node we want. I've put node1 in the example because that's the hostname we used in my [previous post](/articles/k8s-on-pi).

Awesome! We now have a volume and a definition of how our host should allocate disk space to the volume.

### Define a PersistentVolumeClaim
Next up is our [PersistentVolumeClaim](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistentvolumeclaims) that our service will use to attach to that volume.

```yaml
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pihole-local-etc-claim
spec:
  storageClassName: local
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  selector:
    matchLabels:
      directory: etc
```

- **.metadata.name** lets us reference this claim later in our deployment.
Notice that we've used the same format as in the PersistentVolume. We're going to define a PersistentVolumeClaim for dnsmasq.d as well.
- **.spec.storageClassName** specifies which StorageClass to use and lets this PersistentVolumeClaim identify the PersistentVolume we defined above a a valid candidate for claiming.
- **.spec.accessModes** should be the same as our PersistentVolume as well, for the same reason as in .spec.storageClassName
- **.spec.resources.requests.storage** defines how much storage space our claim will request from available volumes and will affect which volumes are eligible for claiming. Make sure that this is equal to or less than the size of our intended PersistentVolume.
- [.spec.resources.selector.matchLabels](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#selector) ensures that this claim attaches to the correct PersistentVolume. The key:value pair defined beneath matchLabels should match the label and value for that label defined on the PersistentVolume we intend this claim to attach to.

### Define a PV and PVC for dnsmasq.d
Now we need to create a PersistentVolume and PersistentVolumeClaim for dnsmasq.d (in addition to the ones defined above for etc). Make sure that the value you use for `/path/to/volume/on/host` is different than the one used above.

```yaml
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pihole-local-dnsmasq-volume
  labels:
    directory: dnsmasq.d
spec:
  capacity:
    storage: 1Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  storageClassName: local
  local:
    path: /path/to/volume/on/host
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - node1
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pihole-local-dnsmasq-claim
spec:
  storageClassName: local
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
  selector:
    matchLabels:
      directory: dnsmasq.d
```

### Define the Deployment
Almost done! There are many ways to control how our app gets deployed. For our use case, we're going to use a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/). This specifies a desired state for our app, which kubernetes then attempts to attain.

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pihole
  labels:
    app: pihole
spec:
  replicas: 1
  selector:
    matchLabels:
      app: pihole
  template:
    metadata:
      labels:
        app: pihole
        name: pihole
    spec:
      containers:
      - name: pihole
        image: pihole/pihole:latest
        imagePullPolicy: Always
        env:
        - name: TZ
          value: "America/New_York"
        - name: WEBPASSWORD
          value: "secret"
        volumeMounts:
        - name: pihole-local-etc-volume
          mountPath: "/etc/pihole"
        - name: pihole-local-dnsmasq-volume
          mountPath: "/etc/dnsmasq.d"
      volumes:
      - name: pihole-local-etc-volume
        persistentVolumeClaim:
          claimName: pihole-local-etc-claim
      - name: pihole-local-dnsmasq-volume
        persistentVolumeClaim:
          claimName: pihole-local-dnsmasq-claim
```

- **.spec.replicas** defines how many instances of the service we should deploy. We only need one pi-hole for this tutorial.
- **.spec.selector.matchLabels.app** specifies which service to deploy.
- **.spec.template.metadata** makes it easier for us to reference this deployment later with kubectl.
- [.spec.template.spec.containers.image](https://kubernetes.io/docs/concepts/containers/images/) should be the same as the image from the docker script example at the beginning of this tutorial. We're pulling the latest pi-hole image.
- [.spec.template.spec.containers.imagePullPolicy](https://kubernetes.io/docs/concepts/containers/images/#updating-images) defines when to pull updates to the image. We're using pihole/pihole:latest, so we might as well pull every time.
- [.spec.template.spec.containers.env](https://kubernetes.io/docs/tasks/inject-data-application/define-environment-variable-container/#define-an-environment-variable-for-a-container) will let us set the timezone and a password for the pi-hole admin dashboard. Feel free to leave this section out if you'd prefer to use a randomly generated password.
- **.spec.template.spec.containers.volumeMounts** defines how our VolumeMounts attach to the container's filesystem. Make sure the .name labels match the names of our VolumeMount definitions above. The .mountPath labels should match the example (and the docker script at the beginning of the tutorial).
- **.spec.template.spec.volumes** connect our deployment to our VolumeMounts and VolumeMountClaims. Make sure that these names match those in the corresponding definitions above.

### Define a Service
The last thing we need to do is define our pi-hole [Service](https://kubernetes.io/docs/concepts/services-networking/service/). A Service allows us to expose an application running on our cluster externally over the network.

```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: pihole
spec:
  selector:
    app: pihole
  ports:
  - port: 8000
    targetPort: 80
    name: pihole-admin
  - port: 53
    targetPort: 53
    protocol: TCP
    name: dns-tcp
  - port: 53
    targetPort: 53
    protocol: UDP
    name: dns-udp
  externalIPs:
  - node1.ip.address
```

- **.spec.selector.app** defines which application this service exposes.
- [.spec.ports](https://kubernetes.io/docs/concepts/services-networking/service/#multi-port-services) defines the ports that pi-hole needs to serve DNS requests and host the admin dashboard.
- [.spec.externalIPs](https://kubernetes.io/docs/concepts/services-networking/service/#external-ips) assigns our pi-hole service to a static IP.

> For our simple use case, we're going to directly assign the Service an external IP address. This prevents us from using some of kubernetes' more useful features like load balancing and external traffic policies, but is straight forward to understand and set up.

### Time to deploy
Save the manifest and we're ready to deploy pi-hole.
Run `kubectl create -f pihole.yaml` and we're all set! If you elected to separate your definitions into their own files, you must `kubectl create` each file individually. You can use the following commands to keep an eye on your deployment and make sure everything is proceeding smoothly:

- `kubectl get all` to list all the parts of our deployed manifest
- `kubectl describe deployment pihole` to get more info on the deployment
- `kubectl describe pod pihole` to get more info on the pod itself
- `kubectl logs -f -l name=pihole` to tail the logs

When experimenting with kubernetes myself, I found [this page](https://kubernetes.io/docs/reference/kubectl/cheatsheet/) very helpful.

Now, go to `http://node1.ip.address:8000/admin`, enter the password we defined earlier (or the randomly generated one pulled from the logs), and check out the pi-hole dashboard! So long as you've directed your traffic to `node1` for DNS requests, you're now blocking ad domains.

---

### A note about our Service
As I mentioned earlier, we're using a basic Service definition with an explicitly defined external IP address. The downside to this is that all requests reflected in the pihole dashboard will be forwarded from the `kube-dns` cluster internal IP address. We still have all the data on where our requests are going, but this keeps us from understanding who's making the requests.

This will, likely, be the subject of my next article as I explore how to load balance multiple pihole instances and properly forward external traffic to them.
