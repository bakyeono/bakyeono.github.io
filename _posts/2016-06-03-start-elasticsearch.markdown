---
layout: post
title: 엘라스틱서치 기초 사용법
author: 박연오(bakyeono@gmail.com)
date: 2016-06-03 00:20 +0900
tags: 엘라스틱서치 검색 은전한닢
---
* table of contents
{:toc}

이 글은 '노동자연대' 개발팀의 검색 개발 관련 세미나에서 내가 발제한 내용을 정리한 것이다.


## 참고 자료

* 《시작하세요! 엘라스틱서치》 (김종민): 국내 엘라스틱서치 커뮤니티 활동가(현재 엘라스틱사 직원)가 지은 책으로 기본 개념과 기초 사용법을 쉽게 익히는 데 도움이 된다. 하지만 초기버전을 기준으로 쓰인 책이어서 현재 엘라스틱서치 2.3 대 버전과는 차이가 있다.
* Elasticsearch Reference <https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html>: 공식 문서. 필요한 게 있을 땐 여기서 찾아보면 나온다.


## 선제 지식

* JVM: 엘라스틱서치가 자바 애플리케이션이기 때문에 자바 가상 기계 환경에 대한 이해가 있는 편이 좋다.
* HTTP / REST API: 엘라스틱서치의 모든 조작은 REST API를 통해 이뤄지므로, HTTP 요청보내는 방법을 숙지하고 있어야 한다. 참고: 커맨드라인 환경에서 REST API 요청 보내기 <http://bakyeono.net/post/2016-05-02-rest-api-client-for-cli.html>
* JSON: 엘라스틱서치에 저장되는 문서는 JSON 형식으로 저장되며, 엘라스틱서치에 보낼 요청과 응답 본문도 JSON 형식이다.


## 검색과 색인

검색은 왜 필요할까? 방대한 자료 속에서 필요한 데이터를 끄집어내기 위해 필요하다.

검색을 하는 가장 간단한 방법은 무엇인가? 모든 자료를 순차적으로 조회하면 된다. 하지만 이렇게 하면 시간이 너무 많이 걸리고 수고스럽다. 'REST API'의 뜻을 찾기 위해서 도서관의 모든 책을 하나씩 꺼내 첫 페이지부터 마지막 페이지까지 훑어본다면 며칠이나 걸릴까? 밥 안 먹고 밤낮으로 해도 1년은 걸릴 듯하다.

효과적인 검색을 위해서는 미리 분류와 색인을 만들어 두는 것이 도움이 된다. 도서관의 십진분류표나 도서 뒷부분의 찾아보기 항목이 분류와 색인의 좋은 예다. 분류를 통해 어떤 책을 뒤져야 할지 알 수 있고 찾아보기를 통해 'REST API'라는 단어가 있는 페이지를 알 수 있다.

솔라(Solr), 엘라스틱서치 같은 루씬(Lucene) 기반의 검색 애플리케이션을 이용하면 쉽게 색인을 만들고 검색할 수 있다.


## 검색의 과정

일반 사용자들 기준에서 검색이라고 하면 구글에 검색어를 입력하는 단계만 떠올리기 쉽다. 서비스를 구축/제공하는 입장에서는 더 많은 단계를 염두에 둬야 한다. 거칠게 보면 단 한 번의 검색을 하더라도 다음과 같은 단계가 필요하다.

* 데이터 수집(입력) -> 색인 -> 검색 요청 -> 요청 분석 -> 조회/평가 -> 결과


## 엘라스틱서치의 기본 개념/용어

엘라스틱서치에서 사용되는 용어다. 엘라스틱서치를 색인 기능이 추가된 NoSQL DBMS라고 생각하면 이해하기 쉬울 수도 있다.

* 인덱스/타입/문서(index/type/document): 엘라스틱서치의 데이터 계층이다. MySQL로 치면 database/table/row에 대응하는 개념이다. REST API 에서 문서를 표현할 때는 `/news/article/10000` 과 같이 표현한다. 이 때 `news`가 인덱스, `article`이 타입, `10000`이 문서다.

