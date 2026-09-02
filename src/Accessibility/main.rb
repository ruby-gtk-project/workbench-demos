require 'gtk4'
require 'adwaita'

class AccessibilityDemo
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
                b.append(directions_group)
                b.append(custom_group)
                b.append(documentation_list)

                directions_group.tap do |group|
                  group.add(orca_row)
                  group.add(next_row)
                  group.add(prev_row)
                  group.add(activate_row)

                  orca_row.tap do |row|
                    row.add_suffix(orca_shortcut)
                    row.update_relation(described_by: [orca_shortcut])
                  end

                  next_row.tap do |row|
                    row.add_suffix(next_shortcut)
                    row.update_relation(described_by: [next_shortcut])
                  end

                  prev_row.tap do |row|
                    row.add_suffix(prev_shortcut)
                    row.update_relation(described_by: [prev_shortcut])
                  end

                  activate_row.tap do |row|
                    row.add_suffix(activate_shortcut)
                    row.update_relation(described_by: [activate_shortcut])
                  end
                end

                custom_group.tap do |group|
                  group.append(group_header)
                  group.append(group_box)

                  group_header.tap do |header|
                    header.append(group_label)
                    header.append(group_description)
                  end

                  group_box.tap do |gb|
                    gb.append(custom_button)
                    gb.append(standard_button)
                    gb.update_relation(labelled_by: [group_label], described_by: [group_description])

                    custom_button.tap do |btn|
                      btn.child = custom_button_label
                      btn.update_relation(labelled_by: [custom_button_label])
                      btn.add_controller(click_gesture)
                      btn.add_controller(key_controller)
                    end
                  end
                end

                documentation_list.tap do |list|
                  list.append(developer_docs_item)
                  list.append(hig_item)

                  developer_docs_item.tap { |item| item.append(developer_docs_link) }
                  hig_item.tap { |item| item.append(hig_link) }
                end
              end
            end
          end
        end

        click_gesture.tap do |gesture|
          gesture.signal_connect('released') { toggle_custom_button }
        end

        key_controller.tap do |controller|
          controller.signal_connect('key-released') do |_, keyval, _code, _state|
            toggle_custom_button if activation_keys.include?(keyval)
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.accessibility', :default_flags)
  def clamp = @clamp ||= Adwaita::Clamp.new.tap { |c| c.maximum_size = 480 }
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0)
  def click_gesture = @click_gesture ||= Gtk::GestureClick.new
  def key_controller = @key_controller ||= Gtk::EventControllerKey.new
  def custom_button_label = @custom_button_label ||= Gtk::Label.new('Custom Button')

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Accessibility'
      win.set_default_size(720, 900)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Accessibility'
      page.description = 'Help people with disabilities to participate in substantial life activities'
    end
  end

  def directions_group
    @directions_group ||= Adwaita::PreferencesGroup.new.tap do |group|
      group.title = 'Directions'
      group.description = 'Instructions for testing this demo'
    end
  end

  def orca_row = @orca_row ||= Adwaita::ActionRow.new.tap { |r| r.title = 'Enable the Screen Reader' }
  def next_row = @next_row ||= Adwaita::ActionRow.new.tap { |r| r.title = 'Move to Next Element' }
  def prev_row = @prev_row ||= Adwaita::ActionRow.new.tap { |r| r.title = 'Move to Previous Element' }
  def activate_row = @activate_row ||= Adwaita::ActionRow.new.tap { |r| r.title = 'Activate Current Element' }

  def orca_shortcut = @orca_shortcut ||= shortcut_label('<Super><Alt>s')
  def next_shortcut = @next_shortcut ||= shortcut_label('Tab')
  def prev_shortcut = @prev_shortcut ||= shortcut_label('<Shift>Tab')

  def activate_shortcut
    @activate_shortcut ||= shortcut_label('space').tap do |label|
      label.update_property(description: 'Spacebar')
    end
  end

  def custom_group
    @custom_group ||= Gtk::Box.new(:vertical, 18).tap do |box|
      box.margin_top = 18
    end
  end

  def group_header
    @group_header ||= Gtk::Box.new(:vertical, 6).tap do |box|
      box.accessible_role = :group
    end
  end

  def group_label
    @group_label ||= Gtk::Label.new('Related Elements').tap do |label|
      label.xalign = 0.0
      label.add_css_class('heading')
    end
  end

  def group_description
    @group_description ||= Gtk::Label.new('This is a group of related elements').tap do |label|
      label.xalign = 0.0
      label.add_css_class('dim-label')
    end
  end

  def group_box
    @group_box ||= Gtk::Box.new(:vertical, 18).tap do |box|
      box.accessible_role = :group
      box.add_css_class('card')
    end
  end

  def custom_button
    @custom_button ||= Adwaita::Bin.new.tap do |bin|
      bin.css_name = 'button'
      bin.focusable = true
      bin.focus_on_click = true
      bin.halign = :center
      bin.margin_top = 18
      bin.accessible_role = :toggle_button
      bin.add_css_class('toggle')
      bin.add_css_class('pill')
    end
  end

  def standard_button
    @standard_button ||= Gtk::ToggleButton.new.tap do |btn|
      btn.label = 'Standard Button'
      btn.halign = :center
      btn.margin_bottom = 18
      btn.add_css_class('pill')
    end
  end

  def documentation_list
    @documentation_list ||= Gtk::Box.new(:vertical, 0).tap do |box|
      box.halign = :center
      box.accessible_role = :list
      box.update_property(label: 'Documentation', description: 'Links to accessibility documentation')
    end
  end

  def developer_docs_item = @developer_docs_item ||= list_item_box
  def hig_item = @hig_item ||= list_item_box

  def developer_docs_link
    @developer_docs_link ||=
      Gtk::LinkButton.new('https://developer.gnome.org/documentation/guidelines/accessibility.html').tap do |btn|
        btn.label = 'GNOME Developer Documentation'
      end
  end

  def hig_link
    @hig_link ||= Gtk::LinkButton.new('https://developer.gnome.org/hig/guidelines/accessibility.html').tap do |btn|
      btn.label = 'GNOME Human Interface Guidelines'
    end
  end

  def activation_keys
    @activation_keys ||= [Gdk::Keyval::KEY_space, Gdk::Keyval::KEY_KP_Space, Gdk::Keyval::KEY_Return,
                          Gdk::Keyval::KEY_ISO_Enter, Gdk::Keyval::KEY_KP_Enter]
  end

  private

  def shortcut_label(accelerator)
    Gtk::ShortcutLabel.new(accelerator).tap { |label| label.valign = :center }
  end

  def list_item_box
    Gtk::Box.new(:horizontal, 0).tap { |box| box.accessible_role = :list_item }
  end

  def toggle_custom_button
    custom_button.state_flags.checked?.then do |checked|
      custom_button.update_state(pressed: !checked)

      if checked
        custom_button.unset_state_flags(Gtk::StateFlags::CHECKED)
      else
        custom_button.set_state_flags(Gtk::StateFlags::CHECKED, false)
      end

      custom_button.grab_focus
    end
  end
end

AccessibilityDemo.new.build.run
