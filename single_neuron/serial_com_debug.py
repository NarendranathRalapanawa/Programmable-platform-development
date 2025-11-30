import serial
import time
import struct

PORT = "/dev/ttyUSB1"
BAUD = 115200
SCALE = 1024.0  # Q5.10 fixed point

def float_to_q10(x):
    """Convert Python float -> signed 16-bit Q5.10 int."""
    val = int(round(x * SCALE))
    if val < -32768:
        val = -32768
    if val > 32767:
        val = 32767
    return val & 0xFFFF

def q10_to_float(v):
    """Convert signed 16-bit Q5.10 int -> float."""
    # interpret v as signed 16-bit
    if v & 0x8000:
        v = v - 0x10000
    return v / SCALE

def send_and_receive(ser, x0, x1):
    # convert to fixed-point
    x0_q = float_to_q10(x0)
    x1_q = float_to_q10(x1)

    # little-endian: L byte first, then H
    x0_L = x0_q & 0xFF
    x0_H = (x0_q >> 8) & 0xFF
    x1_L = x1_q & 0xFF
    x1_H = (x1_q >> 8) & 0xFF

    pkt = bytes([0x55, x0_L, x0_H, x1_L, x1_H])
    print(f"Sending: {pkt.hex()}")

    for attempt in range(3):
        print(f"  Attempt {attempt+1}...")
        # flush any old data
        ser.reset_input_buffer()
        ser.reset_output_buffer()

        # send packet
        ser.write(pkt)
        ser.flush()

        # wait a bit for FPGA to process and respond
        time.sleep(0.2)

        # expect header 0xAA + 2 bytes of y
        resp = ser.read(3)
        print("  Raw response:", resp, "len =", len(resp))

        if len(resp) >= 2 and resp[0] == 0xAA:
            if len(resp) == 2:
                # some earlier tests only sent 2 bytes: [AA, y_L]
                y_L = resp[1]
                y_H = 0x00
            else:
                y_L = resp[1]
                y_H = resp[2]

            y_raw = (y_H << 8) | y_L
            y = q10_to_float(y_raw)
            print(f"  y_raw = 0x{y_raw:04X}, y = {y}")
            return y

        print("  No valid response this attempt.")

    print("Failed to get valid response after 3 attempts.")
    return None

def main():
    # open port
    ser = serial.Serial(PORT, BAUD, timeout=2.0)
    print(f"Opened {PORT}")

    try:
        while True:
            # read user inputs
            x0_str = input("x0 = ")
            x1_str = input("x1 = ")
            try:
                x0 = float(x0_str)
                x1 = float(x1_str)
            except ValueError:
                print("Please enter numeric values.")
                continue

            y = send_and_receive(ser, x0, x1)
            print("----------------------------------------")
    finally:
        ser.close()
        print("Port closed.")

if __name__ == "__main__":
    main()
