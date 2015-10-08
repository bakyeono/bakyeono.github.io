---
layout: post
title: 자바스크립트 - 여러 페이지 사이에 데이터를 저장, 교환하기
author: 박연오(bakyeono@gmail.com)
date: 2015-09-25 02:10
tags: 자바스크립트 웹킷
---
* table of contents
{:toc}

## 여러 페이지 사이에 데이터 교환하는 문제

브라우저 위에서 실행되는 자바스크립트는 기본적으로 페이지에 종속돼 있다. 한 페이지에서 다른 페이지로 전환하면 메모리상의 자바스크립트 개체들은 사라져 버린다.

웹킷을 이용한 프로젝트처럼 여러 페이지 사이에 데이터를 교환해야 할 때는 어떻게 하면 좋을까?

sqlite3이나 파일을 이용해도 되고, 믿을만한 RDBMS를 이용할 수도 있을 것이다. 하지만 목적에 비해 너무 번거롭거나 무거운 감이 있다.

찾아보니 HTML5에서 지원되는 훨씬 편리한 방법이 있었다. 바로 sessionStorage를 이용하는 것이다.

## sessionStorage

sessionStorage를 이용하면 한 세션 안에서 여러 페이지에 걸쳐 데이터를 저장하고 읽을 수 있다. 사용법도 매우 간단하다. 그냥 sessionStorage 객체의 원하는 필드명에 데이터를 넣고 쓰면 된다.

이렇게 쓰고,

    sessionStorage.foo = 'bar';

이렇게 로드한다.

    sessionStorage.foo;

### JSON과 함께 쓰기

단, 위의 방법으로는 무조건 문자열만 쓰고 읽을 수 있다. 저기에다 자바스크립트 개체를 넣으면 강제로 `toString`이 호출돼 원하는 결과가 되지 않을 것이므로 주의해야 한다. 특히 `true`, `false`, `0`, `1`, `2` 등 문자열이 아닌 리터럴들을 쓸 때 주의해야 한다.

문자열이든 다른 개체든 JSON 파서를 같이 이용해서 쓰는게 좋다. 간단하다.

이렇게 자바스크립트 개체를 저장하고,

    sessionStorage.foo = JSON.stringify({bar: [1, 2, 3, 4, 5], baz: ['a', 'b', 'c', 'd']});

이렇게 자바스크립트 개체를 로드한다.

    JSON.parse(sessionStorage.foo);

