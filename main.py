from scapy.all import *

# Dictionary to store MAC-IP mappings
#Толь бичгийг MAC-IP хадгалахад ашиглана
arp_table = {}

# packet butsaaj duudah punkts
def packet_callback(packet):
    global arp_table #функц дотроос хандах боломжтой

    if packet.haslayer(ARP):  # Пакет нь ARP давхарга агуулсан эсхийг шалгана
        arp_src_ip = packet[ARP].psrc
        arp_src_mac = packet[ARP].hwsrc   #ARP пакедаас ip,mac хаягийг гаргаж авдаг.

        # ARP Poisoning detection logic arp_table бгаа мэдээлэлтэй таарахгүй бол Энэ нь илрүүлэлтийг харуулсан мессежийг хэвлэдэг
        if arp_src_ip in arp_table and arp_table[arp_src_ip] != arp_src_mac:
            print(f"ARP Poisoning detected! IP: {arp_src_ip}, Old MAC: {arp_table[arp_src_ip]}, New MAC: {arp_src_mac}")

        # Update ARP table Дараа нь arp_table нь шинэ MAC-IP зураглалаар шинэчлэгдэнэ.
        arp_table[arp_src_ip] = arp_src_mac

    elif packet.haslayer(IP):
        src_ip = packet[IP].src
        dst_ip = packet[IP].dst
        protocol = packet[IP].proto

        # Check for suspicious activity Сэжигтэй үйл ажиллагаа байгаа эсэхийг шалгана уу
        if protocol == 6:  # TCP protocol
            if packet.haslayer(TCP):
                src_port = packet[TCP].sport
                dst_port = packet[TCP].dport

                # Implement your detection logic here
                if dst_port == 22:  # Detect SSH traffic илрүүлэх
                    print(f"Potential SSH connection from {src_ip}:{src_port} to {dst_ip}:{dst_port}")
                    # You can add more actions here, like logging or alerting

        elif protocol == 17:  # UDP protocol
            if packet.haslayer(UDP):
                src_port = packet[UDP].sport
                dst_port = packet[UDP].dport

                # Implement your detection logic here
                if dst_port == 53:  # Detect DNS traffic илрүүлэх
                    print(f"Potential DNS query from {src_ip}:{src_port} to {dst_ip}:{dst_port}")
                    # You can add more actions here, like logging or alerting


# Sniff packets on the network interface
#Энэ нь баригдсан пакет бүрийн хувьд packet_callback функцийг дууддаг (prn=packet_callback)
#ба store=0 нь баригдсан пакетуудыг санах ойд хадгалахгүй байхыг баталгаажуулдаг.
sniff(prn=packet_callback, store=0)