* 필드(field): 엘라스틱서치 문서는 JSON이다. JSON의 각 프로퍼티를 엘라스틱서치에서 필드라고 부른다. MySQL로 치면 column에 대응하는 개념이다.

* 매핑(mapping): 인덱스/타입/문서의 규칙을 정의한 것이다. 사용자가 마음대로 정의할 수 있다. MySQL로 치면 스키마다. NoSQL에도 스키마가 있냐고? 물론 있다.

* 색인(index): 엘라스틱서치가 문서를 검색할 수 있도록 색인 데이터를 만들어두는 과정을 말한다. 데이터 계층의 index와 동일한 단어인데 문맥에 따라 다르게 쓰이므로 주의

* 색인(index): 위의 index의 명사형. 명사형으로 쓰일 때는 색인 작업을 거쳐 만들어진 색인 데이터를 가리킨다. 엘라스틱서치가 다루는 실제 저장된 데이터라고 할 수 있다. index 한 단어가 3가지 의미로 쓰이는 셈이다. 한국어 교재에서는 문맥에 따라 인덱스(데이터 계층)와 색인(색인 과정, 색인 결과)이라는 두 개의 단어로 구분하고 있다.

* 클러스터/노드(cluster/node): 여러 대의 서버를 묶어서 구동하기 위해 사용되는 개념이다. 각 서버가 노드, 서버의 묶음이 클러스터.

* 샤드/복사본(shard/replica): 엘라스틱서치는 색인 데이터를 하나의 물리적 데이터 공간에만 저장하는 게 아니라, 여러 개의 저장공간에 나누거나 복사할 수 있다. RAID0, RAID1과 비슷한 개념이다. shard는 성능향상을 위해 데이터를 여러 물리적 공간에 나눠 저장하는 것이고, replica는 한 노드가 실패했을 때도 검색서비스 제공이 가능하도록 데이터를 여러 물리적 공간(그리고 노드)에 복제해 두는 것이다.

* QueryDSL: JSON으로 표현되는 엘라스틱서치의 검색 문법이다.


## 설치와 실행

### 자바 설치

자바가 필요하다.

시행착오를 줄이고 싶다면 되도록 Oracle Java 8(1.8)을 사용하는 것이 좋을 듯하다. 우분투 계열의 경우 Oracle Java PPA가 제공하는 설치 패키지와 설치 스크립트를 이용하면 편리하다.


### 엘라스틱서치 설치

공식사이트에서 패키지 다운로드하여 압축 풀면 설치 끝.

* <https://www.elastic.co/downloads/elasticsearch>

설치된 디렉토리에서 `bin/elasticsearch` 명령으로 실행한다.

`config/elasticsearch.yml` 파일에서 실행 옵션을 수정할 수 있다. 보안, 메모리 설정, 분산환경(클러스터/노드) 설정 등이 포함돼 있다. 처음 공부할 때는 건들지 않아도 무방하다.


### 한글 형태소 분석기 설치

엘라스틱서치는 한국어를 위한 분석기를 내장하고 있지 않다. 한국어는 복합명사, 술어의 활용, 조사 등이 많기 때문에 띄어쓰기만으로 단어를 분리할 경우 검색 품질이 매우 떨어지게 된다. 따라서 한국어 전용 분석기를 사용해야 한다.

엘라스틱서치용으로 공개된 한글 형태소 분석기로는 은전한닢(MeCab-ko analyzer)이 있다. 물론 다른 형태소 분석기를 쓸 수도 있지만 은전한닢이 사용하기에 가장 편한 듯하다. 원래 분석기, 사전 등 여러 패키지를 직접 컴파일해야 해서 설치방법이 까다로운 편이었는데 언제부터인지 플러그인이 개선되어서 설치가 매우 간편해 졌다.

* 은전한닢(MeCab) 품사 태그표: <https://docs.google.com/spreadsheets/d/1-9blXKjtjeKZqsf4NzHeYJCrr49-nXeRF6D80udfcwY>
* 은전한닢(Mecab) 한글 형태소 분석기 엘라스틱서치 플러그인: <http://eunjeon.blogspot.kr>

