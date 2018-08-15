# this is a generated file, to avoid over-writing it just delete this comment
begin
  require 'jar_dependencies'
rescue LoadError
  require 'org/apache/httpcomponents/httpclient/4.5.3/httpclient-4.5.3.jar'
  require 'org/slf4j/slf4j-api/1.7.21/slf4j-api-1.7.21.jar'
  require 'org/slf4j/slf4j-log4j12/1.7.21/slf4j-log4j12-1.7.21.jar'
  require 'log4j/log4j/1.2.17/log4j-1.2.17.jar'
  require 'com/fasterxml/jackson/core/jackson-databind/2.9.4/jackson-databind-2.9.4.jar'
  require 'org/apache/httpcomponents/httpcore/4.4.6/httpcore-4.4.6.jar'
  require 'com/fasterxml/jackson/core/jackson-core/2.9.4/jackson-core-2.9.4.jar'
  require 'org/hamcrest/hamcrest-core/1.3/hamcrest-core-1.3.jar'
  require 'com/fasterxml/jackson/core/jackson-annotations/2.9.0/jackson-annotations-2.9.0.jar'
  require 'junit/junit/4.12/junit-4.12.jar'
  require 'commons-logging/commons-logging/1.2/commons-logging-1.2.jar'
  require 'joda-time/joda-time/2.9.6/joda-time-2.9.6.jar'
  require 'org/bouncycastle/bcprov-jdk15on/1.59/bcprov-jdk15on-1.59.jar'
  require 'com/qcloud/cos_api/5.4.4/cos_api-5.4.4.jar'
  require 'commons-codec/commons-codec/1.10/commons-codec-1.10.jar'
end

if defined? Jars
  require_jar 'org.apache.httpcomponents', 'httpclient', '4.5.3'
  require_jar 'org.slf4j', 'slf4j-api', '1.7.21'
  require_jar 'org.slf4j', 'slf4j-log4j12', '1.7.21'
  require_jar 'log4j', 'log4j', '1.2.17'
  require_jar 'com.fasterxml.jackson.core', 'jackson-databind', '2.9.4'
  require_jar 'org.apache.httpcomponents', 'httpcore', '4.4.6'
  require_jar 'com.fasterxml.jackson.core', 'jackson-core', '2.9.4'
  require_jar 'org.hamcrest', 'hamcrest-core', '1.3'
  require_jar 'com.fasterxml.jackson.core', 'jackson-annotations', '2.9.0'
  require_jar 'junit', 'junit', '4.12'
  require_jar 'commons-logging', 'commons-logging', '1.2'
  require_jar 'joda-time', 'joda-time', '2.9.6'
  require_jar 'org.bouncycastle', 'bcprov-jdk15on', '1.59'
  require_jar 'com.qcloud', 'cos_api', '5.4.4'
  require_jar 'commons-codec', 'commons-codec', '1.10'
end
