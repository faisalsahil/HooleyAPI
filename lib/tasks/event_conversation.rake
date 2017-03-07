task :event_conversations => :environment do
  Event.all.each do |event|
    count = 1
    conversation = event.build_conversation
    conversation.conversation_members.build(user_id: event.member_profile.user.id, is_conversation_admin: true)
    members = event.event_members
    members && members.each do |member|
      conversation.conversation_members.build(user_id: MemberProfile.find_by_id(member.member_profile_id).user.id)
      count  = count + 1
    end
    conversation.conversation_members_count =  count
    conversation.save!
  end
end