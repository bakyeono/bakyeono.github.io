---
layout: post
title: 엘라스틱서치 쿼리 DSL 기초
author: 박연오(bakyeono@gmail.com)
date: 2016-08-20 15:49 +0900
tags: 엘라스틱서치 쿼리DSL 검색
---
* table of contents
{:toc}

> 2017년 1월 25일에 남긴 노트: 이 글은 이제 적합하지 않다. 엘라스틱서치 버전 5가 발표됐는데 이전 버전과 달라진 점이 조금 있기 때문에다. 가능하다면 최신 버전을 다룬 글을 찾아 읽는 것을 권한다.

엘라스틱서치에 색인된 문서를 검색할 때 사용하는 쿼리 DSL에 관한 기초적인 소개다. 내가 학습하면서 요점만 정리한 것이어서 수준이 얕다. 어떻게 써야 하는지 무엇을 할 수 있는지 감을 잡는 데는 도움이 될 것이다. 자세한 내용을 알고 싶으면 공식 문서를 참고하기 바란다.

참고 자료:

* 시작하세요! 엘라스틱서치 (김종민)
* [Elasticsearch Reference](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)
* [Elasticsearch: The Definitive Guide](https://www.elastic.co/guide/en/elasticsearch/guide/current/index.html)
* [Elasticsearch Query DSL: Not Just for Wizards (영상)](https://www.elastic.co/kr/webinars/elasticsearch-query-dsl)

이 문서는 당신이 엘라스틱서치와 한글 분석기 플러그인을 설치했고, 인덱스와 매핑을 설정한 후, 문서 색인까지 마쳐둔 상태임을 전제로 한다. 엘라스틱 서치 기초 사용법은 [이 글](http://bakyeono.net/post/2016-06-03-start-elasticsearch.html)을 참고하기 바란다.

문서에 설명된 예들을 엘라스틱서치 서버에 전송하려면 HTTP 메시지를 보낼 수 있는 클라이언트 프로그램을 사용해야 한다. 엘라스틱의 Sense 앱을 써도 되고, cURL 같은 커맨드라인 유틸리티를 써도 된다. 커맨드라인에서 HTTP 메시지 보내는 방법을 알고싶다면 [이 글](http://bakyeono.net/post/2016-05-02-rest-api-client-for-cli.html)을 참고하자.


## 검색 요청하기

쿼리 DSL로 질의할 때는  `/_search` URL로 GET 요청을 보낸다.

    GET /_search

특정 인덱스에 제한해서 검색하고 싶다면 URL에 인덱스를 명시한다.

    GET /index/_search

특정 타입으로 제한할 수도 있다.

    GET /index/type/_search

쿼리 DSL은 HTTP 요청 메시지 본문에 JSON 문서로 삽입한다. 쿼리 옵션은 "query" 속성의 값으로 넣는다.

    GET /_search
    {
      "query": { ... }
    }

다음은 쿼리에 사용할 수 있는 기본 옵션이다.


### match_all

* `query: match_all`

모든 문서와 매치한다. 생략한 것과 결과가 같다.

    GET /_search
    {
      "query": {"match_all": {}}
    }


### match

* `query: match: 옵션`

지정한 필드에 전문 검색을 수행한다.

    GET /_search
    {
      "query": {"match": {"title": "민주노총"}}
    }


## 검색 결과 가공

### 출력 필드 선택

* `fields: [필드, ...]`

기본으로 매치된 문서의 모든 필드가 출력된다. 네트워크 자원을 절약하고 싶다면 fields 옵션으로 필요한 필드만 선택해서 받아올 수 있다.

예) 작성자, 작성일만 받아오기

    GET /_search
    {
      "fields" : ["user", "created_at"],
      "query" : {
        "term" : {"title" : "민주노총"}
      }
    }

### 페이지 나누기 (Pagination)

* `from: 값`
* `size: 값`

from, size 옵션으로 검색 결과를 분할할 수 있다.

예) 검색 결과 중 10번째 문서부터 5개의 문서 가져오기.

    GET /_search
    {
      "from": 10,
      "size": 5,
      "query" : {
        "term" : {"title" : "민주노총"}
      }
    }

from의 기본값은 0, size의 기본값은 10이다.


### 정렬

* `sort: [{필드: {옵션, ...}}, ...]`

sort 옵션으로 검색 결과를 정렬할 수 있다.

예) 작성자 오름차순, 작성일 내림차순, 연관성 순으로 정렬

    GET /_search
    {
      "sort": [
        {"writer": {"order": "asc""}},
        {"created_at": {"order": "desc""}},
        "_score"
      ],
      "query" : {
        "term" : {"title" : "민주노총"}
      }
    }

참고로 `_doc` 필드로 정렬할 때가 정렬 성능이 가장 빠르다. 정렬이 필요없다면 성능을 위해 `_doc`으로 정렬하도록 하면 된다. 기본으로는 연관성 순으로 정렬된다.


### 하이라이트

* `highlight: fields: 필드: {}`

highlight 옵션으로 매치된 텀을 강조할 수 있다. fields 옵션에 처리를 하고 싶은 필드를 지정한다.

예)

    GET /_search
    {
      "query": {
        "match": {
          "title": "민주노총"
        }
      },
      "highlight": {
        "fields": {
          "title": {}
        }
      }
    }

기본 강조 방식은 `<em>텀</em>` 태그를 붙이는 것이다. 이것을 바꾸고 싶다면 `pre_tags`, `post_tags` 옵션을 지정한다.

예)

    GET /_search
    {
      "query": {
        "match": {
          "title": "민주노총"
        }
      },
      "highlight": {
        "fields": {
          "title": {}
        },
        "pre_tags": ["<em class=\"matched-term\">"],
        "post_tags": ["</em>"]
      }
    }


## 쿼리와 필터의 구분

쿼리와 필터는 둘 다 문서를 걸러내고 선택하는 용도이므로 비슷하지만, 구체적인 쓰임새가 다르다.

쿼리 | 필터
---- | ----
연관성 | YES/NO
캐시 불가 | 캐시 가능
느림 | 빠름

성능을 위해서는 필터를 먼저 한 뒤에 쿼리를 하는 것이 효과적이다.

    GET /_search
    {
      "query": {
        "filtered": {
          "filter": {
            "term": {"genre": "편지"}
          },
          "query": {
            "match": {"title": "민주노총"}
          }
        }
      }
    }


## 필터

필터는 문서를 조건에 따라 참/거짓으로 평가하고, 참인 것만 골라낸다.

문서가 지정한 조건과 얼마나 유사한지(_score)는 평가하지 않는다. boost 옵션을 지정하지 않으면, 매치된 문서의 유사도(_score)는 모두 1점이 된다.

유사도를 평가하지 않기 때문에 쿼리에 비해 성능이 좋다. 캐시도 지원한다.

### 필터의 캐시 원리

루씬은 아래와 같은 형태로 역 색인표를 만든다.

필드 | 텀 | 문서1 | 문서2 | 문서3 | 문서 N
---- | ---- | ---- | ---- | ---- | ----
title | 민주노총 | 1 | 0 | 0 | ...
title | 한상균 | 0 | 1 | 0 | ...
title | 편지 | 1 | 1 | 1 | ...
genre | 편지 | 0 | 0 | 1 | ...

캐시는 필터 전용 역색인표라고 할 수 있다. 마치 역색인표의 일부를 뽑아낸 것과 비슷한 모양으로 저장된다.

필터 종류, 필드, 텀에 의해 캐시의 키를 정하고, 필터의 결과를 비트벡터 형태로 저장해둔다. 예를 들어, 텀 필터의 결과는 다음과 같이 캐시된다.

    "title:민주노총" = [1, 0, 0]
    "title:한상균" = [0, 1, 0]
    "title:편지" = [1, 1, 1]
    "genre:편지" = [0, 0, 1]

필터의 종류에 따라 캐시가 지원되지 않는 것도 있다.


### term 필터

* `query: filtered: filter: term: 필드: 텀`

지정한 필드에 지정한 텀이 들어있는 문서와 매치된다. 여기서 텀은 각각의 고유한 검색어를 가리키는 용어다. 텀 필터는 용어에 분석을 하지 않고, 완전히 일치할 때만 매치한 것으로 본다.

예) 장르가 편지인 문서

    GET /_search
    {
      "query": {
        "filtered": {
          "filter": {
            "term": {"genre": "편지"}
          }
        }
      }
    }


### terms 필터

* `query: filtered: filter: terms: 필드: [텀1, 텀2]`

term 필터와 같지만, 복수의 텀을 배열로 지정할 수 있다.

예) 키워드에 민주노총 또는 민주노동당이 포함된 문서

    GET /_search
    {
      "query": {
        "filtered": {
          "filter": {
            "terms": {"keyword": ["민주노총", "민주노동당"]}
          }
        }
      }
    }


### range 필터

* `query: filtered: filter: range: 필드: gt|lt|gte|lte: 값`

지정한 필드에 들어있는 값이 지정한 범위에 포함되는 문서와 매치된다.

수, 날짜, 문자열 등 다양한 타입에 적용 가능하지만, 수와 날짜에 최적화되어 있다고 한다.

예) id가 10000 - 10010 인 문서

    GET /_search
    {
      "query": {
        "filtered": {
          "filter": {
            "range": {
              "id": {
                "gte": 10000,
                "lt": 10010
              }
            }
          }
        }
      }
    }

