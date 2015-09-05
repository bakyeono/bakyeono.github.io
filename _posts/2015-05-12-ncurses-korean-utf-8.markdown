---
layout: post
title: ncurses 라이브러리에서 한글(utf-8) 출력하기
author: 박연오(bakyeono@gmail.com)
date: 2015-05-12 21:12
tags: c 리눅스 유니코드 한글 curses
---
* table of contents
{:toc}

## ncurses 라이브러리에서 한글이 깨질 때

ncurses 라이브러리를 쓸 때, 로케일 설정을 올바로 했는데도 한글이 깨지는 문제가 있다.

    #include <locale.h>
    #include <curses.h>
    
    int main() {
      setlocale(LC_CTYPE, "ko_KR.utf-8"); /* 로케일 설정을 했는데도 */
      initscr();
      printw("%s", "ABCDEFGHIJKLMNOPQRSTUVWXYZ\n");
      printw("%s", "가나다라마바사아자차카타파하\n");
      refresh();
      sleep(1);
      endwin();
      return 0;
    }

이 코드를 컴파일해 실행하면 한글이 깨져서 출력된다. ncurses 라이브러리가 유니코드를 지원하지 않기 떄문이다.

## 유니코드를 지원하는 버전

ncurses 라이브러리 배포판 중에 데비안 패키지인 `libncurses5-dev`는 유니코드를 지원하지 않는다. 한글을 제대로 출력하려면 유니코드를 지원하는 버전인 `libncursesw5-dev`를 사용해야 한다.

### 설치

데비안 기반 배포판인 경우 아래와 같이 설치한다.

    $ sudo apt-get install libncursesw5-dev

### 헤더 인클루드

다른 라이브러리를 쓰는 것이므로 `curses.h` 대신 `ncursesw/curses.h`를 인클루드해야 한다. 위의 예제 코드를 예로 들면 두 번째 줄을 아래와 같이 고쳐야 한다.

    #include <ncursesw/curses.h>

### 링크

`-lncurses` 대신 `-lncursesw` 옵션으로 링크하면 된다.

    $gcc SOURCE.c -o APP -lncursesw

결과물을 실행해 보면 이제 ncurses에서 한글이 잘 출력된다는 것을 알 수 있다.

