---
layout: post
title: telegram-cli 여러 세션을 동시에 실행하기
author: 박연오(bakyeono@gmail.com)
date: 2015-06-03 10:56
tags: 텔레그램 sudo
---
* table of contents
{:toc}

이 글은 커맨드라인 텔레그램 클라이언트인 [telegram-cli(unofficial)][telegram-cli]로 여러 세션을 동시에 실행하는 방법이다.

## 문제

텔레그램은 하나의 인증(authorization)에 하나의 접속만을 허용한다. 같은 인증으로 새로운 세션이 생성되면 기존의 세션은 종료된다. telegram-cli로 자동 스크립트를 실행하는 도중에 직접 메시지를 보내기 위해 telegram-cli를 새로 실행하면 원래 실행되고 있던 스크립트는 멈추게 된다. 스크립트를 여러 개 함께 실행하는 것도 안 된다.

telegram-cli의 [341번 이슈][telegram-cli-issues-341]에 이 문제가 언급돼 있다. 이 이슈 페이지에는 세션마다 다른 프로파일을 지정해서 문제를 해결하라고 한다. 하지만 환경에 따라 안 되는 경우가 있는 것 같다. 나는 프로파일 기능이 잘 작동하지 않아서 다른 방법으로 문제를 해결했다.

## 우회법

가장 직관적인 방법은 물리적으로 또는 가상화 기술로 분리된 다른 기계로 telegram-cli를 실행하는 것이다. 하지만 리눅스는 다중 사용자 환경이므로 그렇게까지 할 필요가 없다. 그냥 각 세션마다 별도의 리눅스 사용자 계정을 줘 실행하면 된다.

### 예

현재 사용자가 bakyeono라고 할 때, tg-daemon 이라는 사용자를 만들어 telegram-cli 스크립트를 실행한다고 해 보자. 데비안 기반 리눅스를 기준으로 했다.

먼저 사용자를 만든다.

    $ adduser tg-daemon
    Adding user `tg-daemon' ...
    Adding new group `tg-daemon' (1006) ...
    Adding new user `tg-daemon' (1003) with group `tg-daemon' ...
    Creating home directory `/home/tg-daemon' ...
    Copying files from `/etc/skel' ...
    Enter new UNIX password:
    Retype new UNIX password:
    passwd: password updated successfully
    Changing the user information for tg-daemon
    Enter the new value, or press ENTER for the default
            Full Name []:
            Room Number []:
            Work Phone []:
            Home Phone []:
            Other []:
    Is the information correct? [Y/n]

telegram-cli 바이너리가 `/home/bakyeono/telegram-cli`에 있고, 실행할 스크립트는 `/home/bakyeono/telegram-cli-script`에 있다고 하자. tg-daemon 사용자 계정으로 접속해 이들에 대한 링크를 걸어 준다. 로그인은 간단히 ssh로 하면 된다.

    $ ssh tg-daemon@localhost
    tg-daemon@localhost's password:
    Linux antares-pi2 3.18.11-v7+ #781 SMP PREEMPT Tue Apr 21 18:07:59 BST 2015 armv7l
    
    The programs included with the Debian GNU/Linux system are free software;
    the exact distribution terms for each program are described in the
    individual files in /usr/share/doc/*/copyright.
    
    Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
    permitted by applicable law.
    Last login: Wed Jun  3 10:53:34 2015 from localhost

    $ ln -s /home/bakyeono/telegram-cli
    $ ln -s /home/bakyeono/telegram-cli-script
    $ logout
    Connection to localhost closed.

tg-daemon 사용자가 이 경로들에 접근할 수 있도록 이 경로의 소속 그룹(bakyeono)에 포함시킨다.

    $ sudo addgroup tg-daemon bakyeono

같은 그룹 구성원이 작업을 할 수도록 권한을 주는 것도 잊지 말자.

    $ chmod -R g+w /home/bakyeono/telegram-cli /home/bakyeono/telegram-cli-script

이제 tg-daemon 사용자가 telegram-cli와 스크립트에 접근하고 실행할 수 있다. 하지만 매번 tg-daemon 사용자 계정으로 로그인해서 실행하는 것은 번거롭다. 이럴 때 `sudo`를 쓰면 된다. `sudo`는 root 계정으로 작업할 때만 쓰이는 게 아니다. `-u` 옵션으로 root 외에 다른 사용자로도 작업할 수 있다.

tg-daemon 계정으로 telegram-cli 를 실행하려면 이렇게 한다.

    $ sudo -u tg-daemon /home/tg-daemon/telegram-cli/telegram-cli

tg-daemon 계정으로는 처음 실행하는 것이므로 안내 메시지에 따라 인증 절차를 거쳐야 한다. 인증을 거친 후 자유롭게 사용할 수 있다.

백그라운드에서 telegram cli 스크립트가 실행되도록 하려면 다음과 같이 한다.

    $ sudo -u tg-daemon nohup /home/tg-daemon/telegram-cli/telegram-cli -s &

이제 원래의 사용자 계정인 bakyeono 계정으로 telegram-cli를 실행해도 tg-daemon이 접속한 세션이 종료되지 않는다.

[telegram-cli]: https://github.com/vysheng/tg
[telegram-cli-issues-341]: https://github.com/vysheng/tg/issues/341

