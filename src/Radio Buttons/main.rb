require 'gtk4'
require 'adwaita'

class RadioButtonsDemo
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
              b.append(links_box)

              buttons_box.tap do |box|
                box.append(radio_button_1)
                box.append(radio_button_2)
                box.append(radio_button_3)
                box.append(radio_button_4)

                radio_button_1.tap do |btn|
                  btn.signal_connect('toggled') { puts 'Force Light Mode' if btn.active? }
                end

                radio_button_2.tap do |btn|
                  btn.signal_connect('toggled') { puts 'Force Dark Mode' if btn.active? }
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

  def app = @app ||= Gtk::Application.new('org.example.radiobuttons', :default_flags)
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0)

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Radio Buttons'
      win.set_default_size(560, 560)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Radio Buttons'
      page.description = 'Allow users to make a selection from a set of options'
    end
  end

  def buttons_box
    @buttons_box ||= Gtk::Box.new(:vertical, 12).tap { |box| box.halign = :center }
  end

  def links_box
    @links_box ||= Gtk::Box.new(:vertical, 0).tap { |box| box.margin_top = 48 }
  end

  def radio_button_1
    @radio_button_1 ||= Gtk::CheckButton.new.tap do |btn|
      btn.label = 'Force Light Mode'
      btn.active = true
    end
  end

  def radio_button_2
    @radio_button_2 ||= grouped_button('Force Dark Mode')
  end

  def radio_button_3
    @radio_button_3 ||= grouped_button('Mixed State').tap { |btn| btn.inconsistent = true }
  end

  def radio_button_4
    @radio_button_4 ||= grouped_button('Disabled').tap { |btn| btn.sensitive = false }
  end

  def hig_link
    @hig_link ||= Gtk::LinkButton.new(
      'https://developer.gnome.org/hig/patterns/controls/radio-buttons.html'
    ).tap { |btn| btn.label = 'Human Interface Guidelines' }
  end

  def reference_link
    @reference_link ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.CheckButton.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end

  private

  def grouped_button(label)
    Gtk::CheckButton.new.tap do |btn|
      btn.label = label
      btn.group = radio_button_1
    end
  end
end

RadioButtonsDemo.new.build.run
