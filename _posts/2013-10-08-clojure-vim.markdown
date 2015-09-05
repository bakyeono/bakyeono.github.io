---
layout: post
title: "클로저(Clojure)를 위한 Vim 플러그인"
author: 박연오(bakyeono@gmail.com)
date: 2013-10-08 19:12
tags: 클로저 vim
---
* table of contents
{:toc}

## 클로저 코드를 지원하는 편집기

리스프 코드는 [S-표현식][wiki-sexp]을 사용해 문법이 간단하다. 대신 괄호가 많이 사용되기 때문에 괄호 쌍을 정확하게 맞추는 것이 중요하다. 리스프를 처음 접하는 사람은 수많은 괄호들을 복잡하게 느낄 수 있고 괄호를 닫는 위치를 헷갈리거나 괄호 개수를 세다가 질려버릴 수도 있다. 들여쓰기 포맷을 잘 지키고 구문 강조를 지원하는 텍스트 편집기가 있으면 괄호로 인한 실수를 방지할 수 있다. 그래서 리스프 프로그래머에게 구문 강조를 지원하는 편집기는 선택이 아닌 필수다.

[클로저][Clojure]는 신생 언어여서 클로저 문법을 지원하는 편집기가 많지는 않다. 클로저를 지원하는 편집기로는 [GNU 이맥스(Emacs)][Emacs], [Vim][Vim]과 같은 다목적 텍스트 편집기나 [이클립스(Eclipse)][eclipse]같은 IDE 프로그램이 있다.

- 이맥스는 리스프 해커들이 많이 사용하는 편집기로서 아예 이맥스 리스프라는 내장 스크립트 언어로 각종 기능과 플러그인들이 구현되어 있을 정도다. 그래서 리스프 핏줄인 클로저에 대한 지원도 잘 이뤄지고 있다.

- Vim에서는 리스프 계열 플러그인인 [Slimv][Slimv]와 클로저 전용 플러그인인 [VimClojure][VimClojure]이 클로저를 지원한다. 그리고 새로 나온 [vim-fireplace][vim-fireplace]와 [vim-clojure-static][vim-clojure-static] 조합도 있다.

- 이클립스는 자바 사용자들이 주로 사용하는 IDE인데 클로저와 자바의 가까운 관계 덕분인지 클로저를 위한 플러그인([Counterclockwise][Counterclockwise])이 있다.

이 세 가지 개발 환경은 실제로 가장 많이 사용되고 있다. [Clojure Programming][book-clojure-programming]의 공동저자인 Chas Emerick의 [2012년 클로저 설문조사][2012-clojure-survey]에는 "당신이 사용하는 클로저 개발환경은 무엇입니까?" 라는 항목이 있었다. 이에 대한 답변으로

- 이맥스가 58%

- Vim/VimClojure 조합이 23%

- 이클립스가 18%

를 차지했다.

과연 리스프 언어답게 이맥스 사용자가 제일 많다. 하지만 나는 이맥스에 잘 적응하지 못했고 펑션 키 조합보다는 'vi 키'(hjkl)를 좋아해서 그냥 [Vim][Vim]을 사용하고 있다. 이 êm의 클로저 지원 플러그인들 가운데 현재 가장 쉽고 유용한 vim-fireplace/vim-clojure-static 조합을 이용해 클로저 코드 편집을 하는 방법을 소개한다.

Vim의 기초 사용법과 플러그인 설치법 정도는 알아야 Vim으로 클로저 코드를 작성할 수 있다. 만일 Vim에 익숙하지 않다면 다음 도서를 추천한다. 둘 다 국내서다. 책값이 부담된다면 도서관에서 잠깐 빌려 봐도 되고 각종 인터넷 문서를 참고해도 된다.

> **내가 추천하는 Vim 입문서**
> 
> [손에 잡히는 Vim (김선영 지음)][book-vim-tutorial]
> 
> [유닉스 리눅스 프로그래밍 필수 유틸리티 (백창우 지음)][book-linux-tools]

