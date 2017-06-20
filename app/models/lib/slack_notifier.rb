class SlackNotifier
  def self.notify content
    retry_time = 0
    @notifier ||= Slack::Notifier.new "https://hooks.slack.com/services/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", username: "来bug喽！", channel: "yylife"
    begin
      @notifier.ping "#{Rails.env}: #{content}"
    rescue
      if retry_time < 3
        retry_time += 1
        retry
      end
    end
  end
end