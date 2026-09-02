require 'gtk4'
require 'adwaita'
# requiring gtksourceview5 initialises GtkSource; there is no GtkSource.init.
require 'gtksourceview5'

class SourceViewDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(scrolled_window)
              b.append(documentation_link)

              scrolled_window.tap { |sw| sw.child = source_view }
            end
          end
        end

        # The buffer holds the text shown in the source view.
        buffer.tap do |b|
          b.language = GtkSource::LanguageManager.default.get_language('js')
          b.text = 'console.log("Hello World!");'
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.sourceview', :default_flags)
  def buffer = @buffer ||= GtkSource::Buffer.new
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0).tap { |box| box.halign = :center }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Source View'
      win.set_default_size(720, 560)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Source View'
      page.description = 'Widget that enables text-editing with advanced features like syntax highlighting'
    end
  end

  def scrolled_window
    @scrolled_window ||= Gtk::ScrolledWindow.new.tap do |sw|
      sw.set_size_request(600, 180)
      sw.has_frame = true
    end
  end

  def source_view
    @source_view ||= GtkSource::View.new(buffer).tap do |view|
      view.auto_indent = true
      view.indent_width = 2
      view.show_line_numbers = true
      view.monospace = true
    end
  end

  def documentation_link
    @documentation_link ||= Gtk::LinkButton.new(
      'https://gnome.pages.gitlab.gnome.org/gtksourceview/gtksourceview5/'
    ).tap { |btn| btn.label = 'Documentation' }
  end
end

SourceViewDemo.new.build.run
