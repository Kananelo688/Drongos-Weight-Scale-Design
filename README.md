# Drongos-Weight-Scale-Design

## Overview
This project aims to streamline the process of measuring and analyzing bird weights in the field. The system comprises a scale, a microcontroller for data acquisition, and a mobile application for real-time data viewing and interaction. The subsystems work together to provide a seamless and efficient solution for ornithological research.

## Subsystems

### 1. Scale Device
The scale device is designed to accurately measure the weight of birds. It includes:
- **Weight Sensor**: Measures the mass of the bird.
- **Microcontroller (ESP32)**: Captures weight data from the sensor and facilitates wireless communication.

### 2. Wireless Communication
The wireless communication subsystem ensures efficient data transfer between the scale device and the mobile application. It includes:
- **Bluetooth Low Energy (BLE)**: Used for sending short bursts of data and operational commands (e.g., resetting the scale).
- **Wi-Fi**: Facilitates the transmission of real-time weight data over longer distances.

### 3. Mobile Application
The mobile application provides an intuitive interface for interacting with the scale and viewing collected data. Key features include:
- **Real-time Data Display**: Shows the weight measurements in real-time.
- **Data Logging**: Records and stores weight data for future analysis.
- **User Interaction**: Allows users to zero the scale, download data, and associate weights with bird identities.

### 4. User Interface
The user interface is designed to be user-friendly and accessible, ensuring ease of use without requiring extensive training. It includes:
- **Home Screen**: Central hub for navigating to different functionalities.
- **Scale Screen**: Interface for interacting with the scale and viewing weight data.
- **Data Screen**: Displays logged weight data along with bird identities and timestamps.
- **Tracking Screen**: Provides location data associated with each weight measurement.

### 5. Data Management
The data management subsystem handles the storage, retrieval, and organization of the collected data. Features include:
- **Data Storage**: Saves data locally on the mobile device.
- **Data Search and Filter**: Allows users to search and filter data based on various criteria.
- **Data Export**: Facilitates the export of data for further analysis.

### 6. Prototyping and Development Tools
The development of the user interface and mobile application was streamlined using various tools and frameworks:
- **Figma**: Used for designing high-fidelity prototypes of the mobile application.
- **Flutter**: Chosen for developing the mobile application due to its cross-platform capabilities.
- **Visual Studio Code**: Integrated development environment (IDE) used for coding and debugging.

## Getting Started
To get started with the Bird Weight Monitoring System, follow these steps:

1. **Clone the repository**:
    ```bash
    git clone https://github.com/yourusername/bird-weight-monitoring-system.git
    ```

2. **Set up the mobile application**:
    - Ensure you have Flutter installed.
    - Navigate to the mobile app directory:
        ```bash
        cd user-interface/drongo_app
        ```
    - Install dependencies:
        ```bash
        flutter pub get
        ```
    - Run the app:
        ```bash
        flutter run
        ```

3. **Set up the microcontroller**:
    - Flash the ESP32 microcontroller with the provided firmware.
    - Ensure the scale device is properly connected to the microcontroller.

4. **Pair the mobile app with the scale**:
    - Open the mobile app and follow the instructions to connect to the scale via BLE.
    - Start collecting and viewing real-time data.

## Contributions
Contributions to the project are welcome. Please fork the repository and submit a pull request with your changes.

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
