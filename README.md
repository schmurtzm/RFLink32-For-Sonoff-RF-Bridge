# RFLink32 for Sonoff RF Bridge


This is a customized version of RFlink32 for Sonoff RF Bridge.
This powerful firmware supports to transmit decrypted RF frames with following protocols :
- serial
- ser2net ( serial interface over TCP)
- MQTT

It is entierely based on [RFlink32](https://github.com/cpainchaud/RFLink32 "RFlink32"), I have only configured the firmware to work out of the box with the Sonoff RF bridge and removed functionnalities to be able to run it on the ESP8285 of the Sonoff (only 1MB of memory).
Removed functionnalities are : OTA, Online update, possibility to configure other RF receivers. The Original RFlink32 UI has been modified to remove these unvaible settings. [Here the modified UI repo](https://github.com/schmurtzm/rflink-webui "RFlink32 UI Modified").


<img src="https://user-images.githubusercontent.com/7110113/143656552-5f4018af-b972-4762-a367-e4f44412a5c4.png" width="200" height="200"> <img src="https://user-images.githubusercontent.com/7110113/143656585-3943148c-ace1-451a-be2e-974c943e7f06.png" width="200" height="200">
<img src="https://user-images.githubusercontent.com/7110113/143656589-3dc855c3-0ce1-45b9-ac08-17204f9c4b2c.png" width="200" height="200">
<img src="https://user-images.githubusercontent.com/7110113/143656592-8c56f72f-bddb-47e0-b1ce-be1f18ef8df7.png" width="200" height="200">
# How to install : 

### Hardware mod : "Direct Hack"
> This firmware require a hardware hack called "direct hack" to work correctly. The idea is to bypass the chip which decrypt signal on the sonoff and connect directly the RF chip to the ESP8285.
> 
> Here the tutorial for the 2021 Sonoff RF Bridge (R2 v2.2).  [Credits mateine from Home Assistant Forum](https://community.home-assistant.io/t/new-sonoff-rf-bridge-board-need-flashing-help/344326/17 "Credits mateine from Home Assistant Forum") who give the solder points for the R2 V2.2 of the Sonoff RF Bridge.  
> > 
> (For older boards (R1 V1.0 and BOARD R1 V2.0) I recommend [this excellent documentation from ESPurna / Tinkerman](https://github.com/xoseperez/espurna/wiki/Hardware-Itead-Sonoff-RF-Bridge---Direct-Hack "this excellent documentation from ESPurna / Tinkerman") !)  
> 
> 
> > Cut GPIO  :
> 	Sonoff RF Bridge Cut
> 
> <img src="https://user-images.githubusercontent.com/7110113/143658020-4577b195-2692-4183-942b-be5a5cbf23d7.png" width="200" height="200">  
> 
> > Connect the transmitter : 	USBTXD → pin 4 of the 6-legged chip (purple cable, bottom left pin in the image)  
>
> > Connect the receiver :  USBRXD → pin 5 of the 8 legged chip near the LEDs (green cable, bottom right pin in the image)  
>   <img src="https://user-images.githubusercontent.com/7110113/143658031-5545e1ab-cd9e-4d7e-9f12-171bdd176598.png" width="200" height="200">  



### Flash :
> To put in flashing mode, press the ‘pairing button’ while inserting the FTDI in USB.  
> Then run the script tools\Flash_Sonoff_RF.bat . It will :  
>   - ask you to disconnect and reconnect the sonoff in "flashing mode" for eatch step
>   - make a backup of the original firmware of your sonoff
>   - full erase of the esp8266
>   - flash the RFlink32 firmware

> Then go on your mobile phone and find the wifi access point called "RFLink-AP", connect to it and naviguate to adress : http://192.168.4.1  then you will be able to configure your own Wifi.  
> Alternatively you can configure the wifi by sending a command on serial port (with a software like termite) :  
> ```10;config;set;{"wifi":{"client_enabled":true,"client_dhcp_enabled":true,"client_ssid":"MySSID","client_password":"MyPassword"}}```  
> The new IP adress will be displayed on serial monitoring.
> You can compile this code with platformio or you can download a compiled firmware and use the script on Windows) :

### Configure :
> Once your own wifi activated, you can now disable the Access point (AP). You can also :
>   - activate MQTT
>   - activate Ser2net 
>   - configure some Signals settings

> If you are familiar with [ESPhome Flasher](https://github.com/esphome/esphome-flasher/releases), [Tasmotizer](https://github.com/tasmota/tasmotizer/releases/) or [NodeMCU PYFlasher](https://github.com/marcelstoer/nodemcu-pyflasher/releases), you can use it too but I would recommand to make a complete erase of your ESP8285 before.

# Some informations about this firmware : 

   - Support Rflink protocol with multiple output supported :
		○ serial
		○ ser2net ( serial interface over TCP)
		○ MQTT
   -  Web server for configuration and wifi provisionning
   - Wifi Access Point for first configuration
   - web API for configuration, reboot , status
   - configuration over serial

# Why I would prefer this firmware compared to ESPHome, Tasmota or ESPurna ?
- This firmware is dedicated to RF. Unlike Tasmota or ESPhome it doesn't transmit raw information of the RF signal : it analyse the RF frame, decrypt it and send the result.
- So for example many Temperature and Humidity devices are natively recognized by Rflink 32.
- Example when I press a simple RF433 button you will have this result :
  - ESPhome :
    ```
		[remote.rc_switch:256]: Received RCSwitch Raw: protocol=1 data=100110100000000000000110
  - Tasmota :
    ```
		tele/sonoffRFbridge/RESULT = {"RfRaw":{"Data":"AA B1 03 07F9 0124 37DC 010101010101101001010101101010100102 55"}}
  - RFlink32 :
    ```
		20;02;AB400D;ID=60;SWITCH=01;CMD=OFF;
    ```
    20        => Node number 20 means RF message received;       => field separator  
    02        => packet counter (goes from 00-FF)  
    AB400D    => RF Protocol / Device name  
    ID=60     => device ID (often a rolling code and/or device channel number) (Hexadecimal)  
    CMD=OFF   => Command (ON/OFF/ALLON/ALLOFF)  
    
    
	As you can observe Rflink32 output offers a better understanding of the received RF frame.

- The Rflink protocol is directly compatible with Home Assistant (it can add the entities for many sensors automatically) and many others home automation softwares.  
- There are many example of the Rflink community to easily handle the Rflink protocol with your favorite software (Node Red, Home Assistant, Jeedom ,…)  
- Futhermore you can extend the list of decrypted RF protocols with the Rflink protocols files.  

====================================================
# API : 
```/api/status```   : display the current status of the gateway (uptime, wifi state,  MQTT state, ser2net state, number of RF message received…)

```/api/config```  : allow to configure your device, for exemple you can run this POST command :
http://192.168.0.xxx/api/config
```{"wifi":{"client_enabled":true,"client_dhcp_enabled":true,"client_ssid":"MySSID","client_password":"MyPassword","client_ip":"192.168.0.200","client_mask":"255.255.255.0","client_gateway":"192.168.0.1","client_dns":"192.168.0.1","client_hostname":"RFLink32","ap_enabled":false,"ap_ssid":"RFLink-AP","ap_password":"","ap_ip":"192.168.4.1","ap_network":"192.168.4.0","ap_mask":"255.255.255.0"},"mqtt":{"enabled":true,"server":"192.168.0.250","port":1883,"id":"ESP8266-RFLink_xxx","user":"xxx","password":"xxx","topic_in":"/ESP00/cmd","topic_out":"/ESP00/msg","lwt_enabled":true,"topic_lwt":"/ESP00/lwt","ssl_enabled":false,"ssl_insecure":true,"ca_cert":""},"portal":{"enabled":true}}```

API over serial (if you still have your usb FTDI connected to the Sonoff Rfbrige), example :  
`10;config;set;{"wifi":{"client_enabled":true,"client_dhcp_enabled":true,"client_ssid":"MySSID","client_password":"MyPassword"}}`  
`10;REBOOT;`  
`10;rfdebug=<on|off>`  
`10;reboot;`  
`10;config;dump;`  
`10;config;reset;`  



[Full API Documentation Here](https://github.com/cpainchaud/RFLink32/blob/master/CLI_Reference_Guide.md)

# Know issues :
- Rfdebug is not possible due to the lack of memory
- If you see UI problems (json not loader fully) then make a full erase of your ESP8285 before flashing the firmware (you can try to increament the StaticJsonDocument<xxx> value in the file "11_config.cpp".


[Original RFlink32 Documentation](https://github.com/schmurtzm/RFLink32-For-Sonoff-RF-Bridge/blob/master/Original_RFlink32_Documentation.md)

---

Special Thanks to [Couin3](https://github.com/couin3/RFLink), [Erau](https://github.com/cpainchaud/RFLink32) and [many others](https://github.com/cpainchaud/RFLink32/graphs/contributors) for their awesome work on RFlink version which works on arduino, ESP8266 and ESP32 !  

Come to [talk with us about RFlink-ESP and RFlink32 on discord](https://discord.gg/YqrPDHuNPP) !