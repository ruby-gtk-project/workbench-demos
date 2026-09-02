require 'gtk4'
require 'adwaita'

class SaveFileDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(button)
              b.append(reference_button)

              button.tap do |btn|
                btn.signal_connect('clicked') { save_file }
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.savefile', :default_flags)
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 24)

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Save File'
      win.set_default_size(560, 480)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Save File'
      page.description = 'Save a file using a file dialog'
    end
  end

  def button
    @button ||= Gtk::Button.new.tap do |btn|
      btn.halign = :center
      btn.label = 'Save…'
      btn.add_css_class('pill')
      btn.add_css_class('suggested-action')
    end
  end

  def file_dialog
    @file_dialog ||= Gtk::FileDialog.new.tap { |dialog| dialog.initial_name = 'Workbench.txt' }
  end

  def reference_button
    @reference_button ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.FileDialog.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end

  private

  # dialog.save hands back a Gio::File to write to.
  def save_file
    file_dialog.save(window, nil) do |source, result|
      source.save_finish(result).then do |file|
        file.replace_contents('Hello from Workbench!', nil, false, :none)
        puts "File #{file.basename} saved"
      end
    end
  end
end

SaveFileDemo.new.build.run
