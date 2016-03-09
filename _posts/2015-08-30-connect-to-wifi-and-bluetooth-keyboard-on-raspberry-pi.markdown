---
layout: post
title: 삽질 없이 라즈베리 파이 2 모델 B에 와이파이와 블루투스 키보드 연결하기 (커맨드 라인으로)
author: 박연오(bakyeono@gmail.com)
date: 2015-08-30 20:57 +0900
tags: 라즈베리-파이 와이파이 블루투스 리눅스
---
* table of contents
{:toc}

라즈베리 파이에는 아직 무선 환경을 위한 장치가 달려 있지 않다. 그래서 와이파이와 블루투스 장치를 연결하려면 별도의 장치를 설치해야 하고 몇 가지 설정 작업도 해야 한다.

인터넷에 이와 관련한 가이드가 많이 올라와 있다. 그런데 많은 가이드가 그 내용이 영원히 적용될 듯이 씌어 있지만 라즈베리 파이와 리눅스 버전이 올라갈 때마다 맞지 않는 내용들이 생긴다. 특히 와이파이 잡는 방법은 여러 글마다 다르게 설명돼 있어 나도 어려움을 많이 겪었다.

이 글은 라즈비안 2015-05-05 버전이 설치된 라즈베리 파이 2 모델 B에 와이파이와 블루투스 키보드를 연결하는 (아마도) 가장 간단한 방법이다.

이 글은 2015년 8월 30일에 썼다. 이 글도 시간이 흐르면 맞지 않게 될 테니 시간이 많이 지났다면 다른 가이드를 찾아 보기 바란다.

## 1. 와이파이 연결하기

무선네트워크 보안 설정은 WPA-PSK 또는 WPA2-PSK 로 설정돼 있는 걸 전제로 한다. 만일 다른 방식으로 보안이 설정돼 있다면 보안이 취약한 네트워크이니 사용하지 말고, 보안 설정을 변경할 수 있다면 안전한 방식으로 바꿔라.

그리고 당연한 이야기지만 라즈베리 파이 2 모델 B에는 무선 랜카드가 내장되어있지 않기 때문에 USB 무선 랜카드를 장착해야 한다. 드라이버 설치하는 방법까지는까지 이 글에서 설명하기 어렵다. 왠만한 USB 무선 랜카드는 자동으로 드라이버가 잡힐 것이다.

### /etc/network/interfaces 파일은 건드리지 마라!

인터넷 글을 보면 `/etc/network/interfaces` 파일을 수정하라는 글이 많을 것이다. 아니다. 건드리지 마라. 라즈베리 파이 2는 이미 무선 네트워크를 쉽게 연결할 수 있도록 미리 설정이 돼 있다. 그러니까, 그 파일을 건드리지 마라!

혹시 이 파일을 이미 수정했다면, 원래 상태로 돌려라. 원래 상태는 아래 내용과 같다.

    auto lo
    
    iface lo inet loopback
    iface eth0 inet dhcp
    
    allow-hotplug wlan0
    iface wlan0 inet manual
    wpa-roam /etc/wpa_supplicant/wpa_supplicant.conf
    iface default inet dhcp

이 설정은 wpa roaming을 이용해 자동으로 무선 네트워크에 접속하도록 한다.

### /etc/wpa_supplicant 파일만 수정하면 된다

무선 네트워크 설정은 `/etc/wpa_supplicant/wpa_supplicant.conf` 파일에 하면 된다.

관리자 권한으로 이 파일을 수정한다.

    $ sudo vi /etc/wpa_supplicant/wpa_supplicant.conf

그러면 파일 내용은 아래와 같을 것이다.

    ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
    update_config=1

그 아래 줄에 접속한 무선 네트워크를 설정해두면 된다. 아래와 같이 한다.

    ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
    update_config=1

    network={ 
        ssid="접속할 AP ID"
        psk="비밀번호"
    }

스마트폰을 쓸 때처럼 무선 네트워크를 여러 개 설정해두고 싶다면? network를 여러 개 지정해두면 된다.

    ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
    update_config=1

    network={ 
        ssid="접속할 AP ID"
        psk="비밀번호"
    }
    network={ 
        ssid="회사 AP"
        psk="비밀번호"
    }
    network={ 
        ssid="카페 AP"
        psk="비밀번호"
    }

### 변경한 설정 적용하기

이제 시스템을 재시작하거나

    $ sudo reboot

그냥 네트워크만 다시 연결하도록 해도 된다.

    $ sudo ifdown wlan0
    $ sudo ifup wlan0

