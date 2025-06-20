# frozen_string_literal: true

module BrandingHelper
  # WestEd Brand Component Generator
  # Provides sophisticated helper methods for consistent WestEd branding
  
  def wested_logo(variant: :desktop, **options)
    case variant
    when :desktop
      render_wested_logo(width: 80, height: 24, **options)
    when :mobile
      render_wested_logo(width: 60, height: 18, **options)
    when :sidebar
      render_wested_logo(width: 70, height: 20, **options)
    else
      render_wested_logo(width: 80, height: 24, **options)
    end
  end

  def pondero_branding(variant: :full, **options)
    content_tag :div, class: wested_branding_classes(variant, **options) do
      case variant
      when :full
        concat wested_logo(variant: :desktop)
        concat brand_separator
        concat pondero_title_block
      when :mobile
        concat wested_logo(variant: :mobile)
        concat brand_separator
        concat pondero_title_block(compact: true)
      when :sidebar
        concat wested_logo(variant: :sidebar)
        concat brand_separator
        concat pondero_title_block
      end
    end
  end

  def wested_color_class(color_name, property: :background, opacity: nil)
    base_class = "wested-#{color_name.to_s.dasherize}"
    opacity_suffix = opacity ? "-#{(opacity * 100).to_i}" : ""
    "#{base_class}#{opacity_suffix}"
  end

  def wested_gradient(colors, direction: 135)
    colors_array = colors.map { |color| "var(--wested-#{color.to_s.dasherize})" }
    "background: linear-gradient(#{direction}deg, #{colors_array.join(', ')});"
  end

  def wested_stats_card(title:, value:, icon:, color_scheme: :primary_blue, **options)
    render 'shared/wested_stats_card', 
           title: title, 
           value: value, 
           icon: icon, 
           color_scheme: color_scheme,
           **options
  end

  def wested_navigation_item(text, path, **options)
    active = current_page?(path)
    css_classes = ["nav-item"]
    css_classes << "active" if active
    css_classes << options[:class] if options[:class]

    link_to path, class: css_classes.join(" "), **options.except(:class) do
      concat content_tag(:div, options[:icon], class: "nav-icon") if options[:icon]
      concat content_tag(:span, text, class: "nav-text")
    end
  end

  private

  def render_wested_logo(width:, height:, **options)
    viewbox_width = (width * 2.5).to_i
    viewbox_height = (height * 2.5).to_i
    
    content_tag :svg, 
                width: width, 
                height: height, 
                viewBox: "0 0 #{viewbox_width} #{viewbox_height}",
                xmlns: "http://www.w3.org/2000/svg",
                class: "wested-logo #{options[:class]}".strip do
      
      text_size = (height * 1.2).to_i
      ed_x_position = (width * 0.8).to_i
      circle_center_x = (viewbox_width * 0.75).to_i
      circle_center_y = (viewbox_height * 0.5).to_i
      circle_radius = (height * 0.9).to_i

      concat tag(:text, 
                 x: 0, 
                 y: (viewbox_height * 0.67).to_i,
                 'font-family': "var(--font-family-headers)",
                 'font-size': text_size,
                 'font-weight': "600",
                 fill: "var(--wested-primary-blue)") { "west" }
      
      concat tag(:text,
                 x: ed_x_position,
                 y: (viewbox_height * 0.67).to_i,
                 'font-family': "var(--font-family-headers)",
                 'font-size': text_size,
                 'font-weight': "600", 
                 fill: "var(--wested-primary-green)") { "Ed" }
      
      concat tag(:circle,
                 cx: circle_center_x,
                 cy: circle_center_y,
                 r: circle_radius,
                 fill: "none",
                 stroke: "var(--wested-primary-blue)",
                 'stroke-width': "2")
      
      concat tag(:path,
                 d: build_circle_path(circle_center_x, circle_center_y, circle_radius * 0.8, :bottom),
                 fill: "var(--wested-primary-green)",
                 opacity: "0.7")
      
      concat tag(:path,
                 d: build_circle_path(circle_center_x, circle_center_y, circle_radius * 0.8, :right),
                 fill: "var(--wested-primary-blue)",
                 opacity: "0.6")
    end
  end

  def brand_separator
    content_tag :div, "", class: "brand-separator"
  end

  def pondero_title_block(compact: false)
    content_tag :div, class: "pondero-title-block" do
      concat content_tag(:h1, "Pondero", class: "pondero-title")
      concat content_tag(:p, "Reflective Journaling", class: "pondero-subtitle") unless compact
    end
  end

  def wested_branding_classes(variant, **options)
    base_classes = %w[wested-branding flex items-center]
    
    case variant
    when :full
      base_classes << "space-x-4"
    when :mobile, :sidebar
      base_classes << "space-x-3"
    end
    
    base_classes << options[:class] if options[:class]
    base_classes.join(" ")
  end

  def build_circle_path(cx, cy, radius, segment)
    case segment
    when :bottom
      start_x = cx - radius
      end_x = cx + radius
      "M #{start_x} #{cy} A #{radius} #{radius} 0 0 1 #{end_x} #{cy} A #{radius} #{radius} 0 0 1 #{start_x} #{cy} Z"
    when :right
      start_y = cy - radius
      end_y = cy + radius
      "M #{cx} #{start_y} A #{radius} #{radius} 0 0 1 #{cx} #{end_y} A #{radius} #{radius} 0 0 1 #{cx} #{start_y} Z"
    end
  end
end