require 'gtk4'
require 'adwaita'

class WindowDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = toolbar_view

          toolbar_view.tap do |view|
            view.add_top_bar(header_bar)
            view.content = status_page

            header_bar.tap { |bar| bar.pack_end(button_menu) }

            status_page.tap do |page|
              page.child = links_box

              links_box.tap do |box|
                box.append(reference_link)
                box.append(hig_link)
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.window', :default_flags)
  def toolbar_view = @toolbar_view ||= Adwaita::ToolbarView.new
  def header_bar = @header_bar ||= Adwaita::HeaderBar.new
  def links_box = @links_box ||= Gtk::Box.new(:vertical, 0)

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'My App'
      win.set_default_size(800, 600)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'My App'
      page.description = 'My App is awesome'
      page.icon_name = 'applications-science-symbolic'
    end
  end

  def button_menu
    @button_menu ||= Gtk::MenuButton.new.tap do |btn|
      btn.menu_model = menu_app
      btn.icon_name = 'open-menu-symbolic'
      btn.primary = true
    end
  end

  def menu_app
    @menu_app ||= Gio::Menu.new.tap do |menu|
      menu.append_section(nil, Gio::Menu.new.tap do |section|
        section.append('Keyboard Shortcuts', 'app.shortcuts')
        section.append('About My App', 'app.about')
      end)
    end
  end

  def reference_link
    @reference_link ||= Gtk::LinkButton.new(
      'https://gnome.pages.gitlab.gnome.org/libadwaita/doc/1.6/class.ApplicationWindow.html'
    ).tap { |btn| btn.label = 'API Reference' }
  end

  def hig_link
    @hig_link ||= Gtk::LinkButton.new(
      'https://developer.gnome.org/hig/patterns/containers/windows.html'
    ).tap { |btn| btn.label = 'Human Interface Guidelines' }
  end
end

WindowDemo.new.build.run
