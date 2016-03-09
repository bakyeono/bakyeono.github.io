---
layout: post
title: "간디 도메인(gandi.net) DDNS 설정"
author: 박연오(bakyeono@gmail.com)
date: 2014-03-24 20:29 +0900
tags: 네트워크 도메인
---
* table of contents
{:toc}

[No bullshit™][gandi.net-no-bullshit] 정책이 마음이 들어서 간디 도메인([gandi.net][gandi.net])을 쓰고 있다. 다른 건 나름 좋은데 얼마전 [DDNS][ddns] 설정할 일이 있어 알아보니 아쉽게도 간디 도메인은 DDNS 설정을 지원하지 않는다고 한다!

하지만 대신 [DNS 구역][dns] 설정을 수정할 수 있는 웹 API가 제공된다. 그리고 이 API를 쉽게 이용할 수 있도록 하는 [파이썬 프로그램][gandi-dyndns]도 누군가가 만들어놓았다.

이것들을 이용하니 간디 도메인 사용자도 DDNS 업데이트가 어렵지 않다.

## 준비물

- 간디 도메인
- 리눅스가 설치된 서버

## 간디 도메인 사이트에서 API 키 발급

먼저 간디 도메인 사이트에서 API 키를 발급받아야 한다. 아래 순서를 따르자.

### API management 페이지 접속

간디 도메인 사이트에 로그인한 다음 [My Account -> Account management -> API management][gandi.net-api-management] 메뉴를 클릭한다.

### 테스트 플랫폼용 API 키 발급

Activation of the API on the test platform (OT&E) 섹션의 Status를 Activated로 지정하고, Change status 버튼을 누른다.

그러면 API 키 생성 중이라는 메시지가 나온다. 5~10분 정도 기다리면 키가 발급된다.

**주의: 키를 외부에 노출하지 말 것.**

### 진짜 API 키 발급

사실 테스트 플랫폼용 API 키는 필요없다. 다만 진짜 API 키는 먼저 테스트 플랫폼용 키를 받은 다음에 받을 수 있기 때문에 위의 과정을 거친 것이다. 이제 진짜 API 키를 발급받자.

Activation of the production API 섹션의 API XML Status를 Activated로 지정하고, 암호를 지정한 다음, Submit 버튼을 누른다.

그러면 이번에도 API 키 생성 중이라는 메시지가 나오고 5~10분 정도 기다리면 키가 발급된다.

**주의: 키를 외부에 노출하지 말 것.**

## 갱신할 DNS 네임 만들어 두기

### DNS Zones 페이지 접속

간디 도메인 사이트에 로그인한 다음 [My Account -> Services -> Domains -> DNS Zones][gandi.net-dns-zones] 메뉴를 클릭한다.

### DNS Zones 설정 복사본 만들어 수정

수정할 DNS Zones 파일을 하나 열고, Create a new version 을 클릭해 새로운 DNS Zones 버전을 생성한다.

그후 Add 버튼을 눌러 관리하고자 하는 DNS 네임 레코드를 추가한다. 각 필드에 입력할 값은 다음과 같다.

- Type: A 선택
- TTL: 설정값 유효기간. 즉, 갱신 주기다. 5분에서 3시간 등 다양하게 지정할 수 있다. 나는 15분으로 했다.
- Name: www, home, blog, app 등 사용할 레코드 네임.
- Value: 링크할 주소. 우리는 API를 통해 이 값을 꾸준히 수정할 것이다. 일단 잘 변경되는지 테스트를 하기 위해 대충 아무 ip 주소 또는 도메인을 입력해 두자. (예: 127.0.0.1, google.com 등)

### 새로 만든 복사본을 사용 버전으로 지정

Use this version 을 클릭해 이 버전을 사용하도록 지정한다.

## DNS 갱신 프로그램 설치와 설정

### gandi-dyndns 프로그램 설치

터미널에서 다음을 입력한다.

    $ cd ~
    $ git clone https://github.com/lembregtse/gandi-dyndns.git
    $ sudo chown -R root:root gandi-dyndns
    $ sudo mv gandi-dyndns /usr/local

설치 완료.

### gandi-dyndns 사용

gandi-dyndns 사용법은 다음과 같다.

    $ gandi-dyndns --api=APIKEY --domain=DOMAIN --record=RECORD

