---
layout: post
title: .profile에 설정한 내용이 터미널 에뮬레이터에서 안 먹힐 때
author: 박연오(bakyeono@gmail.com)
date: 2015-09-05 21:49
tags: 리눅스 X-윈도우 bash
---
* table of contents
{:toc}

내가 겪은 문제다. X-윈도우에서 터미널 에뮬레이터(XTERM, Terminator, GNOME Terminal 등)를 사용할 때 `~/.profile`, `~/.bash_profile` 같은 사용자 쉘 설정 파일이 적용되지 않는 것이다. `PATH` 환경변수 설정이 내 뜻대로 되지 않아서 매우 답답했다.

더 당혹스러운 것은 X-윈도우가 아닌 CUI 모드[^1]나 SSH에서는 쉘 설정이 로드되는 것이다. 왜 그때그때 동작이 다른 것일까?

알고 보면 별 거 아니지만 누군가 나처럼 삽질을 경험할 수 있으니 원인과 해결방법을 남겨둔다.

## 원인

이 문제는 `~/.profile`, `~/.bash_profile`, `~/.bashrc` 파일의 용도가 다르기 때문에 발생한다.

* `~/.profile`, `~/.bash_profile`은 세션에 로그인할 때 로드된다.
* `~/.bashrc`는 bash가 실행될 때 로드된다.

X-윈도우에서 터미널 에뮬레이터를 실행하면 X-윈도우의 현재 세션을 유지할 뿐 별도로 로그인 과정을 거치지 않는다. 그래서 에뮬레이터에서는 `~/.bashrc`만이 로드되는 것이다.

## 해결방법

### 방법 1: 그냥 .bashrc에 설정 넣기

설정할 내용을 `~/.profile` 또는 `~/.bash_profile` 말고, 그냥 `~/.bashrc`에 넣는다.

### 방법 2: .bashrc가 세션 설정 파일을 로드하도록 하기

`~/.bashrc`에 `~/.profile` 또는 `~/.bash_profile`을 로드하도록 하는 명령을 추가한다.

> 주의: `~/.profile` 또는 `~/.bash_profile`이 `~/.bashrc`를 로드하도록 설정되어 있을 가능성이 높다. 이렇게 되면 순환 재귀가 발생하여 bash를 쓸 수 없게 된다. [ctrl] + [c]를 누르면 순환 재귀가 취소되긴 한다.

### 방법 3 (추천): 에뮬레이터로 로그인 쉘 사용

터미널 에뮬레이터의 환경 설정에서 쉘을 로그인 상태로 시작하도록 하는 옵션을 켠다.

SSH 같은 별도 세션과 터미널 에뮬레이터의 동작이 달랐던 원인이 바로 이거다. 터미널 에뮬레이터를 별도의 로그인 세션으로 동작하게 하는 방법이다. 이 방법이 제일 무난한 것 같다.

## 참고 문서

* [ask ubuntu 121073번 글](http://askubuntu.com/questions/121073/why-bash-profile-is-not-getting-sourced-when-opening-a-terminal)
* [stack overflow 415403번 글](http://stackoverflow.com/questions/415403/whats-the-difference-between-bashrc-bash-profile-and-environment)

[^1]: [ctrl] + [alt] + [1]-[6]

