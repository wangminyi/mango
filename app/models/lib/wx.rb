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

    def update_menu
      # 防止将 & 转义成 unicode，微信服务器不接受
      # http://stackoverflow.com/questions/17936318/why-does-to-json-escape-unicode-automatically-in-rails-4
      # ActiveSupport.escape_html_entities_in_json = false

      params = {
        button: [
          {
            name: '精品选购',
            type: 'view',
            url:  'http://yylife.online'
          },
          {
            type: 'click',
            name: '店主微信',
            key:  'NGIRL_MOM',
          }
        ]
      }.to_json


      SSLRestClient.post "https://api.weixin.qq.com/cgi-bin/menu/create?access_token=#{self.access_token}", params
    end
  end
end