예) 2009-04-09 - 2009-04-30 에 생성된 문서

    GET /_search
    {
      "query": {
        "filtered": {
          "filter": {
            "range": {
              "created_at": {
                "gte": "2009-04-09",
                "lt": "2009-04-30"
              }
            }
          }
        }
      }
    }

예) 1시간 전에 생성된 문서 (수식 입력 가능)

단, 이 경우는 now가 사용되었기 때문에 캐시가 되지 않는다.

    GET /_search
    {
      "query": {
        "filtered": {
          "filter": {
            "range": {
              "created_at": {
                "gte": "now - 1h"
              }
            }
          }
        }
      }
    }


### exists 필터

* `query: filtered: filter: exists: field: 필드`

필드에 어떤 값이든 값이 존재한다면, 그 문서와 매치된다.

예) URL이 입력된 문서

    GET /_search
    {
      "query": {
        "filtered": {
          "filter": {
            "exists": {"field": "url"}
          }
        }
      }
    }


### bool 필터

* `query: filtered: filter: bool: must|should|must_not: [필터]`
* `query: filtered: filter: bool: must|should|must_not: {옵션}`

필터를 AND, OR, NOT 논리 연산으로 결합하는 데 쓰인다.

* must: 문서가 모든 필터에 매치되어야 매치된다. (AND)
* should: 문서가 하나의 필터라도 매치되면 매치된다. (OR)
* must_not: 문서가 필터에 매치되지 않아야 매치된다. (NOT)

