# logstash-input-cos
logstash input插件，实现从腾讯云COS中同步数据

## 使用方式

### 安装插件

进入logstash的解压目录，执行：

```
./bin/logstash-plugin install /logstash-input-cos/logstash-input-cos-0.0.1-java.gem
```
执行结果为：

```
Validating /usr/local/githome/logstash-input-cos/logstash-input-cos-0.0.1-java.gem
Installing logstash-input-cos
Installation successful
```

### 编写配置文件
编写配置文件cos.logstash.conf

```
input {
    cos {
        "endpoint" => "cos.ap-guangzhou.myqcloud.com" # COS访问域名
        "access_key_id" => "*****" # 腾讯云账号secret id
        "access_key_secret" => "****" # 腾讯云账号secret key
        "bucket" => "******" # 腾讯云COS bucket
        "region" => "ap-guangzhou" # 腾讯云COS bucket所在地域
        "appId" => "**********" # 腾讯云账号appId
        "interval" => 60 # 数据同步时间间隔，每60s拉取一次数据
    }
}

output {
    elasticsearch {
    hosts => ["http://172.16.0.39:9200"] # ES endpoint地址
    index => "access.log" # 索引
 }
}
```

### 执行logstash

```
./bin/logstash -f cos.logstash.conf
```
