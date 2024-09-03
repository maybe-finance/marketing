# == Schema Information
#
# Table name: users
#
#  id                :bigint           not null, primary key
#  admin             :boolean          default(FALSE)
#  confirmed_at      :datetime
#  email             :string           not null
#  password_digest   :string           not null
#  unconfirmed_email :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
class User < ApplicationRecord
  include ReviseAuth::Model
end
