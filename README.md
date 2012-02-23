# Apple Airport Client Info

A simple Ruby script that uses SNMP to query an Apple Airport wireless access point for information regarding an attached client.

This script is being used obtain data for graphing the signal strength, noise and signal to noise ratios (SNR) for "permanent" wireless clients.

### Usage

All three parameters are required - the Apple Airport device you're connecting to, the SNMP community string and the MAC address of the wireless client you're investigating.

    $ ruby apple_airport_client_info.rb --help
    USAGE: ruby apple_airport_client_info.rb -x <host> -c <community> -m <mac>

    -x, --host           Apple Airport device IP or host name.
    -c, --community      SNMP community (password).
    -m, --mac            MAC address of the associated wireless device.
    -h, --help           Display this help message.

### Sample Data

    $ ruby apple_airport_client_info.rb -x 10.0.10.2 -c public -m 04:0C:CE:E3:F3:39
    strength:-69 noise:-87 snr:18

### Cacti Integration

Coming soon!

### Contributors

* Matt Lambie <[@mlambie](http://twitter.com/mlambie)>