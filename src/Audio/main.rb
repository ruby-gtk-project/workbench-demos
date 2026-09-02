require 'gtk4'
require 'adwaita'

class AudioDemo
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
              b.append(buttons_box)
              b.append(links_box)

              clamp.tap { |c| c.child = controls }

              buttons_box.tap do |box|
                box.append(button_sound)
                box.append(button_music)

                button_sound.tap do |btn|
                  btn.signal_connect('clicked') { play('Dog.ogg') }
                end

                button_music.tap do |btn|
                  btn.signal_connect('clicked') { play('Chopin-nocturne-op-9-no-2.ogg') }
                end
              end

              links_box.tap do |box|
                box.append(controls_reference)
                box.append(file_reference)
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.audio', :default_flags)
  def clamp = @clamp ||= Adwaita::Clamp.new.tap { |c| c.maximum_size = 400 }
  def controls = @controls ||= Gtk::MediaControls.new
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0).tap { |box| box.halign = :fill }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Audio'
      win.set_default_size(640, 480)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Audio'
      page.description = 'Play Audio with media controls'
    end
  end

  def buttons_box
    @buttons_box ||= Gtk::Box.new(:horizontal, 0).tap do |box|
      box.margin_top = 12
      box.halign = :center
      box.add_css_class('linked')
    end
  end

  def links_box
    @links_box ||= Gtk::Box.new(:vertical, 6).tap { |box| box.margin_top = 48 }
  end

  def button_sound = @button_sound ||= Gtk::Button.new.tap { |btn| btn.label = 'Play Sound' }
  def button_music = @button_music ||= Gtk::Button.new.tap { |btn| btn.label = 'Play Music' }

  def controls_reference
    @controls_reference ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.MediaControls.html').tap do |btn|
      btn.label = 'Media Controls API Reference'
    end
  end

  def file_reference
    @file_reference ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.MediaFile.html').tap do |btn|
      btn.label = 'Media File API Reference'
    end
  end

  private

  def play(basename)
    controls.media_stream.then { |stream| stream.playing = false if stream }

    controls.media_stream = Gtk::MediaFile.new(Gio::File.new_for_path(File.join(__dir__, basename))).tap(&:play)
  end
end

AudioDemo.new.build.run
