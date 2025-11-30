import serial
import struct
import time
import math

PORT = "/dev/ttyUSB1"
BAUD = 115200
TIMEOUT = 0.5       # seconds
SCALE = 1024.0      # Q6.10 -> divide by 1024

def float_to_q10(x: float) -> int:
    """Convert Python float to signed Q6.10 16-bit int."""
    n = int(round(x * SCALE))
    if n < -32768:
        n = -32768
    if n > 32767:
        n = 32767
    return n

def read_reply(ser: serial.Serial, max_wait_header=1.0) -> int | None:
    """
    Read one reply frame from FPGA.

    Current FPGA behaviour (from sim + real):
      - Sends 2 bytes: 0xAA (header), then y_low
      - y_high is effectively 0 (we'll assume that)

    This function:
      1) Waits for header 0xAA
      2) Then tries to read up to 2 bytes
         - len == 0 -> fail
         - len == 1 -> y_low = that byte, y_high = 0
         - len >= 2 -> y_low = first, y_high = second
    Returns signed 16-bit y_raw, or None on failure.
    """
    start = time.time()

    # --- step 1: hunt for header 0xAA ---
    while True:
        b = ser.read(1)
        if b:
            if b[0] == 0xAA:
                # header found
                break
            else:
                # stray byte, ignore
                continue
        # no byte, check timeout for header
        if time.time() - start > max_wait_header:
            return None

    # --- step 2: get the payload bytes ---
    payload = ser.read(2)   # may get 0, 1, or 2 bytes
    if len(payload) == 0:
        return None
    elif len(payload) == 1:
        y_l = payload[0]
        y_h = 0
    else:
        y_l = payload[0]
        y_h = payload[1]

    y_raw = (y_h << 8) | y_l
    # sign-extend 16-bit
    if y_raw & 0x8000:
        y_raw -= 0x10000
    return y_raw

def main():
    with serial.Serial(PORT, BAUD, timeout=TIMEOUT) as ser:
        print(f"Opened {PORT} at {BAUD} baud")

        while True:
            try:
                line = input("Enter x0 and x1 (e.g. 0.5 -0.5) or 'q' to quit: ").strip()
            except (EOFError, KeyboardInterrupt):
                print("\nExiting.")
                break

            if not line:
                continue
            if line.lower() in ("q", "quit", "exit"):
                break

            parts = line.split()
            if len(parts) != 2:
                print("Please enter exactly two numbers like: 0.5 -0.5")
                continue

            try:
                x0 = float(parts[0])
                x1 = float(parts[1])
            except ValueError:
                print("Could not parse numbers, try again.")
                continue

            n0 = float_to_q10(x0)
            n1 = float_to_q10(x1)

            print(f"\n[x0, x1] = [{x0}, {x1}]")
            print(f" fixed-point: n0 = {n0} (0x{n0 & 0xFFFF:04x}), "
                  f"n1 = {n1} (0x{n1 & 0xFFFF:04x})")

            # Packet: 0x55, x0_L, x0_H, x1_L, x1_H
            pkt = struct.pack("<Bhh", 0x55, n0, n1)
            print("Sending:", pkt.hex())

            # clear any old bytes
            ser.reset_input_buffer()

            ser.write(pkt)
            ser.flush()

            y_raw = read_reply(ser)
            if y_raw is None:
                print("  No valid frame received from FPGA.")
            else:
                y = y_raw / SCALE
                print(f"  FPGA: y_raw = 0x{(y_raw & 0xFFFF):04x}, y = {y}")

            print("-" * 40)

if __name__ == "__main__":
    main()