(인트라넷이 아니라면) 인터넷이 잘 되는지 확인해본다.

    $ ping google.com
    PING google.com (59.18.49.251) 56(84) bytes of data.
    64 bytes from cache.google.com (59.18.49.251): icmp_req=1 ttl=56 time=6.80 ms
    64 bytes from cache.google.com (59.18.49.251): icmp_req=2 ttl=56 time=3.77 ms
    64 bytes from cache.google.com (59.18.49.251): icmp_req=3 ttl=56 time=7.92 ms
    
    --- google.com ping statistics ---
    3 packets transmitted, 3 received, 0% packet loss, time 2002ms
    rtt min/avg/max/mdev = 3.777/6.168/7.927/1.752 ms

## 2. 블루투스 키보드 연결하기 (라즈비안 2015-05-05 버전 기준)

라즈베리 파이 2 모델 B에는 무선 랜카드뿐 아니라 블루투스 동글도 달려있지 않다. 따라서 블루투스 장치를 쓰고 싶다면 별도로 USB 동글을 장착해줘야 한다. 이 글은 USB 동글을 설치했고, 드라이버도 정상적으로 작동한다는 것을 전제로 한다. 일반적인 블루투스 동글은 USB를 연결하면 드라이버가 바로 잡힐 것이니 걱정하지 않아도 된다.

### 필요한 패키지 설치

라즈비안에는 블루투스 장치 연결에 필요한 소프트웨어가 기본 설치되어 있지 않다. 따라서 블루투스 장치 지원을 위한 몇 가지 패키지를 설치해야 한다.

우선 apt 저장소 업데이트를 안했다면 해 둔다.

    $ sudo apt-get update
    $ sudo apt-get upgrade

다음 명령으로 블루투스 지원 패키지를 설치한다.

    $ sudo apt-get install bluetooth blue-utils


dBus를 활성화한다.

    $ sudo update-rc.d -f dBus defaults

라즈베리 파이를 재시작한다.

    $ sudo reboot

### 장치 검색

블루투스 키보드의 페어링 버튼을 몇 초 동안 꾹~ 누르고, 아래 명령으로 장치를 검색한다. (장치를 찾지 못하거나 오류가 발생하면 페어링 버튼을 다시 누르고 해보라.)

    $ sudo hcitool scan
    Scanning ...
            00:0D:F0:8B:12:33 LG-PC
            00:1F:20:F0:20:12 Logitech Keyboard K480

이런 식으로 장치가 나오면 성공이다. 연결하려는 장치의 MAC 주소를 확인해둔다. (이 경우엔 `00:1F:20:F0:20:12`)

### 장치 연결

다시 블루투스 키보드의 페어링 버튼을 꾹 누르고, 아래 명령으로 장치를 연결한다.

    $ sudo bluez-simple-agent hci0 00:1F:20:F0:20:12

> 주의: 여러분은 `00:1F:20:f0:20:12`가 아니라, 위에서 발견한 MAC 주소를 입력해야 한다.

PIN 번호를 입력하는 다이얼로그가 다오면 `0000`을 입력하고 엔터 키를 누른다. 그 후 블루투스 키보드로 `0000`을 입력하고 엔터 키를 누르면 된다.

오류가 발생하면 블루투스 키보드의 페어링 버튼을 다시 꾹~ 누르고 다시 시도해보라.

장치를 신뢰할 수 있는 장치로 연결해 둔다. 그래야 앞으로 연결 작업을 반복하지 않는다.

    $ sudo bluez-test-device trusted 00:1F:20:F0:20:12 yes

> 주의: 여러분은 `00:1F:20:f0:20:12`가 아니라, 위에서 발견한 MAC 주소를 입력해야 한다.

아직 블루투스 키보드가 작동하지 않을 것이다. 아직 한 단계가 더 남았다. 아래 명령을 입력한다.

    $ sudo bluez-test-input connect 00:1F:20:F0:20:12

> 주의: 여러분은 `00:1F:20:f0:20:12`가 아니라, 위에서 발견한 MAC 주소를 입력해야 한다.

이제 시스템을 재시작한다. 부팅 과정이 끝나고 몇 초 뒤 블루투스 키보드를 사용할 수 있을 것이다.

## 3. (2016-02-16에 내용 추가) 블루투스 키보드 연결하기 (라즈비안 JESSIE 2016-02-09 버전 기준)

> 오랜만에 확인해 보니 라즈비안 버전이 갱신되어 이전 방법으로는 블루투스를 연결할 수 없다. 이전 방법에 필요한 blue-utils 패키지가 아예 저장소에서 삭제되었다. 대신 bluez-tools 패키지의 유틸리티를 이용해야 한다. 따라서 2번 항목에 소개한 방법을 따르지 말고 여기 쓴 새로운 방법을 따르기 바란다. 이것도 날짜가 많이 경과했다면 배포판 버전이 달라 안 먹힐 수 있으니 유의하라.

