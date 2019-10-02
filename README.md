# 特定メールアドレスにのみ送信するメールクライアント

何かあったらメールで通知してくれるツールはいろいろある。

でも、そういったメールは自分にだけ送ってくれればそれでいい。
間違って他の人に送るとか、あって欲しくない。

subject と body だけ指定したら、あとはあらかじめ指定してある
メールアドレスに送信して欲しい。

これはそんなメールツールです。

### インストール

`pamail.rb` を `/usr/bin/` にコピーしてください。

`/etc/pamail.rc` を以下のテンプレートに従って作成してください。

```rb
MAIL_FROM = ''
MAIL_TO   = ''
SMTP_HOST = ''
SMTP_PORT = 587
SMTP_HELO = ''
SMTP_USER = ''
SMTP_PASS = ''
```

内容は見れば解ると思います。

`MAIL_FROM`, `MAIL_TO` はメールアドレス部分のみです。
名前を付けることはできません。

### 使い方

第1引数に subject、標準入力にメールボディを入力してください。

```sh
echo body | /usr/bin/pamail.rb subject
```

こんな感じです。

ヘッダに追加することはできません。

### 注意

starttls 必須にしてあります。

### Copyright

GPLv3

### 作者

masm11