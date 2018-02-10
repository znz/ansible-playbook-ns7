# ansible-playbook for ns7

## Initialize

- `git clone https://github.com/znz/ansible-playbook-ns7`
- `cd ansible-playbook-ns7`
- `git clone https://github.com/OpenVPN/easy-rsa`
- Restore `easy-rsa/easyrsa3/pki`
- Copy `ta.key` from `ns7:/etc/openvpn/server/ta.key`

## Initialize pki

- `cd easy-rsa/easyrsa3`
- `./easyrsa init-pki`
- `./easyrsa --keysize=4096 build-ca`
- `./easyrsa --keysize=4096 build-server-full ns7 nopass`
- `./easyrsa gen-crl`

## for vagrant env

### Create .env

```
NADOKA_SERVICE_NAME=example
NADOKA_IRC_HOST=irc.example.org
NADOKA_IRC_PORT=6667
NADOKA_IRC_PASS="'serverpass'"
NADOKA_CHANNEL_INFO="'#channel' => { key: 'chankey' }"
ATIG_USERNAMES="foo,bar"
ATIG_OAUTH="---\nfoo:\n- ...\n- ...\nbar:\n- ...\n- ...\n"
```

### test

- `dotenv vagrant up` (first time)
- `dotenv vagrant provision` (after modifications)

## for production env

### Create provision/inventory/production

```
[default]
ns7.example.jp

[all:vars]
stage=production
```

### Create provision/vars/production.yml

see `provision/vars/vagrant.yml` and `provision/roles/*/defaults/main.yml`.

### deploy

- Download roles: `ansible-galaxy install --role-file provision/requirements.yml --roles-path provision/roles` (or `dotenv vagrant up` or `dotenv vagrant provision`)
- Run playbook: `ansible-playbook -i provision/inventory/production -K provision/playbook.yml`

## Add OpenVPN clients

### On CA

- `cd easy-rsa/easyrsa3`
- `CN=some-client-user` (`some-client-user` must be unique common name on CA)
- `./easyrsa --keysize=4096 build-client-full $CN nopass`
- `cd pki`
- `git add .`
- `git commit -m "./easyrsa --keysize=4096 build-client-full $CN nopass"`
- `cd ../../..`
- `./make-config.sh $CN`

And pass `client-config-files/$CN.ovpn` via safe transport.

### On OpenVPN Server

- Create `ns7:/etc/openvpn/server/ccd/some-client-user` (`some-client-user` is same as above)
  - For example: `ifconfig-push 192.168.8.9 192.168.8.10` (see [クライアント特有のルールとアクセスポリシーの設定](https://www.openvpn.jp/document/how-to/#AccessPolicies)「IPアドレスの最後のオクテットの組み合わせ」から選ぶ (1,2 are used on server side) )

## Guide for users

```
https://www.openvpn.jp/document/openvpn-gui-for-windows/
を参考にして OpenVPN GUI for Windows をインストールしてください。

管理者権限が必要です。
管理者がいる状態で初回の接続確認まで設定してください。

途中で出てくる TAP のドライバーも必ずインストールしてください。

タスクトレイのアイコンを右クリックすると出てくるメニューから「Import file…」を選んで、
別途安全な方法で受け渡した ovpn ファイルを選びます。

タスクトレイのアイコンをダブルクリックするか、タスクトレイのアイコンを右クリックして
「接続」を選ぶと接続できます。
初回は OpenVPN Administrators グループへの追加に管理者権限が必要になります。

不要な時はタスクトレイのアイコンの右クリックメニューから「切断」してください。

OpenVPN 接続中は直接 172.x.y.z や 10.x.y.z に ping を送ったり、ブラウザーで開いたり、
telnet で接続したりできます。

インポートした設定は、「%USERPROFILE%\OpenVPN\config」に入っているので、
インポートし直す場合はエクスプローラーなどで削除してからインポートし直してください。
```