Vim은 유용한 도구이며 폭풍 간지도 자랑하므로 리눅스 사용자라면 기본으로 익혀두는 것이 좋다. 하지만 당장 클로저 사용이 급하고 Vim을 배울 여유가 없다면 쉽게 익힐 수 있는 이클립스를 이용하는 것도 나쁘지 않을 듯하다. 이클립스는 자바에 특화되어 있어 클로저 코드와 자바 코드를 번갈아가며 작성하기에 유용하다는 장점도 있다.

## [VimClojure][VimClojure]의 유산

클로저 코드의 편집기에는 크게 두 가지 기능이 있어야 한다.

첫번째는 괄호쌍을 맞춰주고 구문에 색을 입혀 코드 작성을 도와주는 문법 강조 기능이다.

두번째는 편집기에서 입력한 내용을 클로저의 REPL로 보내 실행할 수 있게 하는 REPL 연계 기능이다. 리스프 계열 언어에서 REPL은 함수형 코드 단위들을 바로바로 테스트하며 개발할 수 있게 해주기 때문에 개발 환경의 중요한 구성 요소다. 만일 편집기와 REPL이 연동되지 않으면 일일이 코드를 REPL에 따로 옮겨가며 테스트해야 한다.

Vim을 위한 클로저 플러그인으로 먼저 등장한 VimClojure는 두 기능을 모두 지원한다. 하지만 VimClojure는 REPL 연동시 Nailgun으로 REPL 서버를 구동하도록 하는데 이 설정법이 너무 까다로워서 문제였다. 나도 머리를 싸매고 고생하다 안 돼서 결국 REPL 연동을 포기하고 구문 강조 기능만 이용했었다. 다른 사람들도 어려웠는지, 나중에 Nailgun 설정을 도와주는 vimclojure-easy가 나오기도 했다.

다행히 올해초 VimClojure의 대안으로 vim-fireplace가 나와서 편두통에 시달릴 걱정이 줄어들었다. vim-fireplace를 사용하면 별다른 설정 없이도 [Leiningen][Leiningen]을 통해 실행중인 REPL을 알아서 찾아 연동시켜준다. 다만, vim-fireplace는 구문 강조 기능은 제공하지 않기 때문에 VimClojure의 구문 강조 기능을 사용해야 한다. 이를 위해 VimClojure의 구문 강조 기능만을 따로 뽑아놓은 플러그인이 vim-clojure-static이다.

참고로 VimClojure의 개발자는 VimClojure의 개발 진행속도가 거의 멈춰진 상태고 vim-fireplace가 미래라고 인정했다.([해당 글][meikel-said]) 하지만 VimClojure는 REPL 연동만 할 줄 알면 쓸만한 플러그인이고 충분히 개발되어 안정적이기도 하므로 VimClojure를 이미 잘 쓰고 있다면 굳이 vim-fireplace로 갈아탈 필요까지는 없다. VimClojure 개발자가 자기가 만든 프로그램보다 더 나은 프로그램이 나왔다며 추천하는 모습이 존경스럽다.

## 설치와 설정

*참고: 아래 설치과정은 [크런치뱅 리눅스 11][crunchbang-linux]에서 테스트했다. 다른 리눅스 배포판에서도 크게 다르지 않을 것이다.*

### Vim 설치

리눅스에 Vim이 설치되어 있지 않은 경우는 잘 없지만 설치되어 있지 않거나 버전이 낮은 경우에는 알아서 설치하자.

특히, 우분투 계열 배포판인 경우(크런치뱅 포함) Vim-tiny가 설치되어 있으므로 제거하고 Vim을 설치하자.

    $ sudo apt-get update
    $ sudo apt-get remove vim-tiny
    $ sudo apt-get install vim vim-gnome

### 플러그인 설치

리눅스 배포판 저장소에 없는 프로그램들을 설치하기 위해 curl과 git이 필요하다. 없다면 지금 설치하자.

    $ sudo apt-get install curl git

