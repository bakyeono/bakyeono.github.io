---
layout: post
title: html-xml-utils - 커맨드라인에서 HTML 문서 탐색하기
author: 박연오(bakyeono@gmail.com)
date: 2015-06-11 14:50 +0900
tags: html 리눅스 bash
---
* table of contents
{:toc}

스택 오버플로의 [이 글][stackoverflow-no-regex-on-html]에 따르면 정규표현식으로 HTML 문서를 파싱하면 좋지 않다고 한다. 프로그래밍 환경에서 제공되는 적절한 HTML(XML) 문서 탐색기를 이용하는 것이 바람직하다. 리눅스 커맨드라인에서는 어떻게 해야 할까? html-xml-utils를 사용하면 CSS 선택자로 HTML 문서를 탐색할 수 있다.

## 설치

데비안 기반 리눅스:

    $ sudo apt-get install html-xml-utils

레드햇 기반 리눅스:

    $ sudo yum install html-xml-utils

패키지 직접 다운로드: [w3.org][w3-html-xml-utils]

## 사용

### hxnormalize -x

HTML 문서를 탐색하기 전에 먼저 HTML 문서를 Well-formed XML 양식으로 변환해야 한다. HTML 정의는 XML보다 약간 느슨하기 때문에 Well-formed XML 문서가 아닌 HTML 문서가 거의 대부분이다. 이를 수행하는 프로그램은 `hxnormalize -x` 다. `hxnormalize`는 HTML 문서 출력기이며 `-x` 옵션을 주면 문서를 닫는 태그(`<img />`, `</li>` 등)가 없는 노드에 닫는 태그를 추가해 Well-formed XML 문서로 만들어준다.

아쉽게도 HTML 문서 내용에 따라 이것이 불가능한 경우도 있다. 이 때는 이 유틸리티만으로 탐색하는 것은 안되는 듯하다.

변환 명령은 다음과 같다.

    $ hxnormalize -x 원본파일명 > 출력파일명

물론, 출력파일 스트림을 지정하지 않으면 STDOUT(콘솔)으로 출력한다.

### hxselect

HTML 문서를 Well-formed XML 양식으로 변환했으면 `hxselect` 명령으로 원하는 노드를 탐색할 수 있다.

명령은 다음과 같다.

    $ hxselect 'CSS선택자' < 파일명

선택한 노드 자체는 빼고 노드가 포함한 내용물만 추출하고 싶다면 `-c` 옵션을 준다.

    $ hxselect -c 'CSS선택자' < 파일명

선택자로 여러 개의 노드가 선택되는 경우에, 각 노드 사이에 구분자를 출력하고 싶다면 `-s` 옵션으로 구분자를 지정한다.

    $ hxselect -s '구분자' 'CSS선택자' < 파일명

### 예

위키피디아의 한 문서를 탐색해 보자.

문서 다운로드

    $ curl "https://en.wikipedia.org/wiki/Lisp" > source.html
      % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                     Dload  Upload   Total   Spent    Left  Speed
    100 53551    0 53551    0     0  58206      0 --:--:-- --:--:-- --:--:-- 69909

Well-formed XML 문서로 변환

    $ hxnormalize -x source.html > normalized.html

원하는 노드 선택

    $ hxselect '#Types' < normalized.html
    <span class="mw-headline" id="Types">Types</span>
    
    $ hxselect '#mw-content-text > ul:nth-child(8) > li:nth-child(3)' < normalized.html
    <li>A "nasal lisp" occurs when part or the entire air stream is directed through the nasal cavity.</li>
    
    $ hxselect -c '#mw-content-text > ul:nth-child(8) > li:nth-child(3)' < normalized.html
    A "nasal lisp" occurs when part or the entire air stream is directed through the nasal cavity.
    
    $ hxselect -s '\n----\n' "#mw-content-text > ul:nth-child(8) > li" < normalized.html
    <li>"Interdental" lisping is produced (...중략...) it is expected.</li>
    ----
    <li>The "lateral" lisp is where the (...중략...) </li>
    ----
    <li>A "nasal lisp" occurs when part (...중략...) the nasal cavity.</li>
    ----
    <li>A "strident lisp" results in a (...중략...) hard surface.</li>
    ----
    <li>A "dentalized lisp" does not have (...중략...) and alveolar ridge.</li>
    ----
    <li>A "palatal lisp" is where the speaker attempts (...중략...) </li>
    ----

복잡한 문서에서 노드 추출을 위한 CSS 선택자 표현식을 작성하는 것은 간단하지는 않다. 여러 웹 브라우저들이 제공하는 개발자 도구를 활용하면 도움이 된다.

[stackoverflow-no-regex-on-html]: http://stackoverflow.com/questions/1732348/regex-match-open-tags-except-xhtml-self-contained-tags/1732454#1732454
[w3-html-xml-utils]: http://www.w3.org/Tools/HTML-XML-utils

