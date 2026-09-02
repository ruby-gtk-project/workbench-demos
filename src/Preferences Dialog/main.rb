require 'gtk4'
require 'adwaita'

class PreferencesDialogDemo
  REFERENCES = {
    'PreferencesDialog' => 'class.PreferencesDialog.html',
    'PreferencesPage' => 'class.PreferencesPage.html',
    'PreferencesGroup' => 'class.PreferencesGroup.html',
    'PreferencesRow' => 'class.PreferencesRow.html'
  }.freeze

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
              b.append(links_flow_box)

              button.tap do |btn|
                btn.signal_connect('clicked') { dialog.present(window) }
              end

              links_flow_box.tap do |box|
                reference_links.each { |link| box.append(link) }
              end
            end
          end
        end

        dialog.tap do |d|
          d.add(appearance_page)
          d.add(behavior_page)

          appearance_page.tap do |page|
            page.add(color_group)
            page.add(text_group)

            color_group.tap { |group| group.add(dm_switch) }

            text_group.tap do |group|
              group.add(font_size_row)
              group.add(font_color_row)

              font_color_row.tap { |row| row.add_suffix(font_color_button) }
            end
          end

          behavior_page.tap do |page|
            page.add(interaction_group)
            page.add(data_group)

            interaction_group.tap do |group|
              group.header_suffix = interaction_settings_button
              group.add(startup_switch)
              group.add(toast_row)

              toast_row.tap do |row|
                row.add_suffix(toast_button)
                row.activatable_widget = toast_button
              end
            end

            data_group.tap do |group|
              group.add(debug_switch)
              group.add(updates_switch)
              group.add(subpage_row)

              subpage_row.tap do |row|
                row.add_suffix(subpage_arrow)
                row.signal_connect('activated') { d.push_subpage(subpage) }
              end
            end
          end
        end

        subpage.tap do |page|
          page.child = subpage_status

          subpage_status.tap do |status|
            status.child = subpage_button

            subpage_button.tap do |btn|
              btn.signal_connect('clicked') { dialog.pop_subpage }
            end
          end
        end

        toast_button.tap do |btn|
          btn.signal_connect('clicked') do
            dialog.add_toast(Adwaita::Toast.new('Preferences dialogs can display toasts'))
          end
        end

        dm_switch.tap do |row|
          row.active = style_manager.dark?
          row.signal_connect('notify::active') do
            style_manager.color_scheme =
              row.active? ? Adwaita::ColorScheme::FORCE_DARK : Adwaita::ColorScheme::FORCE_LIGHT
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.preferencesdialog', :default_flags)
  def style_manager = @style_manager ||= Adwaita::StyleManager.default

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Preferences Dialog'
      win.set_default_size(640, 520)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Preferences Dialog'
      page.description = 'A dialog showing application’s preferences'
    end
  end

  def content_box
    @content_box ||= Gtk::Box.new(:vertical, 12).tap { |box| box.halign = :center }
  end

  def button
    @button ||= Gtk::Button.new.tap do |btn|
      btn.label = 'Open'
      btn.add_css_class('suggested-action')
      btn.add_css_class('pill')
    end
  end

  def links_flow_box
    @links_flow_box ||= Gtk::FlowBox.new.tap do |box|
      box.orientation = :horizontal
      box.margin_top = 12
      box.max_children_per_line = 2
      box.min_children_per_line = 2
    end
  end

  def reference_links
    @reference_links ||= REFERENCES.map do |label, page|
      Gtk::LinkButton.new(
        "https://gnome.pages.gitlab.gnome.org/libadwaita/doc/1.6/#{page}"
      ).tap { |btn| btn.label = label }
    end
  end

  def dialog
    @dialog ||= Adwaita::PreferencesDialog.new.tap do |d|
      d.content_width = 800
      d.content_height = 600
      d.title = 'Preferences'
    end
  end

  def appearance_page
    @appearance_page ||= Adwaita::PreferencesPage.new.tap do |page|
      page.title = 'Appearance'
      page.icon_name = 'brush-monitor-symbolic'
    end
  end

  def behavior_page
    @behavior_page ||= Adwaita::PreferencesPage.new.tap do |page|
      page.title = 'Behavior'
      page.icon_name = 'settings-symbolic'
    end
  end

  def color_group
    @color_group ||= preferences_group('Color Settings', 'Change the color-scheme of the application')
  end

  def text_group
    @text_group ||= preferences_group('Text Settings', 'Customize the appearance of text in the application')
  end

  def interaction_group
    @interaction_group ||= preferences_group('Interaction Settings',
                                             'Change how the app behaves during user interaction')
  end

  def data_group
    @data_group ||= preferences_group('Data Settings', 'Manage user data related settings')
  end

  def dm_switch = @dm_switch ||= Adwaita::SwitchRow.new.tap { |row| row.title = 'Use Dark Mode' }
  def startup_switch = @startup_switch ||= Adwaita::SwitchRow.new.tap { |row| row.title = 'Run on Startup' }
  def debug_switch = @debug_switch ||= Adwaita::SwitchRow.new.tap { |row| row.title = 'Enable Debug' }
  def updates_switch = @updates_switch ||= Adwaita::SwitchRow.new.tap { |row| row.title = 'Check for updates' }

  def font_size_row
    @font_size_row ||= Adwaita::SpinRow.new(Gtk::Adjustment.new(11, 5, 20, 1, 5, 0), 1, 0).tap do |row|
      row.title = 'Font Size'
    end
  end

  def font_color_row = @font_color_row ||= Adwaita::ActionRow.new.tap { |row| row.title = 'Font Color' }

  def font_color_button
    @font_color_button ||= Gtk::ColorDialogButton.new(Gtk::ColorDialog.new).tap do |btn|
      btn.halign = :center
      btn.valign = :center
    end
  end

  # Adwaita::PreferencesGroup can carry suffix widgets, like Adwaita::ActionRow.
  def interaction_settings_button
    @interaction_settings_button ||= Gtk::Button.new.tap do |btn|
      btn.halign = :center
      btn.valign = :center
      btn.icon_name = 'settings-symbolic'
    end
  end

  def toast_row = @toast_row ||= Adwaita::ActionRow.new.tap { |row| row.title = 'Show Toast' }

  def toast_button
    @toast_button ||= Gtk::Button.new.tap do |btn|
      btn.halign = :center
      btn.valign = :center
      btn.label = 'show toast'
      btn.icon_name = 'bread-symbolic'
    end
  end

  def subpage_row
    @subpage_row ||= Adwaita::ActionRow.new.tap do |row|
      row.title = 'Additional Preferences'
      row.activatable = true
    end
  end

  def subpage_arrow
    @subpage_arrow ||= Gtk::Image.new.tap do |image|
      image.icon_name = 'go-next-symbolic'
      image.add_css_class('dim-label')
    end
  end

  def subpage = @subpage ||= Adwaita::NavigationPage.new(subpage_status, 'Additional Preferences')

  def subpage_status
    @subpage_status ||= Adwaita::StatusPage.new.tap { |page| page.description = 'Custom Subpage' }
  end

  def subpage_button
    @subpage_button ||= Gtk::Button.new.tap do |btn|
      btn.label = 'Go back'
      btn.halign = :center
      btn.valign = :center
      btn.add_css_class('suggested-action')
      btn.add_css_class('pill')
    end
  end

  private

  def preferences_group(title, description)
    Adwaita::PreferencesGroup.new.tap do |group|
      group.title = title
      group.description = description
    end
  end
end

PreferencesDialogDemo.new.build.run
