class Conversation < ApplicationRecord
  belongs_to :group_chat, polymorphic: true
  has_many :conversation_members, dependent: :destroy
end
