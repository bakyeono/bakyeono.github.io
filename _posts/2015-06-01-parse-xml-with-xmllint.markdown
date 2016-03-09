---
layout: post
title: xmllint --xpath 로 XML 문서 탐색하기
author: 박연오(bakyeono@gmail.com)
date: 2015-06-01 10:10 +0900
tags: xml xmllint xpath 리눅스 bash
---
* table of contents
{:toc}

`libxml2` 패키지에 포함된 `xmllint`를 이용하면 리눅스 커맨드라인에서 XML 문서를 쉽게 탐색할 수 있다.

## xmllint 초간단 사용법

### 설치

apt

    $ sudo apt-get install libxml2-utils

yum

    $ sudo yum install libxml2

### 사용

    $ xmllint --xpath 'XPath표현식' 파일경로

XPath표현식이 무엇인지 모른다면 아래 내용을 읽어보라.

## XPath (XML Path Language)

* [위키백과의 설명][xpath-wiki]
* [W3C 공식 문서][xpath-1.0-doc]

공식 문서는 조금 복잡하지만 XML 문서에서 필요한 정보를 읽어오는 데는 몇 가지만 알면 된다.

### 몇 가지 기능

기능            | 표현식 예
--------------- | -----------------------
노드 선택       | `/root/node/node/node`
노드 바로 선택  | `//node`
n번째 노드 선택 | `/root/node[n]`
속성 선택       | `/root/node/@attribute`
텍스트 읽기     | `/root/node/text()`
노드 수 세기    | `count(/root/node)`

### 예제

    <breakfast_menu>
      <food>
        <name>Belgian Waffles</name>
        <price>$5.95</price>
        <description>Two of our famous Belgian Waffles with plenty of real maple
            syrup</description>
        <calories>650</calories>
      </food>
      <food>
        <name>Strawberry Belgian Waffles</name>
        <price>$7.95</price>
        <description>Light Belgian waffles covered with strawberries and whipped
            cream</description>
        <calories>900</calories>
      </food>
      <food>
        <name>Berry-Berry Belgian Waffles</name>
        <price>$8.95</price>
        <description>Light Belgian waffles covered with an assortment of fresh
            berries and whipped cream</description>
        <calories>900</calories>
      </food>
      <!-- 중략 -->
    </breakfast_menu>

위 문서는 w3schools.com에 올라와 있는 XML 예제다.([출처][xml-example-1]) xmllint를 써보기 위해 문서를 다운로드한다.

    $ curl http://www.w3schools.com/xml/simple.xml > simple.xml

다음은 이 문서에서 노드와 데이터를 읽기 위한 XPath 표현식이다.

모든 food 태그 선택: `/breakfast_menu/food`

    $ xmllint --xpath '/breakfast_menu/food' simple.xml
    <food>
      <name>Belgian Waffles</name>
      <price>$5.95</price>
      <description>Two of our famous Belgian Waffles with plenty of real maple
          syrup</description>
      <calories>650</calories>
    </food>
    <food>
      <name>Strawberry Belgian Waffles</name>
    (중략)

첫번째 food 태그 선택: `/breakfast_menu/food[1]`

    $ xmllint --xpath '/breakfast_menu/food[1]' simple.xml
    <food>
      <name>Belgian Waffles</name>
      <price>$5.95</price>
      <description>Two of our famous Belgian Waffles with plenty of real maple
          syrup</description>
      <calories>650</calories>
    </food>

첫번째 food/price 태그의 텍스트 읽기: `/breakfast_menu/food[1]/price/text()`

    $ xmllint --xpath '/breakfast_menu/food[1]/price/text()' simple.xml
    5.95$

food 태그가 몇 개인지 세기: `count(/breakfast_menu/food)`

    $ xmllint --xpath 'count(/breakfast_menu/food)' simple.xml
    5

[xpath-wiki]: http://ko.wikipedia.org/wiki/XPath
[xpath-1.0-doc]: http://www.w3.org/TR/xpath
[xml-example-1]: http://www.w3schools.com/xml/simple.xml

