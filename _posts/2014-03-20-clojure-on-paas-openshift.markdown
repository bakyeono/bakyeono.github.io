---
layout: post
title: "레드햇 오픈시프트에 클로저(Clojure) 올리기"
author: 박연오(bakyeono@gmail.com)
date: 2014-03-20 02:38 +0900
tags: 클로저 네트워크 paas
---
* table of contents
{:toc}

## Platform as a Service (PaaS)

웹 프로그램을 운영하려면 서버가 필요하다. 학생이나 개인 개발자들은 개인 서버를 가동하거나 서버를 임대하는 것이 부담이 될 수 있다. 게다가 한국에서는 단순히 APM 돌려주는 웹 호스팅이 많고, 직접 개발한 서버 프로그램을 가동할 수 있는 서버 호스팅은 프리미엄이 붙는 모양인지 비교적 비싼 데다 저가 옵션인 경우 사양도 떨어진다.

이제 걱정 말자! 클라우드 방식으로 서버를 호스팅해주는 [PaaS][ko-wiki-paas]들을 이용해 웹 프로그램 제작 연습, 부하가 적은 공개 서비스 운영, 프로토타입 시험 운영 등을 비용을 들이지 않고 할 수 있다.

PaaS들은 기본 옵션을 무료로 제공하고, 나중에 사용자의 웹 서비스가 잘 나가서 사용자가 서버 사양을 증대할 경우에 과금을 하는 방식이 많기 때문에 간단한 수준의 웹 프로그램이라면 큰 걱정없이 이용할 수 있을 것이다. 다만, 서비스마다 과금 정책이 다르고, 트래픽에 따라 사양 확대를 자동으로 해주는 옵션이 설정되는 경우도 있으므로 과금 정책은 꼭 직접 확인해 보기 바란다.

현재 많이 쓰이는 PaaS로는 요런 것들이 있다.

- [아마존 웹 서비스 (AWS: Amazon Web Services)][amazon-web-services]
- [구글 앱 엔진 (Google App Engine)][google-app-engine]
- [헤로쿠 (Heroku)][heroku]
- [레드햇 오픈시프트 (Red Hat Openshift)][openshift]
- 그 외에도 많음

> 수정: 아마존 웹 서비스는 PaaS가 아니라 IaaS다.

하지만 아쉽게도 아직 클로저를 공식적으로 지원하는 PaaS는 드물다. 내가 아는 것 중에는 헤로쿠만이 클로저를 공식 지원하고 있다.

내가 가장 추천하는 PaaS는 오픈시프트다. 오픈시프트에는 다음과 같은 장점이 있다.

- 거대 오픈소스 기업인 레드햇이 운영하므로 신뢰도가 있다.
- 무료로 제공하는 옵션이 나쁘지 않다.
- 아마존과 달리 계정 생성에 신용카드번호를 요구하지 않는다.
- 다양한 실행 환경(카트리지, 애드온)을 지원한다.

가장 중요한 문제는 클로저를 지원하는가 하는 점이다. 오픈시프트는 클로저를 공식적으로 지원하지는 않는다. 하지만 DIY(Do It Yourself) 카트리지를 제공하기 때문에 비교적 간단한 설정을 통해 클로저 프로그램을 실행시킬 수 있다. 사실, 직접 환경 설정을 할 수 있으므로 클로저뿐만 아니라 필요에 따라 실행 환경을 구성할 수 있다.

물론 헤로쿠도 위와 비슷한 장점들이 있다. 클로저를 공식 지원하고 사용도 간편한 헤로쿠도 좋은 선택이라고 생각한다. 이 글은 오픈시프트를 다룬다.

## 설치와 설정

오픈시프트를 써 보기로 마음먹었다면 시작해보자.

### 루비 설치

오픈시프트 커맨드라인 툴을 사용하려면 시스템에 루비가 설치되어 있어야 한다. Bigmatch 블로그의 글 ['멘붕없이 rvm과 루비 설치하기'][bigmatch-install-ruby]를 참고해서 rvm과 루비를 설치해 두자.

> 리눅스 배포판의 패키지 관리자를 이용해서 루비를 설치해도 rhc 사용에는 문제가 없다. 하지만 이후 다른 버전의 루비를 사용해야 할 일이 생겼을 때 멘붕을 겪을 수 있다. 루비는 버전 간 호환성이 좋지 않은 편이다.

### 오픈시프트 계정 만들기 / ssh 키 등록

[오픈시프트 사이트][openshift]에서 'Sign Up' 메뉴를 눌러 계정을 만든다.

