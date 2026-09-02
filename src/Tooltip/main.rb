require 'gtk4'
require 'adwaita'

class TooltipDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(buttons_box)
              b.append(hint_label)
              b.append(links_box)

              buttons_box.tap do |box|
                box.append(do_not_disturb_button)
                box.append(open_button)
                box.append(button)

                button.tap do |btn|
                  btn.signal_connect('query-tooltip') do |_, _x, _y, _keyboard, tooltip|
                    tooltip.set_custom(custom_tooltip)
                    true
                  end
                end
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

  def app = @app ||= Gtk::Application.new('org.example.tooltip', :default_flags)
  def hint_label = @hint_label ||= Gtk::Label.new('Hover the buttons to see tooltips')

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Tooltip'
      win.set_default_size(640, 520)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Tooltip'
      page.description = 'Show additional information about controls or app content'
    end
  end

  def content_box
    @content_box ||= Gtk::Box.new(:vertical, 24).tap do |box|
      box.halign = :center
      box.valign = :center
    end
  end

  def buttons_box = @buttons_box ||= Gtk::Box.new(:horizontal, 24)

  def do_not_disturb_button
    @do_not_disturb_button ||= Gtk::ToggleButton.new.tap do |btn|
      btn.tooltip_text = 'Do Not Disturb'
      btn.icon_name = 'notifications-disabled-symbolic'
    end
  end

  def open_button
    @open_button ||= Gtk::Button.new.tap do |btn|
      btn.label = 'Open…'
      btn.tooltip_markup = '<i>Select a File</i>'
      btn.add_css_class('pill')
    end
  end

  def button
    @button ||= Gtk::Button.new.tap do |btn|
      btn.has_tooltip = true
      btn.label = 'Custom'
    end
  end

  def custom_tooltip
    @custom_tooltip ||= Gtk::Box.new(:horizontal, 6).tap do |box|
      box.append(Gtk::Label.new('This is a custom tooltip'))
      box.append(Gtk::Image.new.tap { |image| image.icon_name = 'emoji-body-symbolic' })
    end
  end

  def links_box
    @links_box ||= Gtk::Box.new(:vertical, 0).tap { |box| box.halign = :center }
  end

  def reference_link
    @reference_link ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.Tooltip.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end

  def hig_link
    @hig_link ||= Gtk::LinkButton.new('https://developer.gnome.org/hig/patterns/feedback/tooltips').tap do |btn|
      btn.label = 'Human Interface Guidelines'
    end
  end
end

TooltipDemo.new.build.run