시험삼아 터미널에 이 명령을 입력해보자. 물론, APIKEY, DOMAIN, RECORD는 적절한 값으로 바꿔야 한다. 프로그램을 실행하고 잠시 기다리면 현재 IP가 도메인 서버의 네임 설정에 반영되고 그 결과가 터미널에 출력될 것이다. 이 부분이 제대로 안 되면 무언가 잘못 한 것이고 더 진행할 수 없으므로 잘 확인하자.

갱신이 된 후에도 도메인 네임 서버에서 이것이 적용되기까지는 시간이 걸릴 수 있으니 바로 되지 않는다고 조바심을 내지 말자.

### ddns 업데이트 스크립트 만들기

gandi-dyndns 프로그램을 그냥 써도 무방하지만, 나는 업데이트 설정을 쉽게 고치고 로그 기록도 남기기 위해서 간단한 쉘 스크립트를 짰다. 여러분도 이 스크립트를 복사해서 쓰면 편리할 것이다.

선호하는 편집기를 이용해 /usr/local/bin/update-ddns 텍스트 파일을 생성한다. root 권한이 필요하다. vim 사용자라면 다음과 같다.

    $ sudo vim /usr/local/bin/update-ddns

편집기가 실행되면 아래 코드를 입력하고 저장한다.

    #!/bin/sh
    # config
    UPDATER="/usr/local/gandi-dyndns/gandi-dyndns"
    LOG="/var/log/update-ddns.log"
    API="Your-API-Key"
    DOMAIN="yourdomain.net"
    RECORD="www"

    # update & leave log
    TIME_STAMP=$(date +"%F %T")
    RESULT=$($UPDATER --api=$API --domain=$DOMAIN --record=$RECORD --ipv4 2>&1)
    echo [$TIME_STAMP $RECORD.$DOMAIN] $RESULT >> $LOG

위 스크립트에서 config 항목의 각 값은 알맞게 수정하자. API 에는 간디 API 키를, DOMAIN에는 자신의 도메인 주소를, RECORD에는 갱신하고자 하는 이름을 지정하면 된다.

다음으로, 아래와 같이 실행 권한을 설정한다.

    $ sudo chmod ug+x /usr/local/bin/update-ddns

### crontab에 등록

다음 명령을 실행해 crontab 편집기를 실행한다.

    $ sudo crontab -e

편집기가 실행되면, 마지막 줄에 다음 줄을 입력하고 저장한다.

    */15 * * * * /usr/local/bin/update-ddns

참고로 여기서 맨 앞의 `*/15`는 매 15분마다 이 명령을 실행하라는 뜻이다. 5분에 한 번씩 갱신하고 싶으면 `*/5`로 바꾸면 된다.

### 로그 확인하기

ddns 갱신 기록이 잘 이루어지고 있는지 확인하고 싶다면 다음과 같이 /var/log/update-ddns.log 파일을 열어보면 된다.

    $ less /var/log/update-ddns.log
    [2014-03-24 19:30:01 home.bakyeono.net] The IP for 'home' did not change
    [2014-03-24 19:45:01 home.bakyeono.net] The IP for 'home' did not change
    [2014-03-24 20:00:01 home.bakyeono.net] Can't find address for record type 'A'
    [2014-03-24 20:15:02 home.bakyeono.net] Can't find address for record type 'A'
    [2014-03-24 20:30:01 home.bakyeono.net] The IP for 'home' did not change
    [2014-03-24 20:45:01 home.bakyeono.net] The IP for 'home' did not change
    [2014-03-24 21:00:01 home.bakyeono.net] The IP for 'home' did not change
    [2014-03-24 21:15:01 home.bakyeono.net] The IP for 'home' did not change
    [2014-03-24 21:30:01 home.bakyeono.net] The IP for 'home' did not change
    [2014-03-24 21:45:01 home.bakyeono.net] The IP for 'home' did not change
    /var/log/update-ddns.log (END)

[gandi.net]: https://www.gandi.net
[gandi.net-no-bullshit]: https://www.gandi.net/no-bullshit
[gandi.net-api-management]: https://www.gandi.net/admin/api_key
[gandi.net-dns-zones]: https://www.gandi.net/admin/domain/zone/list
[ddns]: http://ko.wikipedia.org/wiki/DDNS
[dns]: http://ko.wikipedia.org/wiki/%EB%8F%84%EB%A9%94%EC%9D%B8_%EB%84%A4%EC%9E%84_%EC%8B%9C%EC%8A%A4%ED%85%9C
[gandi-dyndns]: https://github.com/lembregtse/gandi-dyndns

