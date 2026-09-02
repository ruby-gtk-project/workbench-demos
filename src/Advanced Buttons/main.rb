require 'gtk4'
require 'adwaita'

class AdvancedButtonsDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(split_button_section)
              b.append(split_button_reference)
              b.append(button_content_section)
              b.append(button_content_reference)

              split_button_section.tap do |section|
                section.append(split_button_title)
                section.append(split_button_subtitle)
                section.append(split_button_row)

                split_button_row.tap do |row|
                  row.append(menu_model_column)
                  row.append(popover_column)

                  menu_model_column.tap do |column|
                    column.append(run_split_button)
                    column.append(menu_model_label)
                  end

                  popover_column.tap do |column|
                    column.append(open_split_button)
                    column.append(popover_label)
                  end
                end
              end

              button_content_section.tap do |section|
                section.append(button_content_title)
                section.append(button_content_subtitle)
                section.append(button_content_row)

                button_content_row.tap do |row|
                  row.append(edit_column)
                  row.append(new_column)
                  row.append(bluetooth_column)

                  edit_column.tap do |column|
                    column.append(edit_button)
                    column.append(edit_label)

                    edit_button.tap { |btn| btn.child = edit_content }
                  end

                  new_column.tap do |column|
                    column.append(new_menu_button)
                    column.append(new_label)

                    new_menu_button.tap { |btn| btn.child = new_content }
                  end

                  bluetooth_column.tap do |column|
                    column.append(bluetooth_button)
                    column.append(bluetooth_label)

                    bluetooth_button.tap { |btn| btn.child = bluetooth_content }
                  end
                end
              end
            end
          end
        end

        button_popover.tap do |popover|
          popover.child = popover_box

          popover_box.tap do |box|
            box.append(popover_search)
            box.append(popover_status)
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.advancedbuttons', :default_flags)
  def popover_box = @popover_box ||= Gtk::Box.new(:vertical, 0)
  def button_popover = @button_popover ||= Gtk::Popover.new
  def edit_button = @edit_button ||= Gtk::Button.new
  def bluetooth_button = @bluetooth_button ||= Gtk::ToggleButton.new

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Advanced Buttons'
      win.set_default_size(720, 900)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Advanced Buttons'
      page.description = 'Complex buttons with menus and icons'
    end
  end

  def content_box
    @content_box ||= Gtk::Box.new(:vertical, 6).tap { |box| box.halign = :center }
  end

  def split_button_section = @split_button_section ||= section_box
  def button_content_section = @button_content_section ||= section_box

  def split_button_title
    @split_button_title ||= Gtk::Label.new('Split Button').tap { |l| l.add_css_class('title-4') }
  end

  def split_button_subtitle
    @split_button_subtitle ||= Gtk::Label.new('A combined button and dropdown widget')
  end

  def button_content_title
    @button_content_title ||= Gtk::Label.new('Button Content').tap { |l| l.add_css_class('title-4') }
  end

  def button_content_subtitle
    @button_content_subtitle ||= Gtk::Label.new('A helper widget to create buttons with icons and labels')
  end

  def split_button_row = @split_button_row ||= demo_row
  def button_content_row = @button_content_row ||= demo_row

  def menu_model_column = @menu_model_column ||= demo_column
  def popover_column = @popover_column ||= demo_column
  def edit_column = @edit_column ||= demo_column
  def new_column = @new_column ||= demo_column
  def bluetooth_column = @bluetooth_column ||= demo_column

  def menu_model_label = @menu_model_label ||= Gtk::Label.new('Menu Model')
  def popover_label = @popover_label ||= Gtk::Label.new('Popover')
  def edit_label = @edit_label ||= Gtk::Label.new('Button')
  def new_label = @new_label ||= Gtk::Label.new('Menu Button')
  def bluetooth_label = @bluetooth_label ||= Gtk::Label.new('Toggle Button')

  def run_split_button
    @run_split_button ||= Adwaita::SplitButton.new.tap do |btn|
      btn.halign = :center
      btn.icon_name = 'media-playback-start-symbolic'
      btn.menu_model = button_run_menu
    end
  end

  def open_split_button
    @open_split_button ||= Adwaita::SplitButton.new.tap do |btn|
      btn.label = 'Open'
      btn.popover = button_popover
    end
  end

  def new_menu_button
    @new_menu_button ||= Gtk::MenuButton.new.tap { |btn| btn.menu_model = button_new_menu }
  end

  def edit_content = @edit_content ||= button_content('Edit', 'document-edit-symbolic')
  def new_content = @new_content ||= button_content('New', 'list-add-symbolic')
  def bluetooth_content = @bluetooth_content ||= button_content('Bluetooth', 'bluetooth-active-symbolic')

  def popover_search
    @popover_search ||= Gtk::SearchEntry.new.tap { |entry| entry.placeholder_text = 'Search documents' }
  end

  def popover_status
    @popover_status ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'No Recent Documents'
      page.icon_name = 'document-open-recent-symbolic'
      page.set_size_request(300, 300)
      page.add_css_class('compact')
      page.add_css_class('dim-label')
    end
  end

  def split_button_reference
    @split_button_reference ||= reference_link(
      'https://gnome.pages.gitlab.gnome.org/libadwaita/doc/1.6/class.SplitButton.html'
    ).tap { |btn| btn.margin_bottom = 36 }
  end

  def button_content_reference
    @button_content_reference ||= reference_link(
      'https://gnome.pages.gitlab.gnome.org/libadwaita/doc/1.6/class.ButtonContent.html'
    )
  end

  def button_new_menu
    @button_new_menu ||= Gio::Menu.new.tap do |menu|
      ['New File', 'New Folder', 'New Window'].each { |label| menu.append(label, nil) }
    end
  end

  def button_run_menu
    @button_run_menu ||= Gio::Menu.new.tap do |menu|
      menu.append_section(nil, Gio::Menu.new.tap do |section|
        ['Run', 'Run With Leak Detector', 'Run With Debugger'].each { |label| section.append(label, nil) }
      end)

      menu.append_section('Settings', Gio::Menu.new.tap do |settings|
        settings.append_submenu('Accessibility', Gio::Menu.new.tap do |accessibility|
          accessibility.append('High Contrast', nil)

          accessibility.append_section('Text Direction', Gio::Menu.new.tap do |direction|
            direction.append('Left-to-Right', nil)
            direction.append('Right-to-Left', nil)
          end)
        end)
      end)
    end
  end

  private

  def section_box
    Gtk::Box.new(:vertical, 6).tap { |box| box.halign = :center }
  end

  def demo_row
    Gtk::Box.new(:horizontal, 18).tap do |box|
      box.halign = :center
      box.margin_top = 12
      box.homogeneous = true
    end
  end

  def demo_column
    Gtk::Box.new(:vertical, 6).tap do |box|
      box.margin_top = 6
      box.margin_bottom = 6
    end
  end

  def button_content(label, icon_name)
    Adwaita::ButtonContent.new.tap do |content|
      content.label = label
      content.icon_name = icon_name
    end
  end

  def reference_link(uri)
    Gtk::LinkButton.new(uri).tap { |btn| btn.label = 'API Reference' }
  end
end

AdvancedButtonsDemo.new.build.run
