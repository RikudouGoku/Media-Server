# Table of Contents

- [Media server part 2, Orange Pi 5 Plus](#media-server-part-2-orange-pi-5-plus)
- [Preparation](#preparation)
- [Installation/First Boot From SD Card](#installationfirst-boot-from-sd-card)
- [Boot from NVME SSD](#boot-from-nvme-ssd)
- [Change SSH Port (before OpenMediaVault Installation)](#change-ssh-port-before-openmediavault-installation)
- [Permanent IP Address](#permanent-ip-address)
- [Install Pi-hole (DNS)](#install-pi-hole-dns)
- [Install PiVPN](#install-pivpn)
- [Install OpenMediaVault](#install-openmediavault)
- [Install Docker](#install-docker)
- [File Transfer and Synchronization](#file-transfer-and-synchronization)
- [Install Navidrome](#install-navidrome)
- [What to install next?](#what-to-install-next)
- [Update](#update)
  - [OS update](#os-update)
  - [Docker update](#docker-update)
- [Drive failure protection](#drive-failure-protection)
  - [SnapRAID](#snapraid)
  - [OMV-backup](#omv-backup)
- [Memory](#memory)
- [Statistics](#statistics)
  - [Power consumption](#power-consumption)
  - [Resource usage](#resource-usage)
- [UPS](#ups)
- [Troubleshooting](#troubleshooting)
- [NAS comparison](#nas-comparison)
- [Self-Hosted Streaming vs. Commercial Services: Cost Breakdown](#self-hosted-streaming-vs-commercial-services-cost-breakdown)
- [Conclusion](#conclusion)

## Media server part 2, Orange Pi 5 Plus

So...I ended up buying the Orange Pi 5 Plus (16GB) and it has not been a
year yet since I bought the Synology DS423+. Why?

1. I want to have a private VPN so I can access my Synology when I'm
   outside using mobile data or if I need to use a public Wi-Fi then
   using a VPN will help with privacy and security a ton.
2. To put some Docker Containers that might need to be opened up to the
   Internet on the Pi instead so there is an extra layer of security
   than to have it all on the Synology where all the important data is.
3. To offload some of the Docker Containers running on my Synology to
   the Pi and to run a few more with the better performance (CPU) of
   the Pi.
4. While I'm at it, to try out a cheaper option for a Media Server/NAS
   so I can share my experience with you guys (here we are).

So, why did I pick something from Orange Pi instead of Raspberry Pi? It
is because the Orange Pi boards have quite a bit better hardware for the
money, so it is the better value in my eyes, as for the downside with
the worse support I hope that using third party OS such as Armbian will
negate that part. As for the model I picked, I started out wanting the
Orange Pi 3B as it was the cheapest but still has an ARM based SoC so
support is better than the cheaper Zero boards that uses Allwinner SoC.
But then I thought that the 3B might not be as future proofed as the
more expensive 5 lineup SoC (which is around 2x more expensive but
performance is 3-4x better, 4 vs 8 cores) so I started looking at the 5
series. The 5 series have as of this writing, 6 different versions.

3 versions with the RK3588 SoC (the 5 Plus, 5 MAX and 5 Ultra), the MAX
and ULTRA as of this post does not have any standard nor community
supported build from armbian nor dietpi (although MAX is supported by
joshua-riek´s Ubuntu-rockchip version) which is why I disqualified them
from the start. Then we have 3 versions with the RK3588S SoC (the 5, 5B
and 5 Pro), 5B does not have support from dietpi but supported on the
other 2 OS. Which leaves the 5 Plus, 5 and 5 Pro as the candidates.
Price wise it goes 5 < 5 Pro < 5 Plus. The 5 Pro however does NOT have
an SPI-Flash, which is needed if you want to be able to install and boot
from anything else other than the USB/SD-card and since I want to have
my boot and root partitions on the NVME SSD I bought, the 5 Pro is
disqualified. So now the final choices are the 5 and the 5 Plus.
Differences are:

| Feature         | Orange Pi 5                                  | Orange Pi 5 Plus                             |
| --------------- | -------------------------------------------- | -------------------------------------------- |
| **eMMC socket** | No eMMC socket                               | Has eMMC socket                              |
| **LAN ports**   | Single Gigabit LAN port                      | Dual 2.5 Gigabit LAN ports                   |
| **USB ports**   | 1 x USB 3.0, 2 x USB 2.0, 1 x USB 3.1 Type-C | 2 x USB 3.0, 2 x USB 2.0, 1 x USB 3.0 Type-C |
| **PCIe**        | PCIe 2.0 (single lane, ~500 MB/s)            | PCIe 3.0 x4 (up to 4 GB/s)                   |
| **HDMI ports**  | 1 x HDMI 2.1                                 | 2 x HDMI 2.1                                 |
| **GPIO header** | 26-pin GPIO header                           | 40-pin GPIO header                           |

With all that in mind, I went with the 5 Plus as it is worth the price
increase to me and I picked the 16 GB version so It is more future proof
and because with how powerful this SoC is, going for the lowest 4 GB
version would mean you aren't making that much use of the more powerful
SoC in the 5 Plus compared to the 3B, 8 GB is my recommendation at least
but I went with 16 GB since you cannot really upgrade the RAM
afterwards. Here is the list of what I bought:

| Product                                       | Link                                                                                      | Description                                                                                                                                            | Need?                                                                                                                                        |
| --------------------------------------------- | ----------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------- |
| Acrylic case with heatsink and fan kit        | [Link](https://www.aliexpress.com/item/1005005637567338.html)                             | A cheap case to lift the Pi off the ground a bit, useful heatsink. Fan I do not use but should be decent.                                              | Mandatory, you need some form of cooling and with how powerful the SoC is, active cooling is preferable                                      |
| NVME SSD Thermal pad (70x20x3.0mm)            | [Link](https://www.aliexpress.com/item/1005005914728082.html)                             | No active cooling on the NVME so a passive thermal pad will help. Hovers around 50C in idle                                                            | Not mandatory, but likely better for SSD health for long term. Either this or the COOLLEO heat sink                                          |
| COOLLEO M.2 2280 SSD heat sink                | [Link](https://www.aliexpress.com/item/1005007221906478.html)                             | No active cooling on the NVME so a passive heat sink will help. Hovers around 30C in idle (20C lower than thermal pad)                                 | Not mandatory, but likely better for SSD health for long term. Either this or the Thermal pad                                                |
| NETAC SD Card 64GB                            | [Link](https://www.aliexpress.com/item/4000561924634.html)                                | Need an SD card to first install the OS (can then move to entirely using NVME only)                                                                    | Not mandatory, you just need an SD card (and a dapter/reader) for the first install but if you do not have one already, this should be good. |
| 6-In-1 USB adapter                            | [Link](https://www.aliexpress.com/item/1005005872584302.html)                             | USB adapter for the SD Card so you can use it with your PC.                                                                                            | Mandatory, if you do not have one.                                                                                                           |
| NETAC NVME SSD 1TB                            | [Link](https://www.aliexpress.com/item/1005003794707357.html)                             | Cheap and from my research apparently a good brand for SSDs on AliExpress (rare). Got 1TB since only one NVME slot and I needed a bit more than 500GB. | Not mandatory, but good to have an NVME for Boot/root partition for maximum speed.                                                           |
| UGREEN CAT8 Ethernet cable (Flat PVC version) | [Link](https://www.aliexpress.com/item/1005006895115843.html)                             | Need an Ethernet cable to connect with the router wired. Picked a random one from a reputable brand on AliExpress.                                     | Mandatory, you need a wired Ethernet cable to use with router.                                                                               |
| Orange Pi 5 Plus (with power supply option)   | [Link](https://www.aliexpress.com/item/1005005621748337.html)                             | Bought with the power supply (5V 4A) in case I need it.                                                                                                | Obviously the key part in the setup. Power supply is not needed though if you go with the UPS.                                               |
| Waveshare UPS Module 3S (EN)                  | [Link](https://www.aliexpress.com/item/1005005081170621.html)                             | UPS so if the power goes down it should either gracefully shut down without damage/data-loss or keep running on battery until power comes back.        | Not mandatory, but HIGHLY recommended.                                                                                                       |
| INR18650 MH1                                  | Swedish store (find your own store locally): [Link](https://www.electrokit.com/batteries) | Need 3 x 18650 batteries for the 3S UPS I paid around 18 usd for them.                                                                                 | Mandatory (3x 18650 batteries) if you go with the UPS.                                                                                       |
| 12.6V 2A Charger                              | [Link](https://www.aliexpress.com/item/32976610933.html)                                  | Charger for the UPS                                                                                                                                    | Not needed if Waveshare includes the charger with the UPS, the link I bought from did.                                                       |
| Noctua NF-A4x10 5V                            | [Link](https://noctua.at/en/products/fan/nf-a4x10-5v)                                     | Better fan that is essentially inaudible and excellent cooling (around 30C idling). (make sure it is the 5V and without PWM version)                   | Not mandatory, upgraded fan over the one that comes with the acrylic case kit. Use the stock one or this Noctua fan.                         |
| O-ring (4x2x1mm)                              | [Link](https://www.aliexpress.com/item/32952893714.html)                                  | Needed if you want to fasten the Noctua fan in place.                                                                                                  | Needed if you want to fasten the Noctua fan in place.                                                                                        |

Alright, so now you have all the hardware you need. There are now
multiple ways to go about the OS:

1. Armbian (<https://www.armbian.com/orange-pi-5-plus/>)
2. Joshua-Riek Ubuntu-Rockchip
   (<https://github.com/Joshua-Riek/ubuntu-rockchip>)
3. DietPi (<https://dietpi.com/#downloadinfo>)
4. Optional; if you want to use the Pi as a NAS, you need to install
   OpenMediaVault
   (<https://docs.openmediavault.org/en/stable/installation/on_debian.html>
   <https://www.openmediavault.org/> ) on top of the OS in which case
   you need a Debian based OS and so the Joshua-Riek Ubuntu Rockchip OS
   cannot be used for that. I am doing this so using Armbian is the
   easiest way to then install OMV as there is a built in
   armbian-config tool to install OMV in a single step with all
   performance and reliability tweaks included.

## Preparation

1. Connect the three 18650 batteries to the UPS and then assemble the
   UPS (you need to connect the Type-C, Switch button and DC5521 cables
   to the UPS) take a look at the official
   [pictures](https://www.waveshare.com/ups-module-3s.htm) and you
   should be able to assemble it even without a guide. When done, plug
   in the charger into it and let it charge in the meantime.

2. Download Armbian (Armbian 24.8.1 Bookworm Minimal / IOT Kernel:
   6.1.75, Size: 225.6 MB, Release date: Aug 26, 2024, being the latest
   during this post) image over here
   <https://www.armbian.com/orange-pi-5-plus/> and then install
   Raspberry Pi Imager <https://www.raspberrypi.com/software/> (works
   on Windows, Linux and macOS).

3. Plug in your SD card with the adapter into the pc and open RPI
   Imager. This will wipe the data on the SD card so make sure to make
   a backup of any files you want to keep on it if it is an old card.

4. Select "no filtering" on the "Raspberry Pi Device category, "Erase"
   for the Operating System" category" and **be sure** to select the
   correct "Storage" device (the **SD CARD**!). Click next and agree to
   the warning popup about the data wipe, wait until it is done and it
   is fully wiped and formatted to FAT32.

5. Next, install the Armbian minimal image by first clicking on the
   "Choose OS" and selecting "Use custom" and then select the image you
   just downloaded. Then select the SD card in the Storage category and
   set the "Raspberry Pi device" to "no filtering". Click next after
   all 3 categories have been set, make sure it is the correct device
   (SD CARD!).

6. You will get a popup asking if you wan to customize it, click NO and
   then another popup warning you that it will wipe the data on the
   card, click yes to continue. Wait until it is done and then you can
   disconnect the card from the PC.

7. Assemble the case for the Pi, I am using the Noctua 40mm fan which
   is too big for the included top cover so I ditched it and have the
   board elevated a bit over the ground instead (which should help give
   the NVME SSD some more airflow and should be cooler for the board as
   the SSD is not close to the board now). You can connect the Noctua
   fan with 3pin and then it should only activate above a certain
   temperature (55 degrees Celsius as far as I know) or connect it with
   the included 3pin → 2pin adapter and it will be constantly activated
   at max power (it is barely audible and drains next to no power).
   Connect to these pins (5V and GND) if using the 2pin adapter:

![GPIO Pins](./images/10000000000007D8000002E8E3698715.png)

(if using 3 pin I believe (not 100% sure) you want
    to connect the third yellow wire to the GPIO1_A1 pin.)

## Installation/First Boot From SD Card

1. Connect the SD card, NVME drive and Ethernet cable to the Pi. Then
   connect the UPS USB-C power cable to the Pi LAST.

2. Login to the Pi using SSH, you first need to find the IP address the
   router assigned to it. Do so by either login in to the router
   settings and look it up there (every router brand is different so
   look up how to do so on your specific router). Here is how it looks
   for me.
   
   ![TP-Link](./images/100000000000088C000002357AB7E8D8.png)

3. With the IP address known, you then need to use SSH to login to it,
   on Windows 10/11 SSH should be enabled by default otherwise check
   these guides on how to enable them (Windows
   [10](https://www.youtube.com/watch?v=zsZMKsZHXEE)/[11](https://www.youtube.com/watch?v=wS2DYEu7C0o)),
   you can just use the Terminal on Linux and on Windows you can
   use CMD. I will be using the IP address my Pi got but you need to
   use yours, type in: "ssh <root@192.168.0.114>", click yes if it
   warns you about the authenticity and then when it asks for the
   password type in "1234"

4. It will now ask you to change the password for the root user, pick a
   random but STRONG password (save it in a password manager or
   something like that).

5. Then you need to create a user account by picking a username,
   password and then your real name. I just picked the same name for
   both ones, and a random password. After that it will ask you about
   language and timezone, you can pick on your own or select the
   default one for you. After all that you should see this:
   
   ![Armbian Default Page](./images/100000000000063D00000398FC82C368.png) Continue with the next chapter right after this
   (Boot from NVME SSD) or skip that if you do not have an NVME SSD
   that you want to boot from.

## Boot from NVME SSD

1. Follow the official Manual (
   <https://drive.google.com/file/d/1qJcShkcYlMZdgdr5HVqTmpcYxUYuP-aE/view>
   ) Chapter 2.6.2 "How to use balenaEtcher software to program" from
   step 1 to the end of step 9.
2. Confirm that the Pi can see the SSD by typing in
   "lsblk" in the terminal for ssh after the last step from the
   previous chapter.
   ![lsblk](./images/1000000000000473000001B32215E6FD.png)
3. Here you can see that the Pi can see the nvme drive, it is called
   "nvme0n1" and you can see the sd card as well "mmcblk1" with a
   single partition called "mmcblk1p1"
4. Now we need to create 2 partitions for the nvme, type in
5. Now type in "armbian-install" and this is what you should see:![Armbian-Install1](./images/1000000000000610000002E1A55D6505.png)
6. Select option 7 (use arrow keys to navigate) and
   click yes and WAIT (no progress bar so might look like it is not
   doing anything but WAIT, took me around 5 minutes).![Armbian-Install2](./images/1000000000000542000002D7BF32F362.png)
7. After you get the done message, you might need to
   clear the screen type in "clear". Then type in "armbian-install"
   again. This time select option 4. Click proceed to the wipe warning
   and check so it is wiping the nvme drive (nvme0n1)![Armbian-Install3](./images/10000000000005F0000001A5C506B6FA.png)
8. Click proceed to the automated installation.![Armbian-Install4](./images/1000000000000493000001B4307847F4.png)
9. Select ok and it will create a single partition
   "nvme0n1p1".![Armbian-Install5](./images/100000000000054B000001F917B60589.png)
10. yes.![Armbian-Install6](./images/1000000000000599000002AD65109BB9.png)
11. If you have an nvme that is bigger than 1TB, then
    I would go for btrfs since it is beneficial for OpenMediaVault, but
    since I only have 1TB I cannot use that and need to go for ext4,
    click ok and WAIT.![Armbian-Install7](./images/1000000000000529000001EFF297A418.png)![Armbian-Install8](./images/100000000000052F000001B002C2BAB5.png)
12. Click yes (already did this but do it again to be
    sure) and WAIT.
13. When done select "power off", wait a minute or two to make sure it
    has been turned off properly (the LED should still be on with red
    color indicating that it is connected to a power cable).![Armbian-Install9](./images/10000000000005F2000001A9F1B2FDBE.png)
14. Go to the Pi and remove the sd card then click on
    the power button on the Pi. Go back to the router page and check if
    the IP address is still the same or not, in my case it changed from
    114 to 113 at the end. Go to the Terminal and ssh into it again
    using "ssh <root@192.168.0.113>" and type in the root password.
15. Now if you
    managed to boot into it, we already know it is a
    success but you can check with the "lsblk" command in the terminal. ![ArmbianInstall10](./images/100000000000042D0000018E06A22A7E.png)
16. Armbian is now installed, run "sudo apt update" if there are
    upgrades available, run "sudo apt upgrade". You may keep the SD Card
    as a backup in case something goes wrong later then you just need to
    remove the SSD and put in the SD card and boot from here.
17. Go to the "Change SSH Port (before OpenMediaVault Installation"
    chapter next.

## Change SSH Port (before OpenMediaVault Installation)

1. Change the port used for SSH to improve security, pick a random
   number between 49152--65535.
2. Type in "nano /etc/ssh/sshd_config" in the terminal. ![sshd_config](./images/100000000000064B000003915F34D4C1.png)
3. Change the port number 22 to the random one you
   picked and remove the "#" symbol. Click ctrl+x on the keyboard to
   exit afterwards and click "y" on the keyboard to save and click
   enter to overwrite the old file with the new one. You can confirm if
   it saved by typing in the same code in the terminal.
4. Type in "systemctl restart ssh" and open a NEW terminal (do not exit
   the old one until we confirmed we can use the new port so we are not
   locked out of it).
5. Type in "ssh -p PORT <root@192.168.0.113>" (use the random ssh port
   you picked on step 3) and login with the root password. If logged
   in, the ssh port is now set and confirmed to be working with the new
   one REMEMBER IT (save it in a password manager).
6. Go to the "Permanent IP Address" chapter next.

## Permanent IP Address

1. Go to the router web ui page and set a permanent IP address for the
   Pi so it does not change. Every brand is different, so look
   up how to do it on yours. ![DHCP](./images/100000000000083100000499C0364B40.png)
2. Type in "reboot" in the terminal to reboot and get the new and
   permanent IP address you assigned to it. Then when you SSH into it
   you need to use the new IP address. Example if you gave it
   192.168.0.10 the code would be " ssh -p PORT <root@192.168.0.10>"
   (with the PORT being the SSH port you randomly picked).
3. Go to the next chapter "Install Pi-hole (DNS)"

## Install Pi-hole (DNS)

1. Type in "ip addr" in the terminal, check which one is in use between
   the interfaces (ignore the first "lo"), here it is the
   enP4p65s0.![ip addr](./images/100000000000064E000002D65AC1B528.png)
2. Type in "curl -sSL https://install.pi-hole.net \| bash" in the
   terminal to run the automatic installer. You should see this
   afterwards.![Pi-hole Install1](./images/100000000000062200000383094DE9D3.png)
3. Click ok, twice, then continue when it says you
   need a static IP which we already did in the previous chapter.
4. Select the interface that is in use which we found out in step 1 to
   be
   enP4p65s0![Pi-hole Install2](./images/10000000000005890000030F82B48FE5.png) here.
5. Select the upstream DNS provider, I picked Cloudflare.![Pi-hole Install3](./images/10000000000005B000000329970FA549.png)
6. Select yes to use the default block list.![Pi-hole Install4](./images/100000000000057F000003164CE40C7D.png)
7. Select yes to have Web UI to manage it easier.![Pi-hole Install5](./images/10000000000005A500000313760892D1.png)
8. Yes.![Pi-hole Install6](./images/1000000000000596000003273653CE98.png)
9. Yes![Pi-hole Install7](./images/10000000000005B100000328EEA3E303.png)
10. Select "show everything" and then WAIT.![Pi-hole Install8](./images/10000000000005CB000002F56D61A6AC.png)
11. Open up the web page by opening a new tab in your
    browser and type "192.168.0.50/admin" (example IP) then log in with
    the password shown (SAVE IT) Click ok when done.![Pi-hole Install9](./images/10000000000005950000032A5CD24C42.png)
12. Go to the next chapter "Install PiVPN"

## Install PiVPN

1. Type in "curl -L https://install.pivpn.io \| bash" in the terminal.![PiVPN Install01](./images/10000000000005B10000033D016B7D01.png)
2. Click ok (works for Orange Pi as well as other
   SBCs, not just Raspberry Pi´s).
3. ok![PiVPN Install02](./images/10000000000005CD00000328DC1C271D.png)
4. Yes![PiVPN Install03](./images/10000000000005C10000032FED830224.png)
5. Ok![PiVPN Install04](./images/10000000000005C80000032BCA4AA967.png)
6. ok![PiVPN INstall05](./images/10000000000005C80000032DE08F29FB.png)
7. Select your user.![PiVPN Install06](./images/10000000000005C1000003449BFB9FF4.png)
8. Pick between WireGuard or OpenVPN, WireGuard is
   what I use and is what is mostly recommended as far as I know.![PiVPN Install07](./images/100000000000059E00000316947D9F89.png)
9. Use the default port and confirm it.![PiVPN Install08](./images/10000000000005AB00000368BE2FA6AF.png)
10. Yes.![PiVPN Install09](./images/10000000000005D60000031D6066A2B8.png)
11. Use public IP![PiVPN Install10](./images/10000000000005D300000345369F69C6.png)
12. Ok![PiVPN Install11](./images/10000000000005B70000033A40416BAE.png)
13. Yes![PiVPN Install12](./images/10000000000005C30000032CAAC01433.png)
14. ok![PiVPN Install13](./images/10000000000005BC0000033DDE28D996.png)
15. yes and it will reboot.![PiVPN Install14](./images/10000000000005D80000033F83678DAA.png)
16. After the reboot you might need to close and open
    the terminal again and ssh into it, we want to create client
    profiles, type in "pivpn add" and enter a name for
    the client, since I want the client to be my Phone
    I will just name it the Xperia5V. ![PiVPN Install15](./images/1000000000000347000000528331E8F0.png)![PiVPN Install16](./images/10000000000005E4000001B40F617C00.png)
17. Go to your router settings and add a port forward
    rule to forward all from 51820 via UDP.![PiVPN Install17](./images/10000000000004E60000030F17D7AD44.png)
18. Download the WireGuard app on whatever device you
    want to connect to the Pi remotely, in my case it is my
    [Android](https://play.google.com/store/apps/details?id=com.wireguard.android)
    phone.
19. Type in "pivpn
    -qr" in the terminal and enter the name of the
    client you created at step 16, in my case "Xperia5V", a QR code
    should be shown now.![PiVPN Install18](./images/1000000000000445000000989C81A8A3.png)
20. Open the WireGuard app and click the plus icon at the bottom right
    and select "scan from QR Code" and scan the QR code shown in the
    terminal.
21. Give it a name, I just called mine "PiVPN-OPi5P" and click on the
    create tunnel.
22. To confirm that it is working, use your mobile data (and no Wi-Fi)
    and check what your IP address is
    [here](https://whatismyipaddress.com/) then enable the VPN in the
    app and check what the IP address is again. It should now show a
    different address. And in my case the VPN address is very similar to
    the IP address I have when on my Wi-Fi and the location shown on
    that site is much closer to my real location compared to mobile data
    which isn't as accurate. You can also check the Pi-hole Web UI page
    and it should have some queries and clients now after that test.![PiVPN Install19](./images/10000000000009CB0000017C68255016.png)
23. To use Pi-hole as your DNS on PC, you need to
    change your DNS settings to the IP address of the Pi, [Windows
    10](https://www.windowscentral.com/how-change-your-pcs-dns-settings-windows-10)/[Windows
    11](https://mariushosting.com/synology-use-pi-hole-as-dns-on-windows-11/).![PiVPN Install20](./images/100000000000079600000173E5396331.png)
24. Go to the next chapter "Install OpenMediaVault".

## Install OpenMediaVault

1. First check for updates, type "apt update" if there are run "apt
   upgrade" afterwards.

2. Type in "wget -O -
   https://github.com/OpenMediaVault-Plugin-Developers/installScript/raw/master/install
   \| sudo bash" in the terminal, WAIT.![OMV Install01](./images/100000000000065700000241EB706891.png)

3. Open a new page in your browser and type in the IP
   address of your Pi, you should see the login page for OMV, if not
   immediate wait a few minutes and check your router Web UI to see if
   the Pi is still on and active.![OMV Install02](./images/1000000000000529000004F899A64592.png)

4. Login with user name "**admin**" and
   "**openmediavault**" for password.![OMV Install03](./images/1000000000000ED50000056DEA0FB079.png)

5. Since OMV uses the same port (80) as Pihole
   for the Web UI we need to change it so it does not conflict with
   pihole.

6. SSH into the terminal "ssh
   **[root@IPADDRESS](mailto:root@IPADDRESS)**" (using the IP
   address of the Pi).

7. Type in "omv-firstaid" and select 3 "configure workbench"![OMV Install04](./images/100000000000056E000002A57C3D0A0E.png)

8. Change the port to 8080.![OMV Install05](./images/100000000000059300000190A5F22408.png)

9. Then use the link it gives you to go to the Web UI
   for OMV.![OMV Install06](./images/10000000000003DE000001166A7C15EB.png)

10. Change the password for your admin user in
    OpenMediaVault (and activate dark mode if you want to).![OMV Install07](./images/1000000000000C5700000361A8C34D03.png)

11. The SSH port has been changed back to the default
    22, to change it go to "services" and "SSH" and then input the port
    there.![OMV Install08](./images/1000000000000E95000005106D50617F.png)

12. Then apply ![OMV Install09](./images/1000000000000C4E000000CFA795FCEC.png)

13. Go to the next chapter "Install docker"

## Install Docker

1. SSH into the Pi, type in "wget -O -
   https://github.com/OpenMediaVault-Plugin-Developers/packages/raw/master/install
   \| bash" in the terminal and WAIT.

2. Go back to the Web UI for OpenMediaVault and press ctrl + shift + R.

3. Go into "System" then "omv-extras" and check the box for "Docker
   repo" and click save and WAIT.![Docker Install01](./images/1000000000000EA600000498B39F223F.png)

4. Go into "Plugins" and search for compose and click
   on it.![Docker Install02](./images/1000000000000EBE0000043E72821E4E.png)

5. Install it.![Docker Install03](./images/1000000000000C200000043489275C7E.png)

6. If this happens, click on the close button and
   click on the install button again.![Docker Install04](./images/1000000000000B1300000364120D490C.png)

7. If this happens again (did for me), press ctrl +
   shift + R and check the page if it has not been installed already,
   it did for me.![Docker Install05](./images/1000000000000C56000004AC2F41F9CA.png)

8. Go to "Storage" and then "shared folders" and
   click on the plus icon.![Docker Install06](./images/1000000000000ED3000004439BE13CB9.png)

9. Name the shared folder docker (where docker related
   files will be stored) and select the drive you want it to be on, in
   my case I want it to be on my NVME SSD (and its the only drive I
   have right now) and click save and click on the apply button when
   the yellow popup comes up.

10. ![Docker Install07](./images/1000000000000C2C0000030C2CA3DABF.png)Create another shared folder called "compose" and
    select the same drive. Then save and apply. ![Docker Install08](./images/1000000000000C34000003273669AF90.png)

11. Go to "users" and then "groups" and create a "docker-group"![Docker Install09](./images/1000000000000EB4000004385C5D3E8C.png)

12. Then click on it and then the "shared folder
    permissions" button![Docker Install10](./images/1000000000000C5700000177FA7C7744.png)

13. Give it
    read/write access and save.![Docker Install11](./images/1000000000000EB000000288724FC50B.png)

14. Go to "users" and then "users" and click the plus icon to create
    another user, name it "dockeruser" (or whatever but this is for
    docker specifically), give it a password and put it inside "docker",
    "docker-group", "openmediavault-admin", "openmediavault-config" and
    "sambashare" groups. And click on the "disallow account
    modificiation. Then save and apply. ![Docker Install12](./images/1000000000000ED1000005E2541A000F.png)

15. Go to "services", "compose" and "settings" and select the compose
    folder under the shared folder for compose files and select the
    docker folder under data, scroll all the way to to the bottom and
    click save and apply changes with the yellow popup.![Docker Install13](./images/1000000000000E8B00000348578F7BD4.png)

16. Then click on the reinstall docker button and
    WAIT.![Docker Install14](./images/1000000000000C1600000586703EB53E.png)

17. Click close when done.![Docker Install15](./images/1000000000000B18000001F3B9BA7C77.png)

18. SSH into the Pi with the terminal and type in
    "docker compose version", then "docker ps", then "docker -v", then
    "id admin" and lastly "id dockeruser". To check that docker and
    compose are installed properly and to check the ID of the
    dockeruser.
    
    ![Docker Install16](./images/1000000000000648000001FADB5DDE47.png)

19. **(You may skip this step to the end of this chapter if you prefer
    to manage your Docker Containers via OpenMediaVault, I am used to
    Portainer from my Synology NAS and it has templates that makes
    installing containers easier)** Go to "services", "compose" and
    "files". Click on the plus icon and then select "portainer --
    portainer" and name it "portainer" and save and apply.![Docker Install17](./images/1000000000000EB50000029AA9DF5CE5.png)

20. Go to the "storage", "shared folders" page and
    copy the absolute path for the docker folder.![Docker Install18](./images/1000000000000EA90000025737154ACC.png)

21. Go back to the "services", "compose" and "files"
    page and click on the edit button for portainer.![Docker Install19](./images/1000000000000AE4000001DE9A9CA18C.png)

22. Then change the "CHANGE_TO_COMPOSE_DATA_PATH" to
    the absolute path for the docker folder from step 20.![Docker Install20](./images/10000000000005DE000003B57EF2BA8E.png)

23. Click save![Docker Install21](./images/1000000000000C31000004B16FF21E73.png)

24. Now click on portainer and click on the up icon and
    wait.![Docker Install22](./images/1000000000000DBD000002C7557277F9.png)

25. When "end of line" appears, click close.![Docker Install23](./images/1000000000000B14000003412E367C15.png)

26. Go to the "services" page and you can see the
    container running.![Docker install24](./images/1000000000000EAF0000036827E10521.png)

27. Open
    "[http://IPADDRESS:9000](http://IPADDRESS:9000/)" in another
    page in the browser and create your account.

28. Click "get started" ![Docker Install25](./images/10000000000008D0000004E6FCFC93F3.png)

29. Then the edit icon.![Docker Install26](./images/1000000000000C74000002B7A9DAFBA7.png)

30. Add the IP address of the Pi there and click on
    the "update environment".![Docker Install27](./images/1000000000000A670000044A69041663.png)

31. Environment updated to local should be seen.![Docker Install28](./images/1000000000000B6A00000417A716AC0A.png)

32. Click on "registries" and "add registry"![Docker Install29](./images/1000000000000EAD00000373F5C100A6.png)

33. Click on "custom registry" and put "GHCR" under
    name and "ghcr.io" under URL then add registry button.![Docker Install30](./images/1000000000000C81000004FB69483D8F.png)

34. Repeat step 33 twice, first with "CODEBERG" under
    name and "codeberg.org" under URL and then with "Quay.io" under name
    and "quay.io" under URL.

35. Should look like this.

36. ![Docker Install31](./images/1000000000000C74000002FB813D3FAD.png) Go to the next chapter "copying music folder"

## File Transfer and Synchronization

1. There are many ways to transfer or synchronize your files from PC
   (or any other source like a phone or another NAS) to the Pi such as
   SMB (Samba) which would allow you to mount the Pi as a network drive
   on your PC and just copy over files like it is a regular hard drive
   inside the PC. I prefer to use Syncthing to automate things and so I
   can adjust it to be either one way upload to the Pi or a two-way
   synchronization.

2. Create a new shared folder under "storage", "shared folders" and
   click on the plus icon. Name it Music (this will be the folder used
   to store all your music files, you can name it something else if you
   want to) and select the NVME SSD for the file system and save then
   apply.

3. Go to your Portainer Web UI and click on "settings" and paste this
   URL into the URL field
   "<https://raw.githubusercontent.com/pi-hosted/pi-hosted/master/template/portainer-v2-amd64.json>"
   and save.
   
   ![Portainer](./images/1000000000000B4600000599B891017F.png)

4. Check the ID for the docker-group you created before by typing "id
   dockeruser" in the terminal after SSH into the Pi. In my case
   docker-group is 1002 and dockeruser is 1001.![dockeruser](./images/100000000000063A00000085B66F2FE0.png)

5. Check the absolute path for docker and Music
   folders. They are /docker and /Music.![Sharedfolder](./images/10000000000006CF000001C816248CC6.png)

6. Go to the "users", "groups" and click on the
   permission icon for the group called "docker-group".![Docker-Group1](./images/1000000000000768000003B14A1E593F.png)

7. Make sure it has read/write for both docker and
   Music shared folders.
   
   ![Dockere-Group2](./images/1000000000000BF60000036ADDF0BD20.png)

8. Go to "templates", "applications" and search for
   "syncthing" in the portainer Web UI and click on it.![Syncthing01](./images/1000000000000EA4000002FB6C2B65A1.png)

9. Change the PUID (user ID) to 1001 (for dockeruser) and PGID (group
   ID) to 100 (for users group as the Music folder is owned by it) and
   click on the show advanced options button.![Syncthing2](./images/1000000000000827000005B9A227806F.png)

10. Make sure the host for the /config path is
    "/docker/syncthing/config" and the container /Music has /Music as
    the host path. Both with bind and writeable settings.
    
    ![Syncthing03](Pictures/10000000000007A6000001ED72EB5709.png)

11. Then click on deploy container.

12. Click "containers" and then the link under "8384:8384" which should
    open the Syncthing Web UI.![Portainer02](./images/1000000000000E980000036F01D65DBF.png)

13. Yes or no, up to you.![Syncthing04](./images/10000000000009DB000006C12B5FEE4F.png)

14. Click on the settings button, then "GUI" and
    create your user and password and then save, you will be logged out
    and need to sign in with the just created user.![Syncthing05](./images/1000000000000927000003DD25400BAB.png)

15. Now you need to have Syncthing installed on your
    PC (or the device you want to file transfer/synchronize) check
    [here](https://syncthing.net/downloads/).

16. Click on the "add remote device" on Syncthing running on the Pi.![Syncthing06](./images/10000000000004AB0000012622DAFADB.png)

17. Go to the Web UI for the PC Syncthing and click on
    the "identification" under "This device" and copy the ID there.![Syncthing07](./images/1000000000000835000004996BED7942.png)

18. Paste it in the Pi Syncthing Web UI under "device
    ID" and name it whatever you want, this is my Synology DS423+ so
    that is the name I use, click save.![Syncthing08](./images/10000000000006EC000003EA4DFAF37E.png)

19. Over in the PC Syncthing Web UI, you should get a
    notification click add device to pair them.![Syncthing09](./images/100000000000096B000002383FDE4E4E.png)

20. Give it a name and click save.![Syncthing10](./images/10000000000006F50000030F1E31AB2B.png)

21. The paired device should be under "Remote Devices"
    and the same for the Pi over on the other Syncthing.![Syncthing11](./images/1000000000000928000003C18A1326CE.png)

22. Over on the PC Syncthing, you need to add the
    music folder. I am syncing the Music folder I have on my Synology
    NAS so the path for me looks like this.![Syncthing12](./images/100000000000070000000450A8349CAA.png)

23. I will be doing a two way sync but I recommend to
    use send only first to check so everything is working. After the
    folder has been fully scanned, you need to share it to the Pi.![Syncthing13](./images/10000000000006E2000003CC5EF18E8B.png)

24. Go to the sharing tab and click on the Pi and
    click save.![Syncthing14](./images/1000000000000703000003CAAC970EDB.png)

25. Over in the Syncthing for the Pi, you should get a
    popup asking if you want to add the Music folder, click add.![Syncthing15](./images/1000000000000908000001EF8378319B.png)

26. Change folder path to "/Music".![Syncthing16](./images/10000000000006DA000004AEE87BDC22.png)

27. Go to the advanced tab and change folder type to
    "receive only". Click save. ![Syncthing17](./images/10000000000006D400000358318FF8B2.png)

28. Wait until it has finished transferring the files,
    as this is a "send" then "receive" only folder, nothing will be
    deleted if anything goes wrong so check that the files are all there
    once it is finished. If everything works you can if you want, change
    the folder settings on both Syncthing Web UI to be "send & receive"
    so they are synchronized or leave it as it is if you want them to be
    separate.

29. Go to the next chapter "Install Navidrome" to setup the music
    server.

## Install Navidrome

1. Use the terminal and SSH into the Pi. Type in "sudo mkdir -p
   /docker/navidrome"

2. Then "sudo chown -R dockeruser:docker-group /docker/navidrome".

3. Then "sudo chmod 775 /docker/navidrome"

4. Go "services", "compose" and then "files" and click the plus icon
   and then the "add from example" button.![compose](./images/1000000000000735000003D4AE069073.png)

5. Search for navidrome in the example field and name
   it navidrome and then save.![compose2](./images/1000000000000C60000002BDC0BFDF45.png)

6. Remove these lines.
   
   ![compose3](./images/100000000000046B0000027759CD107E.png)

7. Click on navidrome and then edit it, change user to "1001:100" (or
   whatever the ID is for your "dockeruser" user and "user" group), add
   this environment variable " ND_MUSICFOLDER: /Music", remove
   "ND_BASEURL: "navidrome.\$URL" and change the volumes to match the
   picture shown below. Save and apply. For more customization check
   [here](https://www.navidrome.org/docs/usage/configuration-options/)![compose4](./images/1000000000000C20000004D6F623650E.png)

8. click on it and click on the arrow up symbol to
   start it.

9. Once started open a new page in your browser and go to
   "<http://IPADDRESS:4040/>" (replace with your Pi address) and create
   your admin user.![Navidrome01](./images/100000000000087D00000637CE63DAFB.png)

10. Once in you should see your music as it begins to
    scan the music folder.![Navidrome02](./images/1000000000000EAC000006E47568DA64.png)

11. Took around 12 minutes to fully scan my music
    which is around 520GB.

12. Now you need a client that is able to connect to your navidrome
    server. Any client that is compatible with subsonic will work with
    navidrome as well. Take a look
    [here](https://www.navidrome.org/docs/overview/#apps) for a list of
    clients. I use and recommend
    [Feishin](https://github.com/jeffvli/feishin) (Windows/Linux/Mac)
    and [Symfonium](https://symfonium.app/) for Android, for iOS I do
    not use it so check the list yourself.

13. **(Will show you how to connect with Symfonium but procedure is the
    same for the other clients basically)** Go to the settings in Symfonium,
    click on the settings button to the bottom right, "manage media
    providers", then "add media provider" and select "(open) Subsonic", then
    input the IP address of the Pi (192.168.0.50 for example), port "4040"
    and the admin username and password you created at step 9, then scroll
    to the bottom and click on "add". Wait for it to scan the server and you
    are done! 

| ![Symfonium1](./images/10000000000003150000069BA9878869.png) | ![Symfonium2](./images/10000000000002F30000066D75106A97.png) | ![Symfonium3](./images/10000000000002EC0000065BAB2E256A.png) | ![Symfonium4](./images/10000000000002EA0000066376DEB8DB.png) |
|:------------------------------------------------------------:|:------------------------------------------------------------:|:------------------------------------------------------------:|:------------------------------------------------------------:|

14. Whenever you want to access your music when you are out of
    your LAN, you just need to open the WireGuard app and connect to the VPN
    tunnel you created.

You are now done with the mandatory stuff you need for your music
server, if you want to read more on how to add more features you can
continue reading on but otherwise you can stop here.

## What to install next?

Some suggestions on what you may want on your server.

- [glances](https://github.com/nicolargo/glances): as a way to monitor
  the performance/resources of the Pi (can install from the compose
  tab in OpenMediaVault using "add from example", just change the
  third volume to " - /docker/glances:/glances/conf")![](images/2024-12-28-04-06-15-image.png)

- [Dozzle](https://dozzle.dev/): log and resource viewer for Docker
  Containers (can install from the compose tab in OpenMediaVault using
  "add from example", just change port 8888 to 8889)

- [Speedtest Tracker](https://github.com/henrywhitaker3/Speedtest-Tracker): to measure your network speed
1. Go to Portainer and open "Templates", then
   "Application" and search for speedtest and click on "Speedtest
   Tracker".![Speedtest1](./images/1000000000000EAB000003FADBFA56A5.png)

2. Click on "show advanced options", and change volume mapping host to
   "/docker/speedtest-tracker" and click on deploy container.

3. Then open a new tab and go to
   "<http://IPADDRESS:8765/>" for the Web UI.![Speedtest2](./images/10000000000009DF00000720B56B7206.png)

4. I have mine set to run every 3 hours, you do so by
   going to the settings page (top right) and under "schedule" input
   this "0 \*/3 \* \* \*"  ![Speedtest3](./images/1000000000000EA10000058DB2EBEE2D.png)
- [FileBrowser](https://filebrowser.org/features): a file
  browser/editor in Web UI
1. Go to Portainer and search for filebrowser in the templates
   application page. Use "FileBrowser latest". Show advanced options
   and change the volume mapping to the picture shown below. This will
   enable you to browse/edit the whole disk, if you don't want to give
   it full access you can just specify what folders you want it to
   access instead. (But I use the whole disk as it is much more
   convenient.) Then deploy the container.![FileBrowser1](./images/1000000000000CA0000006C21579D6D7.png)

2. Go to "<http://IPADDRESS:8082/>", and login with
   "admin" for both username and password.

3. Change your password by going into settings.![FileBrowser2](./images/1000000000000EA70000049778EA48E3.png)

4. Then change your username by going to "user
   management". ![FileBrowser3](./images/10000000000008940000071118301792.png)
- [Uptime-Kuma](https://github.com/louislam/uptime-kuma): monitoring
  tool (can install from the compose tab in OpenMediaVault using "add
  from example", just change the first/only volume to "-
  /docker/uptime-kuma/data:/app/data")
1. Edit the compose file and start it.![Kuma1](./images/1000000000000915000005364DC2C931.png)

2. Go to "<http://IPADDRESS:3001/>" and create your
   admin account.![Kuma2](./images/10000000000007CB0000056505024C68.png)

3. Click on the "add one" or the green "add new
   monitor" button.![Kuma3](./images/1000000000000DE60000039BA13FA7C1.png)

4. Change "monitor type" to "Ping", give it a name
   such as "Orange Pi 5 Plus -- Ping", hostname input the IP address of
   the Pi and under retries set it to 3 (or any number you want).
   Heartbeat interval is at 60 seconds so it checks the Pi every
   miunute, you can change that to 300 seconds for every 5 minutes or
   any other value you want (set retry interval to something lower if
   you do that).![Kuma4](./images/1000000000000C160000069994BA3B9E.png)

5. Click on the "Setup Notification"![Kuma5](./images/100000000000082D000005F2C9C51746.png)

6. There are many different ways to setup
   notification, you can use a discord server that you own or use gmail
   (SMTP).![Kuma6](./images/10000000000007730000069ECD2077A1.png)

7. <span id="GMAIL">Gmail SMTP</span> example, go to
   <https://myaccount.google.com/security> and search for app
   passwords.![Kuma7](./images/100000000000072C0000036853380978.png)

8. Create an app password and give it a name such as
   Uptime Kuma, save the password that comes up. ![Kuma8](./images/10000000000005BB000004F5AA88786A.png)

9. In Uptime Kuma, click on the setup notification set it to Email
   (SMTP) input "smtp.gmail.com" under hostname, port 587, username is
   your e-mail, password is the password you got from the previous
   step, from Email is your e-mail and To e-mail is where you want it
   to be sent to, in my case I put the same mail for all 3.![Kuma9](./images/1000000000000614000006FAE03989A9.png)

10. Scroll down and click test and you should get a
    mail to the e-mail address you inputted then click save.

11. Scroll down to bottom and click on the add button for Tags.![Kuma10](./images/1000000000000A33000006CBA7CC0630.png)

12. Create a tag called "Orange Pi 5 Plus" to organize
    related monitors and give it a color and then add.![Kuma11](./images/1000000000000676000004809182CFFF.png)

13. Then click save.![Kuma12](./images/10000000000008D6000003E78832DAAB.png)

14. You can do this for other services such as
    monitoring other Docker Containers, SSH availability. Or websites if
    you want.![Kuma13](./images/1000000000000DFD0000042244AED030.png)

15. To monitor the SSH availability select "TCP Port",
    give it a name, input the IP address of the Pi and input the SSH
    port that you picked in the **Change SSH Port (before OpenMediaVault
    Installation) **chapter and click save. ![Kuma14](./images/10000000000007B20000065048944553.png)

16. To monitor Navidrome, use "HTTP(s)" for Monitor
    type, give it a name, the URL (including http:// and the port 4040)
    and check so the HTTP option method is on GET, save. ![Kuma15](./images/1000000000000747000005B24B8ADEAC.png)

17. To monitor WireGuard, use a ping monitor and use
    the public IP address of WireGuard, you can check the IP address by
    using terminal/SSH and typing "curl ifconfig.me".![Kuma16](./images/100000000000072400000668B0CAE988.png)

18. If you want, you can group all of the related
    monitors in one group by creating a monitor group. Makes it more
    organized if you want to monitor multiple things.![Kuma17](./images/10000000000009C600000610AE0F64E0.png)

19. If you want to adjust the retention time for
    monitoring history, you can do so in the settings. (default 180
    days.) ![Kuma18](./images/1000000000000E7F000005B6903A6018.png)
- [ntfy]([GitHub - jokob-sk/NetAlertX: 🖧🔍 WIFI / LAN intruder detector. Scans for devices connected to your network and alerts you if new and unknown devices are found.](https://github.com/jokob-sk/NetAlertX/tree/main)): notification sender
1. Go to Services, Compose, Files in OpenMediaVault and copy&paste this [netalertx.compose](./configs/netalertx.compose) file
- [NetAlertX]([GitHub - jokob-sk/NetAlertX: 🖧🔍 WIFI / LAN intruder detector. Scans for devices connected to your network and alerts you if new and unknown devices are found.](https://github.com/jokob-sk/NetAlertX/tree/main)): WIFI / LAN intruder detector. Scans for devices connected to your network and alerts you if new and unknown devices are found
1. Go to Services, Compose, Files in OpenMediaVault and copy&paste this [netalertx.compose](./configs/netalertx.compose) file (and change TZ to your own timezone and healthcheck to your IP Address).

2. Open http://IPADDRESS:17811/ and you should see one or 2 devices (router and/or the Pi).  ![](images/2025-01-05-00-22-46-image.png)

3. Click on the about and then system info page. Under network hardware increase the show entries so you can view it all at once then click on the "network mask" sort button to group them all at the top. Check the name for the ethernet port you are using, in my case it is "enP4p65s0" and also the WireGuard (VPN) interface (should be the same "wg0"), note their IP address.![](images/2025-01-05-00-28-37-image.png)

4. Go to the settings page. Scroll down to the "Networks to scan, SCAN_SUBNETS" setting. You can remove the present entry.![](images/2025-01-05-00-33-44-image.png)

5. Add your subnet, "subnet/24 --interface=enP4p65s0" and the wireguard subnet "subnet/24 --interface=wg0" then click on the green save button and wait for a few minutes (should be scanning every 5 minutes).![](images/2025-01-05-00-39-42-image.png)

6. -Go to the Devices, My Devices page to check the added devices.![](images/2025-01-05-01-41-29-image.png)

7. Go to the settings page, scroll down to the Email Publisher (SMTP) and check the picture below for what to adjust. Create the app password like you did [here](#GMAIL) and save, now you should get an email notification whenever a new device connects.![](images/2025-01-05-01-37-36-image.png)![](images/2025-01-05-01-43-27-image.png)
- [Homepage](https://gethomepage.dev/): to organize and group all your
  Web UI links (can install from the compose tab in OpenMediaVault
  using "add from example", just change the first volume to "-
  /docker/homepage:/app/config")
  
  ![Homepage](./images/2024-12-30-22-48-59-image.png)To get this (very basic) look, just download [services.yaml](./configs/services.yaml) and [widgets.yaml](./configs/widgets.yaml) and put them in your Homepage folder

- [Gitea](https://about.gitea.com/): Your own private Github.
1. Go to portainer and search for Gitea in the templates applications page (pick Gitea and not the one with Mariadb).

2. Change volume mapping to the picture below.![](images/2024-12-30-23-29-50-image.png)

3. Change the SSH port the your port, make sure the server domain specifies the IP Addres of your Pi and you can enable "update checker". Then click Install Gitea.![](images/2024-12-30-20-49-47-image.png)![](images/2024-12-30-20-52-07-image.png)

4. Create an account (will have admin access).![](images/2024-12-30-20-59-19-image.png)

5. You can use the Github desktop client for a UI client on your pc.
- [Archivebox]([GitHub - ArchiveBox/ArchiveBox: 🗃 Open source self-hosted web archiving. Takes URLs/browser history/bookmarks/Pocket/Pinboard/etc., saves HTML, JS, PDFs, media, and more...](https://github.com/ArchiveBox/ArchiveBox)): Web archiver.
1. Go to portainer and search for Archivebox in the templates applications page.

2. Change volume mapping to pic below and deploy (takes a while so just wait).![](images/2024-12-30-22-58-43-image.png)

3. Open "http://IPADDRESS:8002/"![](images/2024-12-30-23-07-19-image.png)

4. Open terminal/SSH and type:docker exec -it --user=archivebox archivebox /bin/bash -c "archivebox manage createsuperuser" 
   
   Then create the username, email and password.![](images/2024-12-30-23-18-56-image.png)

5. Go to the archivebox webui page and click on the login button to the top right. And login with the info you created at step 4.![](images/2024-12-30-23-21-17-image.png)![](images/2024-12-30-23-25-23-image.png)
- [Scrutiny]([GitHub - AnalogJ/scrutiny: Hard Drive S.M.A.R.T Monitoring, Historical Trends &amp; Real World Failure Thresholds](https://github.com/AnalogJ/scrutiny)): S.M.A.R.T Monitoring for HDD/SSDs.
1. Go to Services, Compose, Files in OpenMediaVault and copy&paste this [scrutiny.compose](./configs/scrutiny.compose) file. 

2. open "http://IPADDRESS:8081/web/dashboard", you may see this or not, but click on it to view what is triggering this error.![](images/2025-01-06-01-11-31-image.png)![](images/2025-01-06-01-13-26-image.png)
   Check back on it from time to time to see if it does not increase, if not and the number is low, you should be fine otherwise consider swapping the drive (have a backup ready at least).
- [PhotoPrism](https://www.photoprism.app/): basically your own Google
  photos (follow the steps from Portainer templates, run the script
  first via terminal/SSH).

- [Vaultwarden](https://github.com/dani-garcia/vaultwarden): password
  manager

- [Jellyfin](https://jellyfin.org/): Media server ([Guide](https://akashrajpurohit.com/blog/setup-jellyfin-with-hardware-acceleration-on-orange-pi-5-rockchip-rk3558/)).

- [Unbound](https://docs.pi-hole.net/guides/dns/unbound/): eliminates
  need for Pi-hole to rely on 3^rd^ party upstream DNS providers (like
  Google) and is instead fully self hosted/local. Improves privacy and
  performance over time. ([guide](https://youtu.be/nHCDEgZPP68?t=727))

- [gluetun](https://github.com/qdm12/gluetun-wiki/tree/main/setup/providers) (VPN client) + [qBittorent](https://docs.linuxserver.io/images/docker-qbittorrent/): Torrent client and combined with gluetun your ISP will not be able to see what you are doing with it. if you are on Proton VPN you
  might want this mod as the port forwarded port changes on every
  reboot. Here is my compose files for [gluetun](./configs/gluetun.compose) and [qBittorrent](./configs/qBittorrent.compose) using
  Proton VPN with WireGuard and Port Forwarding. (might need this [config.toml](./configs/config.toml) file as well after you started the containers.)

- [paperless-ngx]([GitHub - paperless-ngx/paperless-ngx: A community-supported supercharged version of paperless: scan, index and archive all your physical documents](https://github.com/paperless-ngx/paperless-ngx)): Document management, save physical or digital documents and organize them.

- [stirling-pdf]([GitHub - Stirling-Tools/Stirling-PDF: #1 Locally hosted web application that allows you to perform various operations on PDF files](https://github.com/Stirling-Tools/Stirling-PDF)): PDF editor/tool.

- [PairDrop]([GitHub - schlagmichdoch/PairDrop: PairDrop: Transfer Files Cross-Platform. No Setup, No Signup.](https://github.com/schlagmichdoch/PairDrop)): File transfer.

- [Glance]([GitHub - glanceapp/glance: A self-hosted dashboard that puts all your feeds in one place](https://github.com/glanceapp/glance)): Dashboard for all feeds in one place (RSS, subreddits, bookmarks, Youtube, etc...)

# Update

## OS update

1. When there is an update for the OS you will see a notification in the OpenMediaVault webui, click on it and then click on the "Updates available" notification. (Security updates are automatically installed already.)
    ![](images/2024-12-27-19-36-04-image.png) | ![](images/2024-12-27-19-36-23-image.png) 

2. It will open the System, Update management, Updates page. And it should show updates. Click on the download icon. 
   ![](images/2024-12-27-19-38-49-image.png)

3. Then confirm and click yes.
   ![](images/2024-12-27-19-44-17-image.png)

4. Wait until "END OF LINE" shows and click close, the page should refresh automatically and the update notification is gone.
   ![](images/2024-12-27-19-47-11-image.png)
   ![](images/2024-12-27-19-48-03-image.png)

## Docker update

You can install [Watchtower](https://hub.docker.com/r/v2tec/watchtower) in a docker container to either have it automatically update all (or selected) containers or use it as a way to be notified when there are updates available.

1. Go to OpenMediaVault and use the compose function and click add.

2. Name it watchtower and you can copy and paste the code from this [watchtower.compose](./configs/watchtower.compose) file to the code block. Edit the gmail to your own and create an app password like you did with uptime-kuma [here](#GMAIL) and use the created app password for this environment variable: "WATCHTOWER_NOTIFICATION_EMAIL_SERVER_PASSWORD".

3. Then start the container, and you can check the logs for it in either portainer or Dozzle. Sscan interval is set to 86400 seconds = 24 hours, so you either wait 24 hours to see if it really works or change the interval setting to a shorter period first and then adjust it afterwards.![](images/2024-12-29-00-49-57-image.png)![](images/2024-12-29-01-15-30-image.png)

4. Scanned and there were no updates so it did not send any notification.![](images/2024-12-30-20-33-54-image.png)

# Drive failure protection

I bought an 2 TB [NVME]([2TB WD_BLACK SN770 NVMe™ SSD | Western Digital](https://www.westerndigital.com/en-il/products/internal-drives/wd-black-sn770-nvme-ssd?sku=WDS200T3X0E)) M.2 SSD and put it in an SSD enclosure from [Orico](https://www.aliexpress.com/item/4001297316228.html) (make sure you get an enclosure compatible with your SSD, NVME PCIE M.2 = M-Key enclosure ) with some [heat sinks](https://www.aliexpress.com/item/1005005713814718.html) (around 26C with this setup while idle) as I wanted a way to get some drive failure protection. I am using a mix of openmediavault-backup plugin (for OMV configuration and OS) + snapraid (for media files)

1. Once the SSD has been installed inside the case with the heat sinks, connect it to the Pi (either by USB-C or USB-A, I used one of the USB-A 3.1 ports) then go to the storage, disks page in OpenMediaVault.![](images/2025-01-24-21-05-37-image.png)
   Shows up as a /dev/sda device with RTL9210B-CG being the USB bridge used in the enclosure with the correct capacity of the SSD inside it (2 TB).

2. Wipe the data, click on the correct drive you want to use as backup (MAKE SURE IT IS CORRECT OR IT WILL WIPE ALL YOUR EXISTING DATA!!!). ![](images/2025-01-24-21-13-06-image.png)
   ![](images/2025-01-25-01-48-17-image.png)

3. After the wipe go to the file systems page. Click on the create button and pick EXT4 then save.![](images/2025-01-25-01-53-44-image.png)![](images/2025-01-25-01-55-59-image.png)![](images/2025-01-25-02-18-24-image.png)

4. After you closed the file system creation window, you should see this.![](images/2025-01-25-02-19-43-image.png)
   The newly created file system should be in the list, select it and save. (You can add some tags if you want such as Backup or/and change the usage warning threshold.)

5. Should now be mounted. Click on the column settings and enable "identify as" and "mount point".![](images/2025-01-25-02-33-39-image.png)![](images/2025-03-05-21-15-39-image.png)

6. Go to Storage, Shared folders and click on the create button. Create a folder named omv-backups. ![](images/2025-03-05-21-17-02-image.png)![](images/2025-03-08-23-01-12-image.png)![](images/2025-03-08-23-02-29-image.png)
   
   ## SnapRAID
   
   1. Go to System, Plugins and search for "snapraid" and install it.![](images/2025-03-07-00-47-07-image.png)![](images/2025-03-07-00-49-14-image.png)
   
   2. Then the page should be refreshed and SnapRAID tab is under Services. Go to Services, SnapRAID, Arrays and click on the add button and give the array a name.![](images/2025-03-07-01-15-15-image.png)![](images/2025-03-07-01-15-49-image.png)![](images/2025-03-07-01-16-33-image.png)
   
   3. Then go to Services, SnapRAID, Drives and click on the add button. Select the array that was created in the previous step, your backup drive and then select parity and content and give it a name.![](images/2025-03-07-00-51-31-image.png)![](images/2025-03-07-01-36-38-image.png)
   
   4. Do the same but with your main drive and as a content&data drive.![](images/2025-03-07-01-19-35-image.png)
   
   5. Then go to the Rules section and click add. I have a shared folder "/Music" with my music so I use that with inclusion and then save. (needs trailing slash afterwards to include the content as well as the folder). Do the same but with exclusion for all other files "*". (make sure to add the inclusions you want first.) (note that if you want to include more folders, you need to remove the exclusion first and add it afterwards so it ends up at the bottom of the config file.)![](images/2025-03-07-01-28-11-image.png)![](images/2025-03-08-03-13-29-image.png)
   
   6. Go to the settings page and change scrub frequency to every day (1) and to 5%. full scrub should be done every 20 days. ![](images/2025-03-07-01-52-03-image.png)
   
   7. Go to system, scheduled tasks and edit the task to every day and enable it. (change time if needed but this runs every day at 02:30 AM.)![](images/2025-03-07-01-56-46-image.png)![](images/2025-03-07-01-58-02-image.png)
   
   8. Go to System, Services, Snapraid, Arrays and click on the array then tools and Sync. Took about 3 hours for my 570-ish GB music folder. ![](images/2025-03-08-19-38-48-image.png)![](images/2025-03-08-03-12-52-image.png)
   
   9. Then go to system, scheduled tasks and click on the create button. Enter this in the command section `for conf in /etc/snapraid/omv-snapraid-*.conf; do /usr/bin/snapraid -c ${conf} sync; done`  and then you can set it to your own preferred scheduled, if your data does not change often, you can set it to once a week or longer in between. I personally set this to run every other day. This is the period in between syncs for your media files (or whatever files/folder you included with snapraid). After you created the task, you may run it to make sure it works. Since I have no new files added since the last sync (from step 8) It is not doing anything.![](images/2025-03-08-19-47-54-image.png)![](images/2025-03-08-19-52-00-image.png)![](images/2025-03-08-19-51-39-image.png)
   
   ## OMV-backup
   
   1. Go to System, Plugins and search for backup and install openmediavault-backup.![](images/2025-03-08-20-27-03-image.png)
   
   2. Go to System, Backup, settings. Use fsarchiver as the method, omv-backups as backup destination, change keep (retention time) if needed (I have set it to 14 days) and under extra options exclude the shared folder Music (which has my music files but its protected by snapRAID so not needed here). And some other folders that are not needed to backup. `--exclude=/Music --exclude=/srv/dev-disk-by-uuid-09a0b6fd-1cd2-4e7c-a948-0cff7278adee` (change the uuid to your backup drive which you can see under storage, file systems![](images/2025-03-08-21-17-45-image.png)![](images/2025-03-08-21-06-44-image.png)
   
   3. Go to System, Backup, Schedule. Enable it and adjust the schedule if needed. I have set it so it runs once every week on sundays at 09:00.![](images/2025-03-08-21-19-27-image.png)
   
   4. Go do a manual backup to check if it works. Go to System, Backup, settings and click the backup button.![](images/2025-03-08-21-21-08-image.png)![](images/2025-03-08-22-44-05-image.png)

# Memory

Swap/ZRAM memory, depending on how much RAM you got for your Pi, you
might want to adjust the swap memory settings. If you got the 16GB
version like I do (or if you do not use much RAM and have plenty left
available) and use SD/SSD/USB drive for the OS. I would recommend to
adjust the Swappiness value to 10 so that the system priorities keeping
the data in the RAM instead of moving it to the swap but is high enough
that the system should move data to the swap before the RAM is
completely used up (and prevents risk of crash or other issues due to
lack of memory). This prevents the system from using the swap memory too
much which wears down flash memory very fast since they have a limited
write/erase cycles while also speeding up the system as RAM is
significantly faster than even NVME SSDs. However if you do not have
that much RAM and/or need to use a lot of it or more, then you should
both increase the Swappiness value and the amount. You may also use ZRAM
instead of Swap which compresses the data and keeps it in the RAM
instead of the disk which will help reduce wear on the flash memory
while also being faster than swap (although it does use some CPU
resources which can lead to increased CPU usage but with 8-core CPU in
the 5 Plus it should be negligible).

Here are some suggested values (from ChatGPT) (Use ChatGPT or another chatbot to guide you through this if you want.)

| **RAM**   | **Workload**               | **Storage** | **Disk-based Swap**        | **ZRAM**              | **Swappiness** |
| --------- | -------------------------- | ----------- | -------------------------- | --------------------- | -------------- |
| **4 GB**  | Light (e.g., desktop, IoT) | SD/USB      | 512 MB disk-based swap     | 512 MB ZRAM           | 10             |
|           | Heavy (e.g., Docker, ML)   | SD/USB      | Avoid disk-based swap      | 1–2 GB ZRAM           | 10             |
|           | Heavy                      | SSD         | 2–4 GB disk-based swap     | Optional: 1 GB ZRAM   | 10–20          |
| **8 GB**  | Light                      | SD/USB      | 512 MB disk-based swap     | 512 MB–1 GB ZRAM      | 5–10           |
|           | Heavy                      | SD/USB      | Avoid disk-based swap      | 1–2 GB ZRAM           | 10             |
|           | Heavy                      | SSD         | 4–8 GB disk-based swap     | Optional: 2 GB ZRAM   | 10–20          |
| **16 GB** | Light                      | SD/USB      | 256–512 MB disk-based swap | 512 MB–1 GB ZRAM      | 1–5            |
|           | Heavy                      | SSD         | 2–4 GB disk-based swap     | Optional: 2–4 GB ZRAM | 10–15          |

# Statistics

## Power consumption

Orange pi 5 Plus with 2 NVME SSDs, I added the second drive around January 8t and the power consumption hovers around the 6-8W range with under 5kW.h each month:![](images/2025-03-08-23-19-56-image.png)![](images/2025-03-08-23-17-11-image.png)

For reference my Synology DS423+ with 2x16TB, 1x18TB HDD and 1x2TB NVME SSD drives consume:![](images/2025-03-08-23-22-01-image.png)

Which after factoring in the 3 HDD drives (datasheet puts them at around 5W each) should mean that the Synology DS423+ consumes around 12W which is almost 2x the power consumption of the Orange Pi 5 Plus (despite having a weaker CPU).

## Resource usage

![](images/2025-03-08-23-26-04-image.png)![](images/2025-03-08-23-27-19-image.png)![](images/2025-03-08-23-27-32-image.png)![](images/2025-03-08-23-27-41-image.png)![](images/2025-03-08-23-28-26-image.png)

# UPS

An UPS can be a mandatory need, depending on your use of the Pi and/or the frequency of outages where you live. With the Waveshare UPS Module 3S with 3X3200mAh batteries, with the Orange Pi 5 Plus 16GB RAM with 1TB NVME SSD running around 5,5W idle, it can last for around 6 hours. Which is plenty for the extremely rare and/or short outages I get. But do note that this UPS Module 3S does NOT have any support for automatic shutdown so if you want the Pi to automatically shutdown when the UPS switches to battery mode, you would need to buy a "proper" UPS from like Eaton/APC which usually communicates via a USB cable. Trade off would be the MUCH larger size of the UPS from these other brands, more expensive, not as easy to replace batteries and that they likely consume a lot more power than the Pi you are running with it.

# Troubleshooting

- If the webui for OpenMediaVault just keeps loading but you can still use SSH and use the docker containers, try to reboot using the Terminal/SSH (sudo reboot) or clear the browser cache (CTRL+SHIFT+R) and it should be fixed. 
- If after a reboot, you cannot access the Pi via SSH, webui nor any docker containers and the ethernet port LED is OFF but the power LED is blinking normally, try to connect it to a monitor and check what it says. Here are some pictures on when it happened to me:![](images/2025-01-05-23-58-01-image.png)![](images/2025-01-05-23-58-14-image.png)![](images/2025-01-05-23-58-23-image.png)![](images/2025-01-05-23-58-42-image.png)
  Just type in `fsck.ext4 -f /dev/nvme0n1p1` and click "y" to all, then type in "reboot" at the end and it was fixed for me.

# NAS comparison

| **Category**                      | **Orange Pi 5 Plus**                                                                                                                                                                                                                                                                                                                           | **Orange Pi 5 Plus + DAS (TERRAMASTER D4-300)**                                                                                                                                                                                                                          | **Synology DS423+**                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| --------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Price** (varies by region/time) | ≈ $225                                                                                                                                                                                                                                                                                                                                         | ≈ $395                                                                                                                                                                                                                                                                   | $500                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| **Size**                          | Extremely tiny, fits in my palms                                                                                                                                                                                                                                                                                                               | Virtually the same size as the DS423+ except with the tiny Pi 5 Plus on top or beside it                                                                                                                                                                                 | 2–3x larger in each direction compared with just the Pi 5 Plus                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| **Power usage**                   | Extremely low, idles at around 6-8W with this setup with a 1TB + 2TB NVME M.2 SSD. About 4.7-5.0kW.h/month.                                                                                                                                                                                                                                    | Extremely low, the D4-300 itself draws 2.8W ([source](https://www.reddit.com/r/DataHoarder/comments/151cyko/comment/js9l4jj/)) or 14W with 2x18TB WD Red Pro (same source), so add that to the 6-8W idle that the Pi 5 Plus have, and you are looking at more than 20 W. | 8.45-28.3W according to Synology. But around 12W in my case (after excluding HDDs)                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| **Scalability**                   | Decent, while you technically can upgrade RAM afterwards you would need to solder it yourself with the compatible memory chip (might be hard to find) but from 4 to 16GB RAM options. Dual 2.5Gbps Ethernet ports, cannot change CPU though. 1 NVME slot with 2 USB 3.0 connectors that you can use with external storage cases/DAS if needed. | With a DAS such as the D4-300 you will have more freedom in how you upgrade it later. For a performance increase, just replace the Pi (SBC), for more storage you can either just swap the DAS for a bigger one or just add another DAS as there are 2 USB 3.0 slots.    | Very poor, officially supports up to 6GB RAM but I can personally confirm it works with 18GB RAM problem is that you will not get any customer service support if anything goes wrong (goes for their limited list of HDD that they officially support). Cannot change CPU and Ethernet ports are stuck on 1Gbps. Up to 4 storage bays and 2 NVME slots, does not support their own Expansion units. If you want an upgrade in storage you can get a DAS though like the D4-300. For better performance you need to swap out the entire NAS. |
| **CPU Performance**               | Great efficiency and can handle some heavier docker containers (such as game servers like Azeroth core Wow)                                                                                                                                                                                                                                    | Great efficiency and can handle some heavier docker containers (such as game servers like Azeroth core Wow)                                                                                                                                                              | Decent and works if only used as a NAS but with many or heavier docker containers and it is obvious it is slow.                                                                                                                                                                                                                                                                                                                                                                                                                              |
| **Network Speed**                 | Has dual 2.5Gbps Ethernet ports so clearly faster than the 1Gbps on the Synology                                                                                                                                                                                                                                                               | Has dual 2.5Gbps Ethernet ports so clearly faster than the 1Gbps on the Synology                                                                                                                                                                                         | Only a single 1Gbps Ethernert port                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| **Security**                      | Harder to manage than Synology                                                                                                                                                                                                                                                                                                                 | Harder to manage than Synology                                                                                                                                                                                                                                           | Built into the Synology DSM OS and easier to manage                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| **Ease of setup**                 | Requires manual installation and setup of the software (OS), hopefully easier with this guide though                                                                                                                                                                                                                                           | Identical with the Orange Pi 5 Plus only setup except with the additional DAS setup (which should be similar to just adding another drive)                                                                                                                               | Plug-and-play setup pretty much with clear guides from Synology if needed.                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |

Note: the Pi 5 Plus setup is with the 16GB RAM option with the case, sd
card, heatsink, fan, UPS, batteries and charger. Does not include
storage cost for any of them.

# Self-Hosted Streaming vs. Commercial Services: Cost Breakdown

| **Service**                | **Upfront Cost (USD)** | **Monthly Cost (USD)** | **Yearly Cost (USD)** | **Time to Match Self-Hosted Cost (Months)** |
| -------------------------- | ---------------------- | ---------------------- | --------------------- | ------------------------------------------- |
| **Orange Pi 5 Plus Setup** | ≈ $186                 | $0                     | $0                    | -                                           |
| **Apple Music**            | $0                     | $10.99                 | $131.88               | 17 Months                                   |
| **Tidal HiFi**             | $0                     | $10.99                 | $131.88               | 17 Months                                   |
| **Spotify Premium**        | $0                     | $11.99                 | $143.88               | 16 Months                                   |
| **YouTube Music**          | $0                     | $10.99                 | $131.88               | 17 Months                                   |

Note: the Pi 5 Plus setup is with the 4GB RAM option with the case, sd
card, heatsink, fan, UPS, batteries, charger along with a 500GB NVME
SSD. 512GB for storage was picked as most of you (Audiophiles that voted in my poll) have over 10 000 tracks
which ranges from 84GB if they are 320kbps up to around 350GB if with
FLAC so this will be more than enough for that and to be able to have
your system files on it as well. 4GB RAM was chosen as that is enough to
use as a media server with external access via PiVPN.

Compared to using streaming services, where tracks may or may not be
removed (legal issues, ethical/controversies concerns, artist/label
decisions or due technical/administrative reasons), using a self hosted
media service with your own local files means you only need to spend a
year or two until you have recouped the initial upfront cost and you
also know what files you are using as some streaming services may have
bad mastered tracks (even if they are lossless).

# Conclusion

If you want a cheap, flexible and more future proof method of self hosting your own NAS/Server going with an Orange Pi 5 Plus (or any other comparable SBC) is the better option in my opinion than a prebuilt NAS such a Synology or Terra Master NAS as they are much more limited in what you can or cannot do. However, if you want an easier and faster way to setup your own NAS a prebuilt NAS will be more fitting. 
