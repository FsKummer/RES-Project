require "faker"

PASSWORD = "123123"

Faker::Config.random = Random.new(42)

def seed_user(email:, first_name:, last_name:, nickname:, description:, admin: false, publisher: false, believer: false, converted: false)
  user = User.find_or_initialize_by(email: email)
  user.assign_attributes(
    first_name: first_name,
    last_name: last_name,
    nickname: nickname,
    description: description,
    admin: admin,
    publisher: publisher,
    believer: believer,
    converted: converted
  )
  user.password = PASSWORD if user.new_record?
  user.save!
  user
end

puts "Starting seed..."

base_users = 1_223.times.map do |i|
  user = seed_user(
    email: "flat#{i}@flat.com",
    first_name: "Flat#{i}",
    last_name: "Flat#{i}x",
    nickname: "flat_#{i}",
    description: "flat_earther_#{i}",
    converted: true
  )

  puts "Seeded #{i + 1} base users" if (i + 1) % 100 == 0 || i == 1_222
  user
end

admin_profiles = [
  ["Marie", "Curie", "marie_curie", "Round Earth Society administrator and Nobel Prize-winning physicist"],
  ["Albert", "Einstein", "albert_einstein", "Round Earth Society administrator and theoretical physicist"]
]

admins = admin_profiles.each_with_index.map do |(first_name, last_name, nickname, description), i|
  seed_user(
    email: "admin#{i + 1}@example.com",
    first_name: first_name,
    last_name: last_name,
    nickname: nickname,
    description: description,
    admin: true,
    believer: true,
    converted: true
  )
end

publisher_profiles = [
  ["Neil", "deGrasse Tyson", "neil_degrasse", "Astrophysicist and science communicator"],
  ["Carl", "Sagan", "carl_sagan", "Astronomer and science communicator"],
  ["Stephen", "Hawking", "stephen_hawking", "Theoretical physicist and cosmologist"],
  ["Richard", "Feynman", "richard_feynman", "Physicist known for quantum electrodynamics"],
  ["Galileo", "Galilei", "galileo_galilei", "Astronomer and physicist"],
  ["Isaac", "Newton", "isaac_newton", "Mathematician and physicist"],
  ["Charles", "Darwin", "charles_darwin", "Naturalist and evolutionary theorist"],
  ["Nikola", "Tesla", "nikola_tesla", "Inventor and electrical engineer"]
]

publishers = publisher_profiles.each_with_index.map do |(first_name, last_name, nickname, description), i|
  seed_user(
    email: "publisher#{i + 1}@example.com",
    first_name: first_name,
    last_name: last_name,
    nickname: nickname,
    description: description,
    publisher: true,
    believer: true,
    converted: true
  )
end

requesters = 10.times.map do |i|
  seed_user(
    email: "requester#{i + 1}@example.com",
    first_name: "Requester",
    last_name: (i + 1).to_s,
    nickname: "requester_#{i + 1}",
    description: "Member requesting publisher access #{i + 1}",
    believer: i.even?,
    converted: i.even?
  )
end

categories = %w[
  Science
  Culture
  Debate
  History
  Technology
].map { |name| Category.find_or_create_by!(name: name) }

requesters.each_with_index do |requester, index|
  request = Request.find_or_initialize_by(user: requester)
  request.assign_attributes(
    content: Faker::Lorem.paragraph(sentence_count: 3),
    accepted: false
  )
  request.save!
  puts "Seeded publisher request #{index + 1}"
end

80.times do |i|
  article_number = i + 1
  source_url = "https://example.com/articles/#{article_number}"
  article = Article.find_or_initialize_by(source_url: source_url)
  body = Faker::Lorem.paragraphs(number: 5).map { |paragraph| "<p>#{paragraph}</p>" }.join

  article.assign_attributes(
    title: "Seed Article #{article_number.to_s.rjust(2, '0')}",
    subtitle: Faker::Lorem.sentence(word_count: 8),
    content: ActionView::Base.full_sanitizer.sanitize(body),
    accepted: article_number <= 50,
    source_url: source_url,
    sources: "Round Earth Society Archive",
    user: publishers[i % publishers.length],
    category: categories[i % categories.length],
    rich_body: body
  )
  article.save!

  puts "Seeded article #{article_number}" if article_number % 10 == 0
end

forum_users = (base_users.first(10) + requesters.first(4) + publishers.first(4)).compact

previous_moderation_word = %w[mier da].join
Reply.where("LOWER(content) LIKE ?", "%#{previous_moderation_word}%").destroy_all
Message.where("LOWER(content) LIKE ?", "%#{previous_moderation_word}%").destroy_all

forum_topic_data = [
  ["How do we explain day and night?", "Collecting clear explanations for beginners who ask why the sun appears to move."],
  ["Best evidence for a spherical earth", "Share reliable observations that are easy to reproduce or understand."],
  ["Is the horizon always flat?", "Discuss what people see at sea level, on mountains, and from airplanes."],
  ["Satellite photos discussion", "Compare official imagery, live feeds, and common objections."],
  ["Flight paths and great circles", "Use airline routes to talk about distances and map projections."],
  ["Ask a publisher about gravity", "A place for members to ask publishers about gravity and everyday experiments."]
]

