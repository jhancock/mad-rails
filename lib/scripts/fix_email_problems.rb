# fix email problems 

def fix_email_problem(user_id)
  user = User.find(user_id)
  if user
    # find other user that may be in conflict
    other_user = User.find_by(email: user.email.downcase)
    if other_user && (user.id != other_user.id)
      # merge user accounts...delete problem account
      # other_user is the account to keep
      if other_user.premium_to && user.premium_to
        other_user.premium_to = user.premium_to if user.premium_to > other_user.premium_to
        other_user.save
      end
      user.delete
    else # no user with downcased email
      user.set(email: user.email.downcase)
    end
  end
end

UserEmailProblem.all.each do |user_email_problem|
  fix_email_problem(user_email_problem.user_id)
  user_email_problem.delete
end
