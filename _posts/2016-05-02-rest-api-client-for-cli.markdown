---
layout: post
title: 커맨드라인 환경에서 REST API (HTTP) 요청 보내기 (cURL, resty, httpie, Vim REST Control)
author: 박연오(bakyeono@gmail.com)
date: 2016-05-02 22:34 +0900
tags: http rest-api 리눅스 bash vim
---
* table of contents
{:toc}

커맨드라인에서 REST API 요청을 보내 보자. 이 글은 내가 써 본 도구 몇 가지를 간단히 소개만 하므로 자기에게 맞는 도구를 고른 뒤 매뉴얼을 자세히 읽어보는 게 좋을 것이다.

이 글은 리눅스 커맨드라인 사용법과 [HTTP](https://ko.wikipedia.org/wiki/HTTP)에 대한 기본 사항을 알고 있음을 전제로 한다.


## cURL

가장 쉽게 쓰이는 방법은 cURL을 이용하는 것이다. 

### 설치

cURL은 리눅스 배포판에 대부분 기본으로 포함돼 있다. 보통은 리눅스 커뮤니티가 관리하는 패키지 관리 시스템을 이용해 간단히 설치할 수 있다. 아래 명령으로 설치한다.

    $ sudo apt-get install curl

만일 보안 등의 이유로 이 프로그램이 없거나 사용이 금지돼 있다면 설치가 어려울 수도 있다.

### 요청 보내기

REST API를 사용할 때는 cURL 옵션 중 몇 가지를 꼭 알아두는 것이 좋다.

* `-i`: 응답 헤더 출력 (옵션 없으면 응답 본문만 출력함)
* `-v`: 중간 처리 과정, 오류 메시지, 요청 메시지와 응답 메시지를 헤더와 본문을 포함해 전체 출력
* `-X`: 요청 메소드를 지정 (옵션 없으면 기본값은 GET)
* `-H`: 요청 헤더를 지정
* `-d`: 요청 본문을 지정 (옵션 없으면 요청 본문 없음)

예)

    $ curl -X GET http://127.0.0.1:3000/api/users/bakyeono
    $ curl -X POST http://127.0.0.1:3000/api/languages/ansi-common-lisp
    $ curl -X PUT http://127.0.0.1:3000/api/resources/1789

위 명령은 cURL을 이용해 각각 다음과 같은 요청을 보낸다.

* `http://127.0.0.1:3000/api/users/bakyeono` 리소스를 GET
* `http://127.0.0.1:3000/api/languages/ansi-common-lisp` 리소스를 POST
* `http://127.0.0.1:3000/api/resources/1789` 리소스를 PUT

### URL 인코드(퍼센트 인코드)