계정을 만들었으면 시스템의 SSH 키를 등록해두자. SSH 키가 있어야 커맨드라인 툴로 작업하거나, SSH 서버에 직접 접속할 수 있다. SSH 키 등록은 아래 페이지에서 할 수 있다.

[https://openshift.redhat.com/app/console/settings][openshift-settings]

### rhc (오픈시프트 커맨드라인 클라이언트 툴) 설치

(레드햇, 페도라 계열인 경우에만) 먼저 아래 명령을 실행한다.

    $ sudo rhn-channel --add --channel=rhel-x86_64-server-optional-6

rhc를 설치, 업데이트한다.

    $ gem install rhc
    $ gem update rhc

설치가 끝나면, `rhc setup`을 실행해 사용자 계정 등을 설정한다.

    $ rhc setup

## 클로저 웹 프로그램을 오픈시프트에서 구동하기

이제 클로저 웹 프로그램을 만들어 오픈시프트에 올려보자.

### 프로젝트 생성 / 코딩

#### Leiningen 프로젝트 생성 / 설정

먼저, 아래와 같이 Leiningen 프로젝트를 만든다. 나는 사용자 홈 디렉토리에 만들었다.

    $ cd ~
    $ lein new webapp
    $ cd webapp

프로젝트가 생성되었으면 project.clj 파일을 열어 아래와 같이 필요한 라이브러리와 main 패키지를 지정하자.

**project.clj**

    (defproject webapp "0.1.0-SNAPSHOT"
      :description "Clojure Web Application Example"
      :dependencies [[org.clojure/clojure "1.5.1"]
                     [ring "1.2.2"]
                     [net.cgrand/moustache "1.1.0"]]
      :main webapp.core)

참고로 [ring][ring]은 클로저로 웹 프로그래밍을 할 때 사용되는 사실상의 표준이라고 할 수 있는 라이브러리이며, 라우터 라이브러리인 [moustache][moustache]와 함께 사용하면 편리하다. 여기서는 사용하지 않았지만, HTML 템플릿 처리를 도와주는 [enlive][enlive] 라이브러리도 매우 유용하다.

#### 웹 프로그램 코드 짜기

다음으로, src/webapp/core.clj 파일을 열어 아래 내용을 복사해 넣자.

**src/webapp/core.clj**

    (ns webapp.core
      (:require [ring.adapter.jetty :as jetty]
                [ring.util.response :as response]
                [net.cgrand.moustache :as moustache]))
    
    (defn response [status body]
      {:status status
       :headers {"Content-type" "text/html; charset=utf-8"}
       :body body})
    
    (defn html [body]
      (str "<html lang=\"ko\">"
           "<head><meta charset=\"utf-8\"></head>"
           "<body><h1>" body "</h1></body>"
           "</html>"))
    
    (defn file? [path]
      (.exists (clojure.java.io/as-file path)))
    
    (defn raw-file [request]
      (let [path (str "www" (get request :uri))]
        (if (file? path)
          (response/file-response path)
          (response 404 (html "<h1>페이지를 찾을 수 없습니다.</h1>")))))

    (defn welcome [request]
      (response 200 (html "<h1>반갑습니다. 이 문서가 잘 보이나요?</h1>")))
    
    (def routes (moustache/app [""] welcome
                               [&] raw-file))

    (defn run-server []
      (let [port (Integer/parseInt (get (System/getenv) "OPENSHIFT_DIY_PORT" "8080"))
            host (get (System/getenv) "OPENSHIFT_DIY_IP" "127.0.0.1")]
        (jetty/run-jetty #'routes
                         {:port port
                          :host host
                          :join? false})))

    (defn -main [& args]
      (run-server))

라우터와 HTTP 응답을 처리하는 기본적인 코드다. 주제와 벗어나므로 코드 설명은 생략한다.

다만 호스트와 포트에 관해 적어두는 것이 좋겠다. 오픈시프트에서 서버를 돌릴 때는 호스트와 포트를 OPENSHIFT_DIY_IP:OPENSHIFT_DIY_PORT로 설정해두어야 한다. 이 값은 오픈시프트 서버에서 환경 변수로 제공해 준다. 뒤에 포함한 기본값은 로컬에서 테스트용으로 실행할 때를 위해 넣어 두었다.

#### 테스트

이제 `lein run`을 실행하고 웹 브라우저로 http://localhost:8080 에 접속하면 웹서버가 잘 실행되는지 테스트할 수 있다.

### 오픈시프트에 DIY 카트리지로 실행 환경 만들기

여기서부터는 오픈시프트 커맨드라인 툴(rhc)을 사용할 것이다. rhc의 사용법을 확인하려면 `rhc help`를 명령을 실행해보라.

#### 오픈시프트가 지원하는 카트리지들과 DIY 카트리지

오픈시프트에서 클로저 프로그램을 실행하려면 DIY 카트리지를 생성하여 직접 설정을 해주어야 한다.  혹시 이 글을 보는 시점에서 오픈시프트가 클로저 카트리지를 지원할지도 모르니 `rhc cartridges` 명령으로 지원 카트리지를 확인해보자.

    $ rhc cartridges
    jbossas-7           JBoss Application Server 7              web
    jbosseap-6          JBoss Enterprise Application Platform 6 web
    jenkins-1           Jenkins Server                          web
    nodejs-0.10         Node.js 0.10                            web
    nodejs-0.6          Node.js 0.6                             web
    perl-5.10           Perl 5.10                               web
    php-5.3             PHP 5.3                                 web
    zend-5.6            PHP 5.3 with Zend Server 5.6            web
    php-5.4             PHP 5.4                                 web
    zend-6.1            PHP 5.4 with Zend Server 6.1            web
    python-2.6          Python 2.6                              web
    python-2.7          Python 2.7                              web
    python-3.3          Python 3.3                              web
    ruby-1.8            Ruby 1.8                                web
    ruby-1.9            Ruby 1.9                                web
    jbossews-1.0        Tomcat 6 (JBoss EWS 1.0)                web
    jbossews-2.0        Tomcat 7 (JBoss EWS 2.0)                web
    jboss-vertx-2.1 (!) Vert.x 2.1                              web
    diy-0.1             Do-It-Yourself 0.1                      web
    10gen-mms-agent-0.1 10gen Mongo Monitoring Service Agent    addon
    cron-1.4            Cron 1.4                                addon
    jenkins-client-1    Jenkins Client                          addon
    mongodb-2.4         MongoDB 2.4                             addon
    mysql-5.1           MySQL 5.1                               addon
    mysql-5.5           MySQL 5.5                               addon
    metrics-0.1         OpenShift Metrics 0.1                   addon
    phpmyadmin-4        phpMyAdmin 4.0                          addon
    postgresql-8.4      PostgreSQL 8.4                          addon
    postgresql-9.2      PostgreSQL 9.2                          addon
    rockmongo-1.1       RockMongo 1.1                           addon
    switchyard-0        SwitchYard 0.8.0                        addon
    haproxy-1.4         Web Load Balancer                       addon

클로저 카트리지는 없지만 Do-It-Yourself(diy-0.1) 카트리지로 실행 환경을 준비할 수 있다.

#### 실행 환경 생성

`rhc create-app 프로젝트명 카트리지` 명령으로 diy-0.1 카트리지를 적용한 저장소를 생성하자. 서버 뿐 아니라 로컬에도 저장소가 생성되므로 적절한 작업 경로로 이동해두자. 나는 ~/temp 디렉토리를 만들어 작업하였다.

    $ mkdir ~/temp
    $ cd ~/temp
    $ rhc create-app webapp diy-0.1

작업이 완료되면 아래와 같이 출력된다.

    Application Options
    -------------------
    Domain:     bakyeono
    Cartridges: diy-0.1
    Gear Size:  default
    Scaling:    no
    
    Creating application 'webapp' ...
    
    Waiting for your DNS name to be available ... done
    
    Cloning into 'webapp'...
    
    Your application 'webapp' is now available.
    
      URL:        http://webapp-bakyeono.rhcloud.com/
      SSH to:     webapp-bakyeono.rhcloud.com
      Git remote: ssh://webapp-bakyeono.rhcloud.com/~/git/webapp.git/
      Cloned to:  /home/bakyeono/webapp
    
    Run 'rhc show-app webapp' for more details about your app.

URL, Git 저장소, SSH 서버가 종합 선물세트처럼 한꺼번에 생성되었고, 로컬 저장소도 클론되었음을 알 수 있다.

#### 실행 환경 살펴보기

생성된 실행 환경의 파일 구조를 확인해보자.

    $ cd webapp
    $ tree -a
    .
    ├── diy
    │   ├── index.html
    │   └── testrubyserver.rb
    ├── .git
    ├── misc
    ├── .openshift
    │   ├── action_hooks
    │   │   ├── README.md
    │   │   ├── start
    │   │   └── stop
    │   └── cron
    └── README.md

직관적인 이해를 위해 `tree -a`의 출력 결과의 일부를 임의로 정리했다. 실제로는 위 파일 말고도 몇가지 파일들이 더 있으나 중요한 것들은 아니다. 위의 결과에서 눈여겨 봐야 할 디렉토리/파일은 다음과 같다.

- `diy`: 기본 생성되는 서버 프로그램. 삭제해도 된다.
- `.openshift/action_hooks/start`: 서버 시작 명령을 내리면 실행되는 쉘 스크립트
- `.openshift/action_hooks/stop`: 서버 종료 명령 내리면 실행되는 쉘 스크립트

#### 실행 환경을 클로저에 맞게 수정

먼저, 서버에서 Leiningen 을 실행할 수 있도록 lein을 넣어주자.

    $ mkdir ~/temp/webapp/bin
    $ curl https://raw.github.com/technomancy/leiningen/stable/bin/lein > ~/temp/webapp/bin/lein
    $ chmod ug+x ~/temp/webapp/bin/lein

다음으로 서버의 시작, 종료를 위한 스크립트를 다음과 같이 수정하자.

**.openshift/action_hooks/start**

    #!/bin/bash
    # The logic to start up your application should be put in this
    # script. The application will work only if it binds to
    # $OPENSHIFT_DIY_IP:8080
    export HTTP_CLIENT="wget --no-check-certificate -O"
    export HOME=$OPENSHIFT_DATA_DIR/home
    export LEIN_JVM_OPTS=-Duser.home=$HOME
    
    cd $OPENSHIFT_REPO_DIR
    $OPENSHIFT_REPO_DIR/bin/lein deps
    $OPENSHIFT_REPO_DIR/bin/lein run >${OPENSHIFT_DIY_LOG_DIR}/lein.log 2>&1 &
    disown

**.openshift/action_hooks/stop**

    #!/bin/bash
    source $OPENSHIFT_CARTRIDGE_SDK_BASH
    
    kill `ps -ef | grep 'clojure' | grep -v 'grep clojure' | awk '{ print  }'` >${OPENSHIFT_DIY_LOG_DIR}/stop.log 2>&1
    exit 0

#### 준비 완료

이제 쓸모없는 파일을 삭제하고, 오픈시프트 설정 파일들과 앞서 만들어 둔 클로저 프로젝트를 합치자.

    $ rm -r ~/temp/webapp/diy ~/temp/webapp/README.md
    $ cp -r ~/temp/webapp ~
    $ cd ~/webapp
    $ rm -rf ~/temp/webapp
    $ git add .
    $ git commit -m "오픈시프트 설정과 클로저 프로젝트를 병합한다."

`git push`으로 푸시해주면 변경 사항을 반영하기 위해 서버가 자동으로 재시작된다. 서버 재시작에 시간이 다소 걸리므로 잠시 기다렸다가 접속해서 페이지가 잘 출력되는지 확인해보자.

### rhc 필수 명령어

오픈시프트를 사용하려면 이정도는 외워두는게 편하다.

- 도움말 보기: `rhc help`
- 서버 시작: `rhc app start 이름`
- 서버 중단: `rhc app stop 이름`
- 서버 재시작: `rhc app restart 이름`
- 서버 상태 보기: `rhc app show 이름`

## 참고한 문서

- [Getting Started with OpenShift][openshift-get-started]
- [A First Clojure App On Openshift][a-first-clojure-app-on-openshift]


[amazon-web-services]: http://aws.amazon.com
[google-app-engine]: https://developers.google.com/appengine
[heroku]: https://www.heroku.com
[openshift]: https://www.openshift.com
[openshift-get-started]: https://www.openshift.com/get-started
[openshift-settings]: https://openshift.redhat.com/app/console/settings
[ko-wiki-paas]: http://ko.wikipedia.org/wiki/PaaS
[a-first-clojure-app-on-openshift]: http://simonholgate.wordpress.com/2013/01/31/a-first-clojure-app-on-openshift
[bigmatch-install-ruby]: http://bigmatch.i-um.net/2013/12/%EB%A9%98%EB%B6%95%EC%97%86%EC%9D%B4-rvm%EA%B3%BC-%EB%A3%A8%EB%B9%84-%EC%84%A4%EC%B9%98%ED%95%98%EA%B8%B0
[ring]: https://github.com/ring-clojure/ring
[moustache]: https://github.com/cgrand/moustache
[enlive]: https://github.com/cgrand/enlive

