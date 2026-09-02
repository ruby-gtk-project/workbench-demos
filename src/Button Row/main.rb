require 'gtk4'
require 'adwaita'

class ButtonRowDemo
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
                b.append(separate_list)
                b.append(attached_list)
                b.append(reference_button)

                separate_list.tap do |list|
                  list.append(start_icon_row)
                  list.append(end_icon_row)
                  list.append(button_row_suggested)
                  list.append(button_row_destructive)
                  list.append(disabled_row)

                  button_row_suggested.tap do |row|
                    row.signal_connect('activated') { puts 'Suggested button row activated' }
                  end

                  button_row_destructive.tap do |row|
                    row.signal_connect('activated') { puts 'Destructive button row activated' }
                  end
                end

                attached_list.tap do |list|
                  list.append(plain_row)
                  list.append(attached_row)
                end
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.buttonrow', :default_flags)
  def clamp = @clamp ||= Adwaita::Clamp.new.tap { |c| c.maximum_size = 500 }
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0)
  def plain_row = @plain_row ||= Adwaita::ActionRow.new.tap { |row| row.title = 'Row' }
  def attached_row = @attached_row ||= Adwaita::ButtonRow.new.tap { |row| row.title = 'Attached' }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Button Row'
      win.set_default_size(640, 760)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Button Row'
      page.description = 'Use buttons in boxed lists'
    end
  end

  def separate_list = @separate_list ||= list_box('boxed-list-separate')
  def attached_list = @attached_list ||= list_box('boxed-list')

  def start_icon_row
    @start_icon_row ||= Adwaita::ButtonRow.new.tap do |row|
      row.title = 'Start Icon'
      row.start_icon_name = 'list-add-symbolic'
    end
  end

  def end_icon_row
    @end_icon_row ||= Adwaita::ButtonRow.new.tap do |row|
      row.title = 'End Icon'
      row.end_icon_name = 'go-next-symbolic'
    end
  end

  def button_row_suggested
    @button_row_suggested ||= Adwaita::ButtonRow.new.tap do |row|
      row.title = 'Suggested'
      row.add_css_class('suggested-action')
    end
  end

  def button_row_destructive
    @button_row_destructive ||= Adwaita::ButtonRow.new.tap do |row|
      row.title = 'Destructive'
      row.add_css_class('destructive-action')
    end
  end

  def disabled_row
    @disabled_row ||= Adwaita::ButtonRow.new.tap do |row|
      row.title = 'Disabled'
      row.sensitive = false
    end
  end

  def reference_button
    @reference_button ||= Gtk::LinkButton.new(
      'https://gnome.pages.gitlab.gnome.org/libadwaita/doc/main/class.ButtonRow'
    ).tap do |btn|
      btn.label = 'API Reference'
      btn.margin_top = 24
    end
  end

  private

  def list_box(style)
    Gtk::ListBox.new.tap do |list|
      list.selection_mode = :none
      list.add_css_class(style)
    end
  end
end

ButtonRowDemo.new.build.run
