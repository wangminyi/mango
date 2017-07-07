class WxController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:notify]

  def notify
    result = Hash.from_xml(request.body.read)["xml"]

    if WxPay::Sign.verify?(result)
      order_class = result["out_trade_no"][-9] == "0" ? Order : WholesaleOrder
      order = order_class.find_by(order_no: result["out_trade_no"])

      if order.total_price == result["total_fee"].to_i
        order.paid!
      else
        # notify
      end

      render :xml => {return_code: "SUCCESS"}.to_xml(root: 'xml', dasherize: false)
    else
      render :xml => {return_code: "FAIL", return_msg: "签名失败"}.to_xml(root: 'xml', dasherize: false)
    end
  end

  def oauth_callback
    omniauth = request.env["omniauth.auth"]
    if (openid = omniauth[:extra][:raw_info][:openid]).present?
      user = User.find_or_initialize_by(open_id: openid)
      if user.new_record?
        user.password = SecureRandom.hex(10)
        user.assign_attributes(
          nickname: omniauth[:extra][:raw_info][:nickname],
          user_name: omniauth[:extra][:raw_info][:headimgurl],
        )
        begin
          user.save!
        rescue
          user.nickname = nil
          user.save!
        end
      end
      sign_in user
      user.history_logs.create(
        action: :sign_in,
      )
      redirect_to stored_location_for(:user) || root_path
    else
      SlackNotifier.notify(omniauth.to_json)
      redirect_to 404
    end
  end

  def oauth_failure
    head 404
  end
end
