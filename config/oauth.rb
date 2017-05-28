Rails.application.config.middleware.use OmniAuth::Builder do
  provider :wechat, ENV["wx_id"], ENV["wx_secret"], authorize_params: {:scope => "snsapi_userinfo"}
end