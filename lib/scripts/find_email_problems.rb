# find_email_problems

User.all.each do |user|
  unless user.email.downcase == user.email
    UserEmailProblem.create(user_id: user.id)
  end
end
