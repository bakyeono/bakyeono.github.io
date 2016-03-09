---
layout: post
title: "클로저(Clojure)에서 해시 알고리즘 사용하기"
author: 박연오(bakyeono@gmail.com)
date: 2013-09-29 13:00 +0900
tags: 클로저 암호화
---
* table of contents
{:toc}

## 해시 알고리즘

[해시 알고리즘][wiki-hash-function]은 정보 보안 분야에서 중요하게 사용된다. 해시 알고리즘 중에는 [맵][wiki-hash-map]과 같은 자료구조에서 빠르고 효율적인 인덱싱을 하기 위해서도 사용되는 것도 있지만 정보 보안에서 사용되는 해시 알고리즘과는 차이가 있다.

보안이나 비교를 위해 사용되는 해시는 복호화가 불가능해 메시지 다이제스트(Message Digest)라고도 부른다. [SHA-256][wiki-sha-256], [MD5][wiki-md5] 등이 많이 쓰인다.

해시 알고리즘이 사용되는 시나리오 중의 하나는 웹서버 프로그램이 데이터베이스에 사용자 계정의 비밀번호를 저장할 때다. 만일 비밀번호를 평문으로 저장한다면 데이터가 유실되었을 경우 사용자들의 비밀번호가 고스란히 노출되고 만다. 비밀번호가 암호화되어 있다면 이런 사고를 방지할 수 있겠지만 암호를 풀 수 있는 키가 함께 노출될 수 있기 때문에 여전히 위험성이 있다. 여러 사이트에서 같은 비밀번호를 공유하는 사용자들에게 이 위험성은 치명적일 수 있다.

이 문제는 비밀번호에 해시 알고리즘을 적용해 해결할 수 있다. 해시 알고리즘은 입력된 값에 대해 결정론적 값을 반환하는 함수(즉, 함수형 프로그래밍 개념의 함수)이어서 같은 알고리즘과 같은 대입값에는 언제나 같은 값을 반환한다. 한편 반환된 값으로 원래의 값을 유추할 수 있는 역함수는 존재하지 않는다. 이 특성을 이용하면 사용자의 비밀번호에 해시 알고리즘을 적용한 해시값을 데이터데이스에 저장하여 두고, 이후 비밀번호를 조회해야 할 때는 사용자가 입력한 비밀번호에 해시 알고리즘을 적용한 값과 데이터베이스에 저장된 값을 비교하면 된다. 이 경우에는 데이터가 유실되더라도 공격자에게 평문 비밀번호를 노출할 가능성이 낮아진다.

> **해시 알고리즘에 대한 공격법**  
>   
> 해시 알고리즘을 적용한 값을 평문으로 바꾸는 방법으로는 무차별 대입 공격(Brute-force)이 사용된다. 하지만 이 공격을 시도하더라도 평문의 비밀번호가 충분히 복잡하다면 이 공격 방법으로 평문의 비밀번호를 알아내는데 필요한 비용을 높일 수 있다. 반대로 말하면, 비밀번호가 간단하다면 해시 알고리즘이 적용된 비밀번호라 하더라도 복호화 될 위험이 커진다는 뜻이다.  
>   
> 공격자들은 이 공격을 효율적으로 수행하기 위해 [레인보우 테이블][wiki-rainbow-table]이라 불리는 해시 변환표를 생성해 값을 비교하는데, 이 방법의 약점을 이용해 평문 비밀번호에 솔트(salt: 즉, 양념을 친다는 뜻) 값을 더해 해시 알고리즘을 적용하는 방법이 널리 사용된다. 공격자들은 평문의 레인보우 테이블은 갖고 있지만 불특정한 솔트 값이 더해진 값의 해시 테이블은 갖고 있지 못하기 때문에 이렇게 하면 무차별 대입 공격으로부터 데이터를 좀 더 안전하게 보호할 수 있다.  
>   
> 이 공격법에 대해 재미있게 설명한 [웹툰(IT이야기 시즌2, 미낙스)][minax-07]이 있으니 관심있는 사람은 읽어보자.

예전에 많이 사용하던 MD5 알고리즘은 위험성이 발견되어 사용하지 않는 것이 좋다고 한다. 지금은 SHA-1, SHA-256 등의 알고리즘을 많이 사용한다. 자바에서는 java.security.MessageDigest 클래스를 이용해 각종 해시 알고리즘을 간단히 적용할 수 있다.

