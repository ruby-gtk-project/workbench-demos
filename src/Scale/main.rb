require 'gtk4'
require 'adwaita'

class ScaleDemo
  MARKS = { 0 => 'A', 50 => 'B', 100 => 'C' }.freeze

  VOLUME_ICONS = ['audio-volume-muted-symbolic', 'audio-volume-high-symbolic',
                  'audio-volume-low-symbolic', 'audio-volume-medium-symbolic'].freeze

  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(scales_box)
              b.append(disabled)
              b.append(button)
              b.append(scale_reference)
              b.append(scale_button_reference)
              b.append(hig_link)

              scales_box.tap do |box|
                box.append(one)
                box.append(two)

                one.tap do |scale|
                  scale.signal_connect('value-changed') { report_bounds(scale) }
                end

                two.tap do |scale|
                  MARKS.each { |value, label| scale.add_mark(value, :right, label) }
                  scale.set_increments(25, 100)
                  scale.signal_connect('value-changed') { report_mark(scale) }
                end
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.scale', :default_flags)
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0).tap { |box| box.halign = :center }
  def scales_box = @scales_box ||= Gtk::Box.new(:horizontal, 0).tap { |box| box.halign = :center }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Scale'
      win.set_default_size(640, 720)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Scale'
      page.description = 'Slider control to select a value from a range'
    end
  end

  def one
    @one ||= Gtk::Scale.new(:horizontal, Gtk::Adjustment.new(0, 0, 100, 1, 10, 0)).tap do |scale|
      scale.margin_bottom = 18
      scale.width_request = 130
      scale.draw_value = true
      scale.margin_end = 36
    end
  end

  def two
    @two ||= Gtk::Scale.new(:vertical, Gtk::Adjustment.new(0, 0, 100, 1, 10, 0)).tap do |scale|
      scale.margin_bottom = 18
      scale.height_request = 140
    end
  end

  def disabled
    @disabled ||= Gtk::Scale.new(:horizontal, Gtk::Adjustment.new(25, 0, 50, 1, 10, 0)).tap do |scale|
      scale.sensitive = false
      scale.margin_bottom = 18
      scale.show_fill_level = true
    end
  end

  def button
    # Gtk::ScaleButton.new takes an options hash, not positional arguments.
    @button ||= Gtk::ScaleButton.new(min: 0, max: 100, step: 15, icons: VOLUME_ICONS).tap do |btn|
      btn.orientation = :horizontal
      btn.margin_bottom = 18
      btn.halign = :center
    end
  end

  def scale_reference
    @scale_reference ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.Scale.html').tap do |btn|
      btn.label = 'Scale API Reference'
    end
  end

  def scale_button_reference
    @scale_button_reference ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.ScaleButton.html').tap do |btn|
      btn.label = 'ScaleButton API Reference'
    end
  end

  def hig_link
    @hig_link ||= Gtk::LinkButton.new('https://developer.gnome.org/hig/patterns/controls/sliders.html').tap do |btn|
      btn.label = 'Human Interface Guidelines'
    end
  end

  private

  def report_bounds(scale)
    puts 'Maximum value reached' if scale.value == scale.adjustment.upper
    puts 'Minimum value reached' if scale.value == scale.adjustment.lower
  end

  def report_mark(scale)
    MARKS[scale.value.to_i].then { |label| puts "Mark #{label} reached" if label }
  end
end

ScaleDemo.new.build.run
