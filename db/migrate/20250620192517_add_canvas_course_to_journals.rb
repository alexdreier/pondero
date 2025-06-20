class AddCanvasCourseToJournals < ActiveRecord::Migration[8.0]
  def change
    add_column :journals, :canvas_course_id, :string, comment: 'Canvas LMS Course ID'
    add_column :journals, :canvas_course_url, :text, comment: 'Full Canvas Course URL'
    add_column :journals, :canvas_course_name, :string, comment: 'Canvas Course Display Name'
    add_column :journals, :canvas_assignment_id, :string, comment: 'Canvas Assignment ID if created as assignment'
    add_column :journals, :lti_enabled, :boolean, default: false, comment: 'Whether this journal supports LTI integration'
    
    add_index :journals, :canvas_course_id
    add_index :journals, :lti_enabled
  end
end
