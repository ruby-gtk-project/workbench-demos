require 'gtk4'

# A Gtk::Button subclass registered as its own GType, with a fixed child and
# behaviour of its own — the Ruby equivalent of a UI-template widget.
class AwesomeButton < Gtk::Button
  type_register

  def initialize
    super
    build
  end

  def build
    tap do |btn|
      btn.child = image
      btn.signal_connect('clicked') { puts 'Clicked' }
    end
  end

  def image
    @image ||= Gtk::Image.new.tap do |img|
      img.halign = :center
      img.icon_name = 'emoji-people-symbolic'
    end
  end
end

class CustomWidgetDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = scrolled_window

          scrolled_window.tap do |sw|
            sw.child = container

            container.tap do |flow_box|
              100.times { flow_box.append(AwesomeButton.new) }
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.customwidget', :default_flags)
  def scrolled_window = @scrolled_window ||= Gtk::ScrolledWindow.new
  def container = @container ||= Gtk::FlowBox.new.tap { |box| box.hexpand = true }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Custom Widget'
      win.set_default_size(640, 480)
    end
  end
end

CustomWidgetDemo.new.build.run
