from scapy.all import *
import scapy.all as scapy

def get_mac(ip):
    # Get the real MAC address of the sender
    arp_request = scapy.ARP(pdst=ip)
    broadcast = scapy.Ether(dst="ff:ff:ff:ff:ff:ff")
    arp_request_broadcast = broadcast / arp_request
    answered_list = scapy.srp(arp_request_broadcast, timeout=5, verbose=False)[0]
    return answered_list[0][1].hwsrc

def detect_arp_spoofing(packet):
    if packet.haslayer(scapy.ARP):
        if packet[scapy.ARP].op == 2:  # ARP response (ARP reply)
            try:
                real_mac = get_mac(packet[scapy.ARP].psrc)
                response_mac = packet[scapy.ARP].hwsrc
                if real_mac != response_mac:
                    print(f"Potential ARP spoofing detected! Real MAC: {real_mac}, Response MAC: {response_mac}")
            except IndexError:
                pass

# Sniff ARP packets and call the detection function
scapy.sniff(filter='arp', prn=detect_arp_spoofing)

class IDS:
    def __init__(self, interface=None):
        self.rules = {}
        self.interface = interface or conf.iface

    def start_capture(self):
        sniff(iface=self.interface, prn=self.process_packet)

    def process_packet(self, packet):
        for header, blocks in self.rules.items():
            if packet.haslayer(header):
                for block in blocks:
                    block(packet)

    def rule(self, header):
        def decorator(func):
            if header in self.rules:
                self.rules[header].append(func)
            else:
                self.rules[header] = [func]
            return func
        return decorator

# Example usage:
ids = IDS()

@ids.rule(IP)
def handle_ip(packet):
    print("IP packet detected:", packet.summary())

ids.start_capture()
