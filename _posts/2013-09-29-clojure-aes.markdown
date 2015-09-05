---
layout: post
title: "클로저(Clojure)에서 AES 암호화하기"
author: 박연오(bakyeono@gmail.com)
date: 2013-09-29 03:45
tags: 클로저 암호화
---
* table of contents
{:toc}

구매자 정보를 취급하는 판매 관리 프로그램을 클로저로 만들면서 암호화 기능이 필요했다. 이 때 이용한 방법을 간단히 정리해 남긴다.

양방향(대칭) 암호화 알고리즘으로는 [AES(고급 암호화 표준)][wiki-aes]가 널리 사용되고 있고 자바에서도 기본 라이브러리로 제공하고 있다. 클로저는 자바 API를 바로 사용할 수 있다.

## 자바에서 AES 암호화하기

자바에서 암호화 처리를 하는 과정은 다음과 같다.

1. 비밀번호를 128비트 값으로 변환한다.
AES 암호화 알고리즘은 키로 128비트 값을 사용한다. 물론 사용자가 입력하는 비밀번호는 128비트 값이 아니기 때문에 변환해야 한다. (한 분(익명)의 지적으로 이 단락에서 잘못된 부분을 수정했다. - 2014-09-23) 이를 위한 변환 함수가 굳이 양방향일 필요는 없다. 그러므로 해시 함수를 사용할 수 있을 것이다. 비밀번호를 시드값으로 하여 랜덤값을 생성해도 된다.
이를 위해 자바는 암호학적 안전성이 있다고 하는 java.security.SecureRandom 클래스를 제공한다.

2. 준비한 128비트 값을 AES 암호화 알고리즘에 사용할 키 값에 대응하는 객체로 변환한다. javax.crypto.KeyGenerator 클래스에 1에서 생성한 SecureRandom 객체를 넘기면 된다.

3. 키 값의 명세 객체를 생성한다. 앞에서 생성한 보안 키 객체를 javax.crypto.spec.SecretKeySpec 클래스에 넘기면 된다.

4. AES 암호화 객체를 생성한다. javax.crypto.Cipher 클래스에 필요한 암호화 알고리즘을 요청하면 된다. 이 때 3에서 생성한 키 명세 객체가 필요하다.
그리고 암호화할 것인지 복호화할 것인지도 지정한다. 암호화/복호화 모드 지정 값은 javax.crypto.Cipher 클래스에 ENCRYPT_MODE, ENCRYPT_MODE 상수로 정의되어 있다.

5. 생성한 암호화 객체에 데이터를 넘겨 암호화/복호화 처리를 한다. 암호화 객체에 제공할 데이터는 바이트 배열로 직렬화 해두어야 한다.

위 과정들을 자바 코드로 나타내면 다음과 같다.

1번 ~ 2번 과정에 해당하는 코드

    // 지정한 시드 문자열로 보안 키를 생성한다.
    public static byte[] generateRawKey(String seed_string) throws Exception {
      SecureRandom secure_random = SecureRandom.getInstance("SHA1PRNG");
      secure_random.setSeed(seed_string.getBytes("UTF-8"));
      KeyGenerator key_generator = KeyGenerator.getInstance("AES");
      key_generator.init(128, secure_random);
      return (key_generator.generateKey()).getEncoded();
    }

3번 ~ 4번 과정에 해당하는 코드


    // 지정한 모드와 시드 문자열로 javax.crypto.Cipher 객체를 초기화해 반환한다.
    public static Cipher getCipher(int mode, String seed_string) throws Exception {
      SecretKeySpec key_spec = new SecretKeySpec(generateRawKey(seed_string), "AES");
      Cipher cipher = Cipher.getInstance("AES");
      cipher.init(mode, key_spec);
      return cipher;
    }

5번 과정에 해당하는 코드

    // 바이트 배열을 지정한 키 시드 문자열과 AES 알고리즘으로 암호화한다.
    public static byte[] encrypt(byte[] data, String seed_string) throws Exception {
      Cipher cipher = getCipher(Cipher.ENCRYPT_MODE, seed_string);
      return cipher.doFinal(data);
    }
    
    // 바이트 배열을 지정한 키 시드 문자열과 AES 알고리즘으로 복호화한다.
    public static byte[] decrypt(byte[] data, String seed_string) throws Exception {
      Cipher cipher = getCipher(Cipher.DECRYPT_MODE, seed_string);
      return cipher.doFinal(data);
    }

