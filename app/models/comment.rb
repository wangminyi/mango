class Comment < ApplicationRecord
  extend Enumerize

  enumerize :status, in: [
    :visible,
    :invisible
  ], scope: true, default: :visible

  belongs_to :article
end
