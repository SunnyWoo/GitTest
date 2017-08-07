require 'spec_helper'

describe "test app version", type: :request do

  example "invalid user agent" do
    get "/who", nil, {'HTTP_USER_AGENT' => "konnamtb"}
    expect(controller.send(:app_version)).to eq 'Unknown'
    expect(controller.send(:os_type)).to eq 'Unknown'
    expect(controller.send(:os_version)).to eq 'Unknown'
    expect(controller.send(:device_model)).to eq 'Unknown'
  end

  example "ios app 1.0.0" do
    get "/who", nil, {'HTTP_USER_AGENT' => "commandp_1.0_iOS_8.0_iPhone 5S"}
    expect(controller.send(:app_version)).to eq '1.0'
    expect(controller.send(:os_type)).to eq 'iOS'
    expect(controller.send(:os_version)).to eq '8.0'
    expect(controller.send(:device_model)).to eq 'iPhone 5S'
  end

  example "Android app 1.0.0" do
    get "/who", nil, {'HTTP_USER_AGENT' => "commandp_1.0_Android_SDK8_HTC Desire"}
    expect(controller.send(:app_version)).to eq '1.0'
    expect(controller.send(:os_type)).to eq 'Android'
    expect(controller.send(:os_version)).to eq 'SDK8'
    expect(controller.send(:device_model)).to eq 'HTC Desire'
  end

  example "test redis" do
  	get '/who', nil, {'HTTP_USER_AGENT' => "commandp_1.0_iOS_6.0_CFNetwork/548.1.4 Darwin/11.0.0"}
  	get '/who', nil, {'HTTP_USER_AGENT' => "commandp_1.1_iOS_6.0_iPhone 5S"}
  	get '/who', nil, {'HTTP_USER_AGENT' => "commandp_1.2_iOS_6.0_iPhone 5S"}
  	get '/who', nil, {'HTTP_USER_AGENT' => "commandp_1.2_iOS_6.0_iPhone 5S"}
  	get '/who', nil, {'HTTP_USER_AGENT' => "commandp_1.0.0_Android_SDK8_HTC Desire"}
  	get '/who', nil, {'HTTP_USER_AGENT' => "commandp_1.0.0_Android_SDK8_HTC Desire"}
  	get '/who', nil, {'HTTP_USER_AGENT' => "commandp_1.0.0_Android_SDK8_HTC Desire"}
  	get '/who', nil, {'HTTP_USER_AGENT' => "foobar"}

    expect($redis.hgetall("public_api:app_type_#{Date.today}")).to eq({ 'iOS' => '4', 'Android' => '3', 'Unknown' => '1' })
  end

end