Vim 플러그인 관리 툴은 여러가지가 있지만 그중 [pathogen.vim][pathogen.vim]이 쉽고 간편하며 vim-fireplace의 제작자가 권장하는 것이기도 하다. 플러그인 설치를 위해 pathogen.vim을 설치하자. 아래의 명령어를 통째로 터미널에 복사하면 된다.

    # pathogen 공식 페이지에 나와 있는 설치법임
    mkdir -p ~/.vim/autoload ~/.vim/bundle; \
    curl -Sso ~/.vim/autoload/pathogen.vim \
        https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim

pathogen을 설치했으면 vim-fireplace를 설치하는 것은 간단하다. 터미널에 아래 명령어를 복사하면 된다.

    # vim-fireplace 공식 페이지에 나와 있는 설치법임
    cd ~/.vim/bundle
    git clone git://github.com/tpope/vim-fireplace.git
    git clone git://github.com/tpope/vim-classpath.git
    git clone git://github.com/guns/vim-clojure-static.git

pathogen을 이용하므로 ~/.vim/bundle 경로에 플러그인들을 복사해두기만 하면 설치가 끝난다. vim-fireplace와 함께 vim-clojure-static, vim-classpath도 함께 설치했다. vim-clojure-static은 앞에서 설명한 것처럼 VimClojure의 구문 강조 기능을 제공하는 플러그인이고 vim-classpath는 실행 중인 REPL이 없을 때 클로저 코드를 실행하기 위한 JVM의 경로를 지정하는 플러그인이다.

### .vimrc 설정

Vim의 각종 설정과 플러그인 설정은 모두 ~/.vimrc 파일에 기술한다. 좋아하는 편집기로 .vimrc 파일을 편집하자. 파일이 없다면 만들면 된다.

    $ vim ~/.vimrc

설정 파일에 아래 설정 내용 중 필요한 부분을 복사해 넣고 필요한 경우 적절히 수정하기 바란다. 사실 vim-fireplace 플러그인으로 인해 특별히 추가된 것은 거의 없으므로 이미 vimrc 설정을 갖고 있다면 그대로 사용해도 된다.  Vim 왕초보라면 아래 내용을 그대로 복사해 넣자.

    " 파일 유형 탐지
    filetype plugin on

    " 파일 유형별 들여쓰기
    filetype indent on

    " 리더 키 설정 (각종 플러그인의 단축키 중 <leader>로 표시된 키)
    let mapleader = ","
    let g:mapleader = ","

    " 구문 강조 기능
    syntax enable

    " 탭 말고 스페이스 사용
    set expandtab

    " 탭 당 스페이스 수
    set shiftwidth=4
    set tabstop=4

    " 파일을 열었을 때 탭이 있으면 스페이스로 변환
    autocmd FileType c retab
    autocmd FileType java retab
    autocmd FileType lisp retab
    autocmd FileType clojure retab

    " 행 번호
    set number

    " pathogen 설정
    call pathogen#infect()
    call pathogen#helptags()

    " vim-clojure-static의 구문 강조 기능이 한번에 처리할 최대 행 수
    " 높은 값일수록 긴 함수를 만났을 때 처리시간이 오래 걸린다.
    " 0으로 설정하면 제한없이 끝까지 처리.
    let g:clojure_maxlines=200

## Vim/vim-fireplace 사용하기

설정을 마쳤으면 Vim에서 클로저 코드를 작성하는 법을 알아보자.

임시 Leiningen 프로젝트를 하나 생성해서 연습해보려 한다. vim-fireplace는 Leiningen 2.0.0 이상 버전과 함께 사용해야 한다. 만일 아직 Leiningen을 설치하지 않았다면 [이 글][2013-10-02-clojure-tool-1-leiningen]을 참고해 설치하자.

`lein new` 명령으로 vimtest프로젝트를 생성하자.

    $ lein new vimtest
    $ cd vimtest

### REPL 연동

프로젝트의 디렉토리에서 `lein repl` 명령으로 REPL을 실행하자. 그러면 아래와 같이 nREPL 서버가 실행되었다는 메시지가 나온다.

    $ lein repl
    nREPL server started on port 56834 on host 127.0.0.1
    REPL-y 0.2.1
    Clojure 1.4.0

