---
layout: post
title: 새 우편번호 검색을 위한 간단한 스크립트
author: 박연오(bakyeono@gmail.com)
date: 2015-08-09 21:03
tags: 리눅스 bash 우편번호
---
* table of contents
{:toc}

우편번호 체계가 바뀌어서 데이터를 갱신해야 하는 작업이 많다. 한국 포털 검색 엔진에 주소를 검색하면 새 우편번호를 쉽게 찾을 수 있다. 반복잡업을 피하고 싶다면 w3m 브라우저를 이용해 우편번호를 찾는 스크립트를 만들어 쓰면 편하다.

이 글은 개인적 용도로 만든 스크립트를 소개한다.

> 주의: 스크립트를 이용하는 방법은 해석하기에 따라 포털 사이트의 이용약관에 위배될 수 있다. 이 스크립트를 사용하는 사람은 그에 따르는 책임을 지도록 하자. 나는 책임을 지지 않는다.

> 참고: 새 우편번호를 찾으려면 기존 우편번호로 검색하면 안 되고 지번주소 또는 도로명주소로 검색해야 한다. 기존 우편번호와 새 우편번호는 1:1 대응관계가 아니다.

## 새 우편번호 검색 스크립트

이 스크립트를 사용하려면 w3m과 sed가 필요하다. 설치하자.

    $ sudo apt-get install w3m sed

에디터를 열어 스크립트 파일을 만든다. 파일명은 `q-postcode.sh` 로 했다.

    $ vi q-postcode.sh

스크립트 내용은 아래와 같다. 이 내용을 위의 파일에 넣는다.

    #!/bin/bash
    
    # environment
    LANG="ko_KR.utf-8" 
    
    # temp file
    tmp_dir="/tmp" # dirs for temporary files
    tmp_prefix="postcode-conv" # prefix for temporary filename
    clear_tmp=true # clear temporary files after the job?
    time_stamp=`date +%s%N`
    tmp_file=$tmp_dir/$tmp_prefix$time_stamp
    
    # parameter check
    if [ -z $1 ]; then
      >&2 echo "ERROR: No search string supplied."
      exit 1
    fi
    
    # request
    function url_encode() { echo -n $@ | perl -pe's/([^-+_.~A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg'; }
    address=`url_encode $@`
    q_url="http://search.daum.net/search?nil_suggest=btn&w=tot&DA=SBC&q=$address"
    w3m -dump -cols 65536 -ppl 65536 $q_url > $tmp_file 2> /dev/null
    
    # parse
    sedexp='s/\ +([0-9]{5})$/\1\n/p'
    result=`sed -n -r "$sedexp" $tmp_file`
    echo "$result"
    
    # clear temp files
    if [[ $clear_tmp == true ]]; then
      rm $tmp_file
    fi
    
    exit

실행 권한을 지정한다.

    $ chmod u+x q-postcode.sh

스크립트를 시험해 보자.

    $ ./q-postcode 서울시 영등포구 버드나루로 100
    07230

우편번호가 정상적으로 출력된다.

> 주의: 소스를 보면 알곘지만 이건 급하게 만든 임시 스크립트다. html을 구조적으로 해석하지 않고 정규표현식으로 게으르게 읽는다. 따라서 잘못된 결과가 나올 경우가 있을 수 있으며, 포탈 사이트의 출력 방식이 바뀌면 sed 정규표현식을 수정해야 한다.

## 대량의 우편번호 찾기

찾아야 할 우편번호가 많다면 파일에서 주소 목록을 읽어 처리하도록 하면 된다. 한 줄에 주소가 하나씩 있는 파일을 처리하는 스크립트를 만들어 보자. 파일명은 `convert.sh` 로 했다.

    $ vi convert.sh

아래 내용을 입력한다.

    #!/bin/bash
    
    while read line; do
      result=$(./q-postcode.sh $line | head -n 1)
      echo $result
    done

이 스크립트에도 실행 권한을 지정한다.

    $ chmod u+x convert.sh

이 스크립트는 한 줄에 주소 하나씩 입력받아 우편번호를 출력해준다.

스크립트를 시험해보기 위한 데이터 파일을 준비하자. 터미널에 아래와 같이 입력한다. 주소 리스트가 있는 스프레드시트 문서에서 복사해 넣어도 된다.

    $ cat > data.txt << _EOF_
    서울특별시 중구 세종대로 110
    부산 영도구 태종로 423
    율도국 홍길동 7878
    경기도 광주시 행정타운로 50
    _EOF_

찾을 수 없는 주소가 데이터에 있으면 어떻게 출력되는지 확인하기 위해 중간에 **율도국 홍길동 7878**을 넣었다.

이제 시험해보자.

    $ ./convert.sh < data.txt
    04524
    49011
    
    12738

우편번호를 찾을 수 있는 경우 우편번호가 출력됐고, 찾을 수 없는 **율도국 홍길동 7878**의 우편번호는 빈 줄로 출력됐다.

사용해보면 처리 속도가 느리다는 것을 알 수 있을 것이다. 수천 개 이상의 대량의 데이터를 작업해야 한다면 멀티쓰레딩을 해야 할 것이다. 이 글에서는 거기까지는 다루지 않는다.

