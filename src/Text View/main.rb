require 'gtk4'
require 'adwaita'

LOREM = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut ' \
        'labore et dolore magna aliqua. Vel elit scelerisque mauris pellentesque pulvinar. Molestie nunc ' \
        'non blandit massa enim nec dui nunc. Turpis in eu mi bibendum neque egestas congue quisque. Sed ' \
        'velit dignissim sodales ut. Massa tempor nec feugiat nisl pretium fusce id velit. Vitae congue ' \
        'eu consequat ac felis donec et. Ultrices sagittis orci a scelerisque purus semper eget duis at.'

class TextViewDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(frame)
              b.append(clipboard_buttons)
              b.append(selection_buttons)
              b.append(reference_button)

              frame.tap do |f|
                f.child = scrolled_window

                scrolled_window.tap { |sw| sw.child = textview }
              end

              clipboard_buttons.tap do |box|
                box.append(copy)
                box.append(paste)
                box.append(cut)

                copy.tap { |btn| btn.signal_connect('clicked') { handle_copy } }
                paste.tap { |btn| btn.signal_connect('clicked') { handle_paste } }
                cut.tap { |btn| btn.signal_connect('clicked') { handle_cut } }
              end

              selection_buttons.tap do |box|
                box.append(select)
                box.append(clear)

                select.tap do |btn|
                  btn.signal_connect('clicked') { buffer.select_range(buffer.start_iter, buffer.end_iter) }
                end

                clear.tap do |btn|
                  btn.signal_connect('clicked') { buffer.delete(buffer.start_iter, buffer.end_iter) }
                end
              end

              textview.tap do |view|
                view.signal_connect('copy-clipboard') { puts 'Text copied to clipboard' }
                view.signal_connect('cut-clipboard') { puts 'Text cut to clipboard' }
                view.signal_connect('paste-clipboard') { puts 'Text pasted' }
              end
            end
          end
        end

        buffer.text = LOREM

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.textview', :default_flags)
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0).tap { |box| box.halign = :center }
  def frame = @frame ||= Gtk::Frame.new.tap { |f| f.margin_bottom = 12 }
  def buffer = @buffer ||= textview.buffer
  def clipboard = @clipboard ||= Gdk::Display.default.clipboard

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Text View'
      win.set_default_size(760, 720)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Text View'
      page.description = 'A widget that enables text-editing'
    end
  end

  def scrolled_window
    @scrolled_window ||= Gtk::ScrolledWindow.new.tap { |sw| sw.set_size_request(600, 180) }
  end

  def textview
    @textview ||= Gtk::TextView.new.tap do |view|
      view.bottom_margin = 12
      view.left_margin = 12
      view.right_margin = 12
      view.top_margin = 12
      view.editable = true
      view.cursor_visible = true
      view.wrap_mode = :char
    end
  end

  def clipboard_buttons
    @clipboard_buttons ||= Gtk::Box.new(:horizontal, 18).tap do |box|
      box.margin_top = 12
      box.margin_bottom = 12
      box.halign = :center
    end
  end

  def selection_buttons
    @selection_buttons ||= Gtk::Box.new(:horizontal, 18).tap do |box|
      box.halign = :center
      box.margin_bottom = 18
    end
  end

  def copy = @copy ||= Gtk::Button.new.tap { |btn| btn.label = 'Copy' }
  def paste = @paste ||= Gtk::Button.new.tap { |btn| btn.label = 'Paste' }
  def cut = @cut ||= Gtk::Button.new.tap { |btn| btn.label = 'Cut' }

  def select
    @select ||= Gtk::Button.new.tap do |btn|
      btn.halign = :center
      btn.label = 'Select All'
    end
  end

  def clear
    @clear ||= Gtk::Button.new.tap do |btn|
      btn.halign = :center
      btn.label = 'Clear All'
    end
  end

  def reference_button
    @reference_button ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.TextView.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end

  private

  def handle_copy
    if buffer.has_selection?
      buffer.copy_clipboard(clipboard)
    else
      puts 'No text selected to copy'
    end
  end

  def handle_paste
    buffer.paste_clipboard(clipboard, nil, true)
  end

  def handle_cut
    if buffer.has_selection?
      buffer.cut_clipboard(clipboard, true)
    else
      puts 'No text selected to cut'
    end
  end
end

TextViewDemo.new.build.run