이렇게 만든 함수에 데이터와 비밀번호(시드 문자열)을 제공하면 암호화/복호화 처리를 할 수 있다.

## 클로저에서 자바 암호화 라이브러리 사용하기

클로저에서는 자바 코드를 바로 표현할 수 있기 때문에 앞에서 정리한 코드를 어렵지 않게 클로저 코드로 번역할 수 있다. 앞의 자바 코드를 클로저 코드로 표현하면 다음과 같다.

    (defn get-raw-key
      "지정한 시드 문자열로 보안 키를 생성한다."
      [seed-string]
      (let [key-generator (javax.crypto.KeyGenerator/getInstance "AES")
            secure-random (java.security.SecureRandom/getInstance "SHA1PRNG")]
        (.setSeed secure-random (.getBytes seed-string "UTF-8"))
        (.init key-generator 128 secure-random)
        (-> key-generator
          .generateKey
          .getEncoded)))
    
    (defn get-cipher
      "지정한 모드와 시드 문자열로 javax.crypto.Cipher 객체를 초기화해 반환한다."
      [mode seed-string]
      (let [key-spec (javax.crypto.spec.SecretKeySpec. (get-raw-key seed-string) "AES")
            cipher   (javax.crypto.Cipher/getInstance "AES")]
        (.init cipher mode key-spec)
        cipher))
    
    (defn encrypt
      "바이트 배열을 지정한 키 시드 문자열과 AES 알고리즘으로 암호화한다."
      [array seed-string]
      (let [cipher (get-cipher javax.crypto.Cipher/ENCRYPT_MODE seed-string)]
        (.doFinal cipher array)))
    
    (defn decrypt
      "바이트 배열을 지정한 키 시드 문자열과 AES 알고리즘으로 복호화한다."
      [array seed-string]
      (let [cipher (get-cipher javax.crypto.Cipher/DECRYPT_MODE seed-string)]
        (.doFinal cipher array)))

## 직렬화

Cipher 객체가 암호화한 데이터는 바이트 배열로 반환된다. 파일에 저장할 것이라면 바이트 배열을 파일로 바로 쓰면 될 것이다. 온라인 전송시에는 [Base64 인코딩][wiki-base64]을 많이 사용한다. Base64 변환기는 자바 기본 라이브러리로 제공하지 않는 듯하다. 아파치가 제공하는 라이브러리를 사용해야 한다. 이에 관한 설명은 생략한다.

한편, 클로저에서 데이터를 직렬화하려면 간편하고 성능 좋은 라이브러리가 공개되어 있다. Peter Taoussanis가 만든 [nippy][ptaoussanis/nippy] 를 쓰면 된다. 암호화를 위한 직렬화에도 사용할 수 있고 바이너리 파일로 저장할 때도 유용하다.

## 결론

클로저에서는 자바의 라이브러리를 바로 가져다 쓸 수 있기 때문에 이처럼 자바 코드를 클로저 코드로 간단히 옮겨서 쓸 때가 많다. 다만 이 때 클로저의 자바 호출 코드는 클래스 인스턴스 생성법이나 함수 호출 등의 구문이 자바 코드의 구문과 미묘하게 다르기 때문에 주의해야 한다. 리스프에서 자바를 이용하는 것이 이상하게 보일지 모르지만 자바 세계의 방대한 라이브러리를 별도의 과정 없이 호출해 쓸 수 있다는 점이 주류 언어에 비해 라이브러리가 풍부하지 않은 리스프 언어들 가운데 클로저가 갖는 한 가지 장점이다.


[wiki-aes]: http://ko.wikipedia.org/wiki/%EA%B3%A0%EA%B8%89_%EC%95%94%ED%98%B8%ED%99%94_%ED%91%9C%EC%A4%80
[wiki-base64]: http://ko.wikipedia.org/wiki/%EB%B2%A0%EC%9D%B4%EC%8A%A464
[ptaoussanis/nippy]: https://github.com/ptaoussanis/nippy
