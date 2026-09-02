require 'gtk4'
require 'adwaita'

class HeaderBarDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.titlebar = header_bar
          win.child = status_page

          header_bar.tap do |header|
            header.pack_start(open_button)
            header.pack_start(new_tab_button)
            header.pack_end(main_menu_button)
            header.pack_end(search_button)
          end

          status_page.tap do |page|
            page.child = links_box

            links_box.tap do |box|
              box.append(reference_link)
              box.append(hig_link)
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.headerbar', :default_flags)
  def header_bar = @header_bar ||= Adwaita::HeaderBar.new
  def links_box = @links_box ||= Gtk::Box.new(:vertical, 0)
  def new_tab_button = @new_tab_button ||= Gtk::Button.new.tap { |btn| btn.icon_name = 'tab-new-symbolic' }
  def search_button = @search_button ||= Gtk::Button.new.tap { |btn| btn.icon_name = 'edit-find-symbolic' }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Header Bar'
      win.set_default_size(800, 600)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Header Bar'
      page.description = 'Custom titlebars for windows'
    end
  end

  def open_button
    @open_button ||= Gtk::MenuButton.new.tap do |btn|
      btn.label = 'Open'
      btn.menu_model = open_menu
    end
  end

  def main_menu_button
    @main_menu_button ||= Gtk::MenuButton.new.tap do |btn|
      btn.icon_name = 'open-menu-symbolic'
      btn.tooltip_text = 'Main Menu'
      btn.primary = true
      btn.menu_model = window_menu
    end
  end

  def window_menu
    @window_menu ||= Gio::Menu.new.tap do |menu|
      menu.append_section(nil, Gio::Menu.new.tap do |section|
        section.append('Keyboard Shortcuts', 'app.shortcuts')
        section.append('About App', 'app.about')
      end)
    end
  end

  def open_menu
    @open_menu ||= Gio::Menu.new.tap do |menu|
      menu.append_section(nil, Gio::Menu.new.tap do |section|
        ['Item 1', 'Item 2', 'Item 3'].each { |label| section.append(label, nil) }
      end)
    end
  end

  def reference_link
    @reference_link ||= Gtk::LinkButton.new(
      'https://gnome.pages.gitlab.gnome.org/libadwaita/doc/1.6/class.HeaderBar.html'
    ).tap { |btn| btn.label = 'API Reference' }
  end

  def hig_link
    @hig_link ||= Gtk::LinkButton.new(
      'https://developer.gnome.org/hig/patterns/containers/header-bars.html'
    ).tap { |btn| btn.label = 'Human Interface Guidelines' }
  end
end

HeaderBarDemo.new.build.run
