import serial, pyttsx3, time

PORTA_SERIAL = 'COM12'
BAUD_RATE = 9600
BYTESIZE = 7
STOPBITS = 2


try:
    ser = serial.Serial(PORTA_SERIAL, BAUD_RATE, bytesize=BYTESIZE, stopbits=STOPBITS)
    print(f"Conectado {PORTA_SERIAL}")

    restante = bytearray()
    contador = 0
    while True:
        if ser.in_waiting > 0:
            print("in_waiting:", ser.in_waiting)
            dados = ser.read(1)
            
            if contador != 0 and restante:
                dados = restante + dados
                restante = bytearray()

            if b'\x00' in dados:
                parts = dados.split(b'\x00')
                palavra = parts[0].decode('ascii', errors='replace').strip()
                restante = bytearray(b'\x00'.join(parts[1:]))  # se extra após terminador
                if palavra:
                    print(f"[FPGA] Palavra: {palavra}")
                    engine = pyttsx3.init()
                    engine.setProperty('rate', 150)
                    engine.setProperty('volume', 100.0)
                    engine.say(f"A palavra escolhida é: {palavra}")
                    engine.runAndWait()
                    del engine
            else:
                if ser.in_waiting == 0:
                    contador = 0
                    parts = dados.split(b'\x00')
                    letra = parts[0].decode('ascii', errors='replace').strip()
                    restante = bytearray(b'\x00'.join(parts[1:]))  # se extra após terminador
                    if letra:
                        print(f"[FPGA] Letra: {letra}")
                        engine = pyttsx3.init()
                        engine.setProperty('rate', 150)
                        engine.setProperty('volume', 100.0)
                        engine.say(f"A letra escolhida é: {letra}")
                        engine.runAndWait()
                        del engine
                # guarda a porção não finalizada
                restante = bytearray(dados)
                contador += 1
            if ser.in_waiting == 0:
                contador = 0
        time.sleep(0.01)

except KeyboardInterrupt:
    print("Fim")
finally:
    if 'ser' in locals() and ser.is_open:
        ser.close()