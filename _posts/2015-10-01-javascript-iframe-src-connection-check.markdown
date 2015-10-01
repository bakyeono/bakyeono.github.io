---
layout: post
title: 자바스크립트 - iframe이 경로(src)에 접속할 수 없을 때 예외 처리하기
author: 박연오(bakyeono@gmail.com)
date: 2015-10-01 23:30
tags: 자바스크립트 iframe
---
* table of contents
{:toc}

## iframe의 src 경로 접속이 속성이 실패할 때

iframe 노드의 src 속성을 수정하여 iframe이 출력할 페이지의 경로를 지정할 수 있다. jQuery를 쓴다고 하면, 아래 명령으로 iframe의 페이지를 바꿀 수 있다.

    $('iframe').attr('src', 'http://wrong.location.somewhere/');

그런데 지정한 경로에 접속할 수 없는 경우 콘솔에 다음과 같은 예외만 남기고 실패한다.

    GET http://wrong.location.somewhere/ net::ERR_NAME_NOT_RESOLVED

골치 아픈 것은 이 예외를 캐치할 수 없다는 것이다. jQuery를 쓰든 DOM 객체를 직접 건드리든 마찬가지다. 이걸 잡을 수 있는 이벤트도 찾지 못했는데, 아마 없는 것 같다.

## 예외는 못 잡지만... 꼼수로 처리하기

접속할 경로를 미리 테스트해 본 후 성공/실패를 구분하면 간단하다. jQuery를 쓴다고 하면, get 메소드로 테스트하면 된다.

    var location = 'http://wrong.location.somewhere/';
  	$.get(location, function() {
  	  alert('성공');
  		$('iframe').attr('src', location);
  	}).done(function() {
  	  alert('두 번째 성공');
  	}).fail(function(e) {
  	  alert('접속 실패');
  	}).always(function() {
  	  alert('완료');
  	});

이렇게 하면 접속이 가능한 경로만 iframe에 지정해줄 수 있고, 접속할 수 없는 경우 사용자에게 알리는 것도 가능하다.

다만 해당 경로에 요청을 한 번이 아니라 두 번 보내게 된다는 점에 유의해야 한다.

jQuery의 get 메소드에 관한 자세한 명세는 이 공식 문서에 나와 있다. [https://api.jquery.com/jquery.get](https://api.jquery.com/jquery.get)

