class WxController < ApplicationController
  def notify
    result = Hash.from_xml(request.body.read)["xml"]

    if WxPay::Sign.verify?(result)
      order = Order.find(result["out_trade_no"])

      if order.total_price == result["total_fee"]
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
    openid = omniauth[:extra][:raw_info][:openid]
    user = User.find_or_initialize_by(open_id: openid)
    if user.new_record?
      user.password = SecureRandom.hex(10)
      user.save!
    end
    sign_in user
    redirect_to stored_location_for(:user) || root_path
  end

  def oauth_failure
    head 404
  end
end
