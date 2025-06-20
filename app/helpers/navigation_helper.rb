module NavigationHelper
  def wested_navigation_classes(variant)
    base_classes = %w[wested-navigation]
    
    case variant
    when :desktop
      base_classes += %w[hidden lg:flex lg:flex-shrink-0 lg:w-80]
    when :mobile_header
      base_classes += %w[bg-white border-b border-gray-200 lg:hidden]
    when :mobile_overlay
      base_classes += %w[flex flex-col max-w-xs w-full bg-white]
    end
    
    base_classes.join(" ")
  end

  def navigation_header_classes(variant)
    base_classes = %w[navigation-header]
    
    case variant
    when :desktop, :mobile_overlay
      base_classes += %w[flex items-center h-16 px-6 bg-white border-r border-gray-200 shadow-sm]
    when :mobile_header
      base_classes += %w[flex items-center justify-between h-16 px-4]
    end
    
    if variant == :mobile_overlay
      base_classes += %w[justify-between border-b]
    end
    
    base_classes.join(" ")
  end

  def navigation_content_classes(variant)
    base_classes = %w[navigation-content]
    
    case variant
    when :desktop
      base_classes += %w[flex-1 flex flex-col bg-white border-r border-gray-200]
    when :mobile_overlay
      base_classes += %w[flex-1 flex flex-col pb-4 overflow-y-auto]
    end
    
    base_classes.join(" ")
  end

  def navigation_links_container_classes
    %w[flex-1].join(" ")
  end

  def navigation_branding_variant(nav_variant)
    case nav_variant
    when :desktop
      :full
    when :mobile_header
      :mobile
    when :mobile_overlay
      :sidebar
    else
      :full
    end
  end

  def navigation_items_for_user(user)
    [
      {
        text: "Dashboard",
        path: root_path,
        icon: '<i class="fas fa-tachometer-alt"></i>'.html_safe,
        roles: [:all]
      },
      {
        text: "Journals", 
        path: journals_path,
        icon: '<i class="fas fa-book-open"></i>'.html_safe,
        roles: [:all]
      }
    ].select { |item| item[:roles].include?(:all) || (user && item[:roles].include?(user.role&.to_sym)) }
  end

  def instructor_navigation_items
    [
      {
        text: "Templates",
        path: templates_journals_path,
        icon: '<i class="fas fa-clipboard-list"></i>'.html_safe
      },
      {
        text: "Analytics",
        path: analytics_path,
        icon: '<i class="fas fa-chart-bar"></i>'.html_safe
      }
    ]
  end

  def admin_navigation_items
    [
      {
        text: "Users",
        path: admin_users_path,
        icon: '<i class="fas fa-users"></i>'.html_safe
      },
      {
        text: "Themes",
        path: themes_path,
        icon: '<i class="fas fa-palette"></i>'.html_safe
      }
    ]
  end
end