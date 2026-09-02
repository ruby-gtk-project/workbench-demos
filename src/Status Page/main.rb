require 'gtk4'
require 'adwaita'

class StatusPageDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

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

  def app = @app ||= Gtk::Application.new('org.example.statuspage', :default_flags)

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Status Page'
      win.set_default_size(560, 520)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Status Page'
      page.description = 'A page used for empty/error states and similar use-cases'
      page.icon_name = 'help-about-symbolic'
    end
  end

  def links_box
    @links_box ||= Gtk::Box.new(:vertical, 0).tap do |box|
      box.margin_top = 18
      box.halign = :center
    end
  end

  def reference_link
    @reference_link ||= Gtk::LinkButton.new(
      'https://gnome.pages.gitlab.gnome.org/libadwaita/doc/1.6/class.StatusPage.html'
    ).tap { |btn| btn.label = 'API Reference' }
  end

  def hig_link
    @hig_link ||= Gtk::LinkButton.new(
      'https://developer.gnome.org/hig/patterns/feedback/placeholders.html'
    ).tap { |btn| btn.label = 'Human Interface Guidelines' }
  end
end

StatusPageDemo.new.build.run
