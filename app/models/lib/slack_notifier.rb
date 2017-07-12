class SlackNotifier
  def self.notify content
    retry_time = 0
    @notifier ||= Slack::Notifier.new "https://hooks.slack.com/services/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", username: "来bug喽！", channel: "yylife"
    begin
      @notifier.ping "#{Rails.env}: #{content}" unless Rails.env.development?
    rescue
      if retry_time < 3
        retry_time += 1
        retry
      end
    end
  end

  def self.notify_order order
    retry_time = 0
    @order_notifier ||= Slack::Notifier.new "https://hooks.slack.com/services/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", username: "来订单喽！", channel: "order"
    begin
      content = [
        "ID: #{order.id}",
        "金额: #{order.total_price_yuan}",
        "姓名: #{order.receiver_name}",
        "地址: #{order.receiver_address}",
        "电话：#{order.receiver_phone}",
        "备注：#{order.remark}",
      ].join("\n")
      @order_notifier.ping content unless Rails.env.development?
    rescue
      if retry_time < 3
        retry_time += 1
        retry
      end
    end
  end
end