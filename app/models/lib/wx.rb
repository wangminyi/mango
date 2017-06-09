class Wx
  class << self
    def access_token
      return nil if !Rails.env.production?

      token_redis = Redis::Value.new("wx_access_token")
      if token_redis.value.nil?
        id = ENV["wx_id"]
        secret = ENV["wx_secret"]
        res = JSON.parse(RestClient.get("https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=#{id}&secret=#{secret}"))
        token_redis.value = res["access_token"]
        token_redis.expire res["expires_in"].seconds
      end

      token_redis.value
    end

    # 用于JS-SDK使用权限签名算法
    def jsapi_ticket
      return nil if !Rails.env.production?

      ticket_redis = Redis::Value.new("wx_jsapi_ticket")
      if ticket_redis.value.nil?
        res = JSON.parse(RestClient.get "https://api.weixin.qq.com/cgi-bin/ticket/getticket?access_token=#{self.access_token}&type=jsapi")
        ticket_redis.value = res["ticket"]
        ticket_redis.expire res["expires_in"].seconds
      end

      ticket_redis.value
    end

    # 注册微信js的参数
    # wx.config(js_config_params)
    def js_config_params url
      noncestr = "ij4o23jovdfv0d0fjsd"
      timestamp = Time.now.to_i
      {
        appId: ENV[:wx_id],
        noncestr: noncestr,
        timestamp: timestamp,
        signature: self.js_signature(noncestr, timestamp, url),
        jsApiList: ["chooseWXPay"]
      }
    end

    def js_signature noncestr, timestamp, url
      # 按 key 字典序排列
      sign_str = {
        jsapi_ticket: self.jsapi_ticket,
        noncestr: noncestr,
        timestamp: timestamp,
        url: url
      }.map do |key, value|
        "#{key}=#{value}"
      end.join("&")

      require 'digest/sha1'
      Digest::SHA1.hexdigest sign_str
    end
  end
end