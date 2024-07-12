import machine
import time

stepPeriodMs = 2000
ioMap = [21, 19, 18, 5, 17, 16, 4]
pins = list(map(lambda io: machine.Pin(io, machine.Pin.OUT), ioMap))
statusLED = machine.Pin(2, machine.Pin.OUT)

# Pattern from https://github.com/PubInv/ferrofluid-pump/blob/main/doc/FerrofluidPump.pdf
cyclesPattern = [ [0, 0, 1, 0, 0, 1, 1],
                  [0, 1, 0, 0, 1, 1, 0],
                  [1, 0, 0, 1, 1, 0, 0],
                  [1, 0, 0, 1, 0, 0, 1] ]

while True:
    for i in range(len(cyclesPattern)):
        for j in range(len(cyclesPattern[i])):
            pins[j].value(cyclesPattern[i][j])
        print('Step ' + str(i + 1))
        statusLED.value(i % 2)

        time.sleep_ms(stepPeriodMs)
