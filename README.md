     

- ## 脚本说明

| 文件                          | 需要jq | 备注     | 推荐           |
| :---------------------------- | ------ | -------- | -------------- |
| cloudflare_ddns_jq.sh         | 是     | 一次执行 | 是             |
| cloudflare_ddns_jq_loop.sh    | 是     | 循环执行 | 是             |
| cloudflare_ddns_no_jq.sh      | 否     | 一次执行 | 除非无法安装jq |
| cloudflare_ddns_no_jq_loop.sh | 否     | 循环执行 | 除非无法安装jq |

> [!NOTE]
>
> 1. 建议优先使用通过jq解析json的脚本，除非无法安装jq
>
> 2. 不调用jq的脚本通过文本处理进行解析，不同系统的文本显示方式效果存在差异，可能导致执行结果不符合预期
>
> 3. 一次执行脚本建议通过添加crontab定时任务执行，例如：
>
>    `*/10 * * * * /bin/sh /opt/cloudflare_ddns_jq.sh`
>
> 4. 循环脚本可通过nohup手动执行或添加入rc.local开机执行或添加crontab @reboot任务等等方式自动执行



- ## 参数说明

```shell
# 需要解析的FQDN域名
name="ddns.example.com"

# Cloudflare 仪表板 => 网站 => 域名
# 在 API 栏目找到 区域 ID，复制并填入
zone_id="Put your zone ID here"

# 在上述API栏目单击获取您的 API 令牌 => 创建令牌 => 使用编辑区域 DNS模板
# 在 区域资源 栏中，选择包括所有区域，或者你想指定的特定区域
# 单击 继续以显示摘要 => 创建令牌
# 复制并填入
api_token="Put your API token here"

# IPv4更新开关 1=更新
v4_update_switch="1"
# IPv4代理开关 true or false
v4_proxy_switch=false
# IPv4查询地址
v4_query_url="ipv4.whatismyip.akamai.com"

# IPv6更新开关 1=更新
v6_update_switch="1"
# IPv6代理开关 true or false
v6_proxy_switch=false
# IPv6查询地址
v6_query_url="ipv6.whatismyip.akamai.com"

# 更新间隔，单位秒（仅循环模式需要配置）
update_interval=600
```

- ## 关于Windows 脚本 Global API Key-ddns 说明
Global API Key-ddns
需要zone_id 、id 、sub_domain(子域名)、Global API Key   
关于id  这里的id 是子域名id

先获取域名 ID 指的是你在 Cloudflare 中托管一级/顶级域名的 ID（如 xxx.yyy，而不是子域名）
```shell
## Linux 系统
curl -X GET "https://api.cloudflare.com/client/v4/zones" \
-H "X-Auth-Email: 账号邮箱" \
-H "X-Auth-Key: 前面获取的 API 令牌" \
-H "Content-Type: application/json"
## Windows 系统
"D:\Program Files\curl\bin\curl.exe" -X GET "https://api.cloudflare.com/client/v4/zones" ^
-H "X-Auth-Email: 账号邮箱" ^
-H "X-Auth-Key: 前面获取的 API 令牌" ^
-H "Content-Type: application/json"
```
返回json
```shell
"id": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
"name": "yyy.zzz",
"status": "active",
```
# 获取域名解析记录 ID
```shell
## Linux 系统
curl -X GET "https://api.cloudflare.com/client/v4/zones/域名ID/dns_records?page=1&per_page=20&order=type&direction=asc" \
-H "X-Auth-Email: 账号邮箱" \
-H "X-Auth-Key: 前面获取的 API 令牌" \
-H "Content-Type: application/json"
## Windows 系统
"D:\Program Files\curl\bin\curl.exe" -X GET "https://api.cloudflare.com/client/v4/zones/域名ID/dns_records?page=1&per_page=20&order=type&direction=asc" ^
-H "X-Auth-Email: 账号邮箱" ^
-H "X-Auth-Key: 前面获取的 API 令牌" ^
-H "Content-Type: application/json"
```
返回json
```shell
"id":"yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy",
"zone_id":"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
"zone_name":"yyy.zzz",
"name":"xxx.yyy.zzz",
"type":"A",
"content":"X.X.X.X",
"proxied":true,
"ttl":1,
```

