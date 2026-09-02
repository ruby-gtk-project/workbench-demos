require 'gtk4'
require 'adwaita'

# libsoup has no Ruby gem; its namespace comes straight from the typelib.
module Soup
  GObjectIntrospection::Loader.load('Soup', self)
end

class HttpImageDemo
  # https://picsum.photos/
  IMAGE_URL = 'https://picsum.photos/800'

  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap { |b| b.append(picture) }
          end
        end

        load_image

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.httpimage', :default_flags)
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0)
  def session = @session ||= Soup::Session.new

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'HTTP Image'
      win.set_default_size(880, 900)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'HTTP Image'
      page.description = 'Load and display an image from an HTTP URL'
      page.valign = :start
    end
  end

  def picture
    @picture ||= Gtk::Picture.new.tap do |pic|
      pic.halign = :center
      pic.valign = :center
      pic.can_shrink = true
      pic.content_fit = :scale_down
      pic.margin_bottom = 30
    end
  end

  def message
    @message ||= Soup::Message.new('GET', IMAGE_URL)
  end

  private

  def load_image
    session.send_and_read_async(message, GLib::PRIORITY_DEFAULT, nil) do |source, result|
      source.send_and_read_finish(result).then do |bytes|
        if message.status == Soup::Status::OK
          picture.paintable = Gdk::Texture.new(bytes)
        else
          warn "Got #{message.status}, #{message.reason_phrase}"
        end
      end
    end
  end
end

HttpImageDemo.new.build.run