topics = forum_topic_data.each_with_index.to_h do |(title, description), index|
  topic = Topic.find_or_initialize_by(title: title)
  topic.assign_attributes(
    description: description,
    user: forum_users[index % forum_users.length]
  )
  topic.save!

  puts "Seeded forum topic #{index + 1}"
  [title, topic]
end

forum_reply_data = [
  ["How do we explain day and night?", 1, "A lamp and globe demo is still the fastest way to make the rotation idea visible."],
  ["How do we explain day and night?", 2, "Time zones are also useful because they force people to reason about local noon."],
  ["How do we explain day and night?", 3, "This question is basic, but it is worth answering calmly with diagrams."],
  ["Best evidence for a spherical earth", 4, "Lunar eclipses are persuasive because the shadow stays round from different angles."],
  ["Best evidence for a spherical earth", 5, "No seas idiota, that flat earth argument is complete groseria."],
  ["Best evidence for a spherical earth", 6, "Ship visibility tests can be helpful if the observer records height and distance carefully."],
  ["Is the horizon always flat?", 7, "At ground level the curve is subtle, so photos need context and lens information."],
  ["Is the horizon always flat?", 8, "Your horizon claim is groseria and you keep repeating it like an idiot."],
  ["Is the horizon always flat?", 9, "A better exercise is comparing horizon distance from a beach and a high building."],
  ["Satellite photos discussion", 10, "I would start with weather satellite loops because they are updated constantly."],
  ["Satellite photos discussion", 11, "Anyone who trusts those pictures is talking groseria."],
  ["Satellite photos discussion", 12, "There are good questions about image processing, but they need sources and specifics."],
  ["Flight paths and great circles", 13, "Great circle routes are easier to see if we compare the same trip on different projections."],
  ["Flight paths and great circles", 14, "Look at southern hemisphere flights and compare scheduled duration against distance."],
  ["Ask a publisher about gravity", 15, "A pendulum discussion could work well if we keep the setup simple."],
  ["Ask a publisher about gravity", 16, "This gravity explanation is groseria and the publisher should be embarrassed."]
]

replies = forum_reply_data.each_with_index.map do |(topic_title, author_index, content), index|
  reply = Reply.find_or_initialize_by(
    topic: topics.fetch(topic_title),
    user: forum_users[author_index % forum_users.length],
    content: content
  )
  reply.save!

  puts "Seeded forum reply #{index + 1}" if (index + 1) % 4 == 0
  reply
end

forum_comment_data = [
  [0, 5, "This is a good demo for a classroom setting."],
  [1, 6, "Time zones are a strong console-query example too."],
  [4, 7, "This comment should be removed because the tone is not acceptable."],
  [7, 8, "Agreed, that reply is too aggressive for the forum."],
  [10, 9, "Please delete this kind of message before it derails the thread."],
  [15, 10, "The science question is fine, but the insult should go."]
]

forum_comment_data.each_with_index do |(reply_index, author_index, content), index|
  comment = Comment.find_or_initialize_by(
    reply: replies.fetch(reply_index),
    user: forum_users[author_index % forum_users.length],
    content: content
  )
  comment.save!

  puts "Seeded forum comment #{index + 1}"
end

chatroom = Chatroom.find_or_create_by!(name: "Moderation Practice")

chat_message_data = [
  [0, "Can someone point me to the latest publisher article about satellites?"],
  [1, "I am comparing airline routes and want a second opinion."],
  [2, "This chatroom is useful for quick moderation checks."],
  [3, "No seas idiota, your whole explanation is groseria."],
  [4, "Please keep the conversation focused on evidence."],
  [5, "The horizon thread has a few replies worth reviewing."],
  [6, "That source looks interesting. Can you add the link?"],
  [7, "Your argument is pura groseria and nobody should waste time on it."],
  [8, "I found a clear diagram for the day and night topic."],
  [9, "Maybe we should move detailed article feedback to the dashboard."],
  [10, "Stop posting this groseria in every topic."],
  [11, "Can an admin check whether that message crosses the line?"]
]

chat_message_data.each_with_index do |(author_index, content), index|
  message = Message.find_or_initialize_by(
    chatroom: chatroom,
    user: forum_users[author_index % forum_users.length],
    content: content
  )
  message.save!

  puts "Seeded chat message #{index + 1}" if (index + 1) % 4 == 0
end

puts "Seed complete:"
puts "- Base users: #{base_users.count}"
puts "- Admins: #{admins.count}"
puts "- Publishers: #{publishers.count}"
puts "- Pending publisher requests: #{Request.where(accepted: false).count}"
puts "- Articles: #{Article.count} total, #{Article.where(accepted: true).count} approved, #{Article.where(accepted: false).count} pending"
puts "- Forum topics: #{Topic.count} total, #{Reply.count} replies, #{Comment.count} comments"
puts "- Chatrooms: #{Chatroom.count} total, #{Message.count} messages"
