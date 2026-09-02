require 'gtk4'
require 'adwaita'

class SpinnerDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(spinner)
              b.append(button)
              b.append(links_box)

              button.tap do |btn|
                btn.signal_connect('clicked') { toggle_spinner }
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

  def app = @app ||= Gtk::Application.new('org.example.spinner', :default_flags)
  def links_box = @links_box ||= Gtk::Box.new(:vertical, 0)

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Spinner'
      win.set_default_size(560, 520)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Spinner'
      page.description = 'Display loading state'
    end
  end

  def content_box
    @content_box ||= Gtk::Box.new(:vertical, 24).tap { |box| box.halign = :center }
  end

  def spinner
    @spinner ||= Adwaita::Spinner.new.tap do |s|
      s.halign = :center
      s.valign = :center
      s.set_size_request(48, 48)
    end
  end

  def button
    @button ||= Gtk::Button.new.tap do |btn|
      btn.icon_name = 'media-playback-stop'
      btn.halign = :center
      btn.add_css_class('circular')
    end
  end

  def reference_link
    @reference_link ||= Gtk::LinkButton.new(
      'https://gnome.pages.gitlab.gnome.org/libadwaita/doc/1.6/class.Spinner.html'
    ).tap { |btn| btn.label = 'API Reference' }
  end

  def hig_link
    @hig_link ||= Gtk::LinkButton.new(
      'https://developer.gnome.org/hig/patterns/feedback/spinners.html'
    ).tap { |btn| btn.label = 'Human Interface Guidelines' }
  end

  private

  def toggle_spinner
    button.icon_name = spinner.visible? ? 'media-playback-start' : 'media-playback-stop'
    spinner.visible = !spinner.visible?
  end
end

SpinnerDemo.new.build.run