엘라스틱 설치 경로에서 아래 명령을 실행해 플러그인 설치한다. 아래 2.3.3.0 부분을 엘라스틱 버전과 맞춰야 한다.

    bin/plugin install org.bitbucket.eunjeon/elasticsearch-analysis-seunjeon/2.3.3.0

만일 다운로드가 안되거나 설치가 안 되면 은전한닢 페이지 <http://eunjeon.blogspot.kr> 에서 버전에 맞는 배포판이 나왔는지, 경로는 어디인지 등을 확인해 본다.

아래의 명령은 은전한닢 플러그인 설치 가이드에서 예로 든 코드다. 분석기가 잘 설치됐다면 엘라스틱서치 서버를 실행시킨 후 아래 명령으로 분석 요청을 보내면 분석 결과가 출력될 것이다.

    ES='http://localhost:9200'
    ESIDX='seunjeon-idx'
    
    curl -XDELETE "${ES}/${ESIDX}?pretty"
    sleep 1
    curl -XPUT "${ES}/${ESIDX}/?pretty" -d '{
      "settings" : {
        "index":{
          "analysis":{
            "analyzer":{
              "korean":{
                "type":"custom",
                "tokenizer":"seunjeon_default_tokenizer"
              }
            },
            "tokenizer": {
              "seunjeon_default_tokenizer": {
                "type": "seunjeon_tokenizer",
                "user_words": ["낄끼빠빠,-100", "버카충", "abc마트"]
              }
            }
          }
        }
      }
    }'
    
    sleep 1
    
    echo "========================================================================"
    curl -XGET "${ES}/${ESIDX}/_analyze?analyzer=korean&pretty" -d '삼성전자'
    echo "========================================================================"
    curl -XGET "${ES}/${ESIDX}/_analyze?analyzer=korean&pretty" -d '빨라짐'
    echo "========================================================================"
    curl -XGET "${ES}/${ESIDX}/_analyze?analyzer=korean&pretty" -d '낄끼빠빠 어그로'


## 인덱스, 타입 준비 (스키마 설정)

RDBMS의 스키마 설계에 대응하는 과정이다.

관련 문서: <https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html>

### 인덱스 설정

인덱스 설정에서 사용할 샤드와 복제본의 개수, 분석기 등을 설정할 수 있다.

다음은 은전한닢을 한글 분석기로 지정하는 인덱스 설정의 JSON 문서다.

    {
      "number_of_shards": 1,
      "number_of_replicas": 0,
      "index": {
        "analysis": {
          "tokenizer": {
            "seunjeon_default_tokenizer": {
              "type": "seunjeon_tokenizer",
              "user_words": ["낄끼빠빠,-100", "버카충", "abc마트"]
            }
          },
          "analyzer": {
            "korean": {
              "type": "custom",
              "tokenizer": "seunjeon_default_tokenizer"
            }
          }
        }
      }
    }

은전한닢(`seunjeon_tokenizer`)을 사용하는 단어 분리기를 만들고 이름을 `seunjeon_default_tokenizer`로 붙였다. 이 때, 옵션을 줄 수 있는데 예로 든 `user_words` 옵션은 사용자 지정 사전이다.

그 다음, 위에서 만든 `seunjeon_default_tokenizer` 단어 분리기를 사용하는 분석기를 만들고 이름을 `korean`으로 붙였다.


### 타입 매핑

MySQL에서 table을 위한 스키마를 만들어 두는 것처럼 엘라스틱서치의 타입(type)에 매핑을 설정할 수 있다. 매핑을 만들어 두어야 매핑에 따라 색인이 만들어지므로 꼭 필요하다.

다음은 기사 타입의 매핑을 지정한 JSON 문서다. 각 필드(property)의 유형을 type으로 지정하고, 색인에 사용할 분석기(analyzer)를 지정하고 있다.

    {
      "properties": {
        "urn":          {"type": "string", "index": "not_analyzed"},
        "title":        {"type": "string", "analyzer": "korean"},
        "content":      {"type": "string", "analyzer": "korean"},
        "writer":       {
          "type": "nested",
          "properties": {
            "name": {"type": "string", "index": "not_analyzed"},
            "email": {"type": "string", "index": "not_analyzed"}
          }
        }
      }
    }

