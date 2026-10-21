import serial
import time

PORT = "COM5"
BAUD = 38400   # <-- cambiar esto

ser = serial.Serial(
    port=PORT,
    baudrate=BAUD,
    bytesize=serial.EIGHTBITS,
    parity=serial.PARITY_NONE,
    stopbits=serial.STOPBITS_TWO,
    timeout=1,
    write_timeout=1
)

ser.reset_input_buffer()
ser.reset_output_buffer()

a = 0x05
b = 0x05
op = 0x22

paquete = bytes([a, b, op])

print("Enviando:", paquete.hex())
ser.write(paquete)
ser.flush()

time.sleep(0.1)

# Leemos todo lo que haya, por si llega más de un byte
respuesta = ser.read(ser.in_waiting or 1)

if len(respuesta) > 0:
    print("Respuesta recibida:", respuesta.hex())
    print("Primer byte:", respuesta[0])
else:
    print("No llegó respuesta")

ser.close()