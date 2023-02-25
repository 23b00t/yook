class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_many :created_ingredients, class_name: "Ingredient", foreign_key: "creator_id"
  has_many :user_ingredients, dependent: :destroy
  has_many :recipes, dependent: :destroy
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
