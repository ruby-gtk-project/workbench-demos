require 'gtk4'
require 'adwaita'

class CenterBoxDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(clamp)
              b.append(width_scale)
              b.append(reference_button)

              clamp.tap { |c| c.child = center_box }

              center_box.tap do |cb|
                cb.start_widget = start_switch
                cb.center_widget = center_entry
                cb.end_widget = end_check
              end

              width_adjustment.tap do |adjustment|
                adjustment.signal_connect('value-changed') { clamp.maximum_size = adjustment.value.to_i }
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.centerbox', :default_flags)
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 24)
  def clamp = @clamp ||= Adwaita::Clamp.new.tap { |c| c.maximum_size = 325 }
  def center_box = @center_box ||= Gtk::CenterBox.new.tap { |cb| cb.shrink_center_last = true }
  def start_switch = @start_switch ||= Gtk::Switch.new.tap { |sw| sw.valign = :center }
  def center_entry = @center_entry ||= Gtk::Entry.new
  def end_check = @end_check ||= Gtk::CheckButton.new

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Center Box'
      win.set_default_size(640, 520)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Center Box'
      page.description = 'Displays three child widgets, while keeping the middle one centered'
    end
  end

  def width_adjustment = @width_adjustment ||= Gtk::Adjustment.new(325, 200, 500, 1, 10, 0)

  def width_scale
    @width_scale ||= Gtk::Scale.new(:horizontal, width_adjustment).tap do |scale|
      scale.halign = :center
      scale.width_request = 120
    end
  end

  def reference_button
    @reference_button ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.CenterBox.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end
end

CenterBoxDemo.new.build.run
