     

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

- ## 关于Windows 脚本说明
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

| :---------------------------- | ------ | 
| id	                           |域名解析记录 ID|
| zone_id	                      |所属的域名 ID|
| zone_name                     |所属的（顶级/一级）域名|
| name	                      |完整（子）域名|
| type	                      |解析记录类型|
| content	                      |解析 IP 地址|
| proxied	                      |是否走 CDN 代理，是：true，否：false|
| ttl	                      |解析记录生存时间，值为 1 则是自动，单位：秒|

