---
layout: post
title: 텔레그램 로봇, 공식 API로 만들기 (파이썬, 구글 앱 엔진)
author: 박연오(bakyeono@gmail.com)
date: 2015-08-24 12:21 +0900
tags: 텔레그램 봇 파이썬 구글-앱-엔진
---
* table of contents
{:toc}

## telegram-cli와 공식 봇 API의 비교

2015년 6월 24일 텔레그램이 봇 API를 공식 발표했다. 메신저마다 비공식 봇을 만드는 사람들이 있고, 타사 메신저 서비스는 비공식 봇들을 단속하는 경향이 있다. 텔레그램은 이와 반대로 공식적으로 봇을 지원하고 나선 것이 돋보인다. 텔레그램은 봇 API를 발표하기 전에도 텔레그램 API를 지원했기 때문에 봇을 만들기 쉬웠고 특히 telegram-cli로 만들어진 봇이 많았다. 그렇다면 앞으로 어떤 방식으로 봇을 만드는 게 좋을까? 기존 telegram-cli로 만든 봇을 공식 API로 포팅해야 할까?

생각나는 대로 몇 가지 특징을 비교해 봤다.

분류      | telegram-cli 봇   | 텔레그램 봇
--------- | ----------------- | ---------------------
지원      | 오픈소스 커뮤니티 | 텔레그램
합법성    | 비공식            | 공식
통신 API  | 텔레그램 API      | 봇 API
별도 서버 | 필요              | 필요
계정      | 실제 사용자 계정  | 봇 계정
UI        | 메시지            | 메시지, 커스텀 키보드
주 용도   | 개인용 스크립트   | 봇 서비스

개인용으로 봇 스크립트는 telegram-cli로 사용하던 게 있다면 그냥 계속 쓰면 될 것 같고, 사용자들을 대상으로 서비스하는 봇은 공식 API로 새로 제작하는 게 UI, 신뢰도, 법률적인 면에서 유리할 것 같다.

## 참고 문서

이 글을 쓰면서 참고한 문서/프로젝트다. 따라하다가 잘 모르겠으면 아래 문서를 찾아보자.

