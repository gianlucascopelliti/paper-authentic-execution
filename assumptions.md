# Assumptions

## HW
- the execution infrastructure offers specific security primitives – standard enclaves plus support for secure I/O (1.3)
- we assume the underlying architecture is a TEE (3.1)
- TEE provides authenticated encryption primitive (3.1)
- the infrastructure offers physical input and output channels using protected driver modules that translate application events into physical events and vice versa (3.4)		
- Our scheme assumes that each TrustZone device is equipped with a Hardware Unique Key (HUK) (4.3.4)

## Attacker model (2.3)
- attackers that can manipulate all the software on the nodes, including OS, can deploy their own applications on the infrastructure 
- can also control the communication network that nodes use to communicate with each other. Attackers can sniff the network, modify traffic, or mount man-in-the-middle attacks. With respect to the cryptographic capabilities of the attacker, we follow the Dolev-Yao model
- the attacker does not have physical access to the nodes
- neither can they physically tamper with I/O devices. 
- We also do not consider side-channel attacks against our implementation.

## SW
- both a module’s code and data are located in contiguous memory areas called, respectively, its code section and its data section. (3.1)
- correct compiler (measured binaries implement expected source code functionality) (3.1)

## Infrastructure and credentials
- the deployer’s computing infrastructure is assumed to be trusted (2.4)
- connection keys are known only by the modules and their deployer (7.2) (and are always kept in secure memory and transmitted over encrypted channels)
- driver modules are part of the trusted infrastructure (3.4)
- driver module keys are only known to the infrastructure provider (3.4)



Requirements

## Drivers, I/O (3.4)
- R1: the infrastructure provider configures the physical I/O devices as expected, i.e., that the desired peripherals are connected to the right pins and thus mapped to the correct Memory-Mapped I/O (MMIO) addresses in the node.
- R2: the infrastructure must provide a way for the deployer of M_A to attest that it has exclusive access to the driver module M_D and that M_D also has exclusive access to its I/O device D. The deployer must be able to attest M_D to ensure that it indeed only accepts events from the module currently having exclusive access and that it does not release this exclusive access without being asked to do so by the module itself.
- R3: as soon as a microcontroller is turned on, driver modules take exclusive access to their I/O devices and never release it.
- R4: no outputs are produced by output driver modules unless requested by the application module
- R4: input driver modules do not generate outputs to application modules that do not correspond to physical inputs (initialization caveat)

## Deployment (3.5)
- R5: The channel between deployer and infrastructure provider is assumed to be secure
- R6: Before granting such access, the infrastructure provider needs to ensure the authenticity of the driver module controlling the I/O device, e.g., via attestation
- R7: It is assumed that the provider does not leak the driver module keys and that exclusive access to a device is reserved for the deployer until they request to release it or a time T has passed (to which both the deployer and the provider have agreed upon)
- R8: the infrastructure must provide a replay protection for configuration messages sent by the infrastructure provider to the drivers


