require 'gtk4'
require 'adwaita'

class OverlayDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        Gtk::StyleContext.add_provider_for_display(
          Gdk::Display.default, css_provider, Gtk::StyleProvider::PRIORITY_APPLICATION
        )

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = clamp

            clamp.tap do |c|
              c.child = overlay

              overlay.tap do |o|
                o.child = picture
                o.add_overlay(toolbar)

                toolbar.tap do |bar|
                  bar.append(backward_button)
                  bar.append(play_button)
                  bar.append(forward_button)
                  bar.append(scale)
                  bar.append(mute_button)
                end
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.overlay', :default_flags)
  def clamp = @clamp ||= Adwaita::Clamp.new
  def overlay = @overlay ||= Gtk::Overlay.new
  def picture = @picture ||= Gtk::Picture.new(Gio::File.new_for_path(File.join(__dir__, 'image.png')))

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Overlay'
      win.set_default_size(720, 620)
    end
  end

  def css_provider
    @css_provider ||= Gtk::CssProvider.new.tap { |provider| provider.load_from_path(File.join(__dir__, 'main.css')) }
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Overlay'
      page.description = 'Overlay widgets on top of a each other'
    end
  end

  def toolbar
    @toolbar ||= Gtk::Box.new(:horizontal, 0).tap do |box|
      box.margin_start = 24
      box.margin_end = 24
      box.margin_bottom = 18
      box.valign = :end
      box.add_css_class('toolbar')
      box.add_css_class('osd')
      box.add_css_class('darken')
    end
  end

  def backward_button = @backward_button ||= icon_button('media-skip-backward-symbolic')
  def play_button = @play_button ||= icon_button('media-playback-start-symbolic')
  def forward_button = @forward_button ||= icon_button('media-skip-forward-symbolic')
  def mute_button = @mute_button ||= icon_button('audio-volume-muted-symbolic')

  def scale
    @scale ||= Gtk::Scale.new(:horizontal, Gtk::Adjustment.new(50, 0, 100, 1, 10, 0)).tap do |s|
      s.hexpand = true
      s.show_fill_level = true
    end
  end

  private

  def icon_button(icon_name)
    Gtk::Button.new.tap { |btn| btn.icon_name = icon_name }
  end
end

OverlayDemo.new.build.run
