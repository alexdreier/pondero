class FeedbackNotificationJob < ApplicationJob
  queue_as :default

  def perform(response_feedback, notification_type)
    return unless response_feedback.is_a?(ResponseFeedback)
    
    case notification_type.to_sym
    when :instructor_feedback
      notify_student_of_instructor_feedback(response_feedback)
    when :student_replied
      notify_instructor_of_student_reply(response_feedback)
    end
  end

  private

  def notify_student_of_instructor_feedback(feedback)
    student = feedback.student
    return unless student.notify_on_feedback?
    
    # For now, we'll just log. In future, send email
    Rails.logger.info "🔔 Notification: Student #{student.email} received feedback on response #{feedback.response_id}"
    
    # TODO: Implement email notification
    # FeedbackMailer.instructor_feedback(feedback).deliver_now
  end

  def notify_instructor_of_student_reply(feedback)
    # Find all instructors who have given feedback on this response
    response = feedback.response
    instructors = response.feedback_authors.where(role: ['instructor', 'administrator']).distinct
    
    instructors.each do |instructor|
      next unless instructor.notify_on_feedback_reply?
      
      # For now, we'll just log. In future, send email
      Rails.logger.info "🔔 Notification: Instructor #{instructor.email} - student replied to feedback on response #{response.id}"
      
      # TODO: Implement email notification
      # FeedbackMailer.student_reply(feedback, instructor).deliver_now
    end
  end
end