예) 장르가 편지, 키워드가 비정규직이고, 키워드에 현대자동차 또는 파업이 포함돼 있으며, 키워드에 현대중공업이 없는 문서

    GET /_search
    {
      "query": {
        "filtered": {
          "filter": {
            "bool": {
              "must": [
                {"term": {"genre": "편지"}},
                {"term": {"keyword": "비정규직"}}
              ],
              "should": [
                {"term": {"keyword": "현대자동차"}},
                {"term": {"keyword": "파업"}}
              ],
              "must_not": [
                {"term": {"keyword": "현대중공업"}}
              ]
            }
          }
        }
      }
    }

bool 필터 안에 아무 필터나 담을 수 있다. bool 필터를 중첩하는 것도 가능하다.

예) (장르=편지 AND 키워드=비정규직) OR (장르=리뷰 AND 키워드=비정규직)

    GET /_search
    {
      "query": {
        "filtered": {
          "filter": {
            "bool": {
              "should": [
                {
                  "bool": {
                    "must": [
                      {"term": {"genre": "편지"}},
                      {"term": {"keyword": "비정규직"}}
                    ]
                  }
                },
                {
                  "bool": {
                    "must": [
                      {"term": {"genre": "리뷰"}},
                      {"term": {"keyword": "비정규직"}}
                    ]
                  }
                }
              ]
            }
          }
        }
      }
    }

bool 필터 전체는 캐시가 되지 않지만, 각각의 하위 필터는 캐시가 된다.


## 쿼리

쿼리는 필터와 달리 연관성 점수를 매긴다. 대신 시간이 더 걸리고, 캐시도 되지 않는다.


### 연관성 점수 기준

엘라스틱서치는 루씬 라이브러리를 사용하므로, 루씬의 연관성 점수 기준이 사용된다.

* Term frequency: 문서(필드) 안에 term이 자주 출현할수록 고득점
* Inverse document frequency: 색인된 모든 문서(필드)에 term이 적게 존재할수록 고득점
* Length norm: 문서(필드)가 짧을수록 고득점


### bool 쿼리

bool 쿼리는 bool 필터와는 다르게 동작한다.

* must: bool 필터와 동일
* must_not: bool 필터와 동일
* should: minimum_should_match(기본값=1) 값보다 크면 결과에 포함
* minimum_should_match: 기본값=1, (must가 함께 사용되면 기본값=0). 퍼센트, 실수 사용가능

