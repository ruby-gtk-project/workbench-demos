require 'gtk4'
require 'adwaita'

class EmojiChooserDemo
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
            page.child = content_box

            content_box.tap do |b|
              b.append(button)
              b.append(reference_button)

              button.tap { |btn| btn.popover = emoji_chooser }

              emoji_chooser.tap do |chooser|
                chooser.signal_connect('emoji-picked') { |_, emoji| button.label = emoji }
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.emojichooser', :default_flags)
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 24)
  def emoji_chooser = @emoji_chooser ||= Gtk::EmojiChooser.new

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Emoji Chooser'
      win.set_default_size(560, 520)
    end
  end

  def css_provider
    @css_provider ||= Gtk::CssProvider.new.tap { |provider| provider.load_from_path(File.join(__dir__, 'main.css')) }
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Emoji Chooser'
      page.description = 'Display a popover to select emojis'
    end
  end

  def button
    @button ||= Gtk::MenuButton.new.tap do |btn|
      btn.halign = :center
      btn.label = '😀️'
      btn.add_css_class('pill')
      btn.add_css_class('emoji')
    end
  end

  def reference_button
    @reference_button ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.EmojiChooser.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end
end

EmojiChooserDemo.new.build.run