라즈베리 파이 2 모델 B에는 무선 랜카드뿐 아니라 블루투스 동글도 달려있지 않다. 따라서 블루투스 장치를 쓰고 싶다면 별도로 USB 동글을 장착해줘야 한다. 이 글은 USB 동글을 설치했고, 드라이버도 정상적으로 작동한다는 것을 전제로 한다. 일반적인 블루투스 동글은 USB를 연결하면 드라이버가 바로 잡힐 것이니 걱정하지 않아도 된다.

### 필요한 패키지 설치

라즈비안에는 블루투스 장치 연결에 필요한 소프트웨어가 기본 설치되어 있지 않다. 따라서 블루투스 장치 지원을 위한 몇 가지 패키지를 설치해야 한다.

우선 apt 저장소 업데이트를 안했다면 해 둔다.

    $ sudo apt-get update
    $ sudo apt-get upgrade

다음 명령으로 블루투스 지원 패키지를 설치한다.

    $ sudo apt-get install bluetooth bluez-tools

라즈베리 파이를 재시작한다.

    $ sudo reboot

### 장치 검색

블루투스 키보드의 페어링 버튼을 몇 초 동안 꾹~ 누르고, 아래 명령으로 장치를 검색한다. (장치를 찾지 못하거나 오류가 발생하면 페어링 버튼을 다시 누르고 해보라.)

### 장치 연결

커맨드라인에서 다음 명령을 실행한다.

    $ bluetoothctl -a KeyboardOnly

그러면 블루투스 동글을 직접 조작할 수 있는 대화식 프로그램이 실행된다. `help`를 입력하면 사용 가능한 명령어 목록이 나오니 참고하자. 명령어에는 블루투스 동글의 상태를 조작하는 명령어와 접속 대상 장치와 관련된 명령어가 있어서 처음에는 헷갈리기 쉽다.

    [bluetooth]# help

자세한 내용은 프로그램 매뉴얼을 참고하고, 블루투스 키보드 연결을 위해서는 아래 명령어를 따라 입력하면 된다. 먼저 라즈베리 파이에 연결된 블루투스 동글을 확인한다.

    [bluetooth]# list
    Controller 00:15:83:12:12:E7

이 때 나오는 Contoller의 MAC 주소가 블루투스 동글의 MAC 주소다. 이 MAC 주소를 입력해 이 장치를 선택하고, 전원을 켜고, 페어링 모드를 켜고, 스캔을 활성화한다. (`discoverable`은 켜지 않아도 되는 듯한데, 혹시 안 되면 `discoverable on` 으로 켜고 해본다.)

    [bluetooth]# select 00:15:83:12:12:E7
    [bluetooth]# power on
    Changing power on succeded
    [bluetooth]# pairable on
    Changing pairable on succeded
    [bluetooth]# scan on
    Discovery started

`Discovery started` 메시지가 나오면 블루투스 키보드의 연결 버튼을 꾹 눌러 키보드가 발견되도록 한다.

    [New] 00:1F:20:F0:20:12 Device Logitech Keyboard K480

키보드가 발견되었으면 연결할 키보드의 MAC 주소로 페어 명령을 실행한다.

> 주의: 여러분은 `00:1F:20:f0:20:12`가 아니라, 위에서 발견한 MAC 주소를 입력해야 한다.

    [bluetooth]# pair 00:1F:20:F0:20:12
    Attempting to pair with 00:1F:20:F0:20:12
    [agent] PIN code: 123456

출력된 PIN을 **블루투스 키보드로** 입력하고 엔터키를 누른다.

    Pairing successful

장치를 신뢰할 수 있는 장치로 연결해 둔다. 그래야 앞으로 연결 작업을 반복하지 않는다.

    [bluetooth]# trust 00:1F:20:F0:20:12
    
마지막으로, 장치에 접속시킨다.

    [bluetooth]# connect 00:1F:20:F0:20:12
    Connection successful

`quit`를 입력해 설정 프로그램을 종료한다. 

    [bluetooth]# quit

이제 키보드를 사용할 수 있을 것이다. 또한, 시스템을 재시작하더라도 부팅 과정이 끝나고 몇 초 뒤 블루투스 키보드를 사용할 수 있을 것이다.


## 보너스

### 루비 설치

apt 저장소에 있는 루비를 설치하면 멘붕을 경험하게 된다. 멘붕없이 설치하려면 아래 가이드를 따르면 된다.

* [멘붕없이 RVM과 루비 설치하기](http://bigmatch.i-um.net/2013/12/%EB%A9%98%EB%B6%95%EC%97%86%EC%9D%B4-rvm%EA%B3%BC-%EB%A3%A8%EB%B9%84-%EC%84%A4%EC%B9%98%ED%95%98%EA%B8%B0/)

### Node.js 설치

라즈베리 파이의 apt 저장소에 있는 Node.js는 낡은 버전이다. 최신 버전 Node.js를 설치하고 싶으면 아래 사이트에 나온 방법을 따르면 된다.

* [node-arm](http://node-arm.herokuapp.com)


