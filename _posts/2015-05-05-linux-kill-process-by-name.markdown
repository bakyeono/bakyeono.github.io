---
layout: post
title: 프로세스를 이름으로 단번에 종료하기
author: 박연오(bakyeono@gmail.com)
date: 2015-05-05 00:43 +0900
tags: 리눅스 bash grep
---
* table of contents
{:toc}

오... 맙소사... 그동안의 내 타이핑은 다 뭐였단 말인가???? 아 인생이여!!

그동안 매번 `ps -ef | grep PROCESS`로 PID를 찾은 다음 `kill` 했는데, 더 간단하게 프로세스를 끄는 방법을 알았다.

## 간단 설명

### 프로세스명이 일치하는 경우 (killall)

터미널에 아래와 같이 입력한다. 당연히 PROCESS_NAME은 프로세스명으로 대체해서 입력해야 한다.

    $ killall -9 PROCESS_NAME

이렇게 하면 종료된다.

### 프로세스 매개변수를 참고해야 하는 경우 (pkill -f)

예를 들어 `java -jar my_process.jar` 처럼 프로세스명만으로는 원하는 프로그램을 참조할 수 없는 경우가 있다. 이 떄는 `pkill` 명령에 `-f` 옵션을 줘서 명령행 전체를 참조해 `my_process`를 찾아야 한다. 아래와 같이 입력하면 된다.

    $ pkill -9 -ef my_process

여기서 `-9`는 KILL 신호를 보내라는 뜻이며, `-e`는 로그 출력 옵션이다. `-f` 옵션은 명령행 전체 참조 옵션이다.

`-9` 옵션을 다른 옵션과 따로 지정해야 하는 점에 주의.

[askubuntu.com에 올라온 설명][killall-and-pkill-askubuntu-com]에 따르면 `pkill`은 프로세스명을 좀 더 느슨한 패턴으로 찾기 떄문에 일반적인 상황에서는 `pkill`보다 `killall`을 쓰는 습관을 들이는 편이 더 안전하다고 한다. 물론 둘다 쓰기에 따라 위험할 수 있으니 옵션을 잘 보고 사용해야 한다.

## 너저분한 설명

### kill

프로세스를 끄는 명령은 `kill -9 PID`다.[^kill] `kill`의 단점은 프로세스 ID(PID)로만 종료할 프로세스를 지정할 수 있다는 점이다.

### ps, pidof

PID는 `ps` 명령으로 프로세스 목록을 출력해 찾을 수 있다. 만일 프로세스 목록이 길면 눈으로 직접 찾기가 힘들다.

`pidof PROCESS_NAME` 명령을 이용하면 PID를 바로 알아낼 수 있다.

    $ pidof ruby
    13701

### ps -ef | grep

`ps`에 옵션을 지정해 자세히 출력하도록 하고 결과를 `grep` 하면 다른 세션에서 실행되고 있는 프로세스도 찾을 수 있고, 명령행 전체를 옵션으로 참고할 수도 있다.

    $ ps -ef | grep jekyll
    bakyeono 13701     1  0 00:41 pts/0    00:00:00 ruby /home/bakyeono/.rvm/gems/ruby-2.2.0/bin/jekyll serve --watch --force_polling --detach
    bakyeono 13838  9975  0 01:07 pts/0    00:00:00 grep --color=auto jekyll

### pgrep

하지만 `ps | grep` 대신 둘을 합쳐놓은 `pgrep`을 이용하는게 더 편하다.

    $ pgrep -f jekyll
    13701

### pkill, killall

위의 방법은 모두 PID를 일단 찾은 뒤에 `kill`에 전달하는 과정을 거쳐야 한다. 하지만 `pkill`을 이용하면 한방에 정리할 수 있다.

    $ pkill -9 -ef PROCESS_NAME

문서 앞부분의 간단 설명에서 말한 것처럼, 프로세스 매개변수를 참조하지 않아도 된다면 `killall`을 사용해도 된다.


[^kill]: 엄밀히 말하면 `kill`은 프로세스 종료 명령이 아니라 프로세스에 신호를 보내는 명령이다. 단, 9번 신호(KILL)의 경우에는 신호를 보내지 않고 커널이 바로 프로세스를 정리해 버린다. 고집불통이 된 프로세스를 처리하는 데 필요한 신호가 바로 9번이다.

[killall-and-pkill-askubuntu-com]: http://askubuntu.com/questions/27501/whats-the-difference-between-killall-and-pkill

