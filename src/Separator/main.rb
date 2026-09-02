require 'gtk4'
require 'adwaita'

class SeparatorDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(pictures_box)
              b.append(main_separator)
              b.append(toolbar_title)
              b.append(toolbar)
              b.append(reference_button)

              pictures_box.tap do |box|
                box.append(picture_one)
                box.append(pictures_separator)
                box.append(picture_two)
              end

              toolbar.tap do |bar|
                bar.append(welcome_label)
                bar.append(minimize_button)
                bar.append(first_toolbar_separator)
                bar.append(maximize_button)
                bar.append(second_toolbar_separator)
                bar.append(close_button)
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.separator', :default_flags)
  def file = @file ||= Gio::File.new_for_path(File.join(__dir__, 'image.png'))
  def welcome_label = @welcome_label ||= Gtk::Label.new('Welcome to Workbench')

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Separator'
      win.set_default_size(640, 720)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Separator'
      page.description = 'Separates one widget from another'
    end
  end

  def content_box
    @content_box ||= Gtk::Box.new(:vertical, 18).tap { |box| box.halign = :center }
  end

  def pictures_box
    @pictures_box ||= Gtk::Box.new(:horizontal, 18).tap { |box| box.halign = :center }
  end

  def picture_one = @picture_one ||= demo_picture
  def picture_two = @picture_two ||= demo_picture

  def pictures_separator = @pictures_separator ||= Gtk::Separator.new(:vertical)
  def main_separator = @main_separator ||= Gtk::Separator.new(:horizontal)
  def first_toolbar_separator = @first_toolbar_separator ||= Gtk::Separator.new(:vertical)
  def second_toolbar_separator = @second_toolbar_separator ||= Gtk::Separator.new(:vertical)

  def toolbar_title
    @toolbar_title ||= Gtk::Label.new('Separator With Toolbar Class').tap { |l| l.add_css_class('title-4') }
  end

  def toolbar
    @toolbar ||= Gtk::Box.new(:horizontal, 12).tap do |box|
      box.halign = :center
      box.margin_bottom = 24
      box.add_css_class('toolbar')
    end
  end

  def minimize_button = @minimize_button ||= icon_button('window-minimize-symbolic')
  def maximize_button = @maximize_button ||= icon_button('window-maximize-symbolic')
  def close_button = @close_button ||= icon_button('window-close-symbolic')

  def reference_button
    @reference_button ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.Separator.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end

  private

  def demo_picture
    Gtk::Picture.new(file).tap { |picture| picture.set_size_request(180, 180) }
  end

  def icon_button(icon_name)
    Gtk::Button.new.tap { |btn| btn.icon_name = icon_name }
  end
end

SeparatorDemo.new.build.run