URL에 사용할 수 없는 문자가 포함될 경우 [URL 인코드(퍼센트 인코드)](https://ko.wikipedia.org/wiki/%ED%8D%BC%EC%84%BC%ED%8A%B8_%EC%9D%B8%EC%BD%94%EB%94%A9)를 해 줘야 한다는 걸 알 것이다. cURL 자체 기능으로는 URL 인코드를 제공하지 않으므로 알아서 URL 인코드 한 주소를 매개변수로 넘겨야 한다. 그 대신 URL 쿼리 부분은 `--data-urlencode`를 옵션을 이용해 URL 인코딩하여 요청할 수 있다.

    $ curl -X GET --data-urlencode "id=1000&category=post" http://127.0.0.1:3000/api/data

### 본문을 포함해 요청 보내기

`-d` 옵션을 이용한다.

    $ curl -X PUT -H "Content-Type: application/json; charset=utf-8" -d '{"message":"hello"}' http://127.0.0.1:3000/api/chat

이상과 같이 기본적인 동작은 가능하지만 번거롭게 옵션 지정하고 불편한 점이 많으므로 아래의 다른 프로그램을 써 보는 걸 추천한다.


## resty

* resty: <https://github.com/micha/resty>

resty는 cURL을 이용해 REST API 테스트를 쉽게 할 수 있도록 도와주는 스크립트다.

### 설치

resty는 cURL을 이용한다. 따라서 시스템에 cURL이 설치되어 있어야 한다. cURL이 설치된 상태에서 아래 명령을 실행해 스크립트를 다운로드한다.

    $ curl -L http://github.com/micha/resty/raw/master/resty > resty

다운로드한 스크립트를 bash에 source 해주면 resty를 사용할 수 있다.

    $ source resty

물론 세션이 끝나면 해제되므로 `.bashrc` 등에 세션 시작 명령으로 삽입해 둔다.

### URL 설정

`resty` 명령으로 resty를 이용해 요청을 보낼 URL을 지정한다. 예를 들어 로컬 3000번 포트의 `/api` 경로에 요청을 보내려면 다음과 같이 한다.

    $ resty 127.0.0.1:3000/api

### 요청 보내기

URL을 설정했으면 `GET`, `POST`, `PUT`, `DELETE` 같은 HTTP 메소드를 명령행에 입력해 요청을 보낼 수 있다. 매우 직관적이다.

    $ GET /users/bakyeono
    $ POST /languages/ansi-common-lisp
    $ PUT /resources/1789

물론 요청할 URL에 URL 쿼리를 포함시켜도 된다.

    $ GET /data?id=1000&category=post

### 본문을 포함해 요청 보내기

`-d` 옵션으로 본문을 지정할 수 있다. 요청 헤더 지정은 `-H` 옵션으로 한다. cURL 스크립트이기 때문에 사용법이 거의 똑같다.

    $ PUT -H 'Content-Type: application/json; charset=utf-8' -d '{"message":"hello"}' /chat

파일 내용을 삽입하거나 파이프라이닝 하는 것도 가능하다. 자세한 방법은 공식 설명서 참고.


## httpie

httpie는 내가 가장 추천하는 HTTP 클라이언트다. REST API를 이용할 때 필요한 기능을 거의 전부 지원하는 데다 사용법도 쉽다.

* httpie: <https://github.zom/jkbrzt/httpie>

### 설치

데비안 등 리눅스 소프트웨어 저장소에 등록되어 있으므로 설치가 쉽다.

    $ sudo apt-get install httpie

### 요청 보내기

`http` 명령, 메소드, URL을 입력해 요청을 보낼 수 있다.

    $ http GET 127.0.0.1:3000/api/users/bakyeono
    $ http POST 127.0.0.1:3000/api/languages/ansi-common-lisp
    $ http PUT 127.0.0.1:3000/api/resources/1789

이 프로그램도 `-v` 옵션으로 요청/응답 메시지의 헤더/본문을 모두 출력하게 할 수 있으므로 테스트할 때 사용하면 매우 편리하다.

    $ http -v PUT 127.0.0.1:3000/api/resources/1789

### 헤더 지정

헤더는 `필드:값` 표기로 지정한다.

    $ http PUT 'User-Agent:Mozilla/5.0' 127.0.0.1:3000/api/visitor

### 본문을 포함해 요청 보내기

본문은 `body=내용` 표기로 지정한다.

    $ http PUT 127.0.0.1:3000/api/chat body='{"message":"hello"}'

### 파일 첨부, multipart 요청 보내기

`--form` 옵션을 이용해 MIME `multipart/form-data`로 요청을 보낼 수 있다. 본문에 들어갈 각 필드는 `필드=값` 으로 지정한다.

    $ http -v --form PUT 127.0.0.1:3000/api/users/bakyeono name='Bak Yeon O' gender='male' params='{"foo":"bar"}'

이 때, 파일을 첨부해서 보내고 싶다면 `필드@파일경로` 로 지정하면 된다.

    $ http -v --form PUT 127.0.0.1:3000/api/users/bakyeono name='Bak Yeon O' photo@bakyeono.png

이 외에도 생각할 수 있는 필요한 기능들이 대부분 있으니 설명서를 읽어보는 게 좋다.


## Vim REST Control (vim 플러그인)

Vim 사용자라면 편리하게 이용할 수 있는 플러그인들이 있다. 그 중 Vim REST Control이 쓸만했다.

* Vim REST Control: <https://github.com/diepm/vim-rest-console>

### 사용법

파일을 `.rest` 확장자로 만든 뒤 Vim 으로 열어 편집하거나, 아니면 빈 버퍼에서 `set filetype=rest` 명령으로 rest 편집 모드로 들어간다.

버퍼에 요청할 URL을 호스트, 헤더, 메소드와 상대경로, 본문을 한 줄씩 적는다. 헤더와 본문은 생략 가능하다.

예)

    http://127.0.0.1:3000
    GET /api/users/bakyeono
    
    http://127.0.0.1:3000
    POST /api/languages/ansi-common-lisp
    
    http://127.0.0.1:3000
    PUT /api/resources/1789
    
    http://127.0.0.1:3000
    Content-Type: application/text; charset=utf-8
    PUT /api/chat
    {
      "message": "hello"
    }

이렇게 적은 후 요청을 원하는 메시지 위에 커서를 두고 `<C-j>`를 누르면 요청이 전송되고 결과가 임시 버퍼에 출력된다.

테스트할 요청들을 한번 파일로 작성해두고 수시로 테스트 할 수 있으므로 매우 편리하다.


