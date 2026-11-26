import serial
import time

PORT = "/dev/ttyUSB1"
BAUD = 38400

SUM_CODE = 0X20
SUB_CODE = 0X22
AND_CODE = 0X24
OR_CODE  = 0X25
XOR_CODE = 0X26
SRA_CODE = 0X03
SRL_CODE = 0X02
NOR_CODE = 0X27

try:
    ser = serial.Serial(
        port=PORT,
        baudrate=BAUD,
        bytesize=serial.EIGHTBITS,
        parity=serial.PARITY_NONE,
        stopbits=serial.STOPBITS_TWO,
        timeout=1,
        write_timeout=5,
        rtscts=False,
        dsrdtr=False,
        xonxoff=False
    )

    print("Puerto abierto correctamente")

    ser.reset_input_buffer()
    ser.reset_output_buffer()

    print("DTR:", ser.dtr)
    print("RTS:", ser.rts)
    print("CTS:", ser.cts)
    print("DSR:", ser.dsr)
    print("CD:", ser.cd)
    print("RI:", ser.ri)

    operaciones = [
        (0x05, 0xfd, SUM_CODE),     # resultado = 10  0a
        (0x05, 0x03, SUB_CODE),     # resultado = 2   02
        (0x01, 0x03, AND_CODE),     # resultado = 1   01
        (0x01, 0x02, OR_CODE),      # resultado = 3   03
        (0x06, 0x05, XOR_CODE),     # resultado = 3   03
        (0x05, 0x01, SRA_CODE),     # resultado = 2   02
        (0x05, 0x01, SRL_CODE),     # resultado = 2   02
        (0xf4, 0xf2, NOR_CODE),      # resultado = 9

        # prueba de shift con signo negativo
        (0xfd, 0x03, SRA_CODE),      # resultado = ff
        (0xfd, 0x03, SRL_CODE)      # resultado = 1f
    ]

    

    for i, (a, b, op) in enumerate(operaciones, start=1):
        print(f"--- Operacion {i} ---")

        paquete = bytes([a, b, op])
        print("Enviando:", paquete.hex())

        n = ser.write(paquete)
        print("Bytes escritos:", n)

  

        time.sleep(0.1)

        respuesta = ser.read(ser.in_waiting or 1)

        if len(respuesta) > 0:
            print("Respuesta recibida:", respuesta.hex())
            print("Primer byte:", respuesta[0])
        else:
            print("No llegó respuesta")

    ser.close()

except serial.SerialTimeoutException as e:
    print("Timeout de escritura:", e)
    print("El puerto quedó esperando alguna señal de handshake/flow control, o el driver está bloqueando la escritura.")

except serial.SerialException as e:
    print("Error serial:", e)