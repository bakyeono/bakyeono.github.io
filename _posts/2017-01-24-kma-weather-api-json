---
layout: post
title: 기상청 동네예보 API 조회를 JSON 포맷으로 받기
author: 박연오(bakyeono@gmail.com)
date: 2017-01-24 16:58 +0900
tags: weather api
---
기상청 동네예보 API를 사용하고 있었는데 2017년 1월 24일부터 갑자기 JSON 포맷으로 요청하면 406 Not Acceptable 상태가 응답되었다.

동네예보 API는 기본 포맷이 XML이다. JSON으로 받기 위해 평소 HTTP 요청에 Accept 헤더를 application/json으로 지정하여 요청하고 있었는데 갑자기 안 되는 것이다.

API 수정 공지가 있었는지 찾아보았지만 찾을 수 없었다. 아마도 다른 패치를 하다가 같이 건드린 것 같다.

해결책은 간단하다. Accept 헤더를 xml로 하거나 그냥 지정하지 않고, 대신 URL 매개변수에 `type=json` 을 지정하면 된다.

