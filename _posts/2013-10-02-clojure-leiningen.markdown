---
layout: post
title: "클로저(Clojure) 프로젝트 관리 도구 Leiningen"
author: 박연오(bakyeono@gmail.com)
date: 2013-10-02 18:44 +0900
tags: 클로저 leiningen
---
* table of contents
{:toc}

## Leiningen이란?

클로저를 REPL 환경에서 실습하거나 간단한 클로저 소스 코드를 컴파일 하기 위해서는 자바 가상 머신과 클로저만 있으면 된다. 하지만 기초 문법 공부를 넘어서 본격적인 클로저 프로그램 개발을 하려면 프로젝트 관리 도구인 Leiningen을 사용하는 것이 좋다.

**Leiningen을 사용하면 ...**

1. 메이븐 저장소의 클로저·자바 라이브러리를 쉽게 이용할 수 있다.

2. 프로젝트 생성·관리, 실행환경 설정 등에 들어가는 노력을 줄일 수 있다.

3. 현재 대다수의 클로저 라이브러리와 클로저를 지원하는 웹 서비스 등이 Leiningen을 지원하므로 유리하다.

4. 공부하는 입장에서 클로저에 형성된 생태계를 이해하는데 도움이 된다.

5. REPL 환경에서 개발할 때 편집기와 연동해 개발 환경을 구성할 수 있다.

많은 라이브러리를 비롯해 대부분의 클로저 프로젝트들이 Leiningen을 이용하고 있으므로 특별한 경우가 아니라면 Leiningen 이용은 선택이 아닌 필수라고 봐도 될 듯하다. 다만 클로저를 처음 배우는 사람에게는 개발 환경을 설정하는 것도 은근히 부담이 될 수 있으니 REPL 환경에서 먼저 이것저것 해본며 기본적인 문법 등을 익힌 이후에 라이브러리나 프로젝트 관리가 필요할 때 Leiningen을 이용해도 괜찮다. 프로젝트 관리가 기초 학습에서부터 필요한 것은 아니다.

[Leiningen GitHub 페이지][Leiningen]에서 간단한 설치 및 사용법과 자세한 내용을 다룬 문서도 볼 수 있다. 이 글에서는 주로 사용되는 기능만 다뤘으므로 자세한 사용법을 알고 싶다면 방문해서 문서를 읽어보라. 공식 문서의 설명은 간결한 편이다. 난 자바를 많이 다뤄보지 않아서 처음 공식 문서를 읽었을 때 감이 잘 잡히지 않았다. 하지만 자바와 메이븐에 익숙한 사람은 쉽게 이해할 수 있을 것이다. 그렇지 않은 사람은 그냥 이 글을 계속 읽으면서 따라해 보자.

## Leiningen 설치

*참고사항: 이 글은 Leiningen 2.3.2 버전을 기준으로 작성되었다.*

### 사전 준비

Leiningen을 사용하려면 인터넷 연결이 가능해야 하고, JRE 1.6 이상을 지원하는 자바 가상 머신이 설치되어 있어야 한다. 자바 가상 머신이 없다면 [Java][java], [OpenJDK][OpenJDK] 중 하나를 설치해 두자.

혹시라도 자바 가상 머신이라는 것이 무슨 말인지 모른다면 클로저를 배우기 앞서 자바를 약간 공부하는게 좋을 수도 있다. 자바 전문가일 필요는 없지만 자바를 전혀 모르면 클로저 활용에 어려움이 있다.

### Leiningen 쉘 스크립트 다운로드

아래 주소에 연결된 파일은 Leiningen 설치와 실행에 필요한 쉘 스크립트 파일이다.

