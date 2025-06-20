class Theme < ApplicationRecord
  has_many :journals, dependent: :nullify

  validates :name, presence: true, uniqueness: true

  def colors_hash
    return {} unless colors.present?
    JSON.parse(colors)
  rescue JSON::ParserError
    {}
  end

  def colors_hash=(hash)
    self.colors = hash.to_json
  end

  def fonts_hash
    return {} unless fonts.present?
    JSON.parse(fonts)
  rescue JSON::ParserError
    {}
  end

  def fonts_hash=(hash)
    self.fonts = hash.to_json
  end

  def layout_options_hash
    return {} unless layout_options.present?
    JSON.parse(layout_options)
  rescue JSON::ParserError
    {}
  end

  def layout_options_hash=(hash)
    self.layout_options = hash.to_json
  end
end