이렇게 되는 이유는, bool 필터는 True/False 로만 분류하는 반면, bool 쿼리는 연관성 점수를 매기기 때문이다.

bool 쿼리의 연관성 점수 = 문서가 결과에 포함된 각 쿼리 점수의 합 * 문서가 결과에 포함된 쿼리 수 / 전체 쿼리 수

should를 여러 개 쓸 때, minimum_should_match를 이용하면 롱테일(연관성 낮은 것들이 결과에 잔뜩 포함되는 것)을 걸러낼 수 있다.


### term 쿼리

* `query: term: 필드: 질의어`

term 필터와 똑같이 동작하는데, term 필터와는 달리 연관성 점수를 매긴다.

예) 키워드가 민주노총인 문서

    GET /_search
    {
      "query": {
        "term": {
          "keyword": "민주노총"
        }
      }
    }

이것 대신 match 쿼리를 사용하는 것이 좋다. term 쿼리는 저수준의 쿼리로 직접 사용할 필요가 없다. 그리고 은전한닢 분석기로 분석된 한글은 분석을 거치지 않은 한글과는 텀이 일치하지 않으므로 분석을 돌린 필드에는 term 쿼리로 선택이 안 된다.


### match 쿼리

* `query: match: 필드: 텀`
* `query: match: 필드: {옵션}`

고수준의 쿼리로, 매핑과 분석이 적용된다. 문서뿐 아니라 검색어 자체에도 분석을 적용한다.

예) 제목에 박근혜가 들어가는 문서

    GET /_search
    {
      "query": {
        "match": {
          "title": "박근혜"
        }
      }
    }

예) 제목에 박근혜 또는 한반도가 들어가는 문서

term 쿼리와는 달리, 간단히 띄어쓰기만 해 주면 bool-should 쿼리를 한 것과 같이 된다.

    GET /_search
    {
      "query": {
        "match": {
          "title": "박근혜 한반도"
        }
      }
    }

예) 제목에 박근혜와 한반도가 둘 다 들어가는 문서

operator를 and로 지정하면 bool-must 쿼리를 한 것과 같이 된다.

필드를 {}로 한 번 더 감싸고 query 키도 추가해 줘야 한다는 점을 유의

    GET /_search
    {
      "query": {
        "match": {
          "title": {
            "query": "박근혜 한반도",
            "operator": "and"
          }
        }
      }
    }

예) 롱테일 걷어내기

minimum_should_match를 지정해준다.

    GET /_search
    {
      "query": {
        "match": {
          "title": {
            "query": "박근혜 한반도",
            "operator": "or",
            "minimum_should_match": 2
          }
        }
      }
    }


### fuzziness 옵션

검색어와 필드 값이 조금 차이가 나더라도 매치가 되도록 하고 싶을 수 있다. fuzziness 옵션을 지정하면 이것이 가능하다.

> 편집 거리 알고리즘(Levenshtein Edit Distance): 두 문자열이 얼마나 유사한지 계산하는 알고리즘. 문자열 A와 문자열 B가 같아지기 위해 몇 번의 편집 연산(삽입/삭제/대체)을 해야하는지 계산하여 구한다.

fuzziness를 지정하면, 편집 거리 알고리즘을 사용해 약간의 차이를 허용하도록 할 수 있다.

예) 퍼지를 지정하면 '박연오 스캔들'로 검색했는데 박연차 스캔들이 검색된다.

    GET /_search
    {
      "query": {
        "match": {
          "title": {
            "query": "박연오 스캔들",
            "fuzziness": "AUTO"
          }
        }
      }
    }


### match_phrase 쿼리

match_phrase: 필드명: 질의어
match_phrase: 필드명: {옵션}

match 쿼리는 용어 사이에 띄어쓰기를 하면 bool-should 쿼리로 처리된다. 띄어쓰기까지 모두 포함해 정확한 구(phrase)를 검색하고 싶다면 match_phrase 쿼리를 사용한다.

예) 모든 단어가 정확한 위치에 있어야 매치된다.

    GET /_search
    {
      "query": {
        "match_phrase": {
          "title": {
            "query": "민주노총 파업"
          }
        }
      }
    }

이 때, '파업 민주노총'과 같이 단어의 위치가 다를 경우에는 매치가 되지 않는다. slop 옵션을 지정하면 단어의 위치가 도치되었을 때도 어느 정도 허용되도록 할 수 있다.