다운로드 주소: [https://raw.github.com/technomancy/leiningen/stable/bin/lein][leiningen-sh]

웹 브라우저로 다운로드한 후 쉽게 실행할 수 있도록 ~/bin 디렉토리로 옮겨 놓자. 아래는 `curl`로 다운로드하는 명령이다.

<pre class="lang-sh">$ curl https://raw.github.com/technomancy/leiningen/stable/bin/lein > ~/bin/lein</pre>

### 실행 권한 설정

앞으로 계속 실행하게 될 파일이므로 실행 권한을 설정해 두자.

    $ chmod +x ~/bin/lein

### 자동 설치

터미널에 `lein`을 입력해 스크립트를 실행하면 Leiningen이 자동으로 설치된다.

    $ lein
    Downloading Leiningen to ~/you/.lein/self-installs/leiningen-2.3.2-standalone.jar now...
    ...
    ...

설치가 끝났으면 Leiningen을 한 번 실행해 보자. Leiningen을 실행할 때도 설치할 때와 마찬가지로 `lein`을 입력해 똑같은 스크립트를 실행하면 된다. Leiningen이 정상적으로 설치됐다면 아래와 같이 사용법이 출력될 것이다. Leiningen 실행에 시간이 다소 걸린다.

    $ lein
    
    Leiningen is a tool for working with Clojure projects.
    
    Several tasks are available:
    check               Check syntax and warn on reflection.
    classpath           Write the classpath of the current project to output-file.
    clean               Remove all files from project's target-path.
    compile             Compile Clojure source into .class files.
    deploy              Build jar and deploy to remote repository.
    deps                Show details about dependencies.
    do                  Higher-order task to perform other tasks in succession.
    help                Display a list of tasks or help for a given task or subtask.
    install             Install current project to the local repository.
    jar                 Package up all the project's files into a jar file.
    javac               Compile Java source files.
    new                 Generate scaffolding for a new project based on a template.
    plugin              DEPRECATED. Please use the :user profile instead.
    pom                 Write a pom.xml file to disk for Maven interoperability.
    repl                Start a repl session either with the current project or standalone.
    retest              Run only the test namespaces which failed last time around.
    run                 Run the project's -main function.
    search              Search remote maven repositories for matching jars.
    show-profiles       List all available profiles or display one if given an argument.
    test                Run the project's tests.
    trampoline          Run a task without nesting the project's JVM inside Leiningen's.
    uberjar             Package up the project files and all dependencies into a jar file.
    upgrade             Upgrade Leiningen to specified version or latest stable.
    version             Print version for Leiningen and the current JVM.
    with-profile        Apply the given task with the profile(s) specified.
    
    Run `lein help $TASK` for details.
    
    See also: readme, faq, tutorial, news, sample, profiles, deploying, mixed-source, templates, and copying.

## 새 프로젝트 생성

새로운 프로젝트를 만들려면 아래처럼 `lein new 프로젝트명` 명령을 사용한다.

    $ lein new my-project
    Generating a project called my-project based on the 'default' template.
    To see other templates (app, lein plugin, etc), try `lein help new`.

프로젝트명으로 지정한 디렉토리가 생성되며 그 내부에 기본적인 Leiningen 프로젝트 디렉토리와 파일이 생성된다. 자동 생성되는 구조는 다음과 같다.

    .
    ├── doc   .................... 사용설명서, API 문서 등
    ├── src   .................... 소스코드
    │   └── my_project
    │       └── core.clj
    ├── test   ................... 함수별 테스트
    │    └── my_project
    │        └── core_test.clj
    ├── resources
    ├── LICENSE   ................ 라이선스 안내 텍스트 파일
    ├── README.md   .............. GitHub용 마크다운 문서 파일
    └── project.clj   ............ 프로젝트 설정 파일

이 외에도 프로젝트 빌드시 target 등의 디렉토리가 추가로 생성된다. 디렉토리 구조는 마음대로 변경하면 안된다.

프로젝트 생성 후 가장 꼼꼼이 살펴보아야 할 파일은 **project.clj**다. 확장자에서 알 수 있듯이 프로젝트 설정 파일은 클로저 문법을 사용한다.

## 프로젝트 설정 / 사용할 라이브러리 추가

새 프로젝트 생성 후 project.clj 파일을 텍스트 편집기로 열자. project.clj 파일 내부에는 다음과 같이 `defproject` 매크로를 호출하여 프로젝트를 정의하고 있다.

    (defproject my-project "0.0.0"
      :description "프로젝트 설명"
      :license "Eclipse Public License 1.0"
      :url "http://..."
      :dependencies [[org.clojure/clojure "1.5.1"]]
      :plugins [[lein-ring "0.4.5"]])

`defproject` 매크로의 구성 요소들이 직관적이기 때문에 별다른 설명이 필요하지 않을 것이다. 라이브러리 로드 설정을 위한 `:dependencies`에 주목하자.

Leiningen은 project.clj에 정의된 라이브러리 의존성을 확인해 메이븐 저장소에서 라이브러리를 가져온다. Leiningen이 자동으로 클로저와 라이브러리들을 다운로드하므로 별도로 시스템에 클로저를 설치할 필요는 없다.

프로젝트에 사용할 라이브러리를 지정하려면 `:dependencies`에 해당하는 벡터를 수정하면 된다. 아래 코드에서 **클로저 1.5.1**과 **nippy 2.1.0** 라이브러리를 로드하도록 설정한 것을 확인해 보라. 자바 가상 머신의 입장에서는 클로저도 하나의 `clojure.jar` 파일로 라이브러리 패키지일 뿐이라는 점에 주목하자.

    (defproject my-project "0.0.0"
      :description "프로젝트 설명"
      :license "Eclipse Public License 1.0"
      :url "http://..."
      :dependencies [[org.clojure/clojure "1.5.1"]
                     [com.taoensso/nippy "2.1.0"]]
      :plugins [[lein-ring "0.4.5"]])

이렇게 지정해두면 다음 번에 REPL 환경을 시작하거나 컴파일을 할 때 Leiningen이 라이브러리 의존성을 확인해 필요한 파일을 자동으로 다운로드 해준다.

> **필요한 라이브러리를 찾으려면**  
>   
> 원하는 라이브러리의 이름과 버전을 정확히 모른다면 [메이븐 저장소][maven-repository]에서 찾으면 된다. 자바 프로그래머들에게는 너무 당연해서일까? 메이븐에 관해 잘 모르는 사람들도 있을 텐데 이에 관해 설명하는 문서를 본 적이 없어서 약간 의아하다.  
> 메이븐 저장소에는 매우 다양한 라이브러리들이 있다. 클로저 라이브러리뿐 아니라 메이븐 저장소에 있는 자바 라이브러리를 지정해서 사용할 수도 있으니 필요한 자바 라이브러리가 있으면 한 번 해보라.

#### 자주 사용되는 프로젝트 설정 옵션

`defproject` 옵션 중 비교적 자주 사용하는 것이다.

옵션               | 설명
------------------ | -----------------------------------------
:dependencies      | 의존 라이브러리들
:plugins           | Leiningen 플러그인들
:repositories      | 라이브러리 저장소 지정
:main              | 프로그램 시작 함수(-main)가 담긴 패키지
:javac-options     | 컴파일 옵션
:global-vars       | 클로저 전역 바인딩을 오버라이드하도록 설정
:java-cmd          | 클로저를 실행할 자바 가상 머신의 경로
:jvm-opts          | 자바 가상 머신의 실행 옵션
:source-paths      | 클로저 소스 파일이 있는 경로들
:java-source-paths | 자바 소스 파일이 있는 경로들
:native-path       | 네이티브 바이너리 코드의 경로
:omit-source       | jar 패키지 생성시 소스코드 포함 여부

[Leiningen 샘플 프로젝트][leiningen-sample-project]에서 더 많은 옵션들과 자세한 사용 방법을 살펴볼 수 있다. 프로젝트 진행중 필요에 따라 참고하면 되므로 처음부터 다 마스터 하려고 하지는 말자.

## REPL 실행

`lein repl` 명령으로 REPL 환경을 시작할 수 있다. 시간이 약간 걸리므로 커맨드 입력후 잠시 기다리자.

    $ lein repl
    nREPL server started on port 46210 on host 127.0.0.1
    REPL-y 0.2.1
    Clojure 1.5.1
        Docs: (doc function-name-here)
              (find-doc "part-of-name-here")
      Source: (source function-name-here)
     Javadoc: (javadoc java-object-or-class-here)
        Exit: Control+D or (exit) or (quit)

    user=>

`lein repl`을 통해 실행되는 REPL은 일반적인 클로저 REPL의 기능에 REPL 서버 기능을 더해 vim-fireplace 등 편집기와 연동할 수 있도록 해준다. 이에 관해서는 클로저 개발 환경 설정 2편에서 다룰 것이다.

## 프로젝트 컴파일

Leiningen의 컴파일 명령을 사용하면 프로젝트에 포함된 클로저 소스코드(.clj)와 자바 소스코드(.java)를 JVM 바이트코드로 컴파일한다. 그 명령은 다음과 같다.

    $ lein compile

이 때 주의할 사항이 하나 있다. 클로저 소스코드를 **실행시점 이전에 컴파일**하도록 하려면 해당 소스코드의 네임스페이스 선언 구문인 `(ns)` 구문을 호출할 때 `(:gen-class)` 구문을 전달해야 한다.

코드로 나타내면 다음과 같다.

    (ns clojure.examples.hello
        (:gen-class))

그리고 빌드된 클로저 패키지를 바로 실행할 수 있도록 하려면 자바 코드 실행시 main 함수가 정의되어 있어야 하듯이 클로저에서도 시작 함수를 정의해 두어야 한다. 이는 `(:gen-class)` 옵션이 설정된 네임스페이스에서 `-main` 함수를 정의해두면 된다. 자바의 main에 해당하는 함수이므로 명령행 인수를 전달받을 인수가 필요하다.

    (ns clojure.examples.hello
        (:gen-class))
    
    (defn -main
      [greetee]
      (println (str "Hello " greetee "!")))

위 예제는 [클로저 공식 사이트 문서][Clojure-compilation]에서 가져온 것이다. 사전 컴파일(Ahead-of-time Compilation)에 관해 자세히 나와있으니 참고하자.

## 프로젝트 빌드

프로젝트를 하나의 jar 파일로 만들고 싶다면 다음 명령을 사용한다.

    $ lein uberjar

그러면 자동으로 소스코드를 컴파일하고 사용된 라이브러리들을 묶어 target 디렉토리에 프로젝트명-버전.jar 파일과 프로젝트명-버전-standalone.jar 파일을 생성해준다.

jar 파일은 자바 실행환경이 설치된 시스템에서 바로 실행할 수 있으므로 바로 배포해도 된다. 그러나 자바에 익숙하지 않은 라이트 유저에게는 네이티브 실행 파일이 더 익숙할 수 있다. 실행 파일을 만들어야 한다면 플랫폼별로 jar를 실행 파일로 래핑해주는 [launch4j][launch4j] 프로그램을 이용할 수 있다.

## 컴파일 결과물 삭제

Leiningen은 업데이트 된 소스코드가 있으면 알아서 새로 컴파일을 한다. 하지만 명시적으로 컴파일 된 파일들을 정리하려면 다음 명령을 사용한다.

    $ lein clean

사용하는 라이브러리를 버전을 변경하거나 버그 또는 실수로 인해 유효하지 않은 코드가 사용되고 있다고 의심되는 경우 사용하도록 하자. 나는 이전에 컴파일 해놓은 레코드의 정의를 변경했을 때 Leiningen이 이를 새로 컴파일하지 않아 종종 사용해야 했다. 현재 버전에서도 그런지는 확인해보지 못했다.

## 프로젝트 실행

REPL을 사용하지 않고 프로그램 시작지점 함수를 호출해 실행하려면 다음 명령을 사용한다.

    $ lein run

그러면 Leiningen이 필요한 파일들을 컴파일하고 메모리에 올린 후 프로그램을 실행한다. 하지만 내 경우엔 주로 REPL 환경에서 테스트하고 프로그램을 배포할 때도 빌드한 JAR 패키지를 배포거나 웹하게 되므로 이 명령을 쓸 일은 생각보다 많지 않았다.

## 테스트

함수별 테스트를 수행하기 위해서는 미리 테스트를 만들어 두어야 한다. test 디렉토리 안에 각각의 소스코드에 대응하는 소스코드_test.clj 파일을 만들어 두면 된다.

예를 들어,  
src/my-project/foo.clj 라는 소스코드가 있으면,  
**test**/my-project/foo**_test**.clj 라는 파일을 만들어 둔다.

테스트를 준비하고 터미널에 `lein test` 명령을 입력하면 자동으로 테스트를 수행하고 결과를 출력해 준다.

## 참고한 문서

- [Leiningen GitHub 페이지][Leiningen]
- [클로저 공식 사이트][Clojure]


[Leiningen]: https://github.com/technomancy/leiningen
[Leiningen-sh]: https://raw.github.com/technomancy/leiningen/stable/bin/lein
[java]: http://www.java.com/ko
[OpenJDK]: http://openjdk.java.net
[Clojure]: http://clojure.org
[Clojure-compilation]: http://clojure.org/compilation
[maven-repository]: http://mvnrepository.com
[leiningen-sample-project]: https://github.com/technomancy/leiningen/blob/stable/sample.project.clj
[launch4j]: http://launch4j.sourceforge.net

