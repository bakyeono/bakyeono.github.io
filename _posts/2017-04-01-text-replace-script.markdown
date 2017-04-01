---
layout: post
title: 텍스트 파일 일괄 치환 스크립트
author: 박연오(bakyeono@gmail.com)
date: 2017-04-01 23:11 +0900
tags: 파이썬
---
맞춤법을 지키는 것과 용어를 통일하는 것은 문서를 쓸 때 신경써야할 기본 사항이지만 한국어에서는 유독 틀리기가 쉬운 것 같다. 올바른 글 쓰기 훈련이 부족한 한국의 언어 환경도 원인이지만 한국어 어법이 너무나 까다로운 것도 문제다.

다양한 저자의 원고를 받아 출간해 내는 출판사는 이런 문제로 골머리를 썩는 모양이다. 한 출판사의 편집자에게 들은 바로는 자주 틀리는 표현을 사전으로 저장해두고 일괄 치환한다고 한다. 문맥을 고려하지 않고 치환한다는 위험이 있을 것 같지만 조심해서 사용하면 편리할 것 같다. 문제는 이걸 손으로 하고 있다는 거다. 손이 아무리 빨라도 사전 목록이 길면 길수록 작업시간이 증가할 수밖에 없다.

이런 작업을 해주는 Vim 플러그인이 혹시 있을까해서 찾아 봤지만 못 찾았다. 하지만 이런 건 파이썬으로 한시간 정도 투자하면 자동화할 수 있다. 나도 필요한 스크립트여서 만들어 보았다.

내가 만든 스크립트는 여기서 다운로드할 수 있다.

github: <https://github.com/bakyeono/maptext.py>

아쉽지만 용어 사전은 함꼐 제공하지 않는다. 자주 틀리는 표현과 고쳐야 할 표현을 아래와 같이 CSV 파일로 만들어 사용하면 된다. 파일 인코딩은 UTF-8만 지원한다.

```
src,dst
"파이선","파이썬"
"programing","programming"
"acheive","acheive"
"accross","across"
"comming","coming"
"freind","friend"
"lollypop","lollipop"
"politican","politician"
"sence","sense"
"suprise","surprise"
"threshhold","threshold"
"whereever","wherever"
```

