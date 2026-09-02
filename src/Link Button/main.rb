require 'gtk4'
require 'adwaita'

class LinkButtonDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap { |page| page.child = linkbutton }
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.linkbutton', :default_flags)

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Link Button'
      win.set_default_size(560, 420)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Link Button'
      page.description = 'A button with a hyperlink'
    end
  end

  def linkbutton
    @linkbutton ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.LinkButton.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end
end

LinkButtonDemo.new.build.run
