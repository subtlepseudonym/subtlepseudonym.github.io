---
date: 2021-02-14
title: "Creating a Prometheus Exporter for Pihole"
draft: false
---
{{< image src="blacksmith.jpg" alt="header image" >}}
Taken by [Kenny Luo](https://web.archive.org/web/20220819181420/http://kennyluo.com/)
{{< /image >}}

### First, some introduction
<!-- summary -->
Pihole is a self-hosted DNS forwarder and filter for blocking ad domains. I run pihole on my network and have found it to be great fodder for testing devops / SRE concepts. Previously, I took a stab at [running pihole on kubernetes](/articles/pihole-on-k8s). Since then, I've started running [prometheus](https://prometheus.io/) and [grafana](https://grafana.com/) to collect and display metrics. What better way to play with those platforms than with metrics from pihole!
<!-- summary -->

This isn't a recipe blog, so if you care more about the code than my motivations, you can find it here: [subtlepseudonym/pihole-exporter](https://github.com/subtlepseudonym/pihole-exporter)

### Why a new exporter?
As the DNS server for the majority of my local network, pihole generates a whole collection of interesting metrics on my internet usage. Several prometheus exporters already exist, but all the exporters I turned up simply exported the metrics exposed by the pihole API. Unfortunately, those metrics are not as flexible as I'd like.

> It's worth noting that the official prometheus docs [previously recommended](https://github.com/prometheus-net/prometheus-net/issues/63#issuecomment-360070401) exporting an API's data in an unopinionated way, but now contain a [discussion on maintainability vs purity](https://prometheus.io/docs/instrumenting/writing_exporters/#maintainability-and-purity) instead.

My primary issue with the pihole API is that many metrics are already aggregated. A few examples are displayed in the top half of the screencap below. They represent a rolling aggregate of the last 23 full hours plus the time that has elapsed since the last turn of the hour. This makes it impossible to accurately answer questions like "How many queries were served in the last fifteen minutes?" or "What percentage of queries were blocked last month?".

Similarly, the total queries by percent blocked and total queries by client, pictured in the lower half of the screencap, are bucketed into 10 minute segments. In much the same way, this limits our ability to ask questions about the data.

> You can get a clearer idea of what I'm talking about by calling the API from your own pihole instance here:
>
> `http://your.pihole.address/admin/api.php?summaryRaw`
>
> There are additional query parameter options [documented here](https://discourse.pi-hole.net/t/pi-hole-api/1863)

{{< image src="pihole-dashboard.webp" alt="screenshot of the pihole dashboard" >}}
Most days, ~20% of my traffic is ads
{{< /image >}}

### Straight to the source!

We have access to more granular data in the form of individual DNS query information in the FTL database. There are a few tradeoffs we're making by retrieving metrics data directly from the database rather than through the API.

The first thing to consider is the new (expanded) scope of the data we have access to. The database maintains [the last 365 days](https://docs.pi-hole.net/ftldns/configfile/#maxdbdays) of DNS request data by default and retrieving a year's worth of data, in the worst case, isn't a fast operation. This is particularly true if you're running on a single-board computer like a raspberry pi. My initial thought was to spread this long querying time out over several prometheus scrape intervals, but this would pollute the prometheus dataset when I restarted the exporter. On restart, prometheus would scrape counters that were lower than expected and [identify them as resets](https://www.robustperception.io/how-does-a-prometheus-counter-work). This added _huge_ values to my counters on start up, mistakenly attributing all my historical data to _just today_. This meant that I, unfortunately, was better off accepting that the exporter has to wait on a lengthy query on startup. That said, "lengthy" in this case is really only 10–20 seconds, which isn't too bad if you're using the default prometheus scrape interval of 15 seconds.

Another drawback to this approach is the additional complexity of deploying our exporter in a containerized environment. For docker, this is reasonably straight-forward. The exporter needs to have read access to the pihole's FTL database file. Accessing the file can be achieved, on the same host as the pihole container, by attaching the file as a volume to the exporter's container. For example:

```bash
docker create \
  --volume "/path/to/pihole-FTL.db:/pihole/pihole-FTL.db:ro" \
  subtlepseudonym/pihole-exporter:latest
```

Sharing the database between containers gets a bit hairier with kubernetes and I have yet to implement myself. If I do, I'll update this article with the details. In the meantime, I suspect it'll involve a `PersistantVolume` with a `ReadWriteMany` access mode and two distinct `PersistantVolumeClaim` definitions, one with `ReadWriteMany` and another with `ReadOnlyMany`.

### Running the exporter

Design-wise the exporter is fairly simple: It queries the database and exposes the metrics retrieved via the `/metrics` endpoint for prometheus to scrape. When a request is received at the endpoint, the exporter returns the metrics it's got in memory, queries the database, stores those metrics in memory, and waits for the next request. As a result, the deploy process is also fairly simple. The following command will get us up and running with an exporter container:

```bash
docker create \
  --name pihole-exporter \
  --env PIHOLE_DSN="file:/pihole/pihole-FTL.db?_query_only" \
  --volume "/path/to/pihole-FTL.db:/pihole/pihole-FTL.db:ro" \
  --dns 172.17.01 \
  subtlepseudonym/pihole-exporter:latest
```

The `PIHOLE_DSN` variable above is the SQLite DSN for the FTL database file we've attached to our container.
For the `--dns` flag, I've made the assumption that we're using the same docker engine to run both our pihole and exporter containers. The value in the example is the default docker bridge gateway.

### DockerHub

As of publishing this article, you can now pull my exporter down from DockerHub using `docker pull subtlepseudonym/pihole-exporter:latest`
