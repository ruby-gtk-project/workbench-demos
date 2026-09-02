require 'gtk4'
require 'adwaita'

class CheckboxesDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(checkboxes_box)
              b.append(links_box)

              checkboxes_box.tap do |box|
                box.append(checkbox_1)
                box.append(checkbox_2)
                box.append(checkbox_3)
                box.append(checkbox_4)

                checkbox_1.tap do |check|
                  check.signal_connect('toggled') do
                    puts check.active? ? 'Notifications Enabled' : 'Notifications Disabled'
                  end
                end

                checkbox_2.tap do |check|
                  check.signal_connect('toggled') do
                    puts check.active? ? 'Changes will be auto-saved' : 'Changes will not be auto-saved'
                  end
                end
              end

              links_box.tap do |box|
                box.append(hig_link)
                box.append(reference_link)
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.checkboxes', :default_flags)
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0)

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Checkboxes'
      win.set_default_size(560, 560)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Checkboxes'
      page.description = 'Allow users to control binary options or properties'
    end
  end

  def checkboxes_box
    @checkboxes_box ||= Gtk::Box.new(:vertical, 12).tap { |box| box.halign = :center }
  end

  def links_box
    @links_box ||= Gtk::Box.new(:vertical, 0).tap { |box| box.margin_top = 48 }
  end

  def checkbox_1
    @checkbox_1 ||= Gtk::CheckButton.new.tap do |check|
      check.label = 'Enable Notifications'
      check.active = true
    end
  end

  def checkbox_2 = @checkbox_2 ||= Gtk::CheckButton.new.tap { |check| check.label = 'Auto-Save Changes' }

  def checkbox_3
    @checkbox_3 ||= Gtk::CheckButton.new.tap do |check|
      check.label = 'Mixed State'
      check.inconsistent = true
    end
  end

  def checkbox_4
    @checkbox_4 ||= Gtk::CheckButton.new.tap do |check|
      check.label = 'Disabled'
      check.sensitive = false
    end
  end

  def hig_link
    @hig_link ||= Gtk::LinkButton.new('https://developer.gnome.org/hig/patterns/controls/checkboxes.html').tap do |btn|
      btn.label = 'Human Interface Guidelines'
    end
  end

  def reference_link
    @reference_link ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.CheckButton.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end
end

CheckboxesDemo.new.build.run
