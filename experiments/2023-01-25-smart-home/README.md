# 2023-01-25 Smart Home example

## End-to-end measurements

Flow:
1. **user -> web** HTTP POST `enable_switch`
2. **web -> gateway** `enable_switch` output (AES - 2B)
3. **gateway -> light_switch** `set_switch` output (SPONGENT - 2B)
4. **light_switch -> gateway** `send_switch_state` output (SPONGENT - 2B)
5. **gateway -> web** `send_status` output (AES - 97B)

### Data

Results are in `e2e`.

- `logs-complete`: include detail measurements at each stage of the flow. RTT is
  affected by all these time measurements.
- `logs-no-sgx`: does not measure the stages on the SGX side (only RTT), there
  is a slight decrease in the RTT.
- `logs-rtt-only`: removes all measurements except the RTT, it can be noticed
  that the RTT is shorter, meaning that the measurements on the TZ side are
  time-consuming due to the `get_time` syscall.
- `logs-with-mmio`: enables the MMIO connection (`light_switch` ->
  `led_driver`), showing how it affects the RTT. This is the only experiment
  with MMIO enabled.

### Time overhead

In `logs-complete`, intermediate measurements are affected by the `get_time`
syscall, so values need to be adjusted. `overhead.json` shows the average
overhead of a `get_time` syscall in both SGX and TZ.

We computed the overhead in the following way:

```python
# SGX
sgx_num_time_calls = 5
sgx_overhead = (logs-complete-rtt - logs-no-sgx-rtt) / sgx_num_time_calls # 1.5362254545454335

# TZ
tz_num_time_calls = 10
tz_overhead = (logs-no-sgx-rtt - logs-rtt-only-rtt) / tz_num_time_calls # 12.328606363636368
```

- Crypto measurements: they all include one time syscall, so its overhead should
  be removed
- Enclave enter: it includes one system call
- Enclave exit: no time syscalls in the enclave

### MMIO overhead

Between `logs-rtt-only` and `logs-with-mmio` there are 12.35 ms difference,
which is all due to the additional connection between `light_switch` and
`led_driver`. This time also includes the MMIO time, i.e., enabling the LED in
`pmodled`.

### Step-by-step measurements

Network delay timings have been computed separately (see below).

| Stage                                      | Time (ms)      | Time (w/o overhead) (ms) |
| ------------------------------------------ | -------------- | ------------------------ |
| SGX AES encryption (2B)                    | 2.64           | 1.10                     |
| SGX enclave exit                           | 2.05           | 2.05                     |
| SGX - TZ network delay                     | 1.35           | 1.35                     |
| TZ enclave enter                           | 34.71          | 22.38                    |
| TZ AES decryption (2B)                     | 37.33          | 25.00                    |
| TZ SPONGENT encryption (2B)                | 116.31         | 103.98                   |
| TZ enclave exit                            | 11.53          | 11.53                    |
| TZ - Sancus network delay                  | 14.36          | 14.36                    |
| Sancus enclave enter                       | 0.25           | 0.25                     |
| Sancus SPONGENT decryption (2B)            | 0.17           | 0.17                     |
| Sancus LED MMIO                            | 12.35          | 12.35                    |
| Sancus SPONGENT decryption (2B)            | 0.17           | 0.17                     |
| Sancus enclave exit                        | 0.25           | 0.25                     |
| Sancus - TZ network delay                  | 14.36          | 14.36                    |
| TZ enclave enter                           | 34.71          | 22.38                    |
| TZ SPONGENT decryption (2B)                | 116.97         | 104.64                   |
| TZ AES encryption (97B)                    | 43.23          | 30.90                    |
| TZ enclave exit                            | 11.53          | 11.53                    |
| TZ - SGX network delay                     | 1.33           | 1.33                     |
| SGX enclave enter                          | 3.98           | 2.44                     |
| SGX AES decryption (97B)                   | 11.57          | 10.03                    |
| **Sum**                                    | **471.15**     | **392.55**               |
| **Measured RTT**                           | **563.59**     | **432.62**               |
| **Unmeasured stages**                      | **92.44**      | **40.07**                |

The measured RTT of the second column has been computed as: `logs-complete-rtt +
mmio-overhead`. See above for infos about the MMIO overhead.

Between 2nd and 3rd column, there is a difference of 52.37 ms on the unmeasured
stages. This can be explained by the fact that the overhead of `get_time` is not
measured in the `before_{en,de}cryption` measurements, which are 2 in SGX and 4
in TZ. Indeed, the computed unmeasured time for those syscalls is 52.39 ms,
according to:

```python
unmeasured_time_syscall_overhead = 2 * sgx_overhead + 4 * tz_overhead # 52.38687636363634
```

## Network delay

Packet format: `[<code_1B><len_2B>][<sm_id_2B><conn_id_2B>][<cipher><mac_16B>]`

- First part is the fixed header
  - `code`: type of message
  - `len`: total length of payload (subsequent fields)
- Second part is the header of the `RemoteOutput` message
  - `sm_id`: id of SM
  - `conn_id`: id of connection
- Third part is the actual payload
  - `cipher`: ciphertext. Size is `len - 20` bytes
  - `mac`: MAC. Size is 16 bytes

Total size: 23 bytes + ciphertext size. TCP/IP/MAC headers not included in the
count.

### RTT measurements

110 runs using `measure-network.py`. Payload is sent to the Event Manager, which
sends back the same exact data to the sender. Measured using the
`measure-network.py` script.

- NUC - Sancus: connected via UART with the Python bridge converting
  UART<->TCP/IP packets.
  - 2 bytes of ciphertext (total: 25 bytes): `0.026024471629749645 s`
- NUC - i.MX6: local LAN (both connected via Ethernet cables)
  - 2 bytes (total: 25 bytes): `0.002693828669461337`
  - 97 bytes (total: 120 bytes): `0.002672804485667836`

## Module update

Updated: `web`, `gateway`, `sensor`
    - only `sensor` changed node (because of limited memory)

Number of connections to re-establish:
- `web`: 4 + 1 (`init-server`)
- `gateway`: 9
- `sensor`: 2

## Macro-benchmarks

### TZ

- `optee_event_manager`
  - C/C++ files: 1448 LOC
  - binary: 17708 bytes

- `gateway`
  - module: 101 LOC
  - stub code: 1432 LOC
  - binary: 113956 bytes

### SGX

- EM: same as before

- `web`
  - module: 372 LOC
  - stub code: 3412
    - 597 rust-sgx-gen
    - 600 rust-sgx-libs
    - 1577 rust-sgx-remote-attestation
    - 638 spongent-cpp-rs (both Rust and C code)
  - binary: 4418176 bytes

### Sancus

- EM and stub code same as before

- `thermostat`
  - module: 10 LOC
  - binary: 9001 bytes

- `temp_sensor`
  - module: 21 LOC
  - binary: 9423 bytes

- `light_switch`
  - module: 10 LOC
  - binary: 9079 bytes