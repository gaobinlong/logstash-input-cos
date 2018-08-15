# encoding: utf-8
require "logstash/inputs/base"
require "logstash/namespace"
require "stud/interval"
require "socket"
require 'net/http'
require 'uri'

require 'yaml'

require 'java'
java_import java.io.InputStream
java_import java.io.InputStreamReader
java_import java.io.FileInputStream
java_import java.io.BufferedReader
java_import java.util.zip.GZIPInputStream
java_import java.util.zip.ZipException
java_import java.util.List;

require 'logstash-input-cos_jars'
java_import com.qcloud.cos.COSClient
java_import com.qcloud.cos.ClientConfig
java_import com.qcloud.cos.auth.BasicCOSCredentials
java_import com.qcloud.cos.auth.COSCredentials
java_import com.qcloud.cos.exception.CosClientException
java_import com.qcloud.cos.exception.CosServiceException
java_import com.qcloud.cos.model.COSObjectSummary
java_import com.qcloud.cos.model.ListObjectsRequest
java_import com.qcloud.cos.model.ObjectListing
java_import com.qcloud.cos.model.GetObjectRequest
java_import com.qcloud.cos.region.Region


class LogStash::Inputs::Cos < LogStash::Inputs::Base
  config_name "cos"

  # If undefined, Logstash will complain, even if codec is unused.
  default :codec, "plain"

  config :interval, :validate => :number, :default => 60

  # oss client 配置
  config :access_key_id, :validate => :string, :default => nil
  config :access_key_secret, :validate => :string, :default => nil
  config :region, :validate => :string, :default => nil
  config :appId, :validate => :string, :default => nil
  config :endpoint, :validate => :string, :default => nil
  config :bucket, :validate => :string, :default => nil
  config :marker_file, :validate => :string, :default => File.join(Dir.home, '.cos-marker.yml')
  config :prefix, :validate => :string, :default => ""

  public
  def register
    @host = Socket.gethostname
    @markerConfig = MarkerConfig.new @marker_file

    @logger.info("Registering cos input", :bucket => @bucket, :region => @region)

    # 1 初始化用户身份信息(appid, secretId, secretKey)
    cred = com.qcloud.cos.auth.BasicCOSCredentials.new(@access_key_id, @access_key_secret)
    # 2 设置bucket的区域, COS地域的简称请参照 https://www.qcloud.com/document/product/436/6224
    clientConfig = com.qcloud.cos.ClientConfig.new(com.qcloud.cos.region.Region.new(@region))
    # 3 生成cos客户端
    @cosclient = com.qcloud.cos.COSClient.new(cred, clientConfig)
    # bucket名称, 需包含appid
    bucketName = @bucket + "-"+ @appId
    @bucketName = bucketName

    @listObjectsRequest = com.qcloud.cos.model.ListObjectsRequest.new()
    # 设置bucket名称
    @listObjectsRequest.setBucketName(bucketName)
    # prefix表示列出的object的key以prefix开始
    @listObjectsRequest.setPrefix(@prefix)
    # 设置最大遍历出多少个对象, 一次listobject最大支持1000
    @listObjectsRequest.setMaxKeys(1000)
    @listObjectsRequest.setMarker(@markerConfig.getMarker)
  end

  def run(queue)
    @current_thread = Thread.current
    Stud.interval(@interval) do
      process(queue)
    end
  end

  def process_test(queue)
     # we can abort the loop if stop? becomes true
    while !stop?
      event = LogStash::Event.new(
        "host" => @host,
        "endpoint"=> @endpoint,
        "access_key_id" => @access_key_id,
        "access_key_secret" => @access_key_secret,
        "bucket" => @bucket,
        "region" => @region,
        "appId" => @appId
      )
      decorate(event)
      queue << event
      Stud.stoppable_sleep(@interval) { stop? }
    end # loop
  end

  def process(queue)
    @logger.info('Marker from: ' + @markerConfig.getMarker)

    objectListing = @cosclient.listObjects(@listObjectsRequest)
    nextMarker = objectListing.getNextMarker()
    cosObjectSummaries = objectListing.getObjectSummaries()
    cosObjectSummaries.each do |obj|
       # 文件的路径key
       key = obj.getKey()

       if stop?
         @logger.info("stop while attempting to read log file")
         break
       end
       # 3. obj 转化
       getObject(key) { |log|

         # 4. codec 并发送消息
         @codec.decode(log) do |event|
           decorate(event)
           queue << event
         end
       }

       # 5. 记录 marker
       @markerConfig.setMarker(key)
       @logger.info('Marker end: ' + @markerConfig.getMarker)
    end
  end


  # 获取下载输入流
  def getObject(key, &block)
    getObjectRequest = com.qcloud.cos.model.GetObjectRequest.new(@bucketName, key)
    cosObject = @cosclient.getObject(getObjectRequest)
    cosObjectInput = cosObject.getObjectContent()
    buffered =BufferedReader.new(InputStreamReader.new(cosObjectInput))
    while (line = buffered.readLine())
      block.call(line)
    end
  end


  # logstash 关闭回调
  def stop
    @markerConfig.ensureMarker
    @logger.info('Stop cos input!')
    @logger.info('Marker record: ' + @markerConfig.getMarker)
    @cosclient.shutdown()
    Stud.stop!(@current_thread)
  end
end # class LogStash::Inputs::Cos


# 标记配置工具
class MarkerConfig
  KEY_MARKER = 'next_marker'

  def initialize(filename)
    @filename = filename
    dirname = File.dirname(@filename)
    unless Dir.exist?(dirname)
      FileUtils.mkdir_p(dirname)
    end

    if File.exists?(@filename)
      @config = YAML.load_file(@filename)
    else
      @config = {KEY_MARKER => nil}
        File.open(@filename, 'w') do |handler|
          handler.write @config.to_yaml
        end
      end
    end

  def getMarker
    @config[KEY_MARKER] || ''
  end

  public
  def setMarker (marker)
    @config[KEY_MARKER] = marker
  end

  public
  def ensureMarker
    File.open(@filename, 'w') do |handler|
      handler.write @config.to_yaml
    end
  end

end # class bucket 读取配置
