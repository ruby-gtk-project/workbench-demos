require 'gtk4'
require 'adwaita'

class SelectFolderDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(button_single)
              b.append(button_multiple)
              b.append(reference_button)

              button_single.tap do |btn|
                btn.signal_connect('clicked') { select_folder }
              end

              button_multiple.tap do |btn|
                btn.signal_connect('clicked') { select_multiple_folders }
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.selectfolder', :default_flags)
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 24)

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Select Folder'
      win.set_default_size(560, 520)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Select Folder'
      page.description = 'Select folders using a file dialog'
    end
  end

  def button_single = @button_single ||= pill_button('Select Folder…')
  def button_multiple = @button_multiple ||= pill_button('Select Multiple Folders…')

  def reference_button
    @reference_button ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.FileDialog.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end

  private

  def pill_button(label)
    Gtk::Button.new.tap do |btn|
      btn.halign = :center
      btn.label = label
      btn.add_css_class('pill')
    end
  end

  def select_folder
    Gtk::FileDialog.new.select_folder(window, nil) do |source, result|
      source.select_folder_finish(result).then do |file|
        puts "\"#{file.query_info('standard::name', :none).name}\" selected"
      end
    end
  end

  def select_multiple_folders
    Gtk::FileDialog.new.select_multiple_folders(window, nil) do |source, result|
      puts "#{source.select_multiple_folders_finish(result).n_items} selected folders"
    end
  end
end

SelectFolderDemo.new.build.run