REPL이 실행되었으면, REPL을 가만히 둔 채로 다른 터미널에서 vim을 실행하거나 X-window에서 바로 실행할 수 있는 vim-gnome을 실행해 Leiningen이 디폴트로 생성한 파일을 열자.

    $ vim src/clojure-with-vim/core.clj

그러면 vim-fireplace가 자동으로 실행 중인 REPL을 찾아 연동된다. 아래의 명령들을 입력해보면 연동이 된 것을 확인할 수 있을 것이다.

### 기본 명령

- **:help fireplace** - vim-fireplace의 기능 설명 / 도움말 보기

vim-fireplace를 사용하는 방법을 설명한 문서를 보여준다. 어떻게 보면 가장 중요한 명령이다. 그래서 가장 먼저 설명한다. 이 문서에서 설명하지 않은 기능들도 많이 있으니 한 번 확인해보는 것이 좋다.

- **:Eval** - 표현식 평가

core.clj 파일의 아래쪽 적당한 곳에 `(println "Hello, clojure with vim!")` 을 입력하자. 그리고 입력한 행에 커서가 위치한 상태에서 :Eval 명령을 입력하자.

    Hello, clojure with vim!
    nil
    Press ENTER or type command to continue

위와 같이 커서가 위치한 행의 내용이 REPL로 전송되어 실행되고, 출력스트림과 반환값이 Vim을 통해 출력된다.

만일 편집기에 입력되어 있지 않은 내용을 평가하고 싶다면 `:Eval (do something)`과 같은 식으로 :Eval의 인수로 표현식을 넘길 수도 있다.

- **:Require** - 파일 리로드

Vim에서 편집 중인 파일에 `(def did-you-read-this? "YES, I did.")`를 입력한 후, `:update` 명령으로 파일을 저장하고, `:Require` 명령을 실행해 보자.

REPL에서 `did-you-read-this?` 심볼을 평가하면 파일에 입력한 값이 잘 등록되어 있는 것을 볼 수 있다.

    user=> vimtest.core/did-you-read-this?
    "YES, I did."

`:Require` 명령은 REPL에서 `(require 패키지명 :reload)` 명령을 입력한 것과 같다. 패키지는 현재 편집 중인 파일이다. 파일을 편집한 후 파일 내용을 통째로 REPL로 읽어들이기 위해 사용한다.

`!`를 붙여서 `:Require!`을 실행하면 `(require 패키지명 :reload-all)` 명령으로 동작한다. 즉, 현재 파일과 함께 현재 파일이 의존하는 패키지들도 함께 리로드한다.

- **:Source** - 지정한 대상의 소스 보기

:Source 명령을 사용하면 지정한 심볼에 등록된 대상(함수/매크로/상수 등)의 소스코드를 보여준다. `(source 대상)` 매크로와 같다. 클로저 기본 함수, 사용자가 등록한 값, 라이브러리에 있는 매크로 등 소스코드를 바로 열람할 수 있어 매우 편리하다.

- **:Doc** - 지정한 대상의 :doc 보기

예를 들어, `:Doc partition`을 입력하면 아래와 같이 partition 함수의 설명이 출력된다.

    clojure.core/partition
    ([n coll] [n step coll] [n step pad coll])
      Returns a lazy sequence of lists of n items each, ...

:Source와 비슷한 명령이다. 지정한 대상의 :doc 메타데이터(즉, 주석)를 출력한다. `(doc 대상)` 매크로와 같다.

- **:FindDoc** - :doc 메타데이터에서 검색

`(find-doc 검색어)` 함수와 같다. 검색어로 문자열이나 정규식 리터럴을 넘기면 주석에 검색어가 포함된 심볼들과 문서 내용을 모두 보여준다.

- **:Apropos** - 심볼 찾기

`(apropos 검색어)` 함수와 같다. 검색어로 문자열이나 정규식 리터럴을 넘기면 해당하는 심볼들을 모두 보여준다.

예를 들어, `:Apropos part`를 입력하면 아래와 같이 "part"로 시작하는 모든 심볼들을 보여준다.

    (prtition-by prtition-all partition)

