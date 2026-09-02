require 'gtk4'
require 'adwaita'

class ColorDialogDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(dialog_button_section)
              b.append(custom_button_section)

              dialog_button_section.tap do |section|
                section.append(dialog_button_title)
                section.append(color_dialog_button)
                section.append(dialog_button_reference)

                color_dialog_button.tap do |btn|
                  btn.dialog = dialog_standard
                  btn.rgba = initial_color
                  btn.signal_connect('notify::rgba') do
                    puts "Color Dialog Button: The color selected is #{btn.rgba}"
                  end
                end
              end

              custom_button_section.tap do |section|
                section.append(custom_button_title)
                section.append(custom_button)
                section.append(custom_button_reference)

                custom_button.tap do |btn|
                  btn.signal_connect('clicked') { choose_color }
                end
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.colordialog', :default_flags)
  def dialog_button_section = @dialog_button_section ||= Gtk::Box.new(:vertical, 0)
  def custom_button_section = @custom_button_section ||= Gtk::Box.new(:vertical, 0)
  def initial_color = @initial_color ||= Gdk::RGBA.parse('red')

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Color Dialog'
      win.set_default_size(560, 640)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Color Dialog'
      page.description = 'Show a dialog to select a color'
    end
  end

  def content_box
    @content_box ||= Gtk::Box.new(:vertical, 42).tap { |box| box.halign = :center }
  end

  def dialog_button_title = @dialog_button_title ||= section_title('Dialog Button')
  def custom_button_title = @custom_button_title ||= section_title('Dialog With Custom Button')

  def color_dialog_button
    @color_dialog_button ||= Gtk::ColorDialogButton.new(dialog_standard).tap do |btn|
      btn.halign = :center
      btn.margin_bottom = 12
    end
  end

  def custom_button
    @custom_button ||= Gtk::Button.new.tap do |btn|
      btn.label = 'Select Color…'
      btn.margin_start = 42
      btn.margin_end = 42
      btn.margin_bottom = 12
      btn.add_css_class('pill')
    end
  end

  def dialog_standard
    @dialog_standard ||= Gtk::ColorDialog.new.tap do |dialog|
      dialog.title = 'Select a color'
      dialog.modal = true
      dialog.with_alpha = true
    end
  end

  def dialog_custom
    @dialog_custom ||= Gtk::ColorDialog.new.tap do |dialog|
      dialog.title = 'Select a color'
      dialog.modal = true
      dialog.with_alpha = false
    end
  end

  def dialog_button_reference
    @dialog_button_reference ||= reference_link('https://docs.gtk.org/gtk4/class.ColorDialogButton.html')
  end

  def custom_button_reference
    @custom_button_reference ||= reference_link('https://docs.gtk.org/gtk4/class.ColorDialog.html')
  end

  private

  def section_title(text)
    Gtk::Label.new(text).tap do |label|
      label.margin_bottom = 12
      label.add_css_class('title-4')
    end
  end

  def reference_link(uri)
    Gtk::LinkButton.new(uri).tap { |btn| btn.label = 'API Reference' }
  end

  def choose_color
    dialog_custom.choose_rgba(window, nil, nil) do |dialog, result|
      puts "Custom Button: The color selected is #{dialog.choose_rgba_finish(result)}"
    end
  end
end

ColorDialogDemo.new.build.run
