require 'gtk4'
require 'adwaita'

class SwitchDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(switch_on)
              b.append(label_on)
              b.append(switch_off)
              b.append(label_off)
              b.append(switch_disabled)
              b.append(label_disabled)
              b.append(tutorial_link)
              b.append(reference_link)
              b.append(hig_link)

              switch_on.tap do |sw|
                sw.signal_connect('notify::active') do
                  label_on.label = sw.active? ? 'On' : 'Off'
                  switch_off.active = !sw.active?
                end
              end

              switch_off.tap do |sw|
                sw.signal_connect('notify::active') do
                  label_off.label = sw.active? ? 'On' : 'Off'
                  switch_on.active = !sw.active?
                end
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.switch', :default_flags)
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0)

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Switch'
      win.set_default_size(560, 760)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Switch'
      page.description = 'A simple on/off control'
    end
  end

  def switch_on = @switch_on ||= demo_switch.tap { |sw| sw.active = true }
  def switch_off = @switch_off ||= demo_switch.tap { |sw| sw.active = false }
  def switch_disabled = @switch_disabled ||= demo_switch.tap { |sw| sw.sensitive = false }

  def label_on = @label_on ||= caption('On')
  def label_off = @label_off ||= caption('Off')
  def label_disabled = @label_disabled ||= caption('Disabled')

  def tutorial_link
    @tutorial_link ||= Gtk::LinkButton.new(
      'https://developer.gnome.org/documentation/tutorials/beginners/components/switch.html'
    ).tap { |btn| btn.label = 'Tutorial' }
  end

  def reference_link
    @reference_link ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.Switch.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end

  def hig_link
    @hig_link ||= Gtk::LinkButton.new(
      'https://developer.gnome.org/hig/patterns/controls/switches.html'
    ).tap { |btn| btn.label = 'Human Interface Guidelines' }
  end

  private

  def demo_switch
    Gtk::Switch.new.tap do |sw|
      sw.halign = :center
      sw.margin_bottom = 6
    end
  end

  def caption(text)
    Gtk::Label.new(text).tap { |label| label.margin_bottom = 30 }
  end
end

SwitchDemo.new.build.run