:Eval과 :Require 두 명령 만으로도 REPL에 편집 내용을 복사하는 번거로움이 확 줄어든다. 그리고 소스코드와 심볼들을 검색할 수 있는 명령어는 클로저 입문자에게든 상급자에게든 매우 유용한 기능이다. 각종 시퀀스 해석 함수가 기억이 안 날 때마다 온라인 레퍼런스 문서만 뒤적이지 말고 클로저와 vim-fireplace가 지원하는 명령들도 활용해 보자.

- **:A** - 구현 코드/테스트 코드 전환

Leiningen은 구현 코드와 단위 테스트 코드를 분리해서 관리하도록 한다. 따라서 src/domain/package.clj 라는 구현 코드 파일이 있으면 이에 대응하는 test/domain/package_test.clj 라는 테스트 코드 파일을 만들어 두고 `(clojure.test/run-tests 대상패키지)` 명령을 통해 테스트를 수행하도록 할 수 있다.

`:A` 명령을 이용하면 구현 코드와 테스트 코드 두 파일을 서로 전환할 수 있다.

### 단축 명령

vim-fireplace는 좀 더 빠른 손놀림을 위해 단축 명령도 지원한다.

- **cqc** - REPL 전송용 버퍼 호출

Vim 일반 모드에서 `cqc`를 입력하자. 그러면 편집기 하단에 임시 버퍼가 생성된다. 이곳에 표현식을 입력하면 REPL로 전송되어 평가되며, 평가 결과가 Vim에 출력된다. REPL에 직접 명령을 입력하고자 할 때 사용하면 좋다.

- **cqq** - REPL 전송용 버퍼 호출 + 현재 행 내용 복사

`cqq` 명령은 REPL 전송용 임시 버퍼를 생성하면서 커서가 있는 행의 표현식을 복사해준다. 따라서 파일에 있는 내용을 바로 REPL로 전송해 평가하고 결과를 볼 수 있다.

- **cpr** - (require 현재문서 :reload)

말이 필요없는, 매우 자주 사용되는 현재 문서 리로드 명령. 사용하기 전에 파일을 저장하는 것을 잊지 말자. `:Reload` 명령과 같은 기능이다.

- **cpR** - (require 현재문서 :reload-all)

의존 패키지들도 수정되어 함께 리로드해야 할 때 사용. `:Reload!` 명령과 같은 기능이다.

- **K** - 커서가 위치한 심볼의 :doc 메타데이터 보기

:Doc 명령, 또는 (doc 대상) 매크로와 같은 기능이다. `Shift` + `k` 키 하나로 해결. (뭐... 가끔 `Caps Lock`이 눌러진 줄 모르고 커서를 이동하려 할 때 걸리적거리는 단점은 있다.)

