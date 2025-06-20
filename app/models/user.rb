class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, {
    learner: 'learner',
    instructor: 'instructor', 
    administrator: 'administrator'
  }

  # Associations
  has_many :journals, dependent: :destroy  # Journals created by instructors/admins
  has_many :journal_submissions, dependent: :destroy  # Learner's submissions
  has_many :responses, dependent: :destroy
  has_many :comments, dependent: :destroy

  validates :role, presence: true
  validates :first_name, :last_name, presence: true

  def full_name
    "#{first_name} #{last_name}"
  end

  def display_name
    full_name.present? ? full_name : email
  end

  def learner?
    role == 'learner'
  end

  def instructor?
    role == 'instructor'
  end

  def administrator?
    role == 'administrator'
  end

  def can_create_journals?
    instructor? || administrator?
  end

  def can_manage_users?
    administrator?
  end
end
