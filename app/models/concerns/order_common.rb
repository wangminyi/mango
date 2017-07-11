module OrderCommon
  extend ActiveSupport::Concern

  included do
    STAFF_IDS = [2, 3, 4]

    def paid!
      self.update(pay_status: :paid)
      SlackNotifier.notify_order(self)
    end

    def can_abandon?
      %w(finished abandon).exclude? self.status
    end

    def abandon!
      self.update(status: :abandon)
    end

    def can_push_state?
      %w(finished abandon).exclude? self.status
    end

    def next_state!
      if ( _next_state = self.next_state_value).present?
        self.update(status: _next_state)
      end
    end

    # 下一步的状态
    def next_state_value
      options = self.class.status.values
      if (index = options[0...-2].index(self.status)).present?
        options[index + 1]
      end
    end

    # 下一步的文案
    def next_state_text
      options = self.class.status.options
      if (index = options[0...-2].index{|s| s[1] == self.status}).present?
        options[index + 1][0]
      end
    end

    def total_price_yuan
      '%.2f' % (self.total_price / 100.0)
    end

    def distribute_at_text
      "#{self.distribute_at.strftime("%F %H:00")} ~ #{self.distribute_at.since(1.hour).strftime("%H:00")}"
    end
  end
end