- **[d** - 커서가 위치한 심볼의 소스 보기

소스 보기도 키 두번 눌러주는 것으로 해결. 참고로 [는 그냥 `[` 키를 누르라는 뜻이다.

- **[Ctrl-d** - 커서가 위치한 심볼이 정의되어 있는 곳으로 이동

해당 심볼이 위치한 파일을 찾아 열고 심볼이 정의된 위치로 이동한다. `[`키와 `Ctrl` + `d` 키를 차례로 누르면 된다.

- **gf** - 커서가 가리키는 파일로 이동

주로 의존 패키지로 이동할 때 사용한다.

- **cmm** - 현재 행을 `macroexpand` 한 결과 보기

- **c1m** - 현재 행을 `macroexpand-1` 한 결과 보기

이상으로 vim-fireplace가 지원하는 명령들을 간단히 살펴보았다. 더 자세한 내용은 `:help fireplace`를 통해 확인해보기 바란다.

## 더 알아보기

이 문서에서 다루지는 않았지만 Vim에서 클로저 코드 편집을 도와주는 플러그인들이 몇가지 더 있다. vim-fireplace와 함께 사용하면 유용한 플러그인들을 간단하게만 소개한다.

- [rainbow_parentheses.vim][rainbow-parentheses]: 무지개 괄호. 즉 괄호들의 색상을 계층적으로 달리하여 표시하도록 해 준다. Slimv와 VimClojure는 무지개 괄호를 기본으로 지원하는데 vim-clojure-static에서는 이 기능을 빼 놓았다. 그래서 알록달록한 무지개 괄호를 보고 싶다면 이 플러그인을 사용하면 된다. (내 생각에 그다지 가독성을 높여주지는 않는 것 같다. 하지만 예뻐서 쓴다.)

아래 스크린샷은 무지개 괄호를 사용하고 있는 나의 클로저 편집 환경이다.

![무지개 괄호를 사용하고 있는 나의 클로저 편집 환경][img-my-vim-clojure-1]

- [paredit.vim][paredit.vim]: 이맥스의 ParEdit Mode를 Vim 용으로 구현한 것이다. 좋아하는 사람도 있고 싫어하는 사람도 있는데, 사람들이 이 모드를 싫어하는 이유는 사용법을 모르면 코드 작성에 몹시 방해가 되고 거슬리기 때문이며 때때로 오류가 발생해 괄호 처리가 제대로 되지 않는 때도 있기 때문이다.

하지만 약간 시간을 투자해서 배워두면 자동 괄호 완성 기능과 문맥별 편집 기능 덕분에 타자량을 상당히 줄일 수 있다. 1~2시간 정도 투자해서 배워볼 마음만 있다면 꼭 배워서 써보라고 권하고 싶다. 한가지 팁을 알려주자면, 편집 중인 코드를 주석처리하면 해당 부분에 한해 paredit의 간섭을 받지 않고 자유롭게 편집할 수 있다. 편집을 마친 후 주석을 해제하면 된다.

- [vim-sexp][vim-sexp]: vim-fireplace의 제작자가 개발하고 있는 또 다른 플러그인으로, vim의 편집 방법을 리스프에 도입한다고 한다. 나는 아직 써보지 않았지만 개발이 완료되면 유용할 것 같아 일단 링크해 둔다.

## 참고 문서

- [vim-fireplace GitHub 페이지][vim-fireplace]
- [pathogen.vim GitHub 페이지][pathogen.vim]


[wiki-sexp]: http://ko.wikipedia.org/wiki/S-%ED%91%9C%ED%98%84%EC%8B%9D
[2012-clojure-survey]: http://cemerick.com/2012/08/06/results-of-the-2012-state-of-clojure-survey
[Emacs]: http://www.gnu.org/software/emacs
[Counterclockwise]: https://code.google.com/p/counterclockwise
[Vim]: http://www.vim.org
[Eclipse]: http://www.eclipse.org
[VimClojure]: http://www.vim.org/scripts/script.php?script_id=2501
[book-vim-tutorial]: http://www.insightbook.co.kr/books/programming-insight/%EC%86%90%EC%97%90-%EC%9E%A1%ED%9E%88%EB%8A%94-vim
[book-linux-tools]: http://www.hanb.co.kr/book/look.html?isbn=978-89-7914-759-9
[meikel-said]: https://groups.google.com/forum/?fromgroups=#!topic/vimclojure/B-UU8qctd5A
[book-clojure-programming]: http://www.clojurebook.com
[crunchbang-linux]: http://crunchbang.org
[vim-fireplace]: https://github.com/tpope/vim-fireplace
[vim-clojure-static]: https://github.com/guns/vim-clojure-static
[pathogen.vim]: https://github.com/tpope/vim-pathogen
[Slimv]: https://bitbucket.org/kovisoft/slimv
[2013-10-02-clojure-tool-1-leiningen]: http://www.bakyeono.net/blog/2013-10-02-clojure-tool-1-leiningen
[rainbow-parentheses]: https://github.com/kien/rainbow_parentheses.vim
[paredit.vim]: http://www.vim.org/scripts/script.php?script_id=3998
[vim-sexp]: https://github.com/guns/vim-sexp
[Leiningen]: https://github.com/technomancy/leiningen
[Clojure]: http://clojure.org

[img-my-vim-clojure-1]: {{ site.url }}/img/my-vim-clojure-1.png

