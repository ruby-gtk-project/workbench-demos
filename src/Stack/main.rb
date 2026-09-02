require 'gtk4'
require 'adwaita'

class StackDemo
  NAVIGATION_WIDGETS = ['Switcher', 'Sidebar'].freeze

  TRANSITIONS = ['None', 'Cross-fade', 'Slide Right', 'Slide Left', 'Slide Up', 'Slide Down',
                 'Slide Left-Right', 'Slide Up-Down', 'Over Up', 'Over Down', 'Over Left', 'Over Right',
                 'Under Up', 'Under Down', 'Under Left', 'Under Right', 'Over Up-Down', 'Over Down-Up',
                 'Over Left-Right', 'Over Right-Left', 'Rotate Left', 'Rotate Right',
                 'Rotate Left-Right'].freeze

  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = root_box

          root_box.tap do |root|
            root.append(stack)

            stack.tap do |s|
              s.add_titled(page1, 'page1', 'Page 1')
              s.add_titled(page2, 'page2', 'Page 2')
              s.add_titled(page3, 'page3', 'Page 3')

              page1.tap do |page|
                page.child = documentation_box

                documentation_box.tap do |box|
                  box.append(documentation_title)
                  box.append(documentation_links)

                  documentation_links.tap do |links|
                    links.append(stack_reference)
                    links.append(sidebar_reference)
                    links.append(switcher_reference)
                  end
                end
              end

              page2.tap do |page|
                page.child = settings_group

                settings_group.tap do |group|
                  group.add(navigation_row)
                  group.add(transition_row)
                  group.add(interpolate_switch)
                  group.add(transition_spin_button)

                  navigation_row.tap do |row|
                    row.signal_connect('notify::selected-item') { swap_navigation_widget }
                  end

                  transition_row.tap do |row|
                    row.signal_connect('notify::selected') { s.transition_type = row.selected }
                  end

                  interpolate_switch.tap do |row|
                    row.bind_property('active', s, 'interpolate-size', GLib::BindingFlags::SYNC_CREATE)
                  end

                  transition_spin_button.tap do |row|
                    row.signal_connect('notify::value') { s.transition_duration = row.value.to_i }
                  end
                end
              end
            end
          end
        end

        root_box.prepend(navigation_widget)

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.stack', :default_flags)
  def stack = @stack ||= Gtk::Stack.new
  def page1 = @page1 ||= main_status_page
  def page2 = @page2 ||= Adwaita::StatusPage.new
  def page3 = @page3 ||= Adwaita::StatusPage.new.tap { |page| page.title = 'Last Page' }
  def documentation_box = @documentation_box ||= Gtk::Box.new(:vertical, 0)
  def settings_group = @settings_group ||= Adwaita::PreferencesGroup.new.tap { |g| g.add_css_class('boxed-list') }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Stack'
      win.set_default_size(820, 720)
    end
  end

  def root_box
    @root_box ||= Gtk::Box.new(:vertical, 0).tap do |box|
      box.halign = :center
      box.valign = :center
    end
  end

  def main_status_page
    Adwaita::StatusPage.new.tap do |page|
      page.title = 'Stack'
      page.description = 'A container which only shows one of its children at a time'
    end
  end

  def documentation_title
    @documentation_title ||= Gtk::Label.new('Documentation').tap do |label|
      label.margin_top = 24
      label.add_css_class('title-2')
    end
  end

  def documentation_links
    @documentation_links ||= Gtk::Box.new(:horizontal, 0).tap do |box|
      box.halign = :center
      box.margin_top = 24
    end
  end

  def stack_reference = @stack_reference ||= link('Stack API Reference', 'Stack')
  def sidebar_reference = @sidebar_reference ||= link('Stack Sidebar API Reference', 'StackSidebar')
  def switcher_reference = @switcher_reference ||= link('Stack Switcher API Reference', 'StackSwitcher')

  def navigation_row = @navigation_row ||= combo_row('Navigation Widget', NAVIGATION_WIDGETS)
  def transition_row = @transition_row ||= combo_row('Transition Type', TRANSITIONS)

  def interpolate_switch
    @interpolate_switch ||= Adwaita::SwitchRow.new.tap { |row| row.title = 'Interpolate Size' }
  end

  def transition_spin_button
    @transition_spin_button ||= Adwaita::SpinRow.new(Gtk::Adjustment.new(200, 100, 1000, 10, 100, 0), 1, 0).tap do |row|
      row.title = 'Transition Duration'
    end
  end

  def navigation_widget = @navigation_widget ||= build_navigation_widget
  def separator = @separator

  private

  def link(label, class_name)
    Gtk::LinkButton.new("https://docs.gtk.org/gtk4/class.#{class_name}.html").tap { |btn| btn.label = label }
  end

  def combo_row(title, strings)
    Adwaita::ComboRow.new.tap do |row|
      row.title = title
      row.model = Gtk::StringList.new(strings)
    end
  end

  def build_navigation_widget
    if navigation_row.selected.zero?
      Gtk::StackSwitcher.new.tap { |switcher| switcher.stack = stack }
    else
      Gtk::StackSidebar.new.tap { |sidebar| sidebar.stack = stack }
    end
  end

  def swap_navigation_widget
    root_box.remove(navigation_widget)
    root_box.remove(separator) if separator
    @separator = nil
    @navigation_widget = build_navigation_widget

    if navigation_row.selected.zero?
      root_box.orientation = :vertical
      root_box.prepend(navigation_widget)
    else
      @separator = Gtk::Separator.new(:vertical)
      root_box.orientation = :horizontal
      root_box.prepend(separator)
      root_box.prepend(navigation_widget)
    end
  end
end

StackDemo.new.build.run
