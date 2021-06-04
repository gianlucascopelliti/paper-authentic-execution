import sys
import socket
import time
import struct

PORT = int(sys.argv[1])
PAYLOAD_SIZE = int(sys.argv[2])
HOST = sys.argv[3] if len(sys.argv) > 3 else "localhost"

ITERATIONS = 110

CODE = 10 # ping
HEADER_SIZE = 4
MAC_SIZE = 16

payload = \
    struct.pack("!B", CODE) + \
    struct.pack("!H", HEADER_SIZE + PAYLOAD_SIZE + MAC_SIZE) + \
    b"\x00" * HEADER_SIZE + \
    b"\x00" * PAYLOAD_SIZE + \
    b"\x00" * MAC_SIZE

print(f"len: {len(payload)} pl: {payload}")

total_time = 0

for i in range(ITERATIONS):
    recv_len = 0
    print(f"Iteration {i + 1}")

    s = socket.socket()
    s.connect((HOST, PORT))

    start = time.time()
    s.send(payload)

    while recv_len != len(payload):
        recv_len += len(s.recv(1024))

    end = time.time()

    #print(f"Received {recv_len} bytes")
    assert recv_len == len(payload)

    total_time += end - start

    s.close()
    time.sleep(0.5)

print(f"AVG RTT: {total_time / ITERATIONS}")