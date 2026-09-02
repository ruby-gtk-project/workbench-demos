require 'gtk4'
require 'adwaita'

class ToggleButtonDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(grouped_box)
              b.append(grouped_label)
              b.append(independent_box)
              b.append(independent_label)
              b.append(button_console)
              b.append(with_label_label)
              b.append(tutorial_link)
              b.append(reference_link)
              b.append(hig_link)

              grouped_box.tap do |box|
                box.append(button_no_look)
                box.append(button_look)
              end

              independent_box.tap do |box|
                box.append(button_camera)
                box.append(button_flashlight)
              end

              button_console.tap { |btn| btn.child = console_content }

              buttons.each do |button, name|
                button.signal_connect('notify::active') { puts "#{name} #{button.active? ? 'On' : 'Off'}" }
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.togglebutton', :default_flags)
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0)

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Toggle Button'
      win.set_default_size(560, 760)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Toggle Button'
      page.description = 'Represent active-state visually'
    end
  end

  def grouped_box
    @grouped_box ||= Gtk::Box.new(:horizontal, 0).tap do |box|
      box.halign = :center
      box.margin_bottom = 6
      box.add_css_class('linked')
    end
  end

  def independent_box
    @independent_box ||= Gtk::Box.new(:horizontal, 6).tap do |box|
      box.halign = :center
      box.margin_bottom = 6
    end
  end

  def button_no_look
    @button_no_look ||= Gtk::ToggleButton.new.tap do |btn|
      btn.active = true
      btn.icon_name = 'eye-not-looking-symbolic'
    end
  end

  def button_look
    @button_look ||= Gtk::ToggleButton.new.tap do |btn|
      btn.active = false
      btn.icon_name = 'eye-open-negative-filled-symbolic'
      btn.group = button_no_look
    end
  end

  def button_camera = @button_camera ||= independent_toggle('photo-camera-symbolic')
  def button_flashlight = @button_flashlight ||= independent_toggle('flashlight-symbolic')

  def button_console
    @button_console ||= Gtk::ToggleButton.new.tap do |btn|
      btn.halign = :center
      btn.margin_bottom = 6
    end
  end

  def console_content
    @console_content ||= Adwaita::ButtonContent.new.tap do |content|
      content.halign = :center
      content.valign = :center
      content.label = 'Console'
      content.icon_name = 'terminal-symbolic'
    end
  end

  def grouped_label = @grouped_label ||= caption('Grouped')
  def independent_label = @independent_label ||= caption('Independent')
  def with_label_label = @with_label_label ||= caption('With Label')

  def buttons
    @buttons ||= {
      button_no_look => "Don't look",
      button_look => 'Look',
      button_camera => 'Camera',
      button_flashlight => 'Flashlight',
      button_console => 'Console'
    }
  end

  def tutorial_link
    @tutorial_link ||= Gtk::LinkButton.new(
      'https://developer.gnome.org/documentation/tutorials/beginners/components/toggle.html'
    ).tap { |btn| btn.label = 'Tutorial' }
  end

  def reference_link
    @reference_link ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.ToggleButton.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end

  def hig_link
    @hig_link ||= Gtk::LinkButton.new(
      'https://developer.gnome.org/hig/patterns/controls/buttons.html'
    ).tap { |btn| btn.label = 'Human Interface Guidelines' }
  end

  private

  def independent_toggle(icon_name)
    Gtk::ToggleButton.new.tap do |btn|
      btn.active = false
      btn.icon_name = icon_name
      btn.halign = :center
    end
  end

  def caption(text)
    Gtk::Label.new(text).tap { |label| label.margin_bottom = 24 }
  end
end

ToggleButtonDemo.new.build.run