## 클로저에서 해시 알고리즘 사용하기

클로저는 별도의 절차 없이 자바 라이브러를 바로 사용할 수 있기 때문에 MessageDigest 클래스로 해시 알고리즘을 간편하게 사용할 수 있다. MessageDigest의 클래스의 사용법은 다음과 같다.

1. 해시 알고리즘을 적용할 문자열의 바이트 배열을 준비한다. (문자열이 아닌 경우에도 바이트 배열로 직렬화한다.)

2. MessageDigest의 getInstance 메소드에 사용할 알고리즘을 요청해 인스턴스를 획득한다.

3. MessageDigest 인스턴스의 update 메소드를 호출해 해시 알고리즘을 적용할 바이트 배열을 전달한다.

4. MessageDigest 인스턴스의 digest 메소드를 호출해 해시 알고리즘을 수행한다.

5. 해시 알고리즘이 적용된 바이트 배열이 반환된다. 이 값을 필요에 맞게 인코딩한다.

그러면 이 과정을 클로저 코드로 작성해 보자. 함수 이름은 메시지 다이제스트를 뜻하는 'digest'라고 붙였다.

    (defn digest
      "문자열에 지정한 해시 알고리즘을 적용해 바이트 배열로 반환한다."
      [string algorithm]
      (let [message-digest (java.security.MessageDigest/getInstance algorithm)]
        (.update message-digest (.getBytes string))
        (.digest message-digest)))

이 함수를 호출할 때는 평문과 적용할 알고리즘명을 인자로 넘긴다.

    (digest "암호화되지 않은 문자열" "SHA-256")
    ; 반환값: <byte[] [B@4ba43077>

바이트 배열이 반환된 이유는 위 함수에서 5번 과정을 생략했기 때문이다. 바이트 배열을 읽기 쉽고 텍스트 형식으로 저장할 수 있는 hex 문자열로 변환해보자. 나는 아래와 같이 변환 함수를 만들었다.

    (defn byte-array->hex-string
      "바이트 배열을 hex 문자열로 변환한다."
      [array]
      (let [buffer (StringBuffer.)]
        (dotimes [i (count array)]
          (.append buffer (Integer/toString (bit-and (get array i)
                                                     0xff)
                                            16)))
        (.toString buffer)))

해시 함수의 결과값에 변환 함수를 적용해보자.

    (byte-array->hex-string (digest "암호화되지 않은 문자열" "SHA-256"))
    ; 반환값: "62158dba82f57aa5dc5935fc973671d9cac89b6f41bfa9f3ff56c641beced11"

이렇게 hex 문자열 표현을 얻을 수 있다. 필요하다면 [Base64][wiki-base64] 등의 인코딩을 적용할 수도 있을 것이다.

SHA-256이 아닌 다른 해시 알고리즘을 적용하고 싶다면 위에서 만든 digest 함수의 두번째 인자 값으로 "SHA-256" 대신 "MD5", "SHA-1" 과 같이 이용할 알고리즘명을 넘기면 된다. 물론, MessageDigest 클래스가 지원하는 알고리즘이어야 할 것이다. 모든 자바 구현은 MD5, SHA-1, SHA-256 알고리즘을 지원하도록 정의되어 있다. 자바 구현에 따라 이 외의 알고리즘도 추가로 지원할 수 있다.


[wiki-hash-function]: http://ko.wikipedia.org/wiki/%ED%95%B4%EC%8B%9C_%ED%95%A8%EC%88%98
[wiki-hash-map]: http://ko.wikipedia.org/wiki/%ED%95%B4%EC%8B%9C_%ED%85%8C%EC%9D%B4%EB%B8%94
[wiki-md5]: http://ko.wikipedia.org/wiki/MD5
[wiki-sha-1]: http://ko.wikipedia.org/wiki/SHA-1
[wiki-sha-256]: http://ko.wikipedia.org/wiki/SHA-256
[wiki-rainbow-table]: http://en.wikipedia.org/wiki/Rainbow_table
[wiki-base64]: http://ko.wikipedia.org/wiki/%EB%B2%A0%EC%9D%B4%EC%8A%A464
[minax-07]: http://minix.tistory.com/406

