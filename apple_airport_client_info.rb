#!/usr/bin/env ruby
require 'rubygems'
require 'snmp'
require 'slop'
require 'pp'

=begin
Sample data returned by snmpwalk, with added explainations
.1.3.6.1.4.1.63.501.3.2.2.1.1.17.48.52.58.48.67.58.67.69.58.69.51.58.70.51.58.51.56 = STRING: "04:0C:CE:E3:F3:38"
.1.3.6.1.4.1.63.501.3.2.2.1.2.17.48.52.58.48.67.58.67.69.58.69.51.58.70.51.58.51.56 = INTEGER: 1
.1.3.6.1.4.1.63.501.3.2.2.1.3.17.48.52.58.48.67.58.67.69.58.69.51.58.70.51.58.51.56 = STRING: "6(b) 9 12(b) 18 24(b) 36 48 54 MCS: 0-23" (DATE RATES)
.1.3.6.1.4.1.63.501.3.2.2.1.4.17.48.52.58.48.67.58.67.69.58.69.51.58.70.51.58.51.56 = INTEGER: 1614145 (TIME ASSOCIATED)
.1.3.6.1.4.1.63.501.3.2.2.1.5.17.48.52.58.48.67.58.67.69.58.69.51.58.70.51.58.51.56 = INTEGER: 0 (LAST REFRESH TIME)
.1.3.6.1.4.1.63.501.3.2.2.1.6.17.48.52.58.48.67.58.67.69.58.69.51.58.70.51.58.51.56 = INTEGER: -66 (STRENGTH)
.1.3.6.1.4.1.63.501.3.2.2.1.7.17.48.52.58.48.67.58.67.69.58.69.51.58.70.51.58.51.56 = INTEGER: -87 (NOISE)
.1.3.6.1.4.1.63.501.3.2.2.1.8.17.48.52.58.48.67.58.67.69.58.69.51.58.70.51.58.51.56 = INTEGER: 216 (RATES)
.1.3.6.1.4.1.63.501.3.2.2.1.9.17.48.52.58.48.67.58.67.69.58.69.51.58.70.51.58.51.56 = INTEGER: 31570615 (# RECEIVED)
.1.3.6.1.4.1.63.501.3.2.2.1.10.17.48.52.58.48.67.58.67.69.58.69.51.58.70.51.58.51.56 = INTEGER: 23803609 (# TRANSMITTED)
.1.3.6.1.4.1.63.501.3.2.2.1.11.17.48.52.58.48.67.58.67.69.58.69.51.58.70.51.58.51.56 = INTEGER: 113 (# RECEIVE ERRORS)
.1.3.6.1.4.1.63.501.3.2.2.1.12.17.48.52.58.48.67.58.67.69.58.69.51.58.70.51.58.51.56 = INTEGER: 5276 (# TRANSMITTED ERRORS)
=end

AIRPORT = '1.3.6.1.4.1.63.501.3.2.2.1.'

def cacti_format(strength, noise)
  snr = strength - noise
  puts "strength:#{strength} noise:#{noise} snr:#{snr}"
end

def die(message)
  puts "ERROR: #{message}\n\n"
  puts @opts.help
  exit 1
end

@opts = Slop.parse(:help => true) do
  banner "USAGE: ruby #{File.basename(__FILE__)} -x <host> -c <community> -m <mac>\n"
  on '-x', '--host=', 'Apple Airport device IP or host name.', true
  on '-c', '--community=', 'SNMP community (password).', true
  on '-m', '--mac=', 'MAC address of the associated wireless device.', true
end

exit 0 if @opts.help?
die "Missing host option." if (not @opts.present?(:host))
die "Missing community option." if @opts[:community].nil?
die "Missing MAC address option." if @opts[:mac].nil?


dotted = ''
@opts[:mac].each_byte {|b| dotted << "#{b.to_i}."}

begin
  SNMP::Manager.open(:host => @opts[:host], :community => @opts[:community]) do |manager|
    begin
      strength = manager.get_value(AIRPORT + '6.17.' + dotted).to_i
      noise    = manager.get_value(AIRPORT + '7.17.' + dotted).to_i
    rescue
      # We know the host and MAC addresses formats have been validated and the community is not null
      # so it's simply wrong parameters, which results in bad data
      strength = noise = 0
    end
    cacti_format(strength, noise)
  end
rescue
  die "SNMP connection failure. Check host and community options."
end
