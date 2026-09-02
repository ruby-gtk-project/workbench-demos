require 'gtk4'
require 'adwaita'

class DrawingAreaDemo
  TRIANGLE = [[100, 100], [0, -100], [-100, 100]].freeze

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
              b.append(scale)
              b.append(reference_button)

              drawing_area.tap do |area|
                area.set_draw_func { |_, cr, _width, _height| draw(cr) }
              end

              scale.tap do |s|
                s.signal_connect('value-changed') do
                  @angle = s.value / 180 * Math::PI
                  drawing_area.queue_draw
                end
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.drawingarea', :default_flags)
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0).tap { |box| box.halign = :center }
  def angle = @angle ||= 0

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Drawing Area'
      win.set_default_size(560, 700)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Drawing Area'
      page.description = 'Programmatically draw onto a surface'
    end
  end

  def drawing_area
    @drawing_area ||= Gtk::DrawingArea.new.tap do |area|
      area.content_width = 300
      area.content_height = 300
    end
  end

  def scale
    @scale ||= Gtk::Scale.new(:horizontal, Gtk::Adjustment.new(0, -25, 25, 1, 5, 0)).tap do |s|
      s.draw_value = true
    end
  end

  def reference_button
    @reference_button ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.DrawingArea.html').tap do |btn|
      btn.label = 'API Reference'
      btn.margin_top = 48
    end
  end

  private

  # https://www.cairographics.org/tutorial/
  def draw(cr)
    cr.translate(150, 150)
    cr.rotate(angle)
    cr.move_to(*TRIANGLE.last)
    TRIANGLE.each { |vertex| cr.line_to(*vertex) }
    cr.set_source_rgba(1, 0, 1, 1)
    cr.stroke
  end
end

DrawingAreaDemo.new.build.run
