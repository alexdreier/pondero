class Journal < ApplicationRecord
  belongs_to :user
  belongs_to :theme, optional: true
  has_many :sections, -> { order(:position) }, dependent: :destroy
  has_many :questions, -> { order(:position) }, dependent: :destroy
  has_many :journal_submissions, dependent: :destroy
  has_many :journal_entries, dependent: :destroy
  has_many :responses, through: :questions

  validates :title, presence: true
  validates :position, presence: true, uniqueness: { scope: :user_id }
  validates :canvas_course_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: 'must be a valid URL' }, allow_blank: true

  scope :published, -> { where(published: true) }
  scope :available, -> { where('available_from <= ? AND (available_until IS NULL OR available_until >= ?)', Time.current, Time.current) }
  scope :canvas_enabled, -> { where(lti_enabled: true) }
  scope :assigned_to_canvas_course, ->(course_id) { where(canvas_course_id: course_id) }

  enum :status, {
    draft: 'draft',
    published: 'published',
    archived: 'archived'
  }

  enum :visibility, {
    private_access: 'private',        # Only visible to creator and assigned users
    public_access: 'public',          # Visible to all users in the system
    unlisted: 'unlisted'       # Accessible via direct link but not listed publicly
  }

  enum :access_level, {
    restricted: 'restricted',   # Only assigned users can respond
    open: 'open',              # Anyone with access can respond
    read_only: 'read_only'     # Anyone can view but only assigned users can respond
  }

  def available?
    published? && 
    (available_from.nil? || available_from <= Time.current) &&
    (available_until.nil? || available_until >= Time.current)
  end

  def submission_for(user)
    journal_submissions.find_by(user: user)
  end

  def can_be_template?
    published? && questions.any?
  end

  def visible_to?(user)
    return true if user == self.user  # Creator can always see
    return true if user.administrator?        # Admins can see all
    
    case visibility
    when 'public_access'
      published?
    when 'unlisted'
      published?  # Accessible if they have the link
    when 'private_access'
      false       # Only creator and admins
    else
      false
    end
  end

  def accessible_to?(user)
    return false unless visible_to?(user)
    return true if user == self.user || user.administrator?
    
    case access_level
    when 'open'
      true
    when 'read_only'
      true  # Can view but response creation is controlled separately
    when 'restricted'
      # Check if user is specifically assigned (would need a separate assignment model)
      false
    else
      false
    end
  end

  def can_respond?(user)
    return true if user == self.user || user.administrator?
    return false unless published? && visible_to?(user)
    
    case access_level
    when 'open'
      true
    when 'read_only'
      false  # Only assigned users can respond in read-only mode
    when 'restricted'
      # Check if user is specifically assigned (would need a separate assignment model)
      false
    else
      false
    end
  end

  def copy_for_user(user, new_title = nil)
    new_journal = self.dup
    new_journal.title = new_title || "Copy of #{self.title}"
    new_journal.user = user
    new_journal.published = false
    new_journal.status = 'draft'
    new_journal.position = user.journals.count + 1
    new_journal.available_from = nil
    new_journal.available_until = nil
    
    ActiveRecord::Base.transaction do
      new_journal.save!
      
      # Copy all sections first
      section_mapping = {}
      self.sections.order(:position).each do |section|
        new_section = section.dup
        new_section.journal = new_journal
        new_section.save!
        
        # Copy rich text content for section
        if section.description.present?
          new_section.description = section.description
          new_section.save!
        end
        
        section_mapping[section.id] = new_section
      end
      
      # Copy all questions with their rich text content
      self.questions.order(:position).each do |question|
        new_question = question.dup
        new_question.journal = new_journal
        new_question.section = section_mapping[question.section_id] if question.section_id
        new_question.save!
        
        # Copy rich text content
        if question.content.present?
          new_question.content = question.content
        end
        if question.description.present?
          new_question.description = question.description
        end
        new_question.save!
      end
    end
    
    new_journal
  end

  # Canvas LTI Integration Methods
  def assigned_to_canvas_course?
    canvas_course_id.present?
  end

  def canvas_course_display
    return 'Not assigned to a Canvas course' unless assigned_to_canvas_course?
    canvas_course_name.present? ? canvas_course_name : "Canvas Course ##{canvas_course_id}"
  end

  def assign_to_canvas_course(course_id, course_url = nil, course_name = nil)
    self.canvas_course_id = course_id
    self.canvas_course_url = course_url if course_url.present?
    self.canvas_course_name = course_name if course_name.present?
    self.lti_enabled = true
    
    # Extract course ID from URL if not provided but URL is given
    if course_id.blank? && course_url.present?
      extracted_id = extract_course_id_from_url(course_url)
      self.canvas_course_id = extracted_id if extracted_id.present?
    end
    
    save
  end

  def remove_canvas_assignment
    self.canvas_course_id = nil
    self.canvas_course_url = nil
    self.canvas_course_name = nil
    self.canvas_assignment_id = nil
    self.lti_enabled = false
    save
  end

  def canvas_launch_url
    return nil unless assigned_to_canvas_course?
    # This would be the LTI launch URL for this journal
    begin
      host = Rails.application.routes.default_url_options[:host] || 'localhost:3000'
      protocol = Rails.env.production? ? 'https' : 'http'
      "#{protocol}://#{host}/lti/launch?custom_journal_id=#{id}"
    rescue => e
      # Fallback if URL generation fails
      Rails.logger.error "Failed to generate Canvas launch URL: #{e.message}"
      "/lti/launch?custom_journal_id=#{id}"
    end
  end

  private

  def extract_course_id_from_url(url)
    # Extract course ID from Canvas URL patterns like:
    # https://institution.instructure.com/courses/123456
    # https://canvas.institution.edu/courses/123456
    match = url.match(%r{/courses/(\d+)})
    match[1] if match
  end
end
