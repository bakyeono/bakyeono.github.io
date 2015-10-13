---
layout: post
title: Node.js - 자식 프로세스에서 데이터 출력이 불규칙하게 들어올 때 한 줄씩 나누기
author: 박연오(bakyeono@gmail.com)
date: 2015-09-25 01:53
tags: nodejs 자바스크립트
---
* table of contents
{:toc}

## 자식 프로세스 실행

Node.js에서 child_process 모듈을 이용해 외부 프로그램을 자식 프로세스로 실행할 수 있다. 자식 프로세스가 보내주는 데이터는 표준출력(STDOUT) 이벤트에 콜백을 걸어 받을 수 있다. 다음과 같이 한다.

    var spawn = require('child_process').spawn,
        subprocess;
    function on_child_stdout(data) {
      console.log(data.toString());
    };
    function on_child_exit(exit_code) {
      console.log('the child is no more: ' + exit_code);
    };
    
    // 자식 프로세서 실행
    subprocess = spawn('some_process', 'parameter');
    subprocess.stdout.setEncoding('utf8');
    subprocess.stdout.on('data', on_child_stdout);
    subprocess.on('exit', on_child_exit);

## 데이터가 불규칙하게 들어올 때

보통은 한 줄당 한 번씩 STDOUT data 이벤트가 발생하여 한 줄씩 콜백에 전달된다. 그런데 종종 데이터가 불규칙하게 들어오기도 한다.

예를 들어 한 줄에 URL 데이터가 하나씩 들어오는 상황이라고 하면,

    aaa.com
    bbb.com
    ccc.com
    ddd.com\neee.com\nfff.com\nggg.com
    hhh.com

4번째 줄처럼 여러 줄이 한꺼번에 입력되는 경우가 불규칙하게 있는 것이다.

정확히 언제 무슨 이유로 이런 문제가 생기는지는 알 수 없지만 이렇게 될 때가 있다. 아마 비동기 I/O 때문인 듯하다.

## 해결방법

해결방법은 STDOUT data 이벤트에 대한 콜백에서 여러 줄을 각각 분리해주는 것이다. 이 때, 빈 줄이 추가되는 경우도 있으므로 이에 대한 처리도 해주는 것이 좋다. 위의 `on_child_stdout` 함수를 아래와 같이 수정하면 된다.

    function on_child_stdout(data) {
     	var str = data.toString(),
            lines = str.split(/\n/g);
    	for (var i in lines) {
    	  if (! lines[i]) {
            console.log(lines[i]);
    	  }
    	}
    };

이 해결방법은 [스택오버플로 문서](http://stackoverflow.com/questions/9781214/parse-output-of-spawned-node-js-child-process-line-by-line)에서 본 것을 조금 수정한 것이다.