매핑에는 문서 자체에 관한 필드만 만들면 된다. `_id`, `_source`, `_timestamp` 같은 메타 요소들은 내장필드라고하여 자동으로 생성된다.


### 인덱스 생성

이렇게 인덱스 설정과 타입 매핑을 만든 후 엘라스틱서치 서버에 REST API로 요청을 보내 인덱스를 생성한다. 다음과 같이 요청한다.

    PUT /news
    {
      "settings": 위에서 만든 인덱스 설정 JSON,
      "mappings": {
        "article": 바로 위에서 만든 기사 타입의 매핑 JSON
      }
    }

엘라스틱서치에 이 요청을 보내면 `news`라는 인덱스가 지정한 설정과 매핑이 적용된 채로 생성된다.

만일 인덱스를 미리 미리 생성하지 않은 채로 문서를 입력할 경우, 서버가 문서의 내용을 참고해 인덱스와 매핑을 자동 생성한다.

다음 요청으로 특정 타입의 매핑을 조회할 수 있다.

    GET /news/article/_mapping?pretty


## 문서 색인(삽입) 요청 보내기

이제 문서를 삽입하면 앞에서 만든 매핑에 따라 색인이 생성된다. 문서를 삽입할 때는 문서 리소스 URL에 PUT 요청을 보내면 된다. 본문에 JSON 형식으로 문서의 내용을 포함해서 보낸다.

    PUT /news/article/10000
    {
      "urn": "l061-hello-this-is-an-article",
      "title": "안녕하세요. 이것은 기사입니다.",
      "content": "별 내용은 없는 기사...",
      ... 중략 ...
    }

이 때, 인덱스, 타입, 문서ID에 해당하는 문서가 존재하지 않으면 문서가 생성되고, 문서가 이미 존재하면 새 버전으로 갱신된다.

문서의 내용은 매핑에 따라 색인처리되며, 색인 전의 본 내용도 저장되므로 `_source` 내장필드를 통해 꺼낼 수 있다.


## 검색 요청 보내기

관련문서: <https://www.elastic.co/guide/en/elasticsearch/reference/current/search.html>

GET 요청을 문서 리소스 URL을 지정해 보내 문서를 조회할 수 있다.

    GET /news/article/10000

결과:

    {
        "_index" : "news",
        "_type" : "article",
        "_id" : "10000",
        "_version" : 1,
        "found": true,
        "_source" : {
            ... 문서내용 ...
        }
    }

좀 더 자세한 검색을 할 때는 `/인덱스/타입/_search` 에 요청을 보낸다. 옵션은 본문에 JSON으로 지정한다. 다양한 옵션을 한꺼번에 주려 하면 본문이 꽤 복잡해진다.

    GET /news/article/_search
    {
      "size": 20,
      "query": {
        "bool": {
          "must": [
            {
              "nested": {
                "path": "writer",
                "query": {
                  "bool": {
                    "should": [
                      {
                        "match": {
                          "writer.name": "박연오"
                        }
                      }
                    ]
                  }
                }
              }
            },
            {
              "nested": {
                "path": "writer",
                "query": {
                  "bool": {
                    "should": [
                      {
                        "match": {
                          "writer.email": "bakyeono@gmail.com"
                        }
                      }
                    ]
                  }
                }
              }
            },
            {
              "bool": {
                "should": [
                  {
                    "term": {
                      "title": "엘라스틱서치"
                    }
                  }
                ]
              }
            }
          ]
        }
      }
    }

옵션 필드 중 `size`는 찾을 문서의 개수를 제한하는 것이고, `query` 필드는 매치할 문서의 조건을 지정한다. 그 외에도 여러가지 필드가 있다.

`query` 필드에 들어가는 검색 조건은 QueryDSL을 익혀서 사용해야 한다. 분량이 만만치 않으므로 필요한 쿼리를 짤 때 공식 문서를 참고하자. <https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl.html>


이것으로 엘라스틱서치의 가장 기본적인 사용법 소개를 마친다.

이 외에도 어그리게이션 같은 중요한 주제가 있으므로 실무 적용을 위해서는 더 많은 자료를 찾아보아야 할 것이다.



