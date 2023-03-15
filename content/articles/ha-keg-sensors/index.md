---
date: 2023-03-13T10:33:58-04:00
title: "High-Availability Keg Sensors"
draft: true
---
The kegerator has a new gas line and we're ready to get started installing some sensors. The goal with these sensors is to keep track of how much seltzer I've got left and how long it takes the fridge to cool down kegs that have been refilled with room-temperature water.

[https://github.com/subtlepseudonym/kegerator](https://github.com/subtlepseudonym/kegerator)

## Hardware
- raspberry pi zero w
- micro-usb to AC power cable
- small command strips
- 2 flow sensors (digiten or uxcell)
- 2 dht22 sensors
- wire & female dupont connectors
- heatshrink
- soldering iron
- something to write software on

## Installation
[draft]
Installing the raspberry pi and dht22 modules is as simple as sticking each to a command strip, tacking that to the inside wall of the kegerator, and running some wire between the two. The flow meter installations are a bit trickier; they need to be run in-line with the beverage hoses.

![raspberry pi attached to inner fridge wall with a command strip](raspi.jpg)

Considering the effort involved, it's worth testing the flow meters to ensure that they work and are mostly accurate. I have a few shorter lengths of beverage line I hang on to for things like this. For testing, I connect the short hoses to the flow meter, wire it into the raspberry pi with some jumper wires, and run a known quantity of water through it. Afterwards, the total reading can be compared to that known quantity to get a sense of the accuracy. The precision doesn't have to be particularly high for this process because we only need to be accurate enough to ensure that the flow sensor isn't a dud. Assuming roughly accurate results, it's good to install.

![flow meter and attached hose testing flow rate under the faucet](flow-meter-test.jpg)

Fitting a 1/4" barb into a 3/16" ID hose is easiest if you heat up the hose first. The most convenient method I've found is dipping the end of the hose into some hot water for 30 seconds or so. For a short while afterwards, the line is pliable enough that the 1/4" barb can be inserted without too much effort, forming a really tight seal. In my case, the seal was tight enough that I didn't need to use worm clamps.

## Lots of ad-hoc testing
[draft]
There are simpler solutions for POC / testing code than [what I wrote](https://github.com/subtlepseudonym/kegerator/blob/e2c3f547e3ddf006f38abbbf9283e73fb687bcbb/main.go), but I had a more feature-rich service in mind from the start, and this served as a starting point for that future state. Once the flow meters were installed in the kegerator, I used this code to fine-tune the flow constant by dispensing known quantities of water and comparing that to the measured value. For this process, I measured the flow rate of still water, which was a definite source of error when later measuring the flow rate of carbonated water.

> The uxcell and digiten sensors use different flow constants and therefore have different sensitivities. The digiten sensor is, after calibration, roughly twice as sensitive as the uxcell sensor. That said, at about 0.3 and 0.6mL/pulse respectively, both are far more precise than necessary for this application.

## Updating the software
[draft]
The proof-of-concept code is great for testing flow sensors, but leaves a lot to be desired in terms of accomplishing the goal of monitoring the kegerator. I run [prometheus]() and [grafana]() instances on my network, so the simplest way to get state information from the raspberry pi into a human-readable form is by publishing prometheus metrics and setting up a grafana dashboard. Along with some concerns around tuning flow constants and refilling kegs without restarting the program, I assembled a short list of design goals:
- Load any mutable state from a config file
- Maintain that state in memory so we can query it
- Publish state periodically for prometheus

Those goals precipitated the following data structures:
```golang
// KegState is the exported representation of a keg and its flow meter
type KegState struct {
	Keg struct {
		Type   string  // "corny", "sixtel", etc
		Volume float64 // in liters
	}
	Sensor struct {
		Model        string  // "fl-s401a", "ux0151", etc
		FlowConstant float64 // in 1/(liters*seconds)
	}

	Contents string  // "seltzer", "jai alai", etc
	Pin      int     // gpio pin number
	Poured   float64 // in liters
}

// DHTState is the exported representation of a temperature / humidity sensor
type DHTState struct {
	Model       string  // "dht22"
	Pin         int     // gpio pin number
	Temperature float32 // in degrees centigrade
	Humidity    float32 // in percent
}
```

These structures are the representations of the flow meters and temperature / humidity sensors as they are read from the config file and as they're exported on the `/state` HTTP endpoint. The internal representations are a bit more complex in order to handle concurrent updates, live config reloads, and store information on discrete pours. That last feature actually comprises a significant portion of the flow meter update logic (and most of the bugs) despite being an unplanned feature that I just thought was neat. If you're curious, the discrete pour logic can be [found here](https://github.com/subtlepseudonym/kegerator/blob/00210a010fde41f6788851a82bf36740a3f93ae8/flow.go#L203).

Now that the POC shows the sensors working (reasonably) accurately, time to make the service more useful.
Aside about using raspberry pi, making software updates really easy compared to an ESP32 or similar.
Adding http endpoints for sensor state, prometheus metrics, and pours (cool extra feature).

## Displaying in grafana
[draft]
what information I'm displaying in grafana

![screenshot of kegerator data in grafana](grafana.jpg)

## Mistakes and experiments
[draft]
During the course of this project, plenty of different approaches were explored and mistakes were made. Here are a few of the more interesting examples.

### Flow rate problems
The digiten flows poorly (compared to no flow meter) and the uxcell flows _really_ poorly. Something like 4L/min without a sensor down to 1.2 or 1L/min with a sensor. Looked at using a gredia 3/8" thread (due to larger internal aperture) by jury-rigging a 3/8" thread to 1/4" barb adapter. Sensor is BSPT thread, adapter is NPT, with predictable results, leaking everywhere at seltzer pressure (~25psi). Fixed by drilling out the sensor itself, flow rate is fixed, but sensor is less sensitive

### Running in docker?
I'm a big fan of writing with the intention to run in docker; it's portable and makes any assumptions about the running of the code explicit. Unfortunately, docker is very slow running on the pi and, for a reason I haven't figured out, doesn't close the gpio pin connections. Not using the pins for anything else, so mostly just annoying, but not great for "shipping" this project.
`echo ${pin_num} >> /sys/class/gpio${pin_num}`
Settling for `useradd keg` and `sudo su keg && nohup kegerator >> keg.log &`

### Bad calibration
Calibrating the uxcell with still water turns out to have been a bad idea. When the keg was kicked, had measured ~21.369L dispensed, which is unlikely for a 18.93L keg (err rate of ~12.9%). Not a great err rate measurement considering both myself and Jenny ran CO2 through it on the "last" pour, which flows _really_ fast. Haven't actually fixed this yet, but won't be able to until the next keg is kicked due to replacing the uxcell flow meter.

### Signal leakage
The uxcell is putting off enough RF that the digiten is picking it up and recording phantom pours. Unsure if this is the uxcell poorly regulating voltage (and just dumping modulated 5V pulses into the signal cable) or if it's a result of using a longer wire for the uxcell. Testing this by installing a digiten (which has greater accuracy anyway). Initial testing, without installing digiten in-line, seem positive. No signal leakage from a few pours and wires of roughly the same length.
