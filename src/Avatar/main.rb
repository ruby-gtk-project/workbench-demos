require 'gtk4'
require 'adwaita'

class AvatarDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(avatar_initials)
              b.append(initials_label)
              b.append(avatar_image)
              b.append(button)
              b.append(avatar_fallback)
              b.append(fallback_label)
              b.append(reference_button)

              button.tap do |btn|
                btn.signal_connect('clicked') { choose_image }
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.avatar', :default_flags)
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0).tap { |box| box.halign = :center }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Avatar'
      win.set_default_size(560, 760)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Avatar'
      page.description = 'Display a round avatar for image or initials'
    end
  end

  def avatar_initials
    @avatar_initials ||= Adwaita::Avatar.new(96, 'Jay Doe', true).tap { |avatar| avatar.margin_bottom = 6 }
  end

  def avatar_image
    @avatar_image ||= Adwaita::Avatar.new(96, nil, false).tap { |avatar| avatar.margin_bottom = 6 }
  end

  def avatar_fallback
    @avatar_fallback ||= Adwaita::Avatar.new(96, nil, false).tap { |avatar| avatar.margin_bottom = 6 }
  end

  def initials_label = @initials_label ||= Gtk::Label.new('Initials').tap { |l| l.margin_bottom = 30 }
  def fallback_label = @fallback_label ||= Gtk::Label.new('Fallback').tap { |l| l.margin_bottom = 30 }

  def button
    @button ||= Gtk::Button.new.tap do |btn|
      btn.label = 'Image…'
      btn.margin_bottom = 30
      btn.add_css_class('pill')
    end
  end

  def reference_button
    @reference_button ||= Gtk::LinkButton.new(
      'https://gnome.pages.gitlab.gnome.org/libadwaita/doc/1.6/class.Avatar.html'
    ).tap { |btn| btn.label = 'API Reference' }
  end

  def file_filter
    @file_filter ||= Gtk::FileFilter.new.tap do |filter|
      filter.name = 'Images'
      filter.add_pixbuf_formats
    end
  end

  def file_dialog
    @file_dialog ||= Gtk::FileDialog.new.tap do |dialog|
      dialog.title = 'Select an Avatar'
      dialog.modal = true
      dialog.default_filter = file_filter
    end
  end

  private

  def choose_image
    file_dialog.open(window, nil) do |dialog, result|
      avatar_image.set_custom_image(Gdk::Texture.new(dialog.open_finish(result)))
    end
  end
end

AvatarDemo.new.build.run