예) slop 옵션으로 단어 위치 도치 범위 조절

    GET /_search
    {
      "query": {
        "match_phrase": {
          "title": {
            "query": "스캔들 박연차",
            "slop": 5
          }
        }
      }
    }


### dis_max 쿼리

* `query: dis_max: queries: [{쿼리}, ...]`

질의어를 필드마다 별도로 입력(고급 검색)하는 것이 아니라, 하나의 검색어를 여러 필드에 동시에 적용할 때(통합 검색) 점수가 어떻게 계산될까?

예를 들어, "박연오 잘생겼다"로 검색을 할 때, 다음 두 문서가 매치되었다. 무엇이 점수가 더 높을까?

문서 1
    
    제목: 박연오의 하루
    내용: ... 박연오는 오늘 기분이 좋다. ...

문서 2

    제목: 현대 인명사전
    내용: ... 박연오 잘생겼다. ...

"박연오 잘생겼다"라는 정확한 구가 문서 2에 존재하지만, 문서 1이 점수가 더 높다. 여러 필드에 매치되면 하나의 필드에 정확하게 매치되는 것보다 점수가 더 높게 매겨지기 때문이다.

이런 경우에, 문서 2에 더 높은 점수를 주고 싶다면 dis_max 쿼리를 이용한다.

dis_max 쿼리는 여러 쿼리로 매치되는 문서를 모두 뽑은 후, 가장 정확한 매치가 이뤄진 문서에 높은 점수를 매긴다.

예)

    GET /_search
    {
      "query": {
        "dis_max": {
          "queries": [
            {"match": {"title": "억압적인 군대"}},
            {"match": {"content": "억압적인 군대"}}
          ]
        }
      }
    }

여기에 tie_breaker라는 옵션을 줄 수 있다. 이 옵션을 지정하면 여러 필드에서 텀이 발견되었을 때 부여할 가산점의 비율을 정할 수 있다. dis_max 쿼리에서 tie_breaker의 기본값은 0이다.

> dis_max 의 이름은 루씬의 `DisjunctionMaxQuery`에서 딴 것이다.


### multi_match 쿼리

* `query: multi_match: {query: 텀, fields: [필드, ...], type: "다중필드 검색 방식"}`

term, terms, match는 한 번에 하나의 필드에만 적용할 수 있다. 여러 필드에 검색하도록 하려면 bool 쿼리를 사용해야 하는데 좀 불편하다.

multi_match 쿼리를 쓰면 다중 필드 검색 쿼리를 좀 더 편리하게 작성할 수 있다.

multi_match에는 type 옵션이 있다. 다중 필드를 어떤 방식으로 검색하게 할 것인지 정한다.

예) type: "best_fields"(기본값) -- 한 필드에서 정확하게 매치되면 점수가 높다. dis_max와 같은 동작

    GET /_search
    {
      "query": {
        "multi_match": {
          "query": "억압적인 군대",
          "fields": ["title", "content"],
          "tie_breaker": 0.2,
          "type": "best_fields"
        }
      }
    }

예) type: most_fields: 매치되는 필드가 많을 수록 점수가 높다.

    GET /_search
    {
      "query": {
        "multi_match": {
          "query": "억압적인 군대",
          "fields": ["title", "content"],
          "tie_breaker": 0.2,
          "type": "most_fields"
        }
      }
    }

예) type: cross_fields: 모든 필드를 하나의 필드에 합친 것처럼 검색한다.

    GET /_search
    {
      "query": {
        "multi_match": {
          "query": "억압적인 군대",
          "fields": ["title", "content"],
          "tie_breaker": 0.2,
          "type": "cross_fields"
        }
      }
    }


### 가산점 비율 조정

boost 옵션으로 각 쿼리마다 가산점 비율을 조절할 수 있다.

boost의 기본값은 1이다. 1보다 크면 점수가 높게 오르고 1보다 적으면 점수가 낮게 오른다.

하지만 2를 준다고해서 점수가 2배로 오르는 것은 아니며, 정규화를 거친 후 적용된다.

예) 제목에 민주노총이 들어가면 가산점을 주고, 키워드가 세월호면 더 높은 비율로 가산점 부여

    GET /_search
    {
      "query": {
        "bool": {
          "should": [
            {
              "match": {
                "title": {
                  "query": "민주노총",
                  "boost": 1.2
                }
              }
            },
            {
              "match": {
                "keyword": {
                  "query": "세월호",
                  "boost": 2
                }
              }
            }
          ]
        }
      }
    }


