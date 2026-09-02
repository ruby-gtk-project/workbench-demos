require 'gtk4'
require 'adwaita'

class ImageDemo
  ICON_NAMES = ['accessories-calculator-symbolic', 'display-brightness-symbolic',
                'face-monkey-symbolic', 'starred-symbolic'].freeze

  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(normal_icons_box)
              b.append(large_icons_box)
              b.append(file_icons_box)
              b.append(links_box)

              normal_icons_box.tap { |box| normal_icons.each { |icon| box.append(icon) } }
              large_icons_box.tap { |box| large_icons.each { |icon| box.append(icon) } }

              file_icons_box.tap do |box|
                box.append(icon1)
                box.append(icon2)
                box.append(icon3)
              end

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

  def app = @app ||= Gtk::Application.new('org.example.image', :default_flags)
  def normal_icons_box = @normal_icons_box ||= icons_row
  def large_icons_box = @large_icons_box ||= icons_row
  def file_icons_box = @file_icons_box ||= icons_row

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Image'
      win.set_default_size(640, 700)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Image'
      page.description = 'Display images as icons'
    end
  end

  def content_box
    @content_box ||= Gtk::Box.new(:vertical, 18).tap { |box| box.halign = :center }
  end

  def normal_icons = @normal_icons ||= ICON_NAMES.map { |name| symbolic_icon(name, :normal) }
  def large_icons = @large_icons ||= ICON_NAMES.map { |name| symbolic_icon(name, :large) }

  def icon1 = @icon1 ||= file_icon(128, 'icon-dropshadow')
  def icon2 = @icon2 ||= file_icon(64, 'icon-dropshadow')
  def icon3 = @icon3 ||= file_icon(32, 'lowres-icon')

  def links_box
    @links_box ||= Gtk::Box.new(:vertical, 6).tap { |box| box.halign = :center }
  end

  def reference_link
    @reference_link ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.Image.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end

  def hig_link
    @hig_link ||= Gtk::LinkButton.new('https://developer.gnome.org/hig/guidelines/ui-icons.html').tap do |btn|
      btn.label = 'Human Interface Guidelines'
    end
  end

  private

  def icons_row
    Gtk::Box.new(:horizontal, 24).tap { |box| box.halign = :center }
  end

  def symbolic_icon(name, size)
    Gtk::Image.new.tap do |image|
      image.icon_size = size
      image.icon_name = name
    end
  end

  def file_icon(pixel_size, style)
    Gtk::Image.new.tap do |image|
      image.pixel_size = pixel_size
      image.add_css_class(style)
      image.file = File.join(__dir__, 'workbench.png')
    end
  end
end

ImageDemo.new.build.run
