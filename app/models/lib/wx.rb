class Wx
  class << self
    def access_token
      return nil if !Rails.production_group?

      token_redis = Redis::Value.new("wx_access_token")
      if token_redis.value.nil?
        id = ENV["wx_id"]
        secret = ENV["wx_secret"]
        res = JSON.parse(RestClient.get("https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=#{appid}&secret=#{appsecret}"))
        token_redis.value = res["access_token"]
        token_redis.expire res["expires_in"].seconds
      end

      token_redis.value
    end
  end
end