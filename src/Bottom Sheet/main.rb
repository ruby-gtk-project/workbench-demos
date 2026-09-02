require 'gtk4'
require 'adwaita'

class BottomSheetDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = bottom_sheet

          bottom_sheet.tap do |sheet|
            sheet.bottom_bar = bottom_bar
            sheet.content = content_page
            sheet.sheet = sheet_page

            sheet.bind_property('full-width', full_width_row, 'active', GLib::BindingFlags::BIDIRECTIONAL | GLib::BindingFlags::SYNC_CREATE)
            sheet.bind_property('can-open', can_open_row, 'active', GLib::BindingFlags::BIDIRECTIONAL | GLib::BindingFlags::SYNC_CREATE)
            sheet.bind_property('open', open_row, 'active', GLib::BindingFlags::BIDIRECTIONAL | GLib::BindingFlags::SYNC_CREATE)
            sheet.bind_property('can-close', can_close_row, 'active', GLib::BindingFlags::BIDIRECTIONAL | GLib::BindingFlags::SYNC_CREATE)
            sheet.bind_property('show-drag-handle', drag_handle_row, 'active', GLib::BindingFlags::BIDIRECTIONAL | GLib::BindingFlags::SYNC_CREATE)
            sheet.bind_property('modal', modal_row, 'active', GLib::BindingFlags::BIDIRECTIONAL | GLib::BindingFlags::SYNC_CREATE)

            content_page.tap do |page|
              page.child = content_box

              content_box.tap do |box|
                box.append(content_clamp)
                box.append(reference_button)

                content_clamp.tap do |clamp|
                  clamp.child = content_group

                  content_group.tap do |group|
                    group.add(full_width_row)
                    group.add(can_open_row)
                    group.add(open_row)
                  end
                end
              end
            end

            sheet_page.tap do |page|
              page.child = sheet_clamp

              sheet_clamp.tap do |clamp|
                clamp.child = sheet_group

                sheet_group.tap do |group|
                  group.add(can_close_row)
                  group.add(drag_handle_row)
                  group.add(modal_row)
                end
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.bottomsheet', :default_flags)
  def bottom_sheet = @bottom_sheet ||= Adwaita::BottomSheet.new
  def content_clamp = @content_clamp ||= Adwaita::Clamp.new
  def sheet_clamp = @sheet_clamp ||= Adwaita::Clamp.new
  def content_group = @content_group ||= Adwaita::PreferencesGroup.new
  def sheet_group = @sheet_group ||= Adwaita::PreferencesGroup.new

  def full_width_row = @full_width_row ||= switch_row('Full Width')
  def can_open_row = @can_open_row ||= switch_row('Can Open')
  def open_row = @open_row ||= switch_row('Open')
  def can_close_row = @can_close_row ||= switch_row('Can Close')
  def drag_handle_row = @drag_handle_row ||= switch_row('Show Drag Handle')
  def modal_row = @modal_row ||= switch_row('Modal')

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Bottom Sheet'
      win.set_default_size(640, 640)
    end
  end

  def bottom_bar
    @bottom_bar ||= Gtk::Label.new('Bottom Bar').tap do |label|
      label.margin_top = 12
      label.margin_bottom = 12
      label.margin_start = 12
      label.margin_end = 12
    end
  end

  def content_page
    @content_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Bottom Sheet'
      page.description = 'Display content with a bottom sheet'
    end
  end

  def sheet_page
    @sheet_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Sheet'
      page.width_request = 360
    end
  end

  def content_box
    @content_box ||= Gtk::Box.new(:vertical, 12).tap { |box| box.halign = :center }
  end

  def reference_button
    @reference_button ||= Gtk::LinkButton.new(
      'https://gnome.pages.gitlab.gnome.org/libadwaita/doc/main/class.BottomSheet.html'
    ).tap { |btn| btn.label = 'API Reference' }
  end

  private

  def switch_row(title)
    Adwaita::SwitchRow.new.tap { |row| row.title = title }
  end
end

BottomSheetDemo.new.build.run