* [봇 설명 문서](https://core.telegram.org/bots)
* [봇 API 문서](https://core.telegram.org/bots/api)
* [구글 앱 엔진 문서](https://cloud.google.com/appengine/docs/developers-console)
* [yukuku의 텔레그램 봇 스타터킷](https://github.com/yukuku/telebot): 아래에 나오는 봇 서버 프로그램은 이 스타터킷을 수정해 만들었다.

## 봇 제작 과정

1. @BotFather를 통한 봇 등록 / 토큰 발급 / 설정
2. 서버 준비
3. 봇 기능 프로그램
4. 테스트 / 디버그

## 1. @BotFather를 통한 봇 등록 / 토큰 발급

텔레그램 봇은 @BotFather 봇을 통해 관리된다.

텔레그램 클라이언트에서 @botfather 사용자를 채팅 목록에 추가한다. 텔레그램 클라이언트에서 @BotFather를 검색하거나 웹 브라우저에서 [https://telegram.me/botfather](https://telegram.me/botfather) 주소로 접속해도 @BotFather 사용자를 추가할 수 있다.

@BotFather 사용자를 채팅 목록에 추가하면 아래와 같은 화면이 나온다.

![BotFather 채팅 화면](http://bakyeono.net/img/telegram-bot-botfather.png)

**START**를 누른 후 @BotFather에게 `/help` 메시지를 보내면 사용가능한 명령어를 알려준다. 명령어에 대한 자세한 설명은 텔레그램 봇 API 문서에 있다.

### /newbot

@BotFather에게 `/newbot` 메시지를 보내면 봇을 등록할 수 있다.

봇을 만드는 과정은 아래와 같다.

1. `/newbot` 메시지를 보낸다.

2. 봇의 이름을 입력한다. 한글도 쓸 수 있다. 예) `시험용 로봇`

3. 봇의 아이디를 입력한다. 한글은 쓸 수 없으며, 반드시 bot, Bot 등으로 끝나야 한다. 예) `my_testing_bot`

4. @BotFather가 봇이 생성되었다고 알려주며 봇 주소와 토큰을 알려준다. 토큰은 봇 API를 사용하기 위해 꼭 필요하므로 잘 챙겨두고, 유출되지 않도록 한다.

![BotFather newbot 명령 1](http://bakyeono.net/img/telegram-bot-botfather-newbot1.png)

![BotFather newbot 명령 2](http://bakyeono.net/img/telegram-bot-botfather-newbot2.png)

## 2. 봇을 위한 서버 준비

사실 봇을 위한 별도의 서버 없이 그냥 봇을 등록해두기만 하는 것도 가능하다. 하지만 그냥 놔두면 의미 없는 대포 계정에 불과하다. 봇이 제대로 봇 구실을 할 수 있도록 봇의 동작을 정의하거나 데이터를 기록하려면 서버가 필요하다.

이 글에서는 구글 앱 엔진을 사용해 봇 서버를 개발하고 호스팅 받는다. 아래 주소에서 구글 계정에 로그인하면 앱 엔진을 사용할 수 있다.

* [구글 앱 엔진](https://appengine.google.com)

간단한 봇 서버를 운영하는 데는 거의 비용이 들 일이 없지만 혹시라도 요금이 청구될 수 있으니 이용 약관과 결제 설정을 잘 확인하기 바란다.

### 프로젝트 생성

구글 앱 엔진 [관리자 콘솔 페이지](https://console.developers.google.com)에서 '프로젝트 생성...' 버튼을 찾아 프로젝트를 만든다.

![구글 앱 엔진 프로젝트 생성 1](http://bakyeono.net/img/telegram-bot-google-app-engine-new-project1.png)

![구글 앱 엔진 프로젝트 생성 2](http://bakyeono.net/img/telegram-bot-google-app-engine-new-project2.png)

![구글 앱 엔진 프로젝트 생성 3](http://bakyeono.net/img/telegram-bot-google-app-engine-new-project3.png)

이 때 프로젝트 ID를 잘 정해야 한다. 나중에 app.yaml에 기록해야 하며, 앱 접속 주소에도 반영되기 때문이다.

### 구글 앱 엔진 SDK 설치

윈도우 / 맥 환경 용으로는 구글 앱 엔진 GUI 툴이 제공되는 듯하다. 리눅스 용은 커맨드라인 툴이 제공된다. 이 글은 리눅스 환경을 대상으로 한 글이다. 리눅스 환경에서는 아래와 같이 설치한다.

먼저, 파이썬 2.7이 설치돼있나 확인해 본다. 아마 이미 설치돼 있을 것이다.

    $ python -V

만일 파이썬 버전이 2.7.x가 아니거나, 파이썬이 설치돼있지 않으면 아래 페이지를 참고해 파이썬을 2.7을 설치한다.

* [파이썬 다운로드 페이지](https://www.python.org/downloads)

구글 앱 엔진을 다운로드하고 압축을 풀어 둔다.

    $ cd ~
    $ curl https://storage.googleapis.com/appengine-sdks/featured/google_appengine_1.9.25.zip > google_appengine_1.9.25.zip
    $ unzip google_appengine_1.9.25.zip

> 주의: 이 글을 보는 사람에게는 1.9.25.zip이 최신 버전이 아닐 가능성이 높으므로 다운로드 페이지에서 버전을 확인하기 바란다.

잘 실행되는지 확인해본다.

    $ ~/google_appengine/appcfg.py help help
    Usage: appcfg.py help <action>
    
    Print help for a specific action.
    
    
    Options:
      -h, --help            Show the help message and exit.
      -q, --quiet           Print errors only.
      -v, --verbose         Print info level logs.
      --noisy               Print all logs.
      -s SERVER, --server=SERVER
                            The App Engine server.
      -e EMAIL, --email=EMAIL
                            The username to use. Will prompt if omitted.
      -H HOST, --host=HOST  Overrides the Host header sent with all RPCs.
      --no_cookies          Do not save authentication cookies to local disk.
      --skip_sdk_update_check
                            Do not check for SDK updates.
      -A APP_ID, --application=APP_ID
                            Set the application, overriding the application value
                            from app.yaml file.
      -M MODULE, --module=MODULE
                            Set the module, overriding the module value from
                            app.yaml.
      -V VERSION, --version=VERSION
                            Set the (major) version, overriding the version value
                            from app.yaml file.
      -r RUNTIME, --runtime=RUNTIME
                            Override runtime from app.yaml file.
      -E NAME:VALUE, --env_variable=NAME:VALUE
                            Set an environment variable, potentially overriding an
                            env_variable value from app.yaml file (flag may be
                            repeated to set multiple variables).
      -R, --allow_any_runtime
                            Do not validate the runtime in app.yaml
      --oauth2              Ignored (OAuth2 is the default).
      --oauth2_refresh_token=OAUTH2_REFRESH_TOKEN
                            An existing OAuth2 refresh token to use. Will not
                            attempt interactive OAuth approval.
      --oauth2_access_token=OAUTH2_ACCESS_TOKEN
                            An existing OAuth2 access token to use. Will not
                            attempt interactive OAuth approval.
      --authenticate_service_account
                            Authenticate using the default service account for the
                            Google Compute Engine VM in which appcfg is being
                            called
      --noauth_local_webserver
                            Do not run a local web server to handle redirects
                            during OAuth authorization.

여러 가지 도구가 있지만 앱을 업로드할 때 쓰이는 `appcfg` 정도만 알아도 된다.

## 3. 서버 프로그램 만들기

그러면 구글 앱 엔진으로 봇 서버 프로그램을 만들어보자.

딱 두 개의 파일만 만들면 된다. `app.yaml`과 `main.py`다.

### app.yaml - 앱과 요청에 대한 정의

디렉토리를 하나 만들고

    $ mkdir ~/my-testing-bot
    $ cd ~/my-testing-bot

이곳에 `app.yaml` 이라는 이름으로 파일을 만들어 아래 내용을 넣는다.

    application: my-testing-bot
    version: 1
    runtime: python27
    api_version: 1
    threadsafe: yes
    
    handlers:
    - url: /set-webhook
      login: admin
      script: main.app
    - url: .*
      script: main.app
    
    libraries:
    - name: webapp2
      version: 2.5.2

`app.yaml`은 구글 앱 엔진 프로젝트를 정의하는 파일이다.

* application 항목에는 **아까 등록한 구글 앱 엔진 프로젝트의 ID**를 입력한다. `my-testing-bot`을 입력하는 게 아니다.
* handlers 항목은 URL 매개변수에 따른 처리기를 지정하는 항목이다. `/set-webhook`은 구글 계정 로그인을 통해 권한을 검사한 후 main.app을 통해 처리하도록 하였고 기타 url은 로그인 없이 main.app을 통해 처리하도록 했다. 웹훅에 관해서는 나중에 설명하겠다.
* libraries 항목에는 구글 앱 엔진이 로드할 라이브러리와 버전을 지정한다. webapp2는 앱 엔진을 쓰기 위해 추가해야 하는 기본 라이브러리다.

### main.py - 요청을 수행할 파이썬 코드

그 다음으로 핸들러를 정의할 `main.py` 파일을 만들고 아래 내용을 넣는다. 그대로 복사해 넣으면 된다.

> 일러두기: 이 소스코드는 [yukuku의 텔레그램 봇 스타터킷](https://github.com/yukuku/telebot)을 수정해 만든 것이다.

    #-*- coding: utf-8 -*-
    #
    # original:    https://github.com/yukuku/telebot
    # modified by: Bak Yeon O @ http://bakyeono.net
    # description: http://bakyeono.net/post/2015-08-24-using-telegram-bot-api.html
    # github:      https://github.com/bakyeono/using-telegram-bot-api
    #
    
    # 구글 앱 엔진 라이브러리 로드
    from google.appengine.api import urlfetch
    from google.appengine.ext import ndb
    import webapp2
    
    # URL, JSON, 로그, 정규표현식 관련 라이브러리 로드
    import urllib
    import urllib2
    import json
    import logging
    import re
    
    # 봇 토큰, 봇 API 주소
    TOKEN = '137007641:AAFVXObeODnKcyDrbcBfEAHzYFGhcFeVlVk'
    BASE_URL = 'https://api.telegram.org/bot' + TOKEN + '/'
    
    # 봇이 응답할 명령어
    CMD_START     = '/start'
    CMD_STOP      = '/stop'
    CMD_HELP      = '/help'
    CMD_BROADCAST = '/broadcast'
    
    # 봇 사용법 & 메시지
    USAGE = u"""[사용법] 아래 명령어를 메시지로 보내거나 버튼을 누르시면 됩니다.
    /start - (봇 활성화)
    /stop  - (봇 비활성화)
    /help  - (이 도움말 보여주기)
    """
    MSG_START = u'봇을 시작합니다.'
    MSG_STOP  = u'봇을 정지합니다.'
    
    # 커스텀 키보드
    CUSTOM_KEYBOARD = [
            [CMD_START],
            [CMD_STOP],
            [CMD_HELP],
            ]
    
    # 채팅별 봇 활성화 상태
    # 구글 앱 엔진의 Datastore(NDB)에 상태를 저장하고 읽음
    # 사용자가 /start 누르면 활성화
    # 사용자가 /stop  누르면 비활성화
    class EnableStatus(ndb.Model):
        enabled = ndb.BooleanProperty(required=True, indexed=True, default=False,)
    
    def set_enabled(chat_id, enabled):
        u"""set_enabled: 봇 활성화/비활성화 상태 변경
        chat_id:    (integer) 봇을 활성화/비활성화할 채팅 ID
        enabled:    (boolean) 지정할 활성화/비활성화 상태
        """
        es = EnableStatus.get_or_insert(str(chat_id))
        es.enabled = enabled
        es.put()
    
    def get_enabled(chat_id):
        u"""get_enabled: 봇 활성화/비활성화 상태 반환
        return: (boolean)
        """
        es = EnableStatus.get_by_id(str(chat_id))
        if es:
            return es.enabled
        return False
    
    def get_enabled_chats():
        u"""get_enabled: 봇이 활성화된 채팅 리스트 반환
        return: (list of EnableStatus)
        """
        query = EnableStatus.query(EnableStatus.enabled == True)
        return query.fetch()
    
    # 메시지 발송 관련 함수들
    def send_msg(chat_id, text, reply_to=None, no_preview=True, keyboard=None):
        u"""send_msg: 메시지 발송
        chat_id:    (integer) 메시지를 보낼 채팅 ID
        text:       (string)  메시지 내용
        reply_to:   (integer) ~메시지에 대한 답장
        no_preview: (boolean) URL 자동 링크(미리보기) 끄기
        keyboard:   (list)    커스텀 키보드 지정
        """
        params = {
            'chat_id': str(chat_id),
            'text': text.encode('utf-8'),
            }
        if reply_to:
            params['reply_to_message_id'] = reply_to
        if no_preview:
            params['disable_web_page_preview'] = no_preview
        if keyboard:
            reply_markup = json.dumps({
                'keyboard': keyboard,
                'resize_keyboard': True,
                'one_time_keyboard': False,
                'selective': (reply_to != None),
                })
            params['reply_markup'] = reply_markup
        try:
            urllib2.urlopen(BASE_URL + 'sendMessage', urllib.urlencode(params)).read()
        except Exception as e: 
            logging.exception(e)
    
    def broadcast(text):
        u"""broadcast: 봇이 켜져 있는 모든 채팅에 메시지 발송
        text:       (string)  메시지 내용
        """
        for chat in get_enabled_chats():
            send_msg(chat.key.string_id(), text)
    
    # 봇 명령 처리 함수들
    def cmd_start(chat_id):
        u"""cmd_start: 봇을 활성화하고, 활성화 메시지 발송
        chat_id: (integer) 채팅 ID
        """
        set_enabled(chat_id, True)
        send_msg(chat_id, MSG_START, keyboard=CUSTOM_KEYBOARD)
    
    def cmd_stop(chat_id):
        u"""cmd_stop: 봇을 비활성화하고, 비활성화 메시지 발송
        chat_id: (integer) 채팅 ID
        """
        set_enabled(chat_id, False)
        send_msg(chat_id, MSG_STOP)
    
    def cmd_help(chat_id):
        u"""cmd_help: 봇 사용법 메시지 발송
        chat_id: (integer) 채팅 ID
        """
        send_msg(chat_id, USAGE, keyboard=CUSTOM_KEYBOARD)
    
    def cmd_broadcast(chat_id, text):
        u"""cmd_broadcast: 봇이 활성화된 모든 채팅에 메시지 방송
        chat_id: (integer) 채팅 ID
        text:    (string)  방송할 메시지
        """
        send_msg(chat_id, u'메시지를 방송합니다.', keyboard=CUSTOM_KEYBOARD)
        broadcast(text)
    
    def cmd_echo(chat_id, text, reply_to):
        u"""cmd_echo: 사용자의 메시지를 따라서 답장
        chat_id:  (integer) 채팅 ID
        text:     (string)  사용자가 보낸 메시지 내용
        reply_to: (integer) 답장할 메시지 ID
        """
        send_msg(chat_id, text, reply_to=reply_to)
    
    def process_cmds(msg):
        u"""사용자 메시지를 분석해 봇 명령을 처리
        chat_id: (integer) 채팅 ID
        text:    (string)  사용자가 보낸 메시지 내용
        """
        msg_id = msg['message_id']
        chat_id = msg['chat']['id']
        text = msg.get('text')
        if (not text):
            return
        if CMD_START == text:
            cmd_start(chat_id)
            return
        if (not get_enabled(chat_id)):
            return
        if CMD_STOP == text:
            cmd_stop(chat_id)
            return
        if CMD_HELP == text:
            cmd_help(chat_id)
            return
        cmd_broadcast_match = re.match('^' + CMD_BROADCAST + ' (.*)', text)
        if cmd_broadcast_match:
            cmd_broadcast(chat_id, cmd_broadcast_match.group(1))
            return
        cmd_echo(chat_id, text, reply_to=msg_id)
        return
    
    # 웹 요청에 대한 핸들러 정의
    # /me 요청시
    class MeHandler(webapp2.RequestHandler):
        def get(self):
            urlfetch.set_default_fetch_deadline(60)
            self.response.write(json.dumps(json.load(urllib2.urlopen(BASE_URL + 'getMe'))))
    
    # /updates 요청시
    class GetUpdatesHandler(webapp2.RequestHandler):
        def get(self):
            urlfetch.set_default_fetch_deadline(60)
            self.response.write(json.dumps(json.load(urllib2.urlopen(BASE_URL + 'getUpdates'))))
    
    # /set-wehook 요청시
    class SetWebhookHandler(webapp2.RequestHandler):
        def get(self):
            urlfetch.set_default_fetch_deadline(60)
            url = self.request.get('url')
            if url:
                self.response.write(json.dumps(json.load(urllib2.urlopen(BASE_URL + 'setWebhook', urllib.urlencode({'url': url})))))
    
    # /webhook 요청시 (텔레그램 봇 API)
    class WebhookHandler(webapp2.RequestHandler):
        def post(self):
            urlfetch.set_default_fetch_deadline(60)
            body = json.loads(self.request.body)
            self.response.write(json.dumps(body))
            process_cmds(body['message'])
    
    # 구글 앱 엔진에 웹 요청 핸들러 지정
    app = webapp2.WSGIApplication([
        ('/me', MeHandler),
        ('/updates', GetUpdatesHandler),
        ('/set-webhook', SetWebhookHandler),
        ('/webhook', WebhookHandler),
    ], debug=True)

> 주의: 소스코드 중 20번째 줄에 정의된 `TOKEN`은 자신의 봇 토큰으로 바꿔줘야 한다.

주석도 열심히 달아 놓았으니 파이썬 코드를 읽을 수 있다면 소스코드를 한 번 읽어보면 좋다. 소스코드에 관해서는 잠시 뒤에 설명하겠다.

### 서버 프로그램 업로드

아래 명령어로 프로그램을 구글 앱 엔진에 업로드한다.

    $ ~/google_appengine/appcfg.py update .

그러면 브라우저에 구글 앱 엔진 계정 인증 화면이 나올 것이다. 인증을 거치면 프로그램이 업로드된다.

만일 구글 앱 엔진 계정이 여러 개여서 인증 문제가 발생할 경우엔 아래 명령어로 쿠키를 지우고 업로드하면 된다.

    $ ~/google_appengine/appcfg.py --no_cookies update .

프로그램이 정상 업로드 되었는지 확인하려면 웹 브라우저로 아래 주소에 접속한다. 단, `my-testing-bot` 부분을 **아까 등록한 구글 앱 엔진 프로젝트의 ID**로 바꿔 입력해야 한다.

    https://my-testing-bot.appspot.com/me

아래와 같은 유형의 JSON 문서가 반환되면 성공이다.

    {
      "ok": true,
      "result": {
                  "username": "my_testing_bot",
                  "first_name": "\uc2dc\ud5d8\uc6a9 \ub85c\ubd07",
                  "id": 137007641
                }
    }

### 웹훅 설정

봇 서버를 사용하기 전에 먼저 웹훅을 설정해 봇 서버가 텔레그램 API와 통신할 수 있게 해야 한다.

봇이 API와 통신하는 방식을 간단하게 나타내면 이렇다.

* 봇이 메시지 수신할 때

    텔레그램 웹 API -> 봇 서버 웹훅 -> 스크립트 실행 -> 응답

* 봇이 메시지 발신할 때

    봇 서버 스크립트 -> 텔레그램 웹 API

따라서, 발신만 할 때는 상관없지만 메시지를 받아 처리하기 위해서는 웹훅을 설정해둬야 한다.

웹훅을 설정하기 위해 웹 브라우저로 아래 주소에 접속한다. 단, `my-testing-bot` 부분을 **아까 등록한 구글 앱 엔진 프로젝트의 ID**로 바꿔 입력해야 한다. 두 번 나오니 둘 다 고쳐라.

    https://my-testing-bot.appspot.com/set-webhook?url=https://my-testing-bot.appspot.com/webhook

구글 앱 엔진 인증을 마치면 웹훅이 설정된다. 아래와 같은 유형의 JSON 문서가 반환되면 성공이다.

    {
      "ok": true,
      "result": true,
      "description": "Webhook was set"
    }

### 봇 사용하기

이제 봇에게 말을 걸어보자.

텔레그램 클라이언트로 봇 이름이나 ID로 검색해 채팅 목록에 추가한다.

![봇 검색하기](http://bakyeono.net/img/telegram-bot-test-search.png)

웹 브라우저로 https://telegram.me/my_testing_bot 주소로 접속해도 봇을 추가할 수 있다. 물론 주소에서 봇 ID는 자신의 봇 ID로 바꿔야 한다. 사용자들에게 봇을 제공할 때는 이 방법이 더 좋을 것이다.

봇을 추가하면 다음과 같은 화면과 **START** 버튼이 나온다.

![봇 시작하기 1](http://bakyeono.net/img/telegram-bot-test-start1.png)

**START** 버튼을 누르면 아래와 같이 봇을 시작한다는 메시지가 나오고 커스텀 키보드도 쓸 수 있게 된다.

![봇 시작하기 2](http://bakyeono.net/img/telegram-bot-test-start2.png)

커스텀 키보드를 눌러 모든 기능이 잘 동작하는지 확인해보자.

`/broadcast 방송할 내용` 명령을 입력하면 봇이 활성화된 모든 채팅방에 봇이 메시지를 보낸다.

![봇 시작하기 2](http://bakyeono.net/img/telegram-bot-test-broadcast.png)

명령어가 아닌 문장을 입력하면, 봇이 그 말을 똑같이 따라한다.

![봇 시작하기 2](http://bakyeono.net/img/telegram-bot-test-echo.png)

이제 `main.py`를 수정해 위 기능들 중 불필요한 기능을 없애고 필요한 기능을 추가하면 된다. 자신만의 봇을 만들어 서비스해 보자.

## 봇 서버 코드 설명

코드에 달린 주석과 텔레그램 API 문서를 참고하면 이해하기 어려운 부분은 없을 것이다. `main.py` 코드 중 몇 가지만 설명한다.

### 봇 토큰 지정

20번째 줄에 봇의 토큰과 API URL이 정의돼 있다. 여기서 토큰은 자신의 봇 토큰으로 지정해주어야 하며, 노출해서는 안된다.

    TOKEN = '137007641:AAFVXObeODnKcyDrbcBfEAHzYFGhcFeVlVk'
    BASE_URL = 'https://api.telegram.org/bot' + TOKEN + '/'

### 메시지 발송 함수

79번 줄에 메시지 발송 함수를 정의해 놓았다.

    def send_msg(chat_id, text, reply_to=None, no_preview=True, keyboard=None):
        u"""send_msg: 메시지 발송
        chat_id:    (integer) 메시지를 보낼 채팅 ID
        text:       (string)  메시지 내용
        reply_to:   (integer) ~메시지에 대한 답장
        no_preview: (boolean) URL 자동 링크(미리보기) 끄기
        keyboard:   (list)    커스텀 키보드 지정
        """
        params = {
            'chat_id': str(chat_id),
            'text': text.encode('utf-8'),
            }
        if reply_to:
            params['reply_to_message_id'] = reply_to
        if no_preview:
            params['disable_web_page_preview'] = no_preview
        if keyboard:
            reply_markup = json.dumps({
                'keyboard': keyboard,
                'resize_keyboard': True,
                'one_time_keyboard': False,
                'selective': (reply_to != None),
                })
            params['reply_markup'] = reply_markup
        try:
            urllib2.urlopen(BASE_URL + 'sendMessage', urllib.urlencode(params)).read()
        except Exception as e:
            logging.exception(e)

봇이 메시지를 보내게 하려면 `sendMessage` API를 이용한다. 각 매개변수에 대한 설명은 함수 주석을 참고하라.

### 커스텀 키보드

커스텀 키보드는 문자열을 담은 2차원 리스트로 돼 있다. 바깥 리스트의 각 항목(안쪽 리스트)이 키보드의 한 줄을 나타내고, 안쪽 리스트의 각 항목(문자열)은 키보드의 한 줄에 담긴 각 버튼을 나타낸다.

따라서 소스코드에 쓰인 이 키보드 배열은,

    CUSTOM_KEYBOARD = [
            [CMD_START],
            [CMD_STOP],
            [CMD_HELP],
            ]

다음과 같이 출력된다.

![커스텈 키보드 출력 예](http://bakyeono.net/img/telegram-bot-test-start2.png)

봇을 위한 명령어와 커스텀 키보드 버튼에는 한글도 사용할 수 있으며, 심지어 슬래시(`/`)를 붙이지 않아도 된다. 명령어와 키보드를 잘 만들어 편리하고 배우기 쉬운 UI를 제공해보자.

사용자에게 커스텀 키보드를 보여주려면 메시지를 발송할 때 `reply_markup` 매개변수의 값으로 키보드 옵션 JSON 객체를 보내줘야 한다. 위의 메시지 발송 함수 설명을 참고하라.

커스텀 키보드를 끄는 방법은 이 소스코드에 정의해두지 않았다. 키보드를 출력하는 방법과 별로 다를 것 없으니 텔레그램 봇 API 문서를 참고하기 바란다.

### 방송 기능

여러 사용자에게 방송하는 기능이다. 다양한 사용자를 쿼리할 수 있겠지만 여기서는 봇을 작동시켜둔 모든 채팅에 방송하도록 했다.

방송 함수 자체에는 별 내용이 없다.

    def broadcast(text):
        u"""broadcast: 봇이 켜져 있는 모든 채팅에 메시지 발송
        text:       (string)  메시지 내용
        """
        for chat in get_enabled_chats():
            send_msg(chat.key.string_id(), text)

방송 함수가 참고하는 `get_enabled_chats` 함수가 좀더 중요하다.

    def get_enabled_chats():
        u"""get_enabled: 봇이 활성화된 채팅 리스트 반환
        return: (list of EnableStatus)
        """
        query = EnableStatus.query(EnableStatus.enabled == True)
        return query.fetch()

이 함수는 구글 앱 엔진의 Datastore에 쿼리를 보내 결과값을 돌려준다. 자세한 내용은 구글 앱 엔진 Datastore API를 참고하라.

방송 기능을 실제로 서비스 할 때는 아무나 방송을 하지 못하도록 방송을 할 수 있는 사용자를 지정해두고 체크하도록 해야 할 것이다.

### 웹훅 핸들러

202번째 줄에 정의된 웹훅 핸들러는 텔레그램 API가 보내오는 모든 메시지를 처리한다.

    class WebhookHandler(webapp2.RequestHandler):
        def post(self):
            urlfetch.set_default_fetch_deadline(60)
            body = json.loads(self.request.body)
            self.response.write(json.dumps(body))
            process_cmds(body['message'])

핸들러는 구글 앱 엔진의 `webapp2.RequestHandler` 객체를 확장해서 정의한다.

텔레그램 API는 POST 방식으로 오므로, 핸들러에 `post` 메소드를 정의했다.

이 메소드는 텔레그램이 보내온 JSON 객체를 해석해 `process_cmds` 함수가 메시지를 처리하도록 전달한다.

`process_cmd()` 함수는 152번째 줄에 아래와 같이 정의돼 있다.

    def process_cmds(msg):
        u"""사용자 메시지를 분석해 봇 명령을 처리
        chat_id: (integer) 채팅 ID
        text:    (string)  사용자가 보낸 메시지 내용
        """
        msg_id = msg['message_id']
        chat_id = msg['chat']['id']
        text = msg.get('text')
        if (not text):
            return
        if CMD_START == text:
            cmd_start(chat_id)
            return
        if (not get_enabled(chat_id)):
            return
        if CMD_STOP == text:
            cmd_stop(chat_id)
            return
        if CMD_HELP == text:
            cmd_help(chat_id)
            return
        cmd_broadcast_match = re.match('^' + CMD_BROADCAST + ' (.*)', text)
        if cmd_broadcast_match:
            cmd_broadcast(chat_id, cmd_broadcast_match.group(1))
            return
        cmd_echo(chat_id, text, reply_to=msg_id)
        return

단순히 메시지 텍스트가 명령어에 해당되는지 비교하는 분기들이다.

눈여겨 봐둘 만한 부분은 봇 상태가 활성화되지 않았을 때는 `CMD_START` 명령 외에는 처리하지 않도록 한 부분이다.

또, 방송 명령`CMD_BROADCAST`의 경우에는 정규표현식 처리를 하여 명령과 매개변수(방송할 메시지)를 구분하였다.

그리고,

    app = webapp2.WSGIApplication([
        ('/me', MeHandler),
        ('/updates', GetUpdatesHandler),
        ('/set-webhook', SetWebhookHandler),
        ('/webhook', WebhookHandler),
    ], debug=True)

새로운 핸들러를 지정할 때는 `webapp2.WSGIApplication` 객체를 생성할 때 매개변수에 추가해 둬야 한다.

## 기타

### 봇 서버 프로젝트 다운로드

이 글에서 작성한 봇 서버 프로젝트는 아래 GitHub에 올려두었다. 필요하면 아래 주소에서 다운로드 할 수 있다.

GitHub URL: [https://github.com/bakyeono/using-telegram-bot-api](https://github.com/bakyeono/using-telegram-bot-api)

### favicon.ico 에러 해결

웹 브라우저는 웹사이트에 접속할 때 웹사이트 아이콘(파비콘)을 표시하기 위해 `/favicon.ico` 파일을 요청한다. 제공하지 않아도 무방하지만 에러 로그가 쌓이는 걸 보기 싫다면 적당한 파일을 하나 넣어두고 URL 핸들러를 지정해주면 된다.

파비콘으로 사용할 `favicon.ico` 파일을 봇 서버 디렉토리에 넣은 후, `app.yaml` 파일에 다음 내용을 추가하면 된다.

    handlers:
    - url: /favicon\.ico
      static_files: favicon.ico
      upload: favicon\.ico

하지만 봇 서버이므로 굳이 파비콘을 제공할 필요 없다. 어차피 웹 브라우저를 통한 접근은 비정상 접근이기 때문이다.

### cron.yaml - 작업 스케줄 (cron job) 등록

봇이 매시간 사용자에게 시간을 알려준다든지, 특정 웹사이트를 분석해 시간대별 상태를 메시지로 보낸다든지 하는, 지정된 시간대에 작업을 반복하도록 하는 것도 가능하다.

반복 작업을 등록하려면 봇 서버가 있는 디렉토리에 `cron.yaml` 파일을 만들고 아래와 같은 내용을 넣으면 된다.

    cron:
    - description: broadcast wspaper.org news
      url: /broadcast-news
      schedule: every 30 mins from 09:00 to 20:00
      timezone: Asia/Seoul

이렇게 지정해두면 서울 시간대로 오전 9시 ~ 오후 8시 사이에 30분에 한 번씩 작업이 요청된다.

물론, `main.py`를 수정해 작업 요청을 수행하기 위한 핸들러(이 경우 '/broadcast-news`)와 기능을 추가해 줘야 한다.

### telegram-cli로 로봇 만들기

telegram-cli로 로봇을 만드는 방법은 [이 글](http://bakyeono.net/post/2015-06-10-tg-broadcast.html)에 나와 있다.


