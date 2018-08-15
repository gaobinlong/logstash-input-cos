# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/inputs/cos"

describe LogStash::Inputs::Cos do

  it_behaves_like "an interruptible input plugin" do
    let(:config) { {
        "endpoint" => 'cos.ap-guangzhou.myqcloud.com',
        "access_key_id" => '*',
        "access_key_secret" => '*',
        "bucket" => 'bellengao',
	      "region" => 'ap-guangzhou',
	      "appId" => '*',
        "interval" => 60 } }
  end

end
