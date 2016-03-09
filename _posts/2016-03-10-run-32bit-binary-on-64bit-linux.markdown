---
layout: post
title: 64비트 리눅스에서 32비트 프로그램이 실행되지 않을 때
author: 박연오(bakyeono@gmail.com)
date: 2016-03-10 03:21 +0900
tags: 리눅스
---
* table of contents
{:toc}

## 증상

파일 시스템에 실행 파일이 존재하고 경로를 정확히 지정했는데도, 프로그램을 실행하려 하면 bash가 파일을 찾을 수 없다는 오류를 낸다.

예: 안드로이드 SDK의 aapt

    $ /opt/android-sdk-linux/build-tools/23.0.2/aapt
    -bash: /opt/android-sdk-linux/build-tools/23.0.2/aapt: No such file or directory

에러 메시지만 봐서는 말도 안 되는 현상이고 원인을 알기가 거의 불가능하다. 이게 대체 무슨 현상인가?

## 원인과 해결 방법

프로그램이 32비트용으로 컴파일되었기 때문에 64비트 리눅스의 파일 시스템이 실행 파일로 취급하지 못하는 것이다.

가능하면 OS의 아키텍처에 맞게 컴파일된 배포판을 쓰거나 직접 컴파일해서 쓰면 될 것이다. 하지만 호환성 등의 문제로 32비트 버전만 제공하는 프로그램도 있다. 안드로이드 SDK가 대표적이다.

이럴 때는 리눅스가 32비트 프로그램을 실행할 수 있도록 필요한 의존성 패키지를 설치해주면 된다.

(우분투 14.04 LTS 기준)

    sudo dpkg --add-architecture i386
    sudo apt-get update
    sudo apt-get install libc6:i386 libncurses5:i386 libstdc++6:i386 zlib1g:i386

프로그램이 의존하는 라이브러리에 따라 이 외에도 설치해야하는 패키지가 있을 수 있다.

## 참고문서

* [http://askubuntu.com/questions/133389/no-such-file-or-directory-but-the-file-exists](Stack Overflow 문서)
* [http://developer.android.com/sdk/installing/index.html?pkg=tools](Android SDK 문서)

