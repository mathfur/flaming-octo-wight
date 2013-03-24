Usage
-----

1. data/dictionary.txtに辞書ファイルを置く。各行が「英単語+半角スペース+その単語の意味」の形になっていること。
2. Amazon Linux AMI 2012.09.1のインスタンスを作成して起動する。
3. "ssh -i ~/.ssh/foo.pem ec2-user@EC2のPublicDNS" でログインできることを確認する。
4. config/domainsに"app EC2のPublicDNS"の行を足す。
5. PRIVATE_KEY=~/.ssh/foo.pem cap deployを実行する。
