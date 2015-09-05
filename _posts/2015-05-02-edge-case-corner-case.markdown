---
layout: post
title: 엣지 케이스(edge case)와 코너 케이스(corner case)
author: 박연오(bakyeono@gmail.com)
date: 2015-05-02 19:13
tags: 용어 디버그 테스트
---
[엣지 케이스(edge case)][edge-case-wikipedia]와 [코너 케이스(corner case)][corner-case-wikipedia]는 프로그래밍, 디버깅, 단위 테스트 등에서 사용되는 비슷하지만 다른 용어다.

책을 보다 헷갈려서 의미를 구분해 봤다.

## 엣지 케이스

엣지 케이스란 알고리즘이 처리하는 데이터의 값이 알고리즘의 특성에 따른 일정한 범위를 넘을 경우에 발생하는 문제를 가리킨다.

예를 들면 fixnum이라는 변수의 값이 -128 ~ 127의 범위를 넘는 순간 문제가 발생하는 경우가 있을 수 있다. 어떤 분모가 0이 되는 상황처럼 데이터의 특정값에 대해 문제가 발생하는 경우도 마찬가지다.

엣지 케이스는 알고리즘의 특성에 따라 개발자가 면밀히 검토하여 예상할 수 있는 문제다. 이런 문제는 디버그가 쉽기도 하고 테스트를 통해 미리 방지하기도 쉽다.

비슷한 상황을 가리키는 용어로 [경계 케이스(boundary case)][boundary-case-wikipedia]가 있다.

## 코너 케이스

코너 케이스는 여러 가지 변수와 환경의 복합적인 상호작용으로 발생하는 문제다.

예를 들어 fixnum이라는 변수의 값으로 128이 입력되었을 때, A 기계에서 테스트했을 때는 정상작동하지만 B 기계에서는 오류가 발생한다면 코너 케이스라고 할 수 있다. 같은 장치에서라도 시간이나 다른 환경에 따라 오류가 발생하기도 하고 정상작동 하기도 한다면 이것도 코너 케이스다.

특히 멀티코어 프로그래밍에서 만나기 쉬운 오류일 것이다.

코너 케이스는 오류가 발생하는 상황을 재현하기가 쉽지 않아 디버그와 테스트가 어렵다.

[edge-case-wikipedia]: http://en.wikipedia.org/wiki/Edge_case
[corner-case-wikipedia]: http://en.wikipedia.org/wiki/Corner_case
[boundary-case-wikipedia]: http://en.wikipedia.org/wiki/Boundary_case