## 중첩 필드(nested fields)에서의 쿼리와 필터

### 중첩 필드란

엘라스틱서치는 NoSQL 구조이므로 RDBMS 방식의 관계(엔티티를 키로 연결하는 것)를 지원하지 않는다. 공식 매뉴얼에 따르면 관계를 표현하기 위해 다음 방법을 쓰라고 돼 있다.

* 응용 계층에서 관계 적용: 각 엔티티마다 인덱스(또는 타입)을 만들고, 관계를 통한 검색을 할 때는 여러 차례의 쿼리를 거듭하는 방법. 필터 역할을 할 인덱스의 검색 결과가 적을 때 (1개일 때 가장 좋음) 효과적이다.

* 반정규화/중첩 객체: 데이터를 반정규화하여 색인하는 방법. 관계에 포함될 엔티티의 주요 속성을 반정규화하여 넣어둔다. 엘라스틱서치 본연의 방식이며, 검색 성능이 가장 좋다. 중첩 객체는 필드 교차 검색을 방지하기 위해 필요하다.

* 부모-자식 관계: 하나의 문서 안에 관계 객체를 삽입하는 중첩  객체 방식과는 다르게, 관계 객체를 별도의 문서에 저장하는 방법. RDBMS의 일 대 다 관계 설정이 가능하다. 한 문서가 갱신되어도 연결된 다른 문서의 인덱스를 갱신하지 않는다. 자식의 속성으로 부모를 검색하거나 부모의 속성으로 자식 객체을 검색하는 것이 가능하다. 반정규화/중첩 객체 방식에 비해 인덱스 성능은 더 좋지만, 검색 성능은 5-10배 느리다고 한다.

엘라스틱서치는 이해가 쉽고 성능이 좋은 반정규화/중첩 객체 방식으로 데이터를 저장하는 것을 권장하고 있다.

중첩 객체의 필드가 중첩 필드다. 중첩 필드에 접근하려면 특별한 DSL 옵션을 사용해야 한다.


### 중첩 필드에 접근하기

중첩 필드에 접근할 때는 nested 옵션을 명시해야 한다.

예) 글쓴이 이름이 박연오인 문서

    GET /archive/homework/_search
    {
      "query": {
        "filtered": {
          "filter": {
            "nested": {
              "path": "writer",
              "query": {
                "term": {
                  "writer.name": "박연오"
                }
              }
            }
          }
        }
      }
    }

단, 인덱스와 문서 타입을 지정하지 않은 채로 루트 URL에 `/_search`로 검색을 요청하면 오류가 발생할 것이다. 매핑이 정의된 문서를 대상으로만 사용할 수 있는 듯하다.

예) 글쓴이 이름이 박연오인 문서 중 제목에 Clojure가 들어가는 문서

    GET /archive/homework/_search
    {
      "query": {
        "filtered": {
          "filter": {
            "nested": {
              "path": "writer",
              "query": {
                "term": {
                  "writer.name": "박연오"
                }
              }
            }
          },
          "query": {
            "match": {
              "title": "Clojure"
            }
          }
        }
      }
    }


## 통계 내기 (aggregations)

* `aggs: 통계이름: 옵션`

aggs 옵션을 이용하면 조건에 따른 문서 수를 통계낼 수 있다. SQL의 `GROUP BY`와 유사한 기능이지만 좀 더 유용하다.

예) 키워드 별 문서 수

    GET /_search
    {
      "aggs": {
        "키워드 별 문서 수": {
          "terms": {"field": "keyword"}
        }
      }
    }

다음과 같이 응답 본문의 aggregations 속성에 통계 결과가 출력된다.

    {
      "hits": { ... },
      "aggregations": {
        "키워드 별 문서 수": {
          "buckets": [
            {"key": "사회운동", "doc_count": 1254},
            {"key": "비정규직", "doc_count": 523},
            {"key": "박근혜", "doc_count": 470},
            {"key": "민주노총", "doc_count": 460},
            ...
          ]
        }
      }
    }

분류한 결과를 다른 조건으로 다시 분류할 수도 있다.

예) 키워드 별, 작성자 별 문서 수

    GET /_search
    {
      "aggs": {
        "키워드 별 문서 수": {
          "terms": {"field": "keyword"},
          "aggs": {
            "작성자 별 문서 수": {
              "terms": {"field": "writer"}
            }
          }
        }
      }
    }

