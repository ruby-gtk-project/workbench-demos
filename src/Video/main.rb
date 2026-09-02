require 'gtk4'
require 'adwaita'

class VideoDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = page

          page.tap do |status|
            status.child = content_box

            content_box.tap do |b|
              b.append(video)
              b.append(reference_button)

              video.tap do |v|
                v.file = Gio::File.new_for_path(File.join(__dir__, 'workbench-video.mp4'))
                v.add_controller(click_gesture)
              end
            end
          end
        end

        click_gesture.tap do |gesture|
          gesture.signal_connect('pressed') { toggle_playback }
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.video', :default_flags)
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0).tap { |box| box.halign = :center }
  def click_gesture = @click_gesture ||= Gtk::GestureClick.new

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Video'
      win.set_default_size(760, 800)
    end
  end

  def page
    @page ||= Adwaita::StatusPage.new.tap do |status|
      status.title = 'Video'
      status.description = 'Display video with media controls'
    end
  end

  def video
    @video ||= Gtk::Video.new.tap do |v|
      v.autoplay = true
      v.loop = true
      v.set_size_request(540, 540)
    end
  end

  def reference_button
    @reference_button ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.Video.html').tap do |btn|
      btn.label = 'API Reference'
      btn.margin_top = 12
    end
  end

  private

  def toggle_playback
    video.media_stream.then { |stream| stream.playing? ? stream.pause : stream.play }
  end
end

VideoDemo.new.build.run
