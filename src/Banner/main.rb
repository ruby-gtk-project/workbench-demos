require 'gtk4'
require 'adwaita'

class BannerDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = overlay

          overlay.tap do |o|
            o.child = content_box

            content_box.tap do |b|
              b.append(banner)
              b.append(status_page)

              banner.tap do |bar|
                bar.signal_connect('button-clicked') do
                  overlay.add_toast(troubleshoot_toast)
                  bar.revealed = false
                end
              end

              status_page.tap do |page|
                page.child = page_box

                page_box.tap do |box|
                  box.append(button_show_banner)
                  box.append(links_box)

                  button_show_banner.tap do |btn|
                    btn.signal_connect('clicked') { banner.revealed = true }
                  end

                  links_box.tap do |links|
                    links.append(reference_button)
                    links.append(hig_button)
                  end
                end
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.banner', :default_flags)
  def overlay = @overlay ||= Adwaita::ToastOverlay.new
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0)
  def page_box = @page_box ||= Gtk::Box.new(:vertical, 0).tap { |box| box.halign = :center }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Banner'
      win.set_default_size(640, 520)
    end
  end

  def banner
    @banner ||= Adwaita::Banner.new('An error occurred: Could not resolve host').tap do |bar|
      bar.button_label = 'Troubleshoot'
      bar.revealed = true
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Banner'
      page.description = 'A bar with contextual information'
      page.vexpand = true
    end
  end

  def button_show_banner
    @button_show_banner ||= Gtk::Button.new.tap do |btn|
      btn.label = 'Show Banner'
      btn.halign = :center
      btn.add_css_class('pill')
    end
  end

  def links_box
    @links_box ||= Gtk::Box.new(:vertical, 0).tap do |box|
      box.margin_top = 24
      box.margin_bottom = 24
    end
  end

  def reference_button
    @reference_button ||= Gtk::LinkButton.new(
      'https://gnome.pages.gitlab.gnome.org/libadwaita/doc/1.6/class.Banner.html'
    ).tap { |btn| btn.label = 'API Reference' }
  end

  def hig_button
    @hig_button ||= Gtk::LinkButton.new(
      'https://developer.gnome.org/hig/patterns/feedback/banners.html'
    ).tap { |btn| btn.label = 'Human Interface Guidelines' }
  end

  def troubleshoot_toast
    Adwaita::Toast.new('Troubleshoot successful!').tap { |toast| toast.timeout = 3 }
  end
end

BannerDemo.new.build.run
