---
layout: post
title: Socket.io 통신에서 이벤트명을 모를 때
author: 박연오(bakyeono@gmail.com)
date: 2016-06-02 23:09 +0900
tags: 자바스크립트 소켓
---
* table of contents
{:toc}

다른 회사(갑)와 공동 프로젝트를 하는데 갑 측이 제공하는 Socket.io 서버와 통신을 해야 할 일이 있었다.

Socket.io 서버에서 데이터를 전송받으려면 정의된 엔드포인트(예: `HOST/some-end-point`)에 접속한 다음 정의된 이벤트(예: `some-event`)에 콜백을 바인딩해야 한다.

    io.connect('HOST/some-end-point').on('some-event', function (data) { ... });

문제는 갑 측이 API의 문서화를 제대로 하지 않고 대응도 잘 해 주지 않아, 통신을 위한 엔드포인트만 알려 주고 발생되는 이벤트명을 잘못 알려준 것이었다. 이벤트명이 잘못된 것 같으니 제대로 된 이벤트명을 알려달라고 재차 삼차 문의해도 질문 자체를 이해하지 못하는 듯, 엉뚱한 답변만이 돌아오는 것이었다... OTL 마감은 코 앞인데 이를 어쩌나.

API를 제대로 만들고 문서화를 제대로 해 달라고 요구하는 것이 올바른 방법이겠지만 임시방편으로는 직접 패킷을 조사해서 데이터 원문을 조사하는 방법과 Socket.io 라이브러리가 모든 이벤트에 반응하도록 하는 방법 정도가 있겠다. 특히 Socket.io가 모든 이벤트에 반응하도록 하면, 이벤트명을 몰라도 통신 데이터를 수신 처리할 수가 있고 이벤트명도 알아낼 수 있다.

Socket.io 문서를 찾아보니 아쉽게도 Socket.io 에는 모든 이벤트에 동작하도록 하는 기능은 없었다. 이런 기능을 이용하려면 Socket.io 코드를 고쳐야 한다. 고맙게도 스택 오버플로의 문서 <http://stackoverflow.com/questions/10405070/socket-io-client-respond-to-all-events-with-one-handler> 에서 누군가가 이런 기능을 오버라이딩한 코드를 올려 두었다.

    var socket = io.connect('HOST/some-end-point');

`socket` 이라는 변수에 소켓통신 객체를 바인딩 해 두었을 때,

    var original_$emit = socket.$emit;
    socket.$emit = function() {
        var args = Array.prototype.slice.call(arguments);
        original_$emit.apply(socket, ['*'].concat(args));
        if(!original_$emit.apply(socket, arguments)) {
            original_$emit.apply(socket, ['default'].concat(args));
        }
    }

    socket.on('*',function(event, data) {
        console.log('Event received: ' + event + ' - data:' + JSON.stringify(data));
    });


위와 같이 하면 수신 이벤트명과 수신 데이터를 확인할 수 있다.

이렇게 확인해보니 갑 측이 보내는 데이터의 이벤트명은 `test`로 되어 있었다. (...)


