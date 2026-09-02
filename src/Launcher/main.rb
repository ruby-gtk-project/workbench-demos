require 'gtk4'
require 'adwaita'

class LauncherDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = clamp

            clamp.tap do |c|
              c.child = content_box

              content_box.tap do |b|
                b.append(stack_switcher)
                b.append(stack)

                stack.tap do |s|
                  s.add_titled(file_page, 'file_launcher', 'File Launcher')
                  s.add_titled(uri_page, 'uri_launcher', 'URI Launcher')

                  file_page.tap do |page_box|
                    page_box.append(file_buttons_box)
                    page_box.append(change_file)
                    page_box.append(file_reference)

                    file_buttons_box.tap do |box|
                      box.append(launch_file)
                      box.append(file_location)

                      launch_file.tap do |btn|
                        btn.signal_connect('clicked') { file_launcher.launch(window, nil) {} }
                      end

                      file_location.tap do |btn|
                        btn.signal_connect('clicked') { file_launcher.open_containing_folder(window, nil) {} }
                      end
                    end

                    change_file.tap do |btn|
                      btn.child = change_file_box
                      btn.signal_connect('clicked') { choose_file }

                      change_file_box.tap do |box|
                        box.append(change_file_title)
                        box.append(file_name)
                      end
                    end
                  end

                  uri_page.tap do |page_box|
                    page_box.append(uri_button_box)
                    page_box.append(uri_details)
                    page_box.append(uri_reference)

                    uri_button_box.tap { |box| box.append(uri_launch) }

                    uri_launch.tap do |btn|
                      btn.signal_connect('clicked') { launch_uri }
                    end

                    uri_details.tap do |entry|
                      entry.signal_connect('changed') do
                        uri_launch.sensitive = GLib::Uri.valid?(entry.text, GLib::UriFlags::NONE)
                      end
                    end
                  end
                end
              end
            end
          end
        end

        file_launcher.tap do |launcher|
          launcher.signal_connect('notify::file') do
            file_name.label = launcher.file.query_info('standard::display-name', :none).display_name
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.launcher', :default_flags)
  def clamp = @clamp ||= Adwaita::Clamp.new.tap { |c| c.maximum_size = 640 }
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 24)
  def file = @file ||= Gio::File.new_for_path(File.join(__dir__, 'workbench.txt'))
  def change_file_box = @change_file_box ||= Gtk::Box.new(:vertical, 0).tap { |box| box.halign = :center }
  def uri_button_box = @uri_button_box ||= Gtk::Box.new(:horizontal, 0).tap { |box| box.halign = :center }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Launcher'
      win.set_default_size(720, 660)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Launcher'
      page.description = 'Open a file or URI'
    end
  end

  def stack_switcher
    @stack_switcher ||= Gtk::StackSwitcher.new.tap do |switcher|
      switcher.stack = stack
      switcher.halign = :center
    end
  end

  def stack
    @stack ||= Gtk::Stack.new.tap do |s|
      s.transition_type = :crossfade
      s.vexpand = true
    end
  end

  def file_page = @file_page ||= page_box
  def uri_page = @uri_page ||= page_box

  def file_buttons_box
    @file_buttons_box ||= Gtk::Box.new(:horizontal, 6).tap do |box|
      box.halign = :center
      box.homogeneous = true
    end
  end

  def launch_file = @launch_file ||= pill_button('Launch')
  def file_location = @file_location ||= pill_button('View in Files')
  def uri_launch = @uri_launch ||= pill_button('Launch')

  def change_file = @change_file ||= Gtk::Button.new
  def change_file_title = @change_file_title ||= Gtk::Label.new('Select File…').tap { |l| l.add_css_class('title-4') }

  def file_name
    @file_name ||= Gtk::Label.new('workbench.txt').tap do |label|
      label.add_css_class('dim-label')
      label.add_css_class('body')
    end
  end

  def uri_details
    @uri_details ||= Gtk::Entry.new.tap do |entry|
      entry.placeholder_text = 'URL'
      entry.text = 'https://gnome.org'
    end
  end

  def file_launcher
    @file_launcher ||= Gtk::FileLauncher.new(file).tap { |launcher| launcher.always_ask = true }
  end

  def file_reference = @file_reference ||= reference_link('https://docs.gtk.org/gtk4/class.FileLauncher.html')
  def uri_reference = @uri_reference ||= reference_link('https://docs.gtk.org/gtk4/class.UriLauncher.html')

  private

  def page_box
    Gtk::Box.new(:vertical, 24).tap { |box| box.halign = :center }
  end

  def pill_button(label)
    Gtk::Button.new.tap do |btn|
      btn.label = label
      btn.add_css_class('suggested-action')
      btn.add_css_class('pill')
    end
  end

  def reference_link(uri)
    Gtk::LinkButton.new(uri).tap { |btn| btn.label = 'API Reference' }
  end

  def choose_file
    Gtk::FileDialog.new.open(window, nil) do |dialog, result|
      file_launcher.file = dialog.open_finish(result)
    end
  end

  def launch_uri
    Gtk::UriLauncher.new(uri_details.text).launch(window, nil) {}
  end
end

LauncherDemo.new.build.run
