require 'gtk4'
require 'adwaita'

class FileMonitorDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = overlay

          overlay.tap do |o|
            o.child = status_page

            status_page.tap do |page|
              page.child = content_box

              content_box.tap do |b|
                b.append(file_name)
                b.append(frame)
                b.append(buttons_box)
                b.append(edit_file)
                b.append(reference_button)

                frame.tap do |f|
                  f.child = scrolled_window

                  scrolled_window.tap { |sw| sw.child = edit_entry }
                end

                buttons_box.tap do |box|
                  box.append(view_file)
                  box.append(delete_file)

                  view_file.tap do |btn|
                    btn.signal_connect('clicked') { file_launcher.launch(window, nil) {} }
                  end

                  delete_file.tap do |btn|
                    btn.signal_connect('clicked') { file.delete }
                  end
                end

                edit_file.tap do |btn|
                  btn.signal_connect('clicked') { file.replace_contents(edit_entry.buffer.text, nil, false, :none) }
                end
              end
            end
          end
        end

        file_name.label = file.query_info('standard::display-name', :none).display_name
        edit_entry.buffer.text = 'Start editing ... '

        monitor_for_file.tap do |monitor|
          monitor.signal_connect('changed') do |_, _file, _other, event|
            notify('File modified') if event == Gio::FileMonitorEvent::CHANGES_DONE_HINT
          end
        end

        monitor_for_dir.tap do |monitor|
          monitor.signal_connect('changed') do |_, child, _other, event|
            notify("#{child.basename}: #{event.nick}")
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.filemonitor', :default_flags)
  def overlay = @overlay ||= Adwaita::ToastOverlay.new
  def scrolled_window = @scrolled_window ||= Gtk::ScrolledWindow.new
  def file = @file ||= Gio::File.new_for_path(File.join(__dir__, 'workbench.txt'))
  def monitor_for_file = @monitor_for_file ||= file.monitor(Gio::FileMonitorFlags::NONE)
  def monitor_for_dir = @monitor_for_dir ||= file.parent.monitor(Gio::FileMonitorFlags::WATCH_MOVES)

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'File Monitor'
      win.set_default_size(640, 720)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'File Monitor'
      page.description = 'Monitors a file or directory for changes'
      page.icon_name = 'emblem-documents-symbolic'
    end
  end

  def content_box
    @content_box ||= Gtk::Box.new(:vertical, 18).tap { |box| box.halign = :center }
  end

  def file_name
    @file_name ||= Gtk::Label.new('No File').tap { |label| label.add_css_class('title-4') }
  end

  def frame = @frame ||= Gtk::Frame.new.tap { |f| f.set_size_request(96, 96) }

  def edit_entry
    @edit_entry ||= Gtk::TextView.new.tap do |view|
      view.right_margin = 12
      view.left_margin = 12
      view.top_margin = 12
      view.bottom_margin = 12
      view.wrap_mode = :char
    end
  end

  def buttons_box
    @buttons_box ||= Gtk::Box.new(:horizontal, 0).tap { |box| box.add_css_class('linked') }
  end

  def view_file = @view_file ||= Gtk::Button.new.tap { |btn| btn.label = 'View File' }
  def delete_file = @delete_file ||= Gtk::Button.new.tap { |btn| btn.label = 'Delete File' }

  def edit_file
    @edit_file ||= Gtk::Button.new.tap do |btn|
      btn.label = 'Apply Changes'
      btn.add_css_class('suggested-action')
      btn.add_css_class('pill')
    end
  end

  def file_launcher
    @file_launcher ||= Gtk::FileLauncher.new(file).tap { |launcher| launcher.always_ask = true }
  end

  def reference_button
    @reference_button ||= Gtk::LinkButton.new('https://docs.gtk.org/gio/method.File.monitor.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end

  private

  def notify(title)
    overlay.add_toast(Adwaita::Toast.new(title).tap { |toast| toast.timeout = 2 })
  end
end

FileMonitorDemo.new.build.run
