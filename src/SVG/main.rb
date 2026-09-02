require 'gtk4'
require 'adwaita'

# librsvg has no Ruby gem; its namespace comes straight from the typelib.
module Rsvg
  GObjectIntrospection::Loader.load('Rsvg', self)
end

class SvgDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(drawing_area)
              b.append(documentation_link)

              drawing_area.tap do |area|
                area.set_draw_func { |_, cr, width, height| draw(cr, width, height) }
              end
            end
          end
        end

        report_intrinsic_size

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.svg', :default_flags)
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0).tap { |box| box.halign = :center }
  # rsvg_handle_new_from_file is not bound; the GFile constructor is.
  def handle = @handle ||= Rsvg::Handle.new(Gio::File.new_for_path(File.join(__dir__, 'image.svg')), 0, nil)

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'SVG'
      win.set_default_size(560, 520)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'SVG'
      page.description = 'Display vectorial images at arbitrary sizes'
    end
  end

  def drawing_area
    @drawing_area ||= Gtk::DrawingArea.new.tap { |area| area.set_size_request(128, 128) }
  end

  def documentation_link
    @documentation_link ||= Gtk::LinkButton.new(
      'https://gnome.pages.gitlab.gnome.org/librsvg/Rsvg-2.0/index.html'
    ).tap { |btn| btn.label = 'Librsvg documentation' }
  end

  private

  def report_intrinsic_size
    _known, width, height = handle.intrinsic_size_in_pixels
    puts "SVG intrisic size #{{ width: width, height: height }}"
  end

  def draw(cr, width, height)
    puts "drawing SVG at #{{ width: width, height: height }}"
    handle.render_document(cr, Rsvg::Rectangle.new.tap do |rectangle|
      rectangle.x = 0
      rectangle.y = 0
      rectangle.width = width
      rectangle.height = height
    end)
  end
end

SvgDemo.new.build.run