| 字段名称               | 描述                         |  
| :--: | :--: |  
| id                     | 域名解析记录 ID              |  
| zone_id                | 所属的域名 ID                |  
| zone_name              | 所属的（顶级/一级）域名      |  
| name                   | 完整（子）域名               |  
| type                   | 解析记录类型                 |  
| content                | 解析 IP 地址                 |  
| proxied                | 是否走 CDN 代理，是：true，否：false |  
| ttl                    | 解析记录生存时间，值为 1 则是自动，单位：秒 |

# 更新域名解析记录
```shell
## Linux 系统
curl -X PUT "https://api.cloudflare.com/client/v4/zones/域名ID/dns_records/解析记录ID" \
-H "X-Auth-Email: 账号邮箱" \
-H "X-Auth-Key: 前面获取的 API 令牌" \
-H "Content-Type: application/json" \
--data '{"type":"A","name":"xxx.yyy.zzz","content":"最快 IP","ttl":1,"proxied":true}'

# 如果你只需要更新该域名解析记录中单独 “一个” 信息（上面那个只能同时设置域名解析记录的所有信息），那么可以改成这样：

curl -X PATCH "https://api.cloudflare.com/client/v4/zones/域名ID/dns_records/解析记录ID" \
-H "X-Auth-Email: 账号邮箱" \
-H "X-Auth-Key: 前面获取的 API 令牌" \
-H "Content-Type: application/json" \
--data '{"content":"最快 IP"}'


## Windows 系统
"D:\Program Files\curl\bin\curl.exe" -X PUT "https://api.cloudflare.com/client/v4/zones/域名ID/dns_records/解析记录ID" ^
-H "X-Auth-Email: 账号邮箱" ^
-H "X-Auth-Key: 前面获取的 API 令牌" ^
-H "Content-Type: application/json" ^
--data "{\"type\":\"A\",\"name\":\"xxx.yyy.zzz\",\"content\":\"最快 IP\",\"ttl\":1,\"proxied\":true}"

# 如果你只需要更新该域名解析记录中单独 “一个” 信息（上面那个只能同时设置域名解析记录的所有信息），那么可以改成这样：

"D:\Program Files\curl\bin\curl.exe" -X PATCH "https://api.cloudflare.com/client/v4/zones/域名ID/dns_records/解析记录ID" ^
-H "X-Auth-Email: 账号邮箱" ^
-H "X-Auth-Key: 前面获取的 API 令牌" ^
-H "Content-Type: application/json" ^
--data "{\"content\":\"最快 IP\"}"
```
- ## 关于Windows 脚本 API-TOKEN-ddns 说明
需要几个必须项：
```shell
set ZONE_NAME= 主域名
set DOMAIN= 子域名（需要先去添加随便填写一个ip如8.8.8.8 并开启仅 DNS）
set TOKEN= API令牌 （不是Global API Key！！！ 就是编辑区域 DNS的 API 令牌）
```
- ## 关于群晖Synology ddns
```shell
sudo wget https://raw.githubusercontent.com/songwqs/Cloudflare-DDNS/main/Synology/cloudflareddns.sh -O /sbin/cloudflareddns.sh

(可选关闭代理 默认开启)sudo sed -i 's/proxy="true"/proxy="false"/' /sbin/cloudflareddns.sh

sudo chmod +x /sbin/cloudflareddns.sh
```
```shell
sudo sh -c "cat >> /etc.defaults/ddns_provider.conf << EOF
[Cloudflare]
        modulepath=/sbin/cloudflareddns.sh 
        queryurl=https://www.cloudflare.com
        website=https://www.cloudflare.com 
EOF"
```
服务提供商：Cloudflare
主机名：www.example.com 你的购买的域名
用户名/电子邮件：<Zone ID> 域名的"区域ID"API
密码密钥：<API Token> 操作DNS的API令牌
