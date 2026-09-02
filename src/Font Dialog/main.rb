require 'gtk4'
require 'adwaita'

class FontDialogDemo
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
                section.append(font_dialog_button)
                section.append(dialog_button_reference)

                font_dialog_button.tap do |btn|
                  btn.signal_connect('notify::font-desc') { puts "Font: #{btn.font_desc}" }
                end
              end

              custom_button_section.tap do |section|
                section.append(custom_button_title)
                section.append(custom_button)
                section.append(custom_button_reference)

                custom_button.tap do |btn|
                  btn.signal_connect('clicked') { choose_family }
                end
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.fontdialog', :default_flags)
  def dialog_button_section = @dialog_button_section ||= Gtk::Box.new(:vertical, 0)
  def custom_button_section = @custom_button_section ||= Gtk::Box.new(:vertical, 0)

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Font Dialog'
      win.set_default_size(560, 640)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Font Dialog'
      page.description = 'Show a dialog to select a font'
    end
  end

  def content_box
    @content_box ||= Gtk::Box.new(:vertical, 42).tap { |box| box.halign = :center }
  end

  def dialog_button_title = @dialog_button_title ||= section_title('Dialog Button')
  def custom_button_title = @custom_button_title ||= section_title('Dialog With Custom Button')

  def font_dialog_button
    @font_dialog_button ||= Gtk::FontDialogButton.new(dialog_standard).tap do |btn|
      btn.halign = :center
      btn.margin_bottom = 12
      btn.use_font = true
      btn.use_size = true
    end
  end

  def custom_button
    @custom_button ||= Gtk::Button.new.tap do |btn|
      btn.label = 'Select Font…'
      btn.halign = :center
      btn.margin_bottom = 12
      btn.add_css_class('pill')
    end
  end

  def dialog_standard
    @dialog_standard ||= Gtk::FontDialog.new.tap do |dialog|
      dialog.title = 'Select a Font'
      dialog.modal = true
    end
  end

  def dialog_custom
    @dialog_custom ||= Gtk::FontDialog.new.tap do |dialog|
      dialog.title = 'Select a Font Family'
      dialog.modal = true
    end
  end

  def dialog_button_reference
    @dialog_button_reference ||= reference_link('https://docs.gtk.org/gtk4/class.FontDialogButton.html')
  end

  def custom_button_reference
    @custom_button_reference ||= reference_link('https://docs.gtk.org/gtk4/class.FontDialog.html')
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

  def choose_family
    dialog_custom.choose_family(window, nil, nil) do |dialog, result|
      puts "Font Family: #{dialog.choose_family_finish(result).name}"
    end
  end
end

FontDialogDemo.new.build.run
