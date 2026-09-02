require 'gtk4'
require 'adwaita'

class MenuButtonDemo
  DIRECTIONS = ['Up', 'Down', 'Left', 'Right', 'None'].freeze

  LEARN_LINKS = {
    'Developer Documentation' => 'https://developer.gnome.org/documentation/index.html',
    'Human Interface Guidelines' => 'https://developer.gnome.org/hig/',
    'JavaScript' => 'https://gjs.guide',
    'Vala' => 'https://wiki.gnome.org/Projects/Vala',
    'Rust' => 'https://gtk-rs.org',
    'Blueprint' => 'https://gnome.pages.gitlab.gnome.org/blueprint-compiler/'
  }.freeze

  HELP_LINKS = {
    'Discourse' => 'https://discourse.gnome.org/c/platform/5',
    'Matrix' => 'https://matrix.to/#/#workbench:gnome.org'
  }.freeze

  PLATFORM_TOOLS = {
    'Adwaita Demo' => 'adwaita-1-demo',
    'GTK Demo' => 'gtk4-demo',
    'GTK Widget Factory' => 'gtk4-widget-factory'
  }.freeze

  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = clamp

            clamp.tap do |c|
              c.child = content_box

              content_box.tap do |b|
                b.append(primary)
                b.append(primary_title)
                b.append(primary_subtitle)
                b.append(secondary)
                b.append(secondary_title)
                b.append(secondary_subtitle)
                b.append(list_box)
                b.append(hig_link)
                b.append(reference_link)

                list_box.tap do |list|
                  list.append(direction_row)
                  list.append(circular_switch)

                  direction_row.tap do |row|
                    row.signal_connect('notify::selected') { secondary.direction = row.selected }
                  end

                  circular_switch.tap do |row|
                    row.signal_connect('notify::active') do
                      if row.active?
                        secondary.add_css_class('circular')
                      else
                        secondary.remove_css_class('circular')
                      end
                    end
                  end
                end
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.menubutton', :default_flags)
  def clamp = @clamp ||= Adwaita::Clamp.new.tap { |c| c.maximum_size = 500 }
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 6)

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Menu Button'
      win.set_default_size(640, 820)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Menu Button'
      page.description = 'Displays a popover on button click'
    end
  end

  def primary
    @primary ||= Gtk::MenuButton.new.tap do |btn|
      btn.halign = :center
      btn.icon_name = 'open-menu-symbolic'
      btn.menu_model = primary_button_menu
      btn.primary = true
    end
  end

  def secondary
    @secondary ||= Gtk::MenuButton.new.tap do |btn|
      btn.halign = :center
      btn.margin_top = 18
      btn.icon_name = 'view-more-symbolic'
      btn.menu_model = secondary_button_menu
    end
  end

  def primary_title = @primary_title ||= title('Primary Menu Button')
  def secondary_title = @secondary_title ||= title('Secondary Menu Button')

  def primary_subtitle
    @primary_subtitle ||= Gtk::Label.new('Displays an app-wide menu with standard features')
  end

  def secondary_subtitle
    @secondary_subtitle ||= Gtk::Label.new(
      'Displays view-specific items, typically used with hierarchical navigation and sidebars'
    ).tap do |label|
      label.wrap = true
      label.justify = :center
    end
  end

  def list_box
    @list_box ||= Gtk::ListBox.new.tap do |list|
      list.margin_top = 18
      list.selection_mode = :none
      list.add_css_class('boxed-list')
    end
  end

  def direction_row
    @direction_row ||= Adwaita::ComboRow.new.tap do |row|
      row.title = 'Direction'
      row.model = Gtk::StringList.new(DIRECTIONS)
    end
  end

  def circular_switch = @circular_switch ||= Adwaita::SwitchRow.new.tap { |row| row.title = 'Circular' }

  def primary_button_menu
    @primary_button_menu ||= Gio::Menu.new.tap do |menu|
      menu.append_section(nil, Gio::Menu.new.tap do |section|
        section.append_submenu('Bookmarks', bookmarks_menu)
        section.append('Icon Library', 'app.icon_library')
        section.append_submenu('Platform Tools', platform_tools_menu)
      end)

      menu.append('Documentation', 'app.documentation')

      menu.append_section(nil, Gio::Menu.new.tap do |section|
        section.append('Keyboard Shortcuts', 'app.shortcuts')
        section.append('About Workbench', 'app.about')
      end)
    end
  end

  def bookmarks_menu
    @bookmarks_menu ||= Gio::Menu.new.tap do |menu|
      menu.append_section('Learn', uri_section(LEARN_LINKS))
      menu.append_section('Get Help', uri_section(HELP_LINKS))
    end
  end

  def platform_tools_menu
    @platform_tools_menu ||= Gio::Menu.new.tap do |menu|
      PLATFORM_TOOLS.each { |label, tool| menu.append(label, "app.platform_tools::#{tool}") }
    end
  end

  def secondary_button_menu
    @secondary_button_menu ||= Gio::Menu.new.tap do |menu|
      ['Item 1', 'Item 2', 'Item 3'].each { |label| menu.append(label, nil) }
    end
  end

  def hig_link
    @hig_link ||= Gtk::LinkButton.new('https://developer.gnome.org/hig/patterns/controls/menus.html').tap do |btn|
      btn.label = 'Human Interface Guidelines'
    end
  end

  def reference_link
    @reference_link ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.MenuButton.html').tap do |btn|
      btn.label = 'Menu Button API Reference'
    end
  end

  private

  def title(text)
    Gtk::Label.new(text).tap { |label| label.add_css_class('title-4') }
  end

  def uri_section(links)
    Gio::Menu.new.tap do |section|
      links.each { |label, uri| section.append(label, "app.open_uri::#{uri}") }
    end
  end
end

MenuButtonDemo.new.build.run
