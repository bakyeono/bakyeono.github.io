---
layout: page
title: 프로젝트
label: 프로젝트
permalink: /project.html
---
* table of contents
{:toc}


## 2015년-2017년 플러스21 프로젝트

2015년-2017년 플러스21에서 일할 때 참여한 프로젝트. 내가 개발팀장이었기 때문에 직접 개발을 담당했다.


### 반려동물 돌봄 앱 CMS

* 개발환경: Python, Django, PostgreSQL, Elasticsearch
* 주요기능: 콘텐츠 관리, 콘텐츠 큐레이션, 앱 서비스

반려동물 돌봄 앱은 사내 주력 프로젝트였다. 모바일 앱은 별도로 개발했고 나는 CMS 서버를 개발했다. 앱에 데이터를 제공하기 위한 인터페이스, 에디터가 콘텐츠를 관리하기 위한 웹 인터페이스, 사용자 상황별 콘텐츠 큐레이션, 기상/대기 정보 수집 등을 제공했다.


### 스마트 선박 보안 게이트웨이 대시보드

* 개발환경: Node.js, D3.js, MySQL
* 주요기능: 데이터 수집, 시각화

레인보우와이어리스, YG나을텍, 플러스21이 공동 진행한 국책과제. 내가 있던 회사는 대시보드 제작을 맡았다. 대시보드의 주 기능은 보안 서버와 선박 센서 제어장치가 보내는 데이터를 받은 뒤 재가공하여 D3.js를 이용해 시각화하는 것이었다.


### 웹 기반 안드로이드 게임 앱

* 개발환경: Javascript, Phaser, Cordova
* 주요기능: 게임 로직, 그래픽과 애니메이션, 사용자 인터페이스

보드게임 개발 회사 감성수학RED의 게임 기획을 안드로이드 앱으로 구현하는 프로젝트. 간단한 게임이고 웹으로도 배포해야 했기 때문에 상용 게임 엔진이 아니라 웹 기술을 이용해 개발했다. 개발한 게임은 두 종인데 둘 다 비슷한 방법이 사용되었다.


### 3D 프린터용 모델 암복호화 기능 개발

* 개발환경: Python, Django, PHP, C++, Win32 API
* 주요기능: AES 암복호화, 작업 큐 인터페이스

(주)로킷의 3D 프린터용 모델 공유 웹사이트에 사용자가 업로드한 모델을 암호화, 슬라이싱 처리하는 기능을 추가하는 프로젝트. 서버 프로그램은 Django 기반으로 개발했고 사용자용 복호화 프로그램은 C++로 Win32 API를 직접 호출하도록 하여 개발했다.


### 서포터 활동 관리 시스템 개발

* 개발환경: PHP, CodeIgniter, MySQL
* 주요기능: 데이터 관리, 실시간 통계 쿼리

(주)미니골드의 브랜드 홍보를 위한 블로거 활동 관리 시스템을 개발했다. 프로젝트 자체는 간단한 모바일 웹사이트이지만, 기준 운영중인 시스템이 너무 낡은 환경이어서 여기에 덧붙여 개발하는 것이 까다로웠다.


## 2015년 개인 프로젝트


### 텔레그램 로봇 - 공식 API 버전

* 개발환경: Python, Google App Engine
* 주요기능: 구독자 관리, 구독자에게 메시지 자동 방송 기능 등
* GitHub: <https://github.com/bakyeono/using-telegram-bot-api>

텔레그램 공식 API로 만든 로봇. '노동자 연대' 신문사의 기사 알림 프로그램으로도 사용되고 있다. [(관련 글)](http://webmaster.wspaper.org/archives/485)


### 텔레그램 로봇 - telegram-cli 버전

![](https://raw.githubusercontent.com/bakyeono/tg-broadcast/master/screenshot.png)

* 개발환경: telegram-cli, Lua
* 주요기능: 구독자 관리, 구독자에게 메시지 자동 방송 기능 등
* GitHub: <https://github.com/bakyeono/tg-broadcast>

텔레그램 로봇 API가 공식적으로 발표되기 전에 만든 로봇.


### k-최근접 이웃 알고리즘 구현

* 개발환경: Clojure
* GitHub: <https://github.com/bakyeono/knn>

서강대학교 수학과 김종락 교수의 '기계학습' 강의를 듣고 배운 것을 토대로 구현해 본 것. 비교적 간단한 알고리즘이다.


## 2013년 개인 프로젝트


### 제품 판매 관리·보고 프로그램

* 개발환경: Clojure, Java
* 주요기능: 상품관리, 구매자·판매자 관리, 판매행사 관리, 정기구독 관리, 판매 네트워크 시각화, 각종 통계 산출, 차트 생성, MS-word(docx) 보고서 생성, 자료 암호화 처리 등


### OpenGL 비트맵 한글 폰트 출력기

![](https://github.com/bakyeono/bitmap-font/raw/master/doc/img/bitmap-font-demo.png)

* 개발환경: Clojure, OpenGL
* 주요기능: 초성, 중성, 종성을 분리 출력하여 조합하는 방식으로 비트맵 한글 폰트 출력, 한국어 입력기 오토마타
* GitHub: <https://github.com/bakyeono/bitmap-font>


### Clojure용 범용 MS-Word 문서 출력 라이브러리

* 개발환경: Clojure
* GitHub: <https://github.com/bakyeono/litedocx>

주로 사용되는 기능 위주로 추린, MS-Word(docx) 문서를 생성하는 라이브러리. 완성하지 못했다.


## 2012년 개인 프로젝트


### GUI 프레임워크 데모

![](https://raw.githubusercontent.com/bakyeono/sdl-framework/master/screenshot/my-sdl-framework-screenshot2.jpg)

* 개발환경: C++, SDL
* 주요기능: GUI 컴포넌트 조합, 한국어 입력기 오토마타
* GitHub: <https://github.com/bakyeono/sdl-framework>


### 도트홀릭 - 네모네모로직 게임

![](https://raw.githubusercontent.com/bakyeono/dotholic/master/dotholic.png)

* 개발환경: C++, SDL
* GitHub: <https://github.com/bakyeono/dotholic>

하루만에 만든 게임.


### Clojure 테트리스

![](https://raw.githubusercontent.com/bakyeono/clojure-tetris/master/screenshot/clojure-tetris.png)

* 개발환경: Clojure, Swing
* GitHub: <https://github.com/bakyeono/clojure-tetris>

Clojure를 배우고 처음 만들어 본 프로그램. 함수형 프로그래밍으로 제작한 테트리스.


## 2011년 개인 프로젝트


### 롤플레잉 게임 엔진 데모

![](https://raw.githubusercontent.com/bakyeono/hexa-map-rpg/master/document/screenshot-height.jpg)

* 개발환경: C++, SDL
* 주요기능: 6각형 타일맵, 랜덤 지형 생성, 시야선 가림 처리 등
* GitHub: <https://github.com/bakyeono/hexa-map-rpg>


### ASCII 팩맨

* 개발환경: C, Unix IPC
* GitHub: <https://github.com/bakyeono/ascii-packman>

Unix IPC 통신을 학습하면서 만든 3인용 멀티플레이어 게임


## 2009년 개인 프로젝트


### SDL 테트리스

![](https://raw.githubusercontent.com/bakyeono/sdl-tetris/master/screenshot/screenshot-tetris2.png)

* 개발환경: C++, SDL
* Github: <https://github.com/bakyeono/sdl-tetris>

C++을 배운 뒤 만들어 본 테트리스


### 제노사이드 한국어 패치

![](https://raw.githubusercontent.com/bakyeono/xenocide-korean-patch/master/screenshot/xenocide4.png)

* 개발환경: C++
* GitHub: <https://github.com/bakyeono/xenocide-korean-patch>

SF 로그라이크 게임인 제노사이드의 한국어화 패치. 게임 내 모든 데이터를 꼼꼼하게 번역했다.

