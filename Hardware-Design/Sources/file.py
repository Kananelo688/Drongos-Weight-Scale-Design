import serial

# Configure the serial connections
# Replace 'COM3' with your Arduino's serial port
ser = serial.Serial('/dev/ttyUSB0', 115200);

# Open or create a file for appending
with open('output.txt', 'a') as f:
    while True:
        try:
            # Read a line from the serial port
            line = ser.readline().decode('utf-8').strip()
            print(line)  # Print it to the console
            f.write(line + '\n')  # Write to the file
        except KeyboardInterrupt:
            print("Interrupted by user")
            break
        except Exception as e:
            print("Error occurred: {}".format(e))
            break

# Close the serial connection
ser.close